import 'package:flutter_test/flutter_test.dart';

import 'package:bookverse/models/book.dart';

void main() {
  test('book data round trips through Firestore fields', () {
    final book = Book.fromMap('firestore-id', {
      'title': 'Cloud Databases',
      'author': 'A. Student',
      'size': '2 MB',
      'date': '2026-10-19',
      'category': 'Educational',
      'description': 'Database concepts and examples.',
      'content': 'Chapter content.',
      'pdfUrl': 'https://example.com/book.pdf',
      'page': 12,
      'total': 100,
      'color': 0xFF3155C8,
      'rating': 4.8,
    });

    expect(book.id, 'firestore-id');
    expect(book.progress, 0.12);
    expect(Book.fromMap(book.id, book.toMap()).content, 'Chapter content.');
    expect(book.toMap()['pdfUrl'], 'https://example.com/book.pdf');
  });
}
