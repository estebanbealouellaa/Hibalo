/// Small helpers for reading lessons.json safely. Every error names where in
/// the JSON it happened (for example "b02 > parts[3] > options"), so a typo in
/// the file is easy to find.
class JsonReader {
  JsonReader(this.map, this.path);

  final Map<String, dynamic> map;

  /// Where this object sits in the file, for error messages.
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

  /// An optional list of text: missing or null gives an empty list.
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

  /// An optional list of objects: missing or null gives an empty list.
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

  /// The file is bundled with the app.
  final bool found;
}

/// Turns JSON paths into bundled asset paths. The JSON leaves out "assets/",
/// so it is added here. A picture that isn't in the AssetManifest becomes
/// null, and the screens show firefly_reading. Audio keeps its path either
/// way (see [resolveAudio]). Every lookup is recorded in [refs].
class AssetResolver {
  AssetResolver(this.available);

  /// Every asset bundled with the app (from the AssetManifest).
  final Set<String> available;

  final List<AssetRef> refs = [];

  String? resolve(String? jsonPath, String where) {
    if (jsonPath == null || jsonPath.isEmpty) return null;
    final full = 'assets/$jsonPath';
    final found = available.contains(full);
    refs.add(AssetRef(where, jsonPath, found ? full : null, found: found));
    return found ? full : null;
  }

  /// Audio clips keep their path even when the file isn't in the app yet:
  /// the audio buttons always show, and a missing clip simply plays nothing
  /// (§1.4). When the recordings are added, the same buttons play them.
  String? resolveAudio(String? jsonPath, String where) {
    if (jsonPath == null || jsonPath.isEmpty) return null;
    final full = 'assets/$jsonPath';
    refs.add(AssetRef(where, jsonPath, full, found: available.contains(full)));
    return full;
  }
}
