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

  // ============================================================
  // Lifecycle
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadBooks();
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // Load books
  // ============================================================

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

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.wifi_off_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Unable to load books. Check your connection.'),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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

  // ============================================================
  // Search
  // ============================================================

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

  // ============================================================
  // Pagination
  // ============================================================

  void nextPage() {
    if (books.length < Network.booksPerPage) {
      return;
    }

    setState(() {
      currentPage++;
    });

    loadBooks();
  }

  void previousPage() {
    if (currentPage <= 1) {
      return;
    }

    setState(() {
      currentPage--;
    });

    loadBooks();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // Header
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),

              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Find something worth reading today.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // Search
            // ==================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),

              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.035),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: TextField(
                  controller: searchController,

                  textInputAction: TextInputAction.search,

                  onSubmitted: (_) {
                    searchBooks();
                  },

                  onChanged: (_) {
                    setState(() {});
                  },

                  decoration: InputDecoration(
                    hintText: 'Search title or author',

                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),

                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            tooltip: 'Clear search',
                            onPressed: clearSearch,
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,

                    filled: true,

                    fillColor: colorScheme.surfaceContainerLow,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),

                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ),

            // ==================================================
            // Section title
            // ==================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),

              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      currentQuery.isEmpty ? 'Popular books' : 'Search results',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  if (!isLoading && books.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '${books.length} books',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ==================================================
            // Current search query
            // ==================================================
            if (currentQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 15,
                          color: colorScheme.onPrimaryContainer,
                        ),

                        const SizedBox(width: 6),

                        Flexible(
                          child: Text(
                            currentQuery,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ==================================================
            // Books
            // ==================================================
            Expanded(
              child: isLoading
                  ? const _LoadingBooksGrid()
                  : books.isEmpty
                  ? _EmptyBooks(
                      isSearch: currentQuery.isNotEmpty,
                      onRetry: loadBooks,
                    )
                  : GridViewWidget(books: books),
            ),

            // ==================================================
            // Pagination
            // ==================================================
            if (!isLoading && books.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PageButton(
                        icon: Icons.chevron_left_rounded,
                        enabled: currentPage > 1,
                        onPressed: previousPage,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Page $currentPage',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      _PageButton(
                        icon: Icons.chevron_right_rounded,
                        enabled: books.length >= Network.booksPerPage,
                        onPressed: nextPage,
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

// ============================================================
// Page button
// ============================================================

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

    return IconButton(
      onPressed: enabled ? onPressed : null,

      icon: Icon(icon),

      style: IconButton.styleFrom(
        backgroundColor: enabled
            ? colorScheme.surfaceContainerHighest
            : Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }
}

// ============================================================
// Loading state
// ============================================================

class _LoadingBooksGrid extends StatelessWidget {
  const _LoadingBooksGrid();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),

      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 210,
        mainAxisExtent: 330,
        crossAxisSpacing: 18,
        mainAxisSpacing: 24,
      ),

      itemCount: 6,

      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: 100,
              height: 11,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: 55,
              height: 22,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// Empty state
// ============================================================

class _EmptyBooks extends StatelessWidget {
  final VoidCallback onRetry;

  final bool isSearch;

  const _EmptyBooks({required this.onRetry, required this.isSearch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 94,
              height: 94,

              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(30),
              ),

              child: Icon(
                isSearch
                    ? Icons.search_off_rounded
                    : Icons.auto_stories_rounded,
                size: 42,
                color: colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              isSearch ? 'No matching books' : 'No books available',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isSearch
                  ? 'Try a different title, author, or keyword.'
                  : 'We could not load books right now.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 22),

            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
