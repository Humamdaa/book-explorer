class Book {
  final String id;
  final String title;
  final List<String> authors;

  bool favorite;

  final String? publisher;
  final String? publishedDate;
  final String? description;
  final String? industryIdentifiers;
  final int? pageCount;
  final String? language;
  final String? imageLinks;
  final String? previewLink;
  final String? infoLink;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    this.favorite = false,
    this.publisher,
    this.publishedDate,
    this.description,
    this.industryIdentifiers,
    this.pageCount,
    this.language,
    this.imageLinks,
    this.previewLink,
    this.infoLink,
  });

  bool get isFavorite => favorite;

  set isFavorite(bool value) {
    favorite = value;
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    final coverId = json['cover_i'];

    String? imageUrl;

    if (coverId != null) {
      imageUrl = 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
    }

    final authorsJson = json['author_name'];

    List<String> authors = [];

    if (authorsJson is List) {
      authors = authorsJson.map((author) => author.toString()).toList();
    }

    final key = json['key']?.toString() ?? '';

    return Book(
      id: key.isNotEmpty
          ? key.replaceAll('/works/', '')
          : (json['cover_edition_key']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString()),

      title: json['title']?.toString() ?? 'Unknown title',

      authors: authors,

      publisher:
          json['publisher'] is List && (json['publisher'] as List).isNotEmpty
          ? (json['publisher'] as List).first.toString()
          : null,

      publishedDate: json['first_publish_year']?.toString(),

      description: json['first_sentence']?.toString(),

      pageCount: json['number_of_pages_median'] is int
          ? json['number_of_pages_median'] as int
          : null,

      language:
          json['language'] is List && (json['language'] as List).isNotEmpty
          ? (json['language'] as List).first.toString()
          : null,

      imageLinks: imageUrl,

      previewLink: key.isNotEmpty ? 'https://openlibrary.org$key' : null,

      infoLink: key.isNotEmpty ? 'https://openlibrary.org$key' : null,
    );
  }

  factory Book.fromJsonDatabase(Map<String, dynamic> json) {
    return Book(
      id: json['id']?.toString() ?? '',

      title: json['title']?.toString() ?? '',

      authors: json['authors'] != null && json['authors'].toString().isNotEmpty
          ? json['authors'].toString().split(',').map((e) => e.trim()).toList()
          : [],

      favorite: json['favorite'] == 1,

      publisher: json['publisher']?.toString(),

      publishedDate: json['publishedDate']?.toString(),

      description: json['description']?.toString(),

      industryIdentifiers: json['industryIdentifiers']?.toString(),

      pageCount: json['pageCount'] is int
          ? json['pageCount'] as int
          : int.tryParse(json['pageCount']?.toString() ?? ''),

      language: json['language']?.toString(),

      imageLinks: json['imageLinks']?.toString(),

      previewLink: json['previewLink']?.toString(),

      infoLink: json['infoLink']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors.join(', '),
      'favorite': favorite ? 1 : 0,
      'publisher': publisher,
      'publishedDate': publishedDate,
      'description': description,
      'industryIdentifiers': industryIdentifiers,
      'pageCount': pageCount,
      'language': language,
      'imageLinks': imageLinks,
      'previewLink': previewLink,
      'infoLink': infoLink,
    };
  }
}
