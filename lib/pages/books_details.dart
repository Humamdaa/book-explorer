import 'package:flutter/material.dart';
import 'package:reader_tracker/db/database_helper.dart';
import 'package:reader_tracker/models/book.dart';
import 'package:reader_tracker/utils/book_details_arguments.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool isSaving = false;

  Future<void> saveBook(Book book) async {
    setState(() {
      isSaving = true;
    });

    try {
      await DatabaseHelper.instance.insert(book);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Book added to your library'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      debugPrint('Error saving book: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not save this book'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as BookDetailsArguments;

    final Book book = args.itemBook;
    final bool isFromSavedScreen = args.isFromSavedScreen;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      appBar: AppBar(
        title: const Text('Book Details'),

        centerTitle: true,

        backgroundColor: Colors.transparent,
        elevation: 0,

        actions: [
          if (isFromSavedScreen)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border_rounded),
            ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

        child: Column(
          children: [
            // Book cover
            Container(
              width: 210,
              height: 300,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              clipBehavior: Clip.antiAlias,

              child: book.imageLinks != null && book.imageLinks!.isNotEmpty
                  ? Image.network(
                      book.imageLinks!,
                      fit: BoxFit.cover,

                      errorBuilder: (context, error, stackTrace) {
                        return _DetailsNoCover(colorScheme: colorScheme);
                      },
                    )
                  : _DetailsNoCover(colorScheme: colorScheme),
            ),

            const SizedBox(height: 25),

            // Title
            Text(
              book.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Authors
            Text(
              book.authors.isNotEmpty
                  ? book.authors.join(', ')
                  : 'Unknown author',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 22),

            // Information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InfoItem(
                  icon: Icons.calendar_month_rounded,
                  title: 'Published',
                  value: book.publishedDate ?? 'Unknown',
                ),

                _InfoItem(
                  icon: Icons.menu_book_rounded,
                  title: 'Pages',
                  value: book.pageCount?.toString() ?? 'Unknown',
                ),

                _InfoItem(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  value: book.language ?? 'Unknown',
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Save button
            if (!isFromSavedScreen)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : () => saveBook(book),

                  icon: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bookmark_add_rounded),

                  label: Text(isSaving ? 'Saving...' : 'Save to My Library'),

                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // Description
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About this book',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
              ),

              child: Text(
                book.description ?? 'No description available for this book.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 23),

        const SizedBox(height: 6),

        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DetailsNoCover extends StatelessWidget {
  final ColorScheme colorScheme;

  const _DetailsNoCover({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 80,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
