import 'package:flutter/material.dart';
import 'package:reader_tracker/components/gridview_widget.dart';
import 'package:reader_tracker/models/book.dart';
import 'package:reader_tracker/network/network.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Network network = Network();
  final TextEditingController searchController = TextEditingController();

  List<Book> books = [];

  int currentPage = 1;
  bool isLoading = false;
  String currentQuery = '';

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await network.getBooks(
        query: currentQuery,
        page: currentPage,
      );

      if (!mounted) return;

      setState(() {
        books = result;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Unable to load books. Check your connection.',
          ),
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
          isLoading = false;
        });
      }
    }
  }

  void searchBooks() {
    FocusScope.of(context).unfocus();

    setState(() {
      currentQuery = searchController.text.trim();
      currentPage = 1;
    });

    loadBooks();
  }

  void clearSearch() {
    searchController.clear();

    setState(() {
      currentQuery = '';
      currentPage = 1;
    });

    loadBooks();
  }

  void nextPage() {
    if (books.length < Network.booksPerPage) return;

    setState(() {
      currentPage++;
    });

    loadBooks();
  }

  void previousPage() {
    if (currentPage <= 1) return;

    setState(() {
      currentPage--;
    });

    loadBooks();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find your next great read',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                8,
              ),
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => searchBooks(),

                decoration: InputDecoration(
                  hintText: 'Search books, authors...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                  ),

                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: clearSearch,
                          icon: const Icon(
                            Icons.close_rounded,
                          ),
                        )
                      : null,

                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),

                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),

                onChanged: (_) {
                  setState(() {});
                },
              ),
            ),

            // Search result title
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                14,
                20,
                8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      currentQuery.isEmpty
                          ? 'Popular Books'
                          : 'Search Results',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (currentQuery.isNotEmpty)
                    Text(
                      currentQuery,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),

            // Books
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : books.isEmpty
                      ? _EmptyBooks(
                          onRetry: loadBooks,
                        )
                      : GridViewWidget(
                          books: books,
                        ),
            ),

            // Pagination
            if (!isLoading && books.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  14,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    _PageButton(
                      icon: Icons.chevron_left_rounded,
                      enabled: currentPage > 1,
                      onPressed: previousPage,
                    ),

                    const SizedBox(width: 18),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '$currentPage',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),

                    const SizedBox(width: 18),

                    _PageButton(
                      icon: Icons.chevron_right_rounded,
                      enabled:
                          books.length >= Network.booksPerPage,
                      onPressed: nextPage,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: enabled
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.4,
            ),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: enabled
                ? colorScheme.onSurface
                : colorScheme.onSurface.withValues(
                    alpha: 0.3,
                  ),
          ),
        ),
      ),
    );
  }
}

class _EmptyBooks extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyBooks({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 42,
                color: colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'No books found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Try another search or check your connection.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
