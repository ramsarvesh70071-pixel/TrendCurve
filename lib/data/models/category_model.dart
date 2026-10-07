import 'package:flutter/material.dart';

/// Predefined and custom metric category model.
class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 'business',
      name: 'Business',
      icon: Icons.business_center_rounded,
      color: Color(0xFF6366F1),
    ),
    CategoryModel(
      id: 'finance',
      name: 'Finance',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF10B981),
    ),
    CategoryModel(
      id: 'health',
      name: 'Health',
      icon: Icons.favorite_rounded,
      color: Color(0xFFEF4444),
    ),
    CategoryModel(
      id: 'productivity',
      name: 'Productivity',
      icon: Icons.bolt_rounded,
      color: Color(0xFF8B5CF6),
    ),
    CategoryModel(
      id: 'social',
      name: 'Social',
      icon: Icons.share_rounded,
      color: Color(0xFFEC4899),
    ),
    CategoryModel(
      id: 'education',
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFF06B6D4),
    ),
    CategoryModel(
      id: 'technology',
      name: 'Technology',
      icon: Icons.devices_rounded,
      color: Color(0xFF3B82F6),
    ),
    CategoryModel(
      id: 'custom',
      name: 'Custom',
      icon: Icons.tune_rounded,
      color: Color(0xFFF59E0B),
    ),
  ];

  static CategoryModel getByName(String name) {
    return defaultCategories.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => defaultCategories.last,
    );
  }
}
