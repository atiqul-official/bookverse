import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/book.dart';

class LocalBookRepository {
  LocalBookRepository({Future<String> Function()? documentsPath})
    : _documentsPath =
          documentsPath ??
          (() async => (await getApplicationDocumentsDirectory()).path);

  final Future<String> Function() _documentsPath;

  Future<Directory> _libraryDirectory(String uid) async {
    if (uid.isEmpty) {
      throw ArgumentError.value(uid, 'uid', 'A user ID is required.');
    }
    final userDirectory = base64Url
        .encode(utf8.encode(uid))
        .replaceAll('=', '');
    final directory = Directory(
      '${await _documentsPath()}${Platform.pathSeparator}bookverse${Platform.pathSeparator}$userDirectory',
    );
    await directory.create(recursive: true);
    return directory;
  }

  Future<File> _indexFile(String uid) async => File(
    '${(await _libraryDirectory(uid)).path}${Platform.pathSeparator}books.json',
  );

  Future<List<Book>> loadBooks({required String uid}) async {
    final index = await _indexFile(uid);
    if (!await index.exists()) return [];
    final decoded = jsonDecode(await index.readAsString());
    if (decoded is! List) {
      throw const FormatException('The local book index is invalid.');
    }
    return decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('A local book entry is invalid.');
      }
      return Book.fromLocalMap(item);
    }).toList();
  }

  Future<Book> importPdf(
    PlatformFile pickedFile, {
    required String uid,
    String? title,
    String? author,
    String? category,
  }) async {
    if (pickedFile.extension?.toLowerCase() != 'pdf') {
      throw const FormatException('Choose a PDF file.');
    }

    final directory = await _libraryDirectory(uid);
    final id =
        'local_${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}';
    final safeName = pickedFile.name.replaceAll(
      RegExp(r'[^A-Za-z0-9._-]'),
      '_',
    );
    final destination = File(
      '${directory.path}${Platform.pathSeparator}${id}_$safeName',
    );
    final sourcePath = pickedFile.path;
    try {
      if (sourcePath != null) {
        await File(sourcePath).copy(destination.path);
      } else {
        await destination.writeAsBytes(await pickedFile.readAsBytes());
      }
      final input = await destination.open(mode: FileMode.read);
      late final List<int> signature;
      try {
        signature = await input.read(5);
      } finally {
        await input.close();
      }
      if (String.fromCharCodes(signature) != '%PDF-') {
        throw const FormatException('The selected file is not a valid PDF.');
      }

      final fileSize = await destination.length();
      final now = DateTime.now();
      final fileTitle = pickedFile.name.replaceFirst(
        RegExp(r'\.pdf$', caseSensitive: false),
        '',
      );
      final book = Book(
        id: id,
        title: title?.trim().isNotEmpty == true ? title!.trim() : fileTitle,
        author: author?.trim().isNotEmpty == true
            ? author!.trim()
            : 'Unknown author',
        size: _formatSize(fileSize),
        date:
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        category: category?.trim().isNotEmpty == true
            ? category!.trim()
            : 'Local PDFs',
        description: '',
        page: 0,
        total: 0,
        color: const Color(0xFF536DFE),
        localPdfPath: destination.path,
      );
      final books = await loadBooks(uid: uid)
        ..add(book);
      await _saveBooks(books, uid: uid);
      return book;
    } catch (_) {
      if (await destination.exists()) await destination.delete();
      rethrow;
    }
  }

  Future<void> removeBook(Book book, {required String uid}) async {
    final directory = await _libraryDirectory(uid);
    final path = book.localPdfPath;
    if (path == null ||
        File(path).parent.absolute.path != directory.absolute.path) {
      throw ArgumentError('The selected book is not stored in this library.');
    }
    final file = File(path);
    if (await file.exists()) await file.delete();
    final books = await loadBooks(uid: uid)
      ..removeWhere((item) => item.id == book.id);
    await _saveBooks(books, uid: uid);
  }

  Future<void> _saveBooks(List<Book> books, {required String uid}) async {
    final index = await _indexFile(uid);
    await index.writeAsString(
      jsonEncode(
        books
            .map(
              (book) => {
                'id': book.id,
                ...book.toMap(),
                'localPdfPath': book.localPdfPath,
              },
            )
            .toList(),
      ),
      flush: true,
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).ceil()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
