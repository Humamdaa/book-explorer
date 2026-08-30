import 'package:flutter/material.dart';
import 'package:reader_tracker/models/book.dart';
import 'package:reader_tracker/utils/book_details_arguments.dart';

class GridViewWidget extends StatelessWidget {
  final List<Book> books;

  const GridViewWidget({
    super.key,
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        20,
      ),

      gridDelegate:
          const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 210,
        mainAxisExtent: 330,
        crossAxisSpacing: 18,
        mainAxisSpacing: 24,
      ),

      itemCount: books.length,

      itemBuilder: (context, index) {
        return _BookCard(
          book: books[index],
        );
      },
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;

  const _BookCard({
    required this.book,
  });

  void _openDetails(
    BuildContext context,
  ) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments: BookDetailsArguments(
        itemBook: book,
        isFromSavedScreen: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius:
            BorderRadius.circular(20),

        child: Padding(
          padding: const EdgeInsets.all(2),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // Book cover
              // ==================================================

              Expanded(
                child: Container(
                  width: double.infinity,

                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(
                          alpha: 0.08,
                        ),
                        blurRadius: 16,
                        offset:
                            const Offset(0, 7),
                      ),
                    ],
                  ),

                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    child: _BookCover(
                      book: book,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // Title
              // ==================================================

              Text(
                book.title,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: theme
                    .textTheme.titleSmall
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 5),

              // ==================================================
              // Author
              // ==================================================

              Text(
                book.authors.isNotEmpty
                    ? book.authors.join(', ')
                    : 'Unknown author',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: theme
                    .textTheme.bodySmall
                    ?.copyWith(
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // Published date
              // ==================================================

              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme
                          .surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(
                        8,
                      ),
                    ),
                    child: Text(
                      book.publishedDate ??
                          'Unknown',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: theme
                          .textTheme.labelSmall
                          ?.copyWith(
                        color: colorScheme
                            .onSurfaceVariant,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Icon(
                    Icons
                        .arrow_forward_rounded,
                    size: 18,
                    color:
                        colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  final Book book;

  const _BookCover({
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    if (book.imageLinks == null ||
        book.imageLinks!.isEmpty) {
      return _NoCover(
        colorScheme: colorScheme,
      );
    }

    return Image.network(
      book.imageLinks!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,

      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return _NoCover(
          colorScheme: colorScheme,
        );
      },
    );
  }
}

class _NoCover extends StatelessWidget {
  final ColorScheme colorScheme;

  const _NoCover({
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          colorScheme.primaryContainer,
      child: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_rounded,
              size: 52,
              color: colorScheme
                  .onPrimaryContainer,
            ),

            const SizedBox(height: 10),

            Text(
              'No cover',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(
                color: colorScheme
                    .onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}