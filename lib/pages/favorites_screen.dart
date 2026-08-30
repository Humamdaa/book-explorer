import 'package:flutter/material.dart';
import 'package:reader_tracker/db/database_helper.dart';
import 'package:reader_tracker/models/book.dart';
import 'package:reader_tracker/utils/book_details_arguments.dart';

class FavoritesScreen
    extends StatefulWidget {
  const FavoritesScreen({
    super.key,
  });

  @override
  State<FavoritesScreen>
      createState() =>
          _FavoritesScreenState();
}

class _FavoritesScreenState
    extends State<FavoritesScreen> {
  late Future<List<Book>>
      _favoritesFuture;

  // ============================================================
  // Lifecycle
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadFavorites();

    DatabaseHelper
        .instance.changes
        .addListener(
      _onDatabaseChanged,
    );
  }

  @override
  void dispose() {
    DatabaseHelper
        .instance.changes
        .removeListener(
      _onDatabaseChanged,
    );

    super.dispose();
  }

  void _onDatabaseChanged() {
    if (!mounted) return;

    _refresh();
  }

  // ============================================================
  // Load
  // ============================================================

  void _loadFavorites() {
    _favoritesFuture =
        DatabaseHelper.instance
            .getFavorites();
  }

  void _refresh() {
    setState(() {
      _loadFavorites();
    });
  }

  // ============================================================
  // Favorite
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
        SnackBar(
          content: const Row(
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

          margin:
              const EdgeInsets.all(
            16,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),

          duration:
              const Duration(
            seconds: 2,
          ),
        ),
      );
  }

  // ============================================================
  // Details
  // ============================================================

  void _openDetails(
    Book book,
  ) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments:
          BookDetailsArguments(
        itemBook: book,
        isFromSavedScreen: true,
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Scaffold(
      backgroundColor:
          colorScheme.surface,

      body: SafeArea(
        child:
            FutureBuilder<List<Book>>(
          future: _favoritesFuture,

          builder: (
            context,
            snapshot,
          ) {
            final books =
                snapshot.data ?? [];

            return Column(
              children: [
                // ===============================================
                // Header
                // ===============================================

                _FavoritesHeader(
                  count:
                      snapshot.hasData
                          ? books.length
                          : null,
                ),

                // ===============================================
                // Content
                // ===============================================

                Expanded(
                  child:
                      _buildContent(
                    snapshot,
                    books,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    AsyncSnapshot<List<Book>>
        snapshot,
    List<Book> books,
  ) {
    if (snapshot.connectionState ==
        ConnectionState.waiting) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return const _FavoriteState(
        icon:
            Icons.error_outline_rounded,
        title:
            'Something went wrong',
        message:
            'Your favorite books could not be loaded.',
      );
    }

    if (books.isEmpty) {
      return const _FavoriteState(
        icon: Icons
            .favorite_border_rounded,
        title:
            'No favorites yet',
        message:
            'Mark books you love and they will stay together here.',
      );
    }

    return ListView.separated(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        24,
      ),

      itemCount: books.length,

      separatorBuilder: (
        context,
        index,
      ) {
        return const SizedBox(
          height: 14,
        );
      },

      itemBuilder: (
        context,
        index,
      ) {
        final book =
            books[index];

        return _FavoriteBookCard(
          book: book,

          onTap: () {
            _openDetails(book);
          },

          onRemove: () {
            _removeFavorite(book);
          },
        );
      },
    );
  }
}

// ============================================================
// Header
// ============================================================

class _FavoritesHeader
    extends StatelessWidget {
  final int? count;

  const _FavoritesHeader({
    required this.count,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        16,
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  'Favorites',
                  style: theme
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  count == null
                      ? 'Books worth coming back to'
                      : count == 1
                          ? '1 favorite book'
                          : '$count favorite books',
                  style: theme
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 48,
            height: 48,

            decoration:
                BoxDecoration(
              color: colorScheme
                  .errorContainer,
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),

            child: Icon(
              Icons
                  .favorite_rounded,
              color: colorScheme
                  .onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Favorite card
// ============================================================

class _FavoriteBookCard
    extends StatelessWidget {
  final Book book;

  final VoidCallback onTap;

  final VoidCallback onRemove;

  const _FavoriteBookCard({
    required this.book,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Material(
      color:
          colorScheme.surfaceContainerLow,

      borderRadius:
          BorderRadius.circular(22),

      clipBehavior:
          Clip.antiAlias,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        child: Padding(
          padding:
              const EdgeInsets.all(
            12,
          ),

          child: Row(
            children: [
              // ================================================
              // Cover
              // ================================================

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),

                child:
                    _FavoriteBookCover(
                  book: book,
                ),
              ),

              const SizedBox(
                width: 15,
              ),

              // ================================================
              // Info
              // ================================================

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
                                .w700,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    Text(
                      book.authors
                              .isNotEmpty
                          ? book.authors
                              .join(', ')
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
                      height: 12,
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons
                              .calendar_today_rounded,
                          size: 14,
                          color: colorScheme
                              .onSurfaceVariant,
                        ),

                        const SizedBox(
                          width: 6,
                        ),

                        Expanded(
                          child: Text(
                            book.publishedDate ??
                                'Publication date unknown',
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: theme
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                              color: colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              // ================================================
              // Favorite button
              // ================================================

              IconButton(
                tooltip:
                    'Remove from favorites',

                onPressed:
                    onRemove,

                style:
                    IconButton.styleFrom(
                  backgroundColor:
                      colorScheme
                          .errorContainer,
                  foregroundColor:
                      colorScheme
                          .onErrorContainer,
                ),

                icon: const Icon(
                  Icons.favorite_rounded,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Cover
// ============================================================

class _FavoriteBookCover
    extends StatelessWidget {
  final Book book;

  const _FavoriteBookCover({
    required this.book,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    if (book.imageLinks == null ||
        book.imageLinks!.isEmpty) {
      return Container(
        width: 78,
        height: 112,
        color:
            colorScheme.primaryContainer,
        child: Icon(
          Icons
              .auto_stories_rounded,
          color: colorScheme
              .onPrimaryContainer,
          size: 30,
        ),
      );
    }

    return Image.network(
      book.imageLinks!,
      width: 78,
      height: 112,
      fit: BoxFit.cover,

      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return Container(
          width: 78,
          height: 112,
          color: colorScheme
              .primaryContainer,
          child: Icon(
            Icons
                .auto_stories_rounded,
            color: colorScheme
                .onPrimaryContainer,
            size: 30,
          ),
        );
      },
    );
  }
}

// ============================================================
// Empty / error state
// ============================================================

class _FavoriteState
    extends StatelessWidget {
  final IconData icon;

  final String title;

  final String message;

  const _FavoriteState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 94,
              height: 94,

              decoration:
                  BoxDecoration(
                color: colorScheme
                    .errorContainer,
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),

              child: Icon(
                icon,
                size: 42,
                color: colorScheme
                    .onErrorContainer,
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            Text(
              title,
              textAlign:
                  TextAlign.center,
              style: theme
                  .textTheme.titleLarge
                  ?.copyWith(
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              message,
              textAlign:
                  TextAlign.center,
              style: theme
                  .textTheme.bodyMedium
                  ?.copyWith(
                color: colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}