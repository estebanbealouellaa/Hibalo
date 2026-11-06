class NLPService {
  // Convert to lowercase, trim, and collapse extra spaces
  String normalize(String text) {
    return text.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Split sentence into words

  // Remove punctuation
  String removePunctuation(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]'), '');
  }

  // Clean text before translation
  String preprocess(String text) {
    return normalize(removePunctuation(text));
  }

  // Fuzzy match score between two strings (0.0 - 1.0)
}
