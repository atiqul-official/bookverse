import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/book.dart';

class LocalBookRepository {
  static final Map<String, Map<String, Book>> _books = {};

  LocalBookRepository({Future<String> Function()? documentsPath}) {
    if (documentsPath != null) {
      throw UnsupportedError('Custom document paths are not available here.');
    }
  }

  Future<List<Book>> loadBooks({required String uid}) async =>
      _books[uid]?.values.toList() ?? [];

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
    final bytes = await pickedFile.readAsBytes();
    if (String.fromCharCodes(bytes.take(5)) != '%PDF-') {
      throw const FormatException('The selected file is not a valid PDF.');
    }

    final id = 'local_${DateTime.now().microsecondsSinceEpoch}';
    final now = DateTime.now();
    final size = pickedFile.lengthSync() ?? bytes.length;
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
      size: size < 1024 * 1024
          ? '${(size / 1024).ceil()} KB'
          : '${(size / (1024 * 1024)).toStringAsFixed(1)} MB',
      date:
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      category: category?.trim().isNotEmpty == true
          ? category!.trim()
          : 'Local PDFs',
      description: '',
      page: 0,
      total: 0,
      color: const Color(0xFF536DFE),
      localPdfBytes: bytes,
    );
    (_books[uid] ??= {})[book.id] = book;
    return book;
  }

  Future<void> removeBook(Book book, {required String uid}) async {
    if (_books[uid]?.remove(book.id) == null) {
      throw ArgumentError('The selected PDF is not in this library.');
    }
  }
}
