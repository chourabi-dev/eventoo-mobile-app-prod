import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'dart:ui';
import '../screens/home/home_screen.dart';

class ModuleCard extends StatefulWidget {
  final ModuleData data;
  final VoidCallback onTap;

  const ModuleCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    

    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isHovered
                          ? [
                              widget.data.color.withOpacity(0.4),
                              widget.data.color.withOpacity(0.2),
                            ]
                          : [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isHovered
                          ? widget.data.color.withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isHovered
                            ? widget.data.color.withOpacity(0.3)
                            : Colors.black.withOpacity(0.2),
                        blurRadius: _isHovered ? 20 : 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background gradient circle
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                widget.data.color.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: widget.data.gradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.data.color.withOpacity(0.5),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.data.icon,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Title
                            Text(
                              '${ widget.data.title(l10n) }',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Arrow indicator
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isHovered ? 1.0 : 0.5,
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: _isHovered ? 24 : 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}