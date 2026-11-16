class Series {
  final int id;
  final String name;
  final List<String> genres;
  final double rating;
  final String image;
  final String originalImage;
  final String summary;

  Series({
    required this.id,
    required this.name,
    required this.genres,
    required this.rating,
    required this.image,
    required this.originalImage,
    required this.summary,
  });

  static String cleanHtml(String? html) {
    if (html == null || html.isEmpty) return 'Tidak ada deskripsi.';
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  factory Series.fromJson(Map<String, dynamic> json) {
    double parsedRating = 0.0;
    if (json['rating'] != null && json['rating']['average'] != null) {
      parsedRating = (json['rating']['average'] as num).toDouble();
    }

    String mediumImg = '';
    String origImg = '';
    if (json['image'] != null) {
      mediumImg = json['image']['medium'] ?? '';
      origImg = json['image']['original'] ?? mediumImg;
    }

    List<String> parsedGenres = [];
    if (json['genres'] != null) {
      parsedGenres = List<String>.from(json['genres']);
    }

    return Series(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tanpa Judul',
      genres: parsedGenres,
      rating: parsedRating,
      image: mediumImg,
      originalImage: origImg.isNotEmpty ? origImg : mediumImg,
      summary: cleanHtml(json['summary']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'genres': genres,
      'rating': rating,
      'image': image,
      'originalImage': originalImage,
      'summary': summary,
    };
  }

  factory Series.fromMap(Map<dynamic, dynamic> map) {
    return Series(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      genres: List<String>.from(map['genres'] ?? []),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      image: map['image'] ?? '',
      originalImage: map['originalImage'] ?? map['image'] ?? '',
      summary: map['summary'] ?? '',
    );
  }
}
