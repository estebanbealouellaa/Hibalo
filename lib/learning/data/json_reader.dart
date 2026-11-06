/// Reads lessons.json; every error names its place in the JSON (e.g. "b02 > parts[3] > options").
class JsonReader {
  JsonReader(this.map, this.path);

  final Map<String, dynamic> map;

  final String path;

  Never fail(String message) => throw FormatException('$path: $message');

  bool has(String key) => map[key] != null;

  dynamic _get(String key) {
    if (!map.containsKey(key)) fail('missing "$key"');
    return map[key];
  }

  String str(String key) {
    final v = _get(key);
    if (v is! String) fail('"$key" should be text');
    return v;
  }

  String? strOrNull(String key) {
    final v = map[key];
    if (v == null) return null;
    if (v is! String) fail('"$key" should be text or null');
    return v;
  }

  int integer(String key) {
    final v = _get(key);
    if (v is! int) fail('"$key" should be a whole number');
    return v;
  }

  double number(String key) {
    final v = _get(key);
    if (v is! num) fail('"$key" should be a number');
    return v.toDouble();
  }

  bool boolean(String key, {bool? fallback}) {
    final v = map[key];
    if (v == null && fallback != null) return fallback;
    if (v is! bool) fail('"$key" should be true or false');
    return v;
  }

  List<dynamic> list(String key) {
    final v = _get(key);
    if (v is! List) fail('"$key" should be a list');
    return v;
  }

  List<String> strings(String key) {
    final items = list(key);
    for (var i = 0; i < items.length; i++) {
      if (items[i] is! String) fail('"$key"[$i] should be text');
    }
    return items.cast<String>();
  }

  List<String> stringsOrEmpty(String key) =>
      map[key] == null ? const [] : strings(key);

  List<int> ints(String key) {
    final items = list(key);
    for (var i = 0; i < items.length; i++) {
      if (items[i] is! int) fail('"$key"[$i] should be a whole number');
    }
    return items.cast<int>();
  }

  JsonReader object(String key) {
    final v = _get(key);
    if (v is! Map<String, dynamic>) fail('"$key" should be an object');
    return JsonReader(v, '$path > $key');
  }

  JsonReader? objectOrNull(String key) =>
      map[key] == null ? null : object(key);

  List<JsonReader> objects(String key) {
    final items = list(key);
    return [
      for (var i = 0; i < items.length; i++)
        if (items[i] is Map<String, dynamic>)
          JsonReader(items[i] as Map<String, dynamic>, '$path > $key[$i]')
        else
          fail('"$key"[$i] should be an object'),
    ];
  }

  List<JsonReader> objectsOrEmpty(String key) =>
      map[key] == null ? const [] : objects(key);
}

/// One picture or audio path from the JSON, and what it became in the app.
class AssetRef {
  const AssetRef(this.where, this.jsonPath, this.assetPath, {required this.found});

  /// Where it was found, for example "b02 > items[0] > audio".
  final String where;

  /// The path as written in the JSON (without "assets/").
  final String jsonPath;

  /// What the model holds: the asset path, or null for a missing picture.
  /// Audio keeps its path even when the clip is missing (see resolveAudio).
  final String? assetPath;

  final bool found;
}

/// Adds "assets/" to JSON paths; a missing picture becomes null (firefly_reading is shown).
class AssetResolver {
  AssetResolver(this.available);

  final Set<String> available;

  final List<AssetRef> refs = [];

  String? resolve(String? jsonPath, String where) {
    if (jsonPath == null || jsonPath.isEmpty) return null;
    final full = 'assets/$jsonPath';
    final found = available.contains(full);
    refs.add(AssetRef(where, jsonPath, found ? full : null, found: found));
    return found ? full : null;
  }

  /// Audio keeps its path even before the clip exists: the button shows and plays nothing until it is recorded.
  String? resolveAudio(String? jsonPath, String where) {
    if (jsonPath == null || jsonPath.isEmpty) return null;
    final full = 'assets/$jsonPath';
    refs.add(AssetRef(where, jsonPath, full, found: available.contains(full)));
    return full;
  }
}
