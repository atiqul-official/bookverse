import 'package:flutter/material.dart';

import '../models/book.dart';

const List<ReadingStat> readingStats = [
  ReadingStat(
    label: 'Recent',
    value: 'Recently opened',
    icon: Icons.access_time_rounded,
    color: Color(0xFFE7ECFF),
    iconColor: Color(0xFF3155C8),
  ),
  ReadingStat(
    label: 'Favorites',
    value: 'Saved books',
    icon: Icons.favorite_rounded,
    color: Color(0xFFFFE7E9),
    iconColor: Color(0xFFFF5C67),
  ),
  ReadingStat(
    label: 'Notes',
    value: 'Study notes',
    icon: Icons.sticky_note_2_rounded,
    color: Color(0xFFFFF0D8),
    iconColor: Color(0xFFFF9E27),
  ),
  ReadingStat(
    label: 'Library',
    value: 'Your books',
    icon: Icons.folder_rounded,
    color: Color(0xFFDFF2FF),
    iconColor: Color(0xFF26A8E0),
  ),
];

const List<Recommendation> recommendations = [];
