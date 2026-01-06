import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'dart:ui';
import '../models/event.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  String _formatDateRange(String start, String end) {
    try {
      final startDate = DateTime.parse(start);
      final endDate = DateTime.parse(end);

      final formatter = DateFormat('dd MMM yyyy');
      return '${formatter.format(startDate)} → ${formatter.format(endDate)}';
    } catch (_) {
      return '$start → $end';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 8.0, end: 20.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  String getCategoryName(BuildContext context, int id) {
  switch (id) {
    case 1:
      return AppLocalizations.of(context)!.hybrid;    // Hybride
    case 2:
      return AppLocalizations.of(context)!.physical;  // Physique
    case 3:
      return AppLocalizations.of(context)!.virtual;   // Virtuel
    default:
      return AppLocalizations.of(context)!.unknown;
  }
}

  @override
  Widget build(BuildContext context) {

    print(widget.event.imageUrl);

    
    final dateRange = _formatDateRange(
      widget.event.startDate,
      widget.event.endDate,
    );

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
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Hero(
              tag: 'event_${widget.event.id}',
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: _elevationAnimation.value,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Background image
                      Positioned.fill(
                        child: Image.network(
                            widget.event.imageUrl,
                            fit: BoxFit.cover,
                            // force web rendering strategy
                            // webHtmlElementStrategy: WebHtmlElementStrategy.prefer ,
                            errorBuilder: (context, error, stackTrace) { 
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.primaryColor,
                                    AppTheme.secondaryColor,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.event_rounded,
                                size: 60,
                                color: Colors.white54,
                              ),
                            );
                          },
                        )
                      ),

                      // Gradient overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Glassmorphism effect
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.2),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Category badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      getCategoryName(context,widget.event.category),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Event name
                                  Text(
                                    widget.event.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),

                                  // Event date range
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        dateRange,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Arrow indicator
                      Positioned(
                        top: 16,
                        right: 16,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(_isHovered ? 0.3 : 0.2),
                            shape: BoxShape.circle,
                          ),
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
