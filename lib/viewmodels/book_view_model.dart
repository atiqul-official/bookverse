import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../models/book.dart';
import '../services/auth_service.dart';
import '../services/book_repository.dart';
import '../services/local_book_repository.dart';

class BookViewModel extends ChangeNotifier {
  BookViewModel({
    AuthService? authService,
    BookRepository? repository,
    LocalBookRepository? localBookRepository,
  }) : _authService = authService ?? AuthService(),
       _repository = repository ?? BookRepository(),
       _localBookRepository = localBookRepository ?? LocalBookRepository();

  final AuthService _authService;
  final BookRepository _repository;
  final LocalBookRepository _localBookRepository;
  final List<Book> books = [];
  final List<Book> _localBooks = [];
  final List<Book> _remoteBooks = [];
  final Set<String> favoriteIds = {};
  final Set<String> bookmarkedIds = {};
  final List<String> readingHistory = [];
  final Map<String, int> readingPages = {};
  final List<Map<String, dynamic>> notes = [];

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<Book>>? _booksSubscription;
  StreamSubscription<Set<String>>? _favoritesSubscription;
  StreamSubscription<Set<String>>? _bookmarksSubscription;
  StreamSubscription<Map<String, int>>? _historySubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _notesSubscription;
  StreamSubscription<Map<String, dynamic>?>? _profileSubscription;
  int _authChangeGeneration = 0;

  String selectedCategory = 'All';
  String searchQuery = '';
  String? booksError;
  String? localBooksError;
  String? userName;
  String? userEmail;
  bool darkMode = false;
  bool dailyGoalEnabled = true;
  bool showPageNumber = true;
  bool showReadingProgress = true;
  bool autoSaveNotes = true;
  bool pageTurnAnimation = true;
  bool isInitialized = false;
  bool isLoadingBooks = true;
  int fontSize = 16;
  int dailyGoalMinutes = 30;
  User? currentUser;

  bool get isLoggedIn => currentUser != null;
  String? get dataError => booksError ?? localBooksError;

  List<Book> get filteredBooks {
    return books.where((book) {
      final query = searchQuery.toLowerCase();
      final matchesQuery =
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query);
      final matchesCategory =
          selectedCategory == 'All' || book.category == selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  List<Book> get favoriteBooks =>
      books.where((book) => favoriteIds.contains(book.id)).toList();

  List<Book> get bookmarkedBooks =>
      books.where((book) => bookmarkedIds.contains(book.id)).toList();

  List<Book> get recentBooks {
    final byId = {for (final book in books) book.id: book};
    return readingHistory.map((id) => byId[id]).whereType<Book>().toList();
  }

  void initialize() {
    _authSubscription ??= _authService.authStateChanges().listen(
      _onAuthStateChanged,
      onError: (Object error) {
        booksError = 'Could not check your sign-in status: $error';
        isInitialized = true;
        notifyListeners();
      },
    );
  }

  Future<void> _onAuthStateChanged(User? user) async {
    final generation = ++_authChangeGeneration;
    currentUser = user;
    isInitialized = true;
    await _cancelUserSubscriptions();
    if (generation != _authChangeGeneration) return;
    books.clear();
    _localBooks.clear();
    _remoteBooks.clear();
    favoriteIds.clear();
    bookmarkedIds.clear();
    readingHistory.clear();
    readingPages.clear();
    notes.clear();
    _resetSettings();
    userName = user?.displayName;
    userEmail = user?.email;
    booksError = null;
    localBooksError = null;
    isLoadingBooks = user != null;
    notifyListeners();

    if (user == null) return;

    try {
      _localBooks.addAll(await _localBookRepository.loadBooks(uid: user.uid));
    } catch (error) {
      localBooksError = 'Could not load PDFs stored on this device: $error';
    }
    if (generation != _authChangeGeneration) return;
    _refreshBooks();

    _booksSubscription = _repository
        .watchBooks(uid: user.uid)
        .listen(
          (items) {
            _remoteBooks
              ..clear()
              ..addAll(items);
            _refreshBooks();
            booksError = null;
            isLoadingBooks = false;
            notifyListeners();
          },
          onError: (Object error) {
            booksError = 'Could not load books from Firestore: $error';
            isLoadingBooks = false;
            notifyListeners();
          },
        );
    _favoritesSubscription = _repository.watchIds(user.uid, 'favorites').listen(
      (ids) {
        favoriteIds
          ..clear()
          ..addAll(ids);
        notifyListeners();
      },
      onError: _setSubscriptionError,
    );
    _bookmarksSubscription = _repository.watchIds(user.uid, 'bookmarks').listen(
      (ids) {
        bookmarkedIds
          ..clear()
          ..addAll(ids);
        notifyListeners();
      },
      onError: _setSubscriptionError,
    );
    _profileSubscription = _repository.watchProfile(user.uid).listen((profile) {
      userName = profile?['name'] as String? ?? user.displayName;
      userEmail = profile?['email'] as String? ?? user.email;
      darkMode = profile?['darkMode'] as bool? ?? darkMode;
      dailyGoalEnabled = profile?['dailyGoal'] as bool? ?? dailyGoalEnabled;
      autoSaveNotes = profile?['autoSaveNotes'] as bool? ?? autoSaveNotes;
      pageTurnAnimation =
          profile?['pageTurnAnimation'] as bool? ?? pageTurnAnimation;
      showPageNumber = profile?['showPageNumber'] as bool? ?? showPageNumber;
      showReadingProgress =
          profile?['showReadingProgress'] as bool? ?? showReadingProgress;
      fontSize = (profile?['fontSize'] as num?)?.toInt() ?? fontSize;
      dailyGoalMinutes =
          (profile?['dailyGoalMinutes'] as num?)?.toInt() ?? dailyGoalMinutes;
      notifyListeners();
    }, onError: _setSubscriptionError);
    _historySubscription = _repository.watchReadingHistory(user.uid).listen((
      progress,
    ) {
      readingHistory
        ..clear()
        ..addAll(progress.keys);
      readingPages
        ..clear()
        ..addAll(progress);
      notifyListeners();
    }, onError: _setSubscriptionError);
    _notesSubscription = _repository.watchNotes(user.uid).listen((items) {
      notes
        ..clear()
        ..addAll(items);
      notifyListeners();
    }, onError: _setSubscriptionError);
  }

  void _setSubscriptionError(Object error) {
    booksError = 'Could not sync your data: $error';
    notifyListeners();
  }

  void _refreshBooks() {
    books
      ..clear()
      ..addAll(_localBooks)
      ..addAll(_remoteBooks);
  }

  Future<void> _cancelUserSubscriptions() async {
    await Future.wait([
      _booksSubscription?.cancel() ?? Future<void>.value(),
      _favoritesSubscription?.cancel() ?? Future<void>.value(),
      _bookmarksSubscription?.cancel() ?? Future<void>.value(),
      _historySubscription?.cancel() ?? Future<void>.value(),
      _notesSubscription?.cancel() ?? Future<void>.value(),
      _profileSubscription?.cancel() ?? Future<void>.value(),
    ]);
    _booksSubscription = null;
    _favoritesSubscription = null;
    _bookmarksSubscription = null;
    _historySubscription = null;
    _notesSubscription = null;
    _profileSubscription = null;
  }

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  Future<void> toggleFavorite(Book book) async {
    final user = currentUser;
    if (user == null) return;
    await _repository.setSavedBook(
      uid: user.uid,
      collection: 'favorites',
      book: book,
      saved: !favoriteIds.contains(book.id),
    );
  }

  Future<void> toggleBookmark(Book book) async {
    final user = currentUser;
    if (user == null) return;
    await _repository.setSavedBook(
      uid: user.uid,
      collection: 'bookmarks',
      book: book,
      saved: !bookmarkedIds.contains(book.id),
    );
  }

  Future<void> addReadingHistory(Book book, int page) async {
    final user = currentUser;
    if (user == null) return;
    await _repository.updateReadingProgress(
      uid: user.uid,
      book: book,
      page: page,
    );
  }

  int readingPage(Book book) => readingPages[book.id] ?? book.page;

  Future<void> saveNote(Book book, String content) async {
    final user = currentUser;
    if (user == null) return;
    await _repository.saveNote(uid: user.uid, book: book, content: content);
  }

  Future<void> addBook(Book book) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('Sign in before adding a book.');
    }
    await _repository.addBook(book, uid: user.uid);
  }

  Future<void> importLocalPdf(
    PlatformFile file, {
    String? title,
    String? author,
    String? category,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('Sign in before importing a PDF.');
    }
    final book = await _localBookRepository.importPdf(
      file,
      uid: user.uid,
      title: title,
      author: author,
      category: category,
    );
    if (currentUser?.uid != user.uid) return;
    _localBooks.insert(0, book);
    _refreshBooks();
    notifyListeners();
  }

  Future<void> removeLocalBook(Book book) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('Sign in before removing a local PDF.');
    }
    if (!book.isLocalPdf) {
      throw ArgumentError.value(book.id, 'book', 'Book is not stored locally.');
    }
    if (!_localBooks.any((item) => item.id == book.id)) {
      throw ArgumentError.value(
        book.id,
        'book',
        "Book is not in the signed-in user's library.",
      );
    }
    await _localBookRepository.removeBook(book, uid: user.uid);
    if (currentUser?.uid != user.uid) return;
    _localBooks.removeWhere((item) => item.id == book.id);
    favoriteIds.remove(book.id);
    bookmarkedIds.remove(book.id);
    readingPages.remove(book.id);
    readingHistory.remove(book.id);
    _refreshBooks();
    notifyListeners();
  }

  Future<void> removeBook(Book book) async {
    if (book.isLocalPdf) {
      await removeLocalBook(book);
      return;
    }

    final user = currentUser;
    if (user == null) {
      throw StateError('Sign in before deleting a book.');
    }
    if (!_remoteBooks.any((item) => item.id == book.id)) {
      throw ArgumentError.value(
        book.id,
        'book',
        "Book is not in the signed-in user's library.",
      );
    }

    await _repository.deleteBook(book);
    if (currentUser?.uid != user.uid) return;
    _remoteBooks.removeWhere((item) => item.id == book.id);
    favoriteIds.remove(book.id);
    bookmarkedIds.remove(book.id);
    readingPages.remove(book.id);
    readingHistory.remove(book.id);
    notes.removeWhere((note) => note['bookId'] == book.id);
    _refreshBooks();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _authService.login(email: email, password: password);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _authService.register(name: name, email: email, password: password);
  }

  Future<void> resetPassword(String email) =>
      _authService.sendPasswordResetEmail(email);

  Future<void> logout() => _authService.logout();

  void _resetSettings() {
    darkMode = false;
    dailyGoalEnabled = true;
    autoSaveNotes = true;
    pageTurnAnimation = true;
    showPageNumber = true;
    showReadingProgress = true;
    fontSize = 16;
    dailyGoalMinutes = 30;
  }

  Future<void> _persistSettings(Map<String, dynamic> settings) async {
    final user = currentUser;
    if (user != null) {
      await _repository.updateProfileSettings(user.uid, settings);
    }
  }

  Future<void> updateDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    await _persistSettings({'darkMode': value});
  }

  void setFontSize(int size) {
    fontSize = size;
    notifyListeners();
  }

  Future<void> saveFontSize() => _persistSettings({'fontSize': fontSize});

  Future<void> updateDailyGoalMinutes(int minutes) async {
    dailyGoalMinutes = minutes;
    notifyListeners();
    await _persistSettings({'dailyGoalMinutes': minutes});
  }

  Future<void> updateSetting(String key, bool value) async {
    switch (key) {
      case 'dailyGoal':
        dailyGoalEnabled = value;
        key = 'dailyGoal';
      case 'autoSaveNotes':
        autoSaveNotes = value;
      case 'pageTurnAnimation':
        pageTurnAnimation = value;
      case 'showPageNumber':
        showPageNumber = value;
      case 'showReadingProgress':
        showReadingProgress = value;
      default:
        throw ArgumentError.value(key, 'key', 'Unknown setting.');
    }
    notifyListeners();
    await _persistSettings({key: value});
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _cancelUserSubscriptions();
    super.dispose();
  }
}
