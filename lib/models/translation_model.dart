class TranslationModel {
  final String filipino;
  final String hiligaynon;
  final String category;

  TranslationModel({
    required this.filipino,
    required this.hiligaynon,
    required this.category,
  });

  factory TranslationModel.fromFirestore(Map<String, dynamic> data) {
    return TranslationModel(
      filipino: data['filipino'],
      hiligaynon: data['hiligaynon'],
      category: data['category'],
    );
  }
}
