import 'package:flutter/material.dart';
import 'package:reader_tracker/db/database_helper.dart';
import 'package:reader_tracker/models/book.dart';
import 'package:reader_tracker/utils/book_details_arguments.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({
    super.key,
  });

  @override
  State<SavedScreen> createState() =>
      _SavedScreenState();
}

class _SavedScreenState
    extends State<SavedScreen> {
  late Future<List<Book>>
      _booksFuture;

  // ============================================================
  // Lifecycle
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadBooks();

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

  void _loadBooks() {
    _booksFuture =
        DatabaseHelper.instance
            .readAllBooks();
  }

  void _refresh() {
    setState(() {
      _loadBooks();
    });
  }

  // ============================================================
  // Favorite
  // ============================================================

  Future<void> _toggleFavorite(
    Book book,
  ) async {
    final newStatus =
        !book.isFavorite;

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
                    ? Icons
                        .favorite_rounded
                    : Icons
                        .favorite_border_rounded,
                color: Colors.white,
              ),

              const SizedBox(
                width: 10,
              ),

              Text(
                newStatus
                    ? 'Added to favorites'
                    : 'Removed from favorites',
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
  // Delete
  // ============================================================

  Future<void> _deleteBook(
    Book book,
  ) async {
    await DatabaseHelper.instance
        .deleteBook(
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
                Icons
                    .delete_outline_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Text(
                'Book removed from your library',
              ),
            ],
          ),
          behavior:
              SnackBarBehavior.floating,
          margin:
              EdgeInsets.all(16),
          duration:
              Duration(seconds: 2),
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
          future: _booksFuture,

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

                _LibraryHeader(
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
      return const _LibraryState(
        icon: Icons
            .error_outline_rounded,
        title:
            'Something went wrong',
        message:
            'Your library could not be loaded.',
      );
    }

    if (books.isEmpty) {
      return const _LibraryState(
        icon:
            Icons.bookmark_add_outlined,
        title:
            'Your library is empty',
        message:
            'Save books from Discover and they will appear here.',
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

        return _LibraryBookCard(
          book: book,
          onTap: () {
            _openDetails(book);
          },
          onFavorite: () {
            _toggleFavorite(book);
          },
          onDelete: () {
            _deleteBook(book);
          },
        );
      },
    );
  }
}

// ============================================================
// Header
// ============================================================

class _LibraryHeader
    extends StatelessWidget {
  final int? count;

  const _LibraryHeader({
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
                  'My Library',
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
                      ? 'Your saved collection'
                      : count == 1
                          ? '1 saved book'
                          : '$count saved books',
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
                  .primaryContainer,
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),

            child: Icon(
              Icons
                  .bookmark_rounded,
              color: colorScheme
                  .onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Library book card
// ============================================================

class _LibraryBookCard
    extends StatelessWidget {
  final Book book;

  final VoidCallback onTap;

  final VoidCallback onFavorite;

  final VoidCallback onDelete;

  const _LibraryBookCard({
    required this.book,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
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
              const EdgeInsets.all(12),

          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .center,

            children: [
              // ================================================
              // Cover
              // ================================================

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),

                child: _SavedBookCover(
                  book: book,
                ),
              ),

              const SizedBox(
                width: 15,
              ),

              // ================================================
              // Content
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
                      height: 6,
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

                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        if (book
                                .publishedDate !=
                            null)
                          _BookMetaChip(
                            icon: Icons
                                .calendar_today_rounded,
                            label: book
                                .publishedDate!,
                          ),

                        if (book
                                .pageCount !=
                            null)
                          _BookMetaChip(
                            icon: Icons
                                .auto_stories_outlined,
                            label:
                                '${book.pageCount} pages',
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        InkWell(
                          onTap:
                              onFavorite,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),

                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 5,
                              horizontal: 3,
                            ),

                            child: Row(
                              children: [
                                Icon(
                                  book.isFavorite
                                      ? Icons
                                          .favorite_rounded
                                      : Icons
                                          .favorite_border_rounded,
                                  size: 20,
                                  color: book
                                          .isFavorite
                                      ? Colors
                                          .red
                                      : colorScheme
                                          .onSurfaceVariant,
                                ),

                                const SizedBox(
                                  width: 6,
                                ),

                                Text(
                                  book.isFavorite
                                      ? 'Favorite'
                                      : 'Add favorite',
                                  style: theme
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                    color: book
                                            .isFavorite
                                        ? Colors
                                            .red
                                        : colorScheme
                                            .onSurfaceVariant,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ],
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
              // Delete
              // ================================================

              IconButton(
                tooltip:
                    'Remove from library',

                onPressed:
                    onDelete,

                style:
                    IconButton.styleFrom(
                  backgroundColor:
                      colorScheme
                          .errorContainer
                          .withValues(
                    alpha: 0.55,
                  ),
                  foregroundColor:
                      colorScheme.error,
                ),

                icon: const Icon(
                  Icons
                      .delete_outline_rounded,
                  size: 21,
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

class _SavedBookCover
    extends StatelessWidget {
  final Book book;

  const _SavedBookCover({
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
// Meta chip
// ============================================================

class _BookMetaChip
    extends StatelessWidget {
  final IconData icon;

  final String label;

  const _BookMetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),

      decoration:
          BoxDecoration(
        color: colorScheme
            .surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(8),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          Icon(
            icon,
            size: 13,
            color: colorScheme
                .onSurfaceVariant,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            label,
            style: theme
                .textTheme.labelSmall
                ?.copyWith(
              color: colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Empty / error state
// ============================================================

class _LibraryState
    extends StatelessWidget {
  final IconData icon;

  final String title;

  final String message;

  const _LibraryState({
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
                    .primaryContainer,
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),

              child: Icon(
                icon,
                size: 42,
                color: colorScheme
                    .onPrimaryContainer,
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