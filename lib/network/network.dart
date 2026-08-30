import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:reader_tracker/models/book.dart';

class Network {
  static const String _baseUrl =
      'https://openlibrary.org/search.json';

  static const int booksPerPage = 10;

  // ============================================================
  // Get books
  //
  // If query is empty:
  // returns general books.
  //
  // If query has text:
  // searches books.
  // ============================================================

  Future<List<Book>> getBooks({
    String query = '',
    int page = 1,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'q': query.trim().isEmpty ? 'book' : query.trim(),
          'page': page.toString(),
          'limit': booksPerPage.toString(),
        },
      );

      print('Open Library URL: $uri');

      final response = await http.get(uri);

      print('Status Code: ${response.statusCode}');
      print('Response length: ${response.body.length}');

      if (response.statusCode != 200) {
        throw Exception(
          'Open Library API error: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid API response');
      }

      final docs = data['docs'];

      if (docs == null || docs is! List) {
        return [];
      }

      final books = docs
          .whereType<Map<String, dynamic>>()
          .map((book) {
            try {
              return Book.fromJson(book);
            } catch (e) {
              print('Error parsing book: $e');
              return null;
            }
          })
          .whereType<Book>()
          .toList();

      return books;
    } catch (e) {
      print('Network error: $e');
      rethrow;
    }
  }

  // ============================================================
  // Search books
  // ============================================================

  Future<List<Book>> searchBooks(
    String query, {
    int page = 1,
  }) async {
    return getBooks(
      query: query,
      page: page,
    );
  }

  // ============================================================
  // First page
  // ============================================================

  Future<List<Book>> getFirstBooks() async {
    return getBooks(
      page: 1,
    );
  }
}