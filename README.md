# 📚 Book Explorer

A Flutter book discovery and personal library app built with the Open Library API and SQLite.

## About the Project

**Book Explorer** was developed as a practical project after completing a Flutter course.

The goal was to move beyond isolated exercises and build a complete application that combines several core Flutter concepts in one project: REST API integration, JSON parsing, navigation, responsive UI, local data persistence, and state synchronization.

Users can discover books, search by title or author, view book information, save books to a local library, and organize favorites.

## ✨ Features

- Search for books by title, author, or keyword
- Browse books from the Open Library API
- View book covers and useful book metadata
- Open a dedicated details screen for each book
- Save books to a personal local library
- Add or remove books from favorites
- Keep Library and Favorites synchronized
- Store saved data locally with SQLite
- Paginate through search results
- Responsive book grid
- Material 3 interface
- Loading, empty, and error states

## 🛠️ Tech Stack

- **Flutter** — application UI and cross-platform development
- **Dart** — programming language
- **Open Library API** — book search and metadata
- **HTTP** — REST API requests
- **SQLite / sqflite** — local book storage
- **path** — local database path handling
- **Material 3** — interface components and styling

## 📱 Main Screens

### Discover

The main screen lets users browse and search for books.

Search results display book covers, titles, authors, and publication information in a responsive grid.

### Book Details

The details screen displays the selected book's available metadata, such as:

- Title
- Author
- Cover
- Publisher
- Publication date
- Page count
- Language
- Description

Books can be saved to the local library from the application.

### My Library

The Library screen contains books saved locally on the device using SQLite.

Users can manage their saved books and mark them as favorites.

### Favorites

The Favorites screen provides quick access to books marked as favorite.

Favorite state is synchronized with the local library so changes remain consistent between screens.

## 🧠 What I Practiced

This project was created to practice and combine important Flutter concepts, including:

- Building reusable Flutter widgets
- Working with `StatefulWidget`
- Managing asynchronous operations with `Future`
- Consuming a REST API
- Parsing JSON into Dart models
- Handling API loading and error states
- Navigating between screens
- Passing objects between routes
- Building responsive layouts
- Using Material 3 components
- Working with SQLite
- Performing CRUD operations
- Persisting application data locally
- Synchronizing UI state after database changes
- Organizing a Flutter project into models, screens, services, database helpers, and reusable components

## 🏗️ Project Structure

```text
lib/
├── components/
│   └── gridview_widget.dart
├── db/
│   └── database_helper.dart
├── models/
│   └── book.dart
├── network/
│   └── network.dart
├── pages/
│   ├── books_details.dart
│   ├── favorites_screen.dart
│   ├── home_screen.dart
│   └── saved_screen.dart
├── utils/
│   └── book_details_arguments.dart
└── main.dart
```

## 🔄 Application Flow

```text
Open Library API
       │
       ▼
Discover / Search
       │
       ▼
   Book Model
       │
       ├──────────────► Book Details
       │
       ▼
 Save to Library
       │
       ▼
     SQLite
       │
       ├──────────────► My Library
       │
       └──────────────► Favorites
```

The Open Library API is the source of online book information, while SQLite is used as the local source of truth for saved books and favorite status.

## 💾 Local Storage

Saved books are stored in a local SQLite database.

The application stores information such as:

- Book ID
- Title
- Authors
- Favorite status
- Publisher
- Publication date
- Description
- Page count
- Language
- Cover URL
- Preview and information links

Because the data is persisted locally, saved books remain available after the application is restarted.

## 🌐 API

The project uses the **Open Library Search API** to retrieve book information.

Search requests support pagination, and API responses are converted into Dart `Book` objects before being displayed in the UI.

## 🚀 Getting Started

### Prerequisites

Make sure Flutter is installed and configured on your machine.

Check your setup with:

```bash
flutter doctor
```

### Installation

Clone the repository:

```bash
git clone <your-repository-url>
```

Move into the project directory:

```bash
cd flutter-book-explorer
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## 📦 Main Dependencies

```yaml
dependencies:
  http: ^1.2.0
  path: ^1.8.3
  sqflite: ^2.3.2
```

## 🎯 Why I Built This

I built this project after completing a Flutter course to apply the concepts I had learned in a complete application instead of keeping them as separate exercises.

The project helped me practice the connection between a remote API, Dart models, Flutter UI, navigation, and persistent local storage.

It also gave me practical experience with an important application-development problem: keeping the UI synchronized when the same data can be changed from multiple screens.

## 🔮 Possible Future Improvements

- Dark mode
- Search filters and sorting
- Richer book details
- Improved tablet and desktop layouts
- Book categories and recommendations
- Reading status such as *Want to Read*, *Reading*, and *Finished*
- Notes or personal ratings
- Additional animations and transitions
- More automated tests
- Improved offline behavior and caching

## 📌 Project Status

This project is a completed Flutter learning project and may continue to receive UI, architecture, and feature improvements as I expand my Flutter experience.

---

Built with Flutter, Dart, Open Library, and SQLite.
