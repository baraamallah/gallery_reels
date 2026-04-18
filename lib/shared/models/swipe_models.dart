import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

enum SwipeDirection { left, right, up, down }

class SwipeAction {
  final AssetEntity asset;
  final SwipeDirection direction;
  final DateTime timestamp;
  final String? tagId;

  SwipeAction({
    required this.asset,
    required this.direction,
    required this.timestamp,
    this.tagId,
  });
}

class Tag {
  final String id;
  final String name;
  final Color color;

  Tag({
    required this.id,
    required this.name,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.toARGB32(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
