import 'package:flutter/material.dart';
import '../data/unit_model.dart';

class Domain {
  final String id;
  final String name;
  final String description;
  final Color color;
  final List<Unit> units;
  final bool isActive;

  Domain({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.units,
    this.isActive = true,
  });
}

