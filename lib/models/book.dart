import 'dart:typed_data';

import 'package:flutter/material.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String size;
  final String date;
  final String category;
  final String description;
  final String content;
  final String pdfUrl;
  final int page;
  final int total;
  final Color color;
  final double rating;
  final String? localPdfPath;
  final Uint8List? localPdfBytes;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.size,
    required this.date,
    required this.category,
    required this.description,
    this.content = '',
    this.pdfUrl = '',
    required this.page,
    required this.total,
    required this.color,
    this.rating = 4.6,
    this.localPdfPath,
    this.localPdfBytes,
  });

  double get progress => total == 0 ? 0 : page / total;
  bool get isLocalPdf => localPdfPath != null || localPdfBytes != null;
  bool get hasPdf => isLocalPdf || pdfUrl.isNotEmpty;

  factory Book.fromMap(String id, Map<String, dynamic> map) {
    return Book(
      id: id,
      title: map['title'] as String? ?? '',
      author: map['author'] as String? ?? '',
      size: map['size'] as String? ?? '',
      date: map['date'] as String? ?? '',
      category: map['category'] as String? ?? 'Books',
      description: map['description'] as String? ?? '',
      content: map['content'] as String? ?? '',
      pdfUrl: map['pdfUrl'] as String? ?? '',
      page: map['page'] as int? ?? 0,
      total: map['total'] as int? ?? 0,
      color: Color(map['color'] as int? ?? 0xFF536DFE),
      rating: (map['rating'] as num?)?.toDouble() ?? 4.6,
    );
  }

  factory Book.fromLocalMap(Map<String, dynamic> map) {
    final book = Book.fromMap(map['id'] as String, map);
    return Book(
      id: book.id,
      title: book.title,
      author: book.author,
      size: book.size,
      date: book.date,
      category: book.category,
      description: book.description,
      content: book.content,
      pdfUrl: book.pdfUrl,
      page: book.page,
      total: book.total,
      color: book.color,
      rating: book.rating,
      localPdfPath: map['localPdfPath'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'author': author,
    'size': size,
    'date': date,
    'category': category,
    'description': description,
    'content': content,
    'pdfUrl': pdfUrl,
    'page': page,
    'total': total,
    'color': color.toARGB32(),
    'rating': rating,
  };
}

class ReadingStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const ReadingStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });
}

class Recommendation {
  final String title;
  final String subtitle;
  final String badge;

  const Recommendation({
    required this.title,
    required this.subtitle,
    required this.badge,
  });
}
