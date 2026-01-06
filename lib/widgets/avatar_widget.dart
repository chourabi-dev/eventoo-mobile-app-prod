import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool showOnlineDot;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.radius = 42,
    this.showOnlineDot = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fallbackUrl = imageUrl;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Gradient ring + border
          Container(
            width: radius * 2 + 6,
            height: radius * 2 + 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: ClipOval(
                child: Image.network(
                  imageUrl!,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: radius,
                        height: radius,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      imageUrl!,
                      width: radius * 2,
                      height: radius * 2,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
          ),

          // Optional online/offline dot
          if (showOnlineDot)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: radius * 0.3,
                height: radius * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
