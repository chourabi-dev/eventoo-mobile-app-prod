import 'dart:math';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fullName;
  final double radius;

  const UserAvatar({
    super.key,
    required this.fullName,
    this.imageUrl,
    this.radius = 25,
  });

  bool get _hasImage =>  imageUrl != null && imageUrl!.trim().isNotEmpty &&  ! imageUrl!.contains("placeholder") && ! imageUrl!.contains("default");

  String get _initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color _backgroundColor() {
    final random = Random(fullName.hashCode);
    return Color.fromARGB(
      255,
      80 + random.nextInt(120),
      80 + random.nextInt(120),
      80 + random.nextInt(120),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(imageUrl);


    return CircleAvatar(
      radius: radius,
      backgroundColor: _hasImage ? Colors.grey.shade200 : _backgroundColor(),
      backgroundImage: _hasImage ? NetworkImage(imageUrl!) : null,
      child: _hasImage
          ? null
          : Text(
              _initials,
              style: TextStyle(
                fontSize: radius * 0.8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}
