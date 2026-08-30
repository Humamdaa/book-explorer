import 'package:flutter/material.dart';
import 'package:reader_tracker/db/database_helper.dart';
import 'package:reader_tracker/models/book.dart';
import 'package:reader_tracker/utils/book_details_arguments.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() =>
      _SavedScreenState();
}

class _SavedScreenState
    extends State<SavedScreen> {
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();

    _loadBooks();

    // Listen to any database changes.
    DatabaseHelper.instance.changes.addListener(
      _onDatabaseChanged,
    );
  }

  // ============================================================
  // Database changed
  // ============================================================

  void _onDatabaseChanged() {
    if (!mounted) return;

    _refresh();
  }

  @override
  void dispose() {
    DatabaseHelper.instance.changes.removeListener(
      _onDatabaseChanged,
    );

    super.dispose();
  }

  // ============================================================
  // Load books
  // ============================================================

  void _loadBooks() {
    _booksFuture =
        DatabaseHelper.instance.readAllBooks();
  }

  void _refresh() {
    setState(() {
      _loadBooks();
    });
  }

  // ============================================================
  // Favorite
  // ============================================================

  Future<void> _toggleFavorite(Book book) async {
    final newStatus = !book.isFavorite;

    await DatabaseHelper.instance
        .toggleFavoriteStatus(
      book.id,
      newStatus,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                newStatus
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                newStatus
                    ? 'Added to favorites'
                    : 'Removed from favorites',
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
          duration:
              const Duration(seconds: 2),
        ),
      );
  }

  // ============================================================
  // Delete
  // ============================================================

  Future<void> _deleteBook(Book book) async {
    await DatabaseHelper.instance.deleteBook(
      book.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Text(
                'Book removed from your library',
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
        ),
      );
  }

  // ============================================================
  // Open details
  // ============================================================

  void _openDetails(Book book) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments: BookDetailsArguments(
        itemBook: book,
        isFromSavedScreen: true,
      ),
    );
  }

  // ============================================================
  // Image
  // ============================================================

  Widget _bookImage(Book book) {
    if (book.imageLinks == null ||
        book.imageLinks!.isEmpty) {
      return Container(
        width: 70,
        height: 95,
        color: Colors.grey.shade200,
        child: const Icon(
          Icons.menu_book_rounded,
          size: 30,
        ),
      );
    }

    return Image.network(
      book.imageLinks!,
      width: 70,
      height: 95,
      fit: BoxFit.cover,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return Container(
          width: 70,
          height: 95,
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.menu_book_rounded,
            size: 30,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        centerTitle: true,
      ),

      body: FutureBuilder<List<Book>>(
        future: _booksFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong',
              ),
            );
          }

          final books = snapshot.data ?? [];

          // ====================================================
          // Empty library
          // ====================================================

          if (books.isEmpty) {
            return const Center(
              child: Text(
                'Your library is empty',
              ),
            );
          }

          // ====================================================
          // Saved books list
          // ====================================================

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,

            itemBuilder: (context, index) {
              final book = books[index];

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),
                elevation: 0,
                color:
                    colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),

                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(18),

                  // ==========================================
                  // Book -> Details
                  // ==========================================

                  onTap: () {
                    _openDetails(book);
                  },

                  child: Padding(
                    padding:
                        const EdgeInsets.all(10),

                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                          child: _bookImage(book),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                book.title,
                                maxLines: 2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style: theme
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                book.authors.isNotEmpty
                                    ? book.authors.join(
                                        ', ',
                                      )
                                    : 'Unknown author',
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style: theme
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              // ==================================
                              // Favorite
                              // ==================================

                              Row(
                                children: [
                                  IconButton(
                                    padding:
                                        EdgeInsets
                                            .zero,

                                    constraints:
                                        const BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),

                                    onPressed: () {
                                      _toggleFavorite(
                                        book,
                                      );
                                    },

                                    icon: Icon(
                                      book.isFavorite
                                          ? Icons
                                              .favorite_rounded
                                          : Icons
                                              .favorite_border_rounded,
                                      color:
                                          book.isFavorite
                                              ? Colors.red
                                              : colorScheme
                                                  .onSurfaceVariant,
                                    ),
                                  ),

                                  Text(
                                    book.isFavorite
                                        ? 'Favorite'
                                        : 'Add to favorites',
                                    style: theme
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                      color:
                                          book.isFavorite
                                              ? Colors.red
                                              : colorScheme
                                                  .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ========================================
                        // Delete
                        // ========================================

                        IconButton(
                          tooltip: 'Delete book',
                          onPressed: () {
                            _deleteBook(book);
                          },
                          icon: Icon(
                            Icons
                                .delete_outline_rounded,
                            color:
                                colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}