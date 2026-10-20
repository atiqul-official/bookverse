import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookverse/models/book.dart';
import 'package:bookverse/services/local_book_repository.dart';

void main() {
  test('restores and removes a local PDF without exporting its file path', () async {
    final documents = await Directory.systemTemp.createTemp('bookverse-test-');
    addTearDown(() => documents.delete(recursive: true));
    final library = Directory(
      '${documents.path}${Platform.pathSeparator}bookverse${Platform.pathSeparator}dXNlci1h',
    )..createSync(recursive: true);
    final pdf = File('${library.path}${Platform.pathSeparator}local_test.pdf')
      ..writeAsBytesSync('%PDF-test'.codeUnits);
    final book = Book(
      id: 'local_test',
      title: 'Test PDF',
      author: 'Local PDF',
      size: '1 KB',
      date: '2026-10-19',
      category: 'Local PDFs',
      description: '',
      page: 0,
      total: 0,
      color: const Color(0xFF536DFE),
      localPdfPath: pdf.path,
    );
    await File('${library.path}${Platform.pathSeparator}books.json')
        .writeAsString(
          jsonEncode([
            {...book.toMap(), 'id': book.id, 'localPdfPath': book.localPdfPath},
          ]),
        );
    final repository = LocalBookRepository(
      documentsPath: () async => documents.path,
    );

    final restored = await repository.loadBooks(uid: 'user-a');
    expect(restored.single.id, book.id);
    expect(restored.single.localPdfPath, pdf.path);
    expect(restored.single.toMap(), isNot(contains('localPdfPath')));
    expect(await repository.loadBooks(uid: 'user-b'), isEmpty);
    await expectLater(
      repository.removeBook(restored.single, uid: 'user-b'),
      throwsArgumentError,
    );

    await repository.removeBook(restored.single, uid: 'user-a');
    expect(await pdf.exists(), isFalse);
    expect(await repository.loadBooks(uid: 'user-a'), isEmpty);
  });
}
