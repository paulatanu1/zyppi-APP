import 'package:flutter/material.dart';

/// Section item `data.icon` is a plain string (admin-editable JSON, no
/// Flutter-specific type) — maps the handful of icon names used by seed
/// data onto a real [IconData]. Unknown names fall back to a generic
/// category glyph rather than crashing.
IconData resolveSectionIcon(String? name) {
  switch (name) {
    case 'grid_view':
      return Icons.grid_view_rounded;
    case 'eco':
      return Icons.eco_rounded;
    case 'bakery_dining':
      return Icons.bakery_dining_rounded;
    case 'local_drink':
      return Icons.local_drink_rounded;
    default:
      return Icons.category_rounded;
  }
}
