import 'package:flutter/material.dart';
import 'package:reader_tracker/db/database_helper.dart';
import 'package:reader_tracker/models/book.dart';
import 'package:reader_tracker/utils/book_details_arguments.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() =>
      _FavoritesScreenState();
}

class _FavoritesScreenState
    extends State<FavoritesScreen> {
  late Future<List<Book>> _favoritesFuture;

  @override
  void initState() {
    super.initState();

    _loadFavorites();

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
  // Load favorites
  // ============================================================

  void _loadFavorites() {
    _favoritesFuture =
        DatabaseHelper.instance.getFavorites();
  }

  void _refresh() {
    setState(() {
      _loadFavorites();
    });
  }

  // ============================================================
  // Remove from favorites
  // ============================================================

  Future<void> _removeFavorite(
    Book book,
  ) async {
    await DatabaseHelper.instance
        .toggleFavoriteStatus(
      book.id,
      false,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons
                    .favorite_border_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Text(
                'Removed from favorites',
              ),
            ],
          ),
          behavior:
              SnackBarBehavior.floating,
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
        title: const Text('Favorites'),
        centerTitle: true,
      ),

      body: FutureBuilder<List<Book>>(
        future: _favoritesFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
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
          // Empty favorites
          // ====================================================

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons
                        .favorite_border_rounded,
                    size: 80,
                    color:
                        colorScheme.primary,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Text(
                    'No favorites yet',
                    style: theme
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    'Add books to your favorites',
                    style: theme
                        .textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // ====================================================
          // Favorites list
          // ====================================================

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,

            itemBuilder: (
              context,
              index,
            ) {
              final book = books[index];

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                elevation: 0,
                color: colorScheme
                    .surfaceContainerLow,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),

                  // ==========================================
                  // Book -> Details
                  // ==========================================

                  onTap: () {
                    _openDetails(book);
                  },

                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      10,
                    ),

                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                          child:
                              _bookImage(book),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

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
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                book.authors
                                        .isNotEmpty
                                    ? book.authors
                                        .join(
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
                            ],
                          ),
                        ),

                        // ========================================
                        // Remove favorite
                        // ========================================

                        IconButton(
                          tooltip:
                              'Remove from favorites',

                          onPressed: () {
                            _removeFavorite(
                              book,
                            );
                          },

                          icon: const Icon(
                            Icons
                                .favorite_rounded,
                            color: Colors.red,
                            size: 28,
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