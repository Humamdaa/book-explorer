import 'package:flutter/material.dart';
import 'package:reader_tracker/pages/books_details.dart';
import 'package:reader_tracker/pages/favorites_screen.dart';
import 'package:reader_tracker/pages/home_screen.dart';
import 'package:reader_tracker/pages/saved_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Reader',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
        ),
        useMaterial3: true,

        scaffoldBackgroundColor:
            Colors.transparent,

        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      initialRoute: '/',

      routes: {
        '/home': (context) => const HomeScreen(),
        '/saved': (context) => const SavedScreen(),
        '/favorites': (context) =>
            const FavoritesScreen(),
        '/details': (context) =>
            const BookDetailsScreen(),
      },

      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() =>
      _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SavedScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      // IMPORTANT:
      // No AppBar here.
      //
      // HomeScreen has its own header.
      // Saved/Favorites have their own AppBars.
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,

        backgroundColor:
            colorScheme.surface,

        indicatorColor:
            colorScheme.primaryContainer,

        height: 70,

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
            ),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.bookmark_border_rounded,
            ),
            selectedIcon: Icon(
              Icons.bookmark_rounded,
            ),
            label: 'Saved',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.favorite_border_rounded,
            ),
            selectedIcon: Icon(
              Icons.favorite_rounded,
            ),
            label: 'Favorites',
          ),
        ],

        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
