import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile/models/stand_model.dart';
import 'package:mobile/screens/exposition/stand_details_screen.dart';

class StandCard extends StatefulWidget {
  final Stand stand;

  const StandCard({super.key, required this.stand});

  @override
  State<StandCard> createState() => _StandCardState();
}

class _StandCardState extends State<StandCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.stand.isClickable ? (_) => setState(() => _isHovered = true) : null,
      onTapUp: widget.stand.isClickable
          ? (_) {
              setState(() => _isHovered = false);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StandDetailScreen(stand: widget.stand),
                ),
              );
            }
          : null,
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.stand.isClickable
                      ? [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.8),
                        ]
                      : [
                          Colors.grey[300]!.withOpacity(0.5),
                          Colors.grey[400]!.withOpacity(0.5),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.stand.isClickable
                      ? const Color(0xFF6C63FF).withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.stand.isClickable
                        ? const Color(0xFF6C63FF).withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: _isHovered ? 20 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 100,
                        //height: 80,
                        /*decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),*/
                        child: Container(
                          child: Image.network(
                            widget.stand.logo,
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF6C63FF),
                                child: const Icon(
                                  Icons.store,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          widget.stand.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.stand.isClickable
                                ? Colors.black87
                                : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Location
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /*Icon(
                              Icons.location_on,
                              size: 14,
                              color: widget.stand.isClickable
                                  ? const Color(0xFF6C63FF)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.stand.location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),*/
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Non-clickable overlay
                  if (!widget.stand.isClickable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Coming Soon',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
