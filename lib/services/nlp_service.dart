class NLPService {
  String normalize(String text) {
    return text.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String removePunctuation(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]'), '');
  }

  String preprocess(String text) {
    return normalize(removePunctuation(text));
  }

}
