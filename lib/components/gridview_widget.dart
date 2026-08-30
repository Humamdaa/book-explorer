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
        16,
        8,
        16,
        10,
      ),

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),

      itemCount: books.length,

      itemBuilder: (context, index) {
        final book = books[index];

        return _BookCard(
          book: book,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),

      elevation: 0,

      clipBehavior: Clip.antiAlias,

      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        onTap: () {
          Navigator.pushNamed(
            context,
            '/details',
            arguments: BookDetailsArguments(
              itemBook: book,
              isFromSavedScreen: false,
            ),
          );
        },

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // Cover
            Expanded(
              flex: 7,
              child: SizedBox(
                width: double.infinity,
                child: book.imageLinks != null &&
                        book.imageLinks!.isNotEmpty
                    ? Image.network(
                        book.imageLinks!,
                        fit: BoxFit.cover,

                        errorBuilder:
                            (context, error, stackTrace) {
                          return _NoCover(
                            colorScheme: colorScheme,
                          );
                        },
                      )
                    : _NoCover(
                        colorScheme: colorScheme,
                      ),
              ),
            ),

            // Information
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  10,
                  12,
                  10,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      book.authors.isNotEmpty
                          ? book.authors.join(', ')
                          : 'Unknown author',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 15,
                          color: colorScheme.primary,
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          child: Text(
                            book.publishedDate ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
      color: colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 55,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

