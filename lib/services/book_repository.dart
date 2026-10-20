import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/book.dart';

class BookRepository {
  BookRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _books =>
      _firestore.collection('books');

  CollectionReference<Map<String, dynamic>> _userCollection(
    String uid,
    String collection,
  ) => _firestore.collection('users').doc(uid).collection(collection);

  Stream<List<Book>> watchBooks({required String uid}) =>
      _books.where('createdBy', isEqualTo: uid).snapshots().map((snapshot) {
        final docs = snapshot.docs.toList()
          ..sort((a, b) {
            final aCreatedAt = a.data()['createdAt'];
            final bCreatedAt = b.data()['createdAt'];
            if (aCreatedAt is Timestamp && bCreatedAt is Timestamp) {
              return bCreatedAt.compareTo(aCreatedAt);
            }
            return b.id.compareTo(a.id);
          });
        return docs.map((doc) => Book.fromMap(doc.id, doc.data())).toList();
      });

  Stream<Map<String, dynamic>?> watchProfile(String uid) => _firestore
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snapshot) => snapshot.data());

  Future<void> updateProfileSettings(
    String uid,
    Map<String, dynamic> settings,
  ) async {
    await _firestore.collection('users').doc(uid).set({
      ...settings,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Set<String>> watchIds(String uid, String collection) =>
      _userCollection(uid, collection).snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => doc.id).toSet(),
      );

  Stream<List<Map<String, dynamic>>> watchNotes(String uid) =>
      _userCollection(uid, 'notes')
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => {'id': doc.id, ...doc.data()})
                .toList(),
          );

  Stream<Map<String, int>> watchReadingHistory(String uid) =>
      _userCollection(uid, 'reading_history')
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => {
              for (final doc in snapshot.docs)
                doc.id: doc.data()['page'] as int? ?? 0,
            },
          );

  Future<void> setSavedBook({
    required String uid,
    required String collection,
    required Book book,
    required bool saved,
  }) async {
    final reference = _userCollection(uid, collection).doc(book.id);
    if (saved) {
      await reference.set({
        'bookId': book.id,
        'title': book.title,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await reference.delete();
    }
  }

  Future<void> addBook(Book book, {required String uid}) async {
    await _books.add({
      ...book.toMap(),
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBook(Book book) async {
    await _books.doc(book.id).delete();
  }

  Future<void> updateReadingProgress({
    required String uid,
    required Book book,
    required int page,
  }) async {
    await _userCollection(uid, 'reading_history').doc(book.id).set({
      'bookId': book.id,
      'title': book.title,
      'page': page,
      'total': book.total,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveNote({
    required String uid,
    required Book book,
    required String content,
  }) async {
    final reference = _userCollection(uid, 'notes').doc(book.id);
    await reference.set({
      'bookId': book.id,
      'title': book.title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
