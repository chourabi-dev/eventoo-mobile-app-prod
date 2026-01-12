import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'dart:math' as math;

import 'package:mobile/models/event.dart';


class PremiumEventSlider extends StatefulWidget {
  final List<Event> events;
  final Function(String eventId) onContinue;

  const PremiumEventSlider({
    super.key,
    required this.events,
    required this.onContinue,
  });

  @override
  State<PremiumEventSlider> createState() => _PremiumEventSliderState();
}

class _PremiumEventSliderState extends State<PremiumEventSlider> {
  late PageController _pageController;
  double _currentPage = 0.0;
  int _selectedIndex = 0;
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85, // Show partial views of adjacent pages
    );
    _pageController.addListener(_onPageScroll);
 
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  /// Listen to page scroll and update the current page value for animations
  void _onPageScroll() {
    setState(() {
      _currentPage = _pageController.page ?? 0.0;
      _selectedIndex = _currentPage.round();
    });
  }

  /// Handle Continue button press
  void _handleContinue() {
    if (widget.events.isNotEmpty) {
      widget.onContinue(widget.events[_selectedIndex].id.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    if (widget.events.isEmpty) {
      return  Center(
        child: Icon(Icons.note_sharp)
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: Column(
        children: [
          // Spacer for visual breathing room
          const SizedBox(height: 40),

          // Main carousel slider
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.events.length,
              itemBuilder: (context, index) {
                return _buildEventCard(index);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Animated page indicators
          _buildPageIndicators(),

          const SizedBox(height: 32),

          // Continue button
          _buildContinueButton(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Build individual event card with parallax and scale animations
  Widget _buildEventCard(int index) {
    // Calculate the difference between current page and this card's index
    final difference = (_currentPage - index).abs();
    
    // Scale factor: active card is larger, others are smaller
    final scale = 1.0 - (difference * 0.2).clamp(0.0, 0.3);
    
    // Opacity factor: fade out cards that are far from center
    final opacity = (1.0 - (difference * 0.3)).clamp(0.5, 1.0);
    
    // Vertical offset for depth effect
    final verticalOffset = difference * 20;

    final event = widget.events[index];

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, verticalOffset),
        child: Transform.scale(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: _buildCardContent(event, difference < 0.5),
          ),
        ),
      ),
    );
  }

  /// Build the card content with logo, title, and premium styling
  Widget _buildCardContent(Event event, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? Colors.black.withOpacity(0.15)
                : Colors.black.withOpacity(0.08),
            blurRadius: isActive ? 30 : 15,
            offset: const Offset(0, 10),
            spreadRadius: isActive ? 2 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Event Logo with animated container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: isActive ? 180 : 160,
              height: isActive ? 180 : 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade100.withOpacity(0.3),
                    Colors.purple.shade100.withOpacity(0.3),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: event.logoURL.startsWith('http')
                          ? Image.network(
                              event.logoURL,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderLogo(event.name);
                              },
                            )
                          : Image.asset(
                              "assets/white-logo.png",
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderLogo(event.name);
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Event Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isActive ? 26 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
                child: Text(
                  event.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  /// Placeholder logo when image fails to load
  Widget _buildPlaceholderLogo(String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.purple.shade400,
          ],
        ),
      ),
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : 'E',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Build animated page indicators
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.events.length,
        (index) => _buildIndicator(index),
      ),
    );
  }

  /// Build individual animated indicator dot
  Widget _buildIndicator(int index) {
    final isActive = index == _selectedIndex;
    
    // Calculate smooth animation based on page scroll
    final difference = (_currentPage - index).abs();
    final scale = isActive ? 1.0 : 0.5 + (1.0 - difference.clamp(0.0, 1.0)) * 0.3;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: isActive ? 32 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: isActive
            ? LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.purple.shade400,
                ],
              )
            : null,
        color: isActive ? null : Colors.grey.shade300,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Transform.scale(
        scale: scale,
        child: Container(),
      ),
    );
  }

  /// Build premium gradient continue button with press animation
  Widget _buildContinueButton() {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isButtonPressed = true),
        onTapUp: (_) {
          setState(() => _isButtonPressed = false);
          _handleContinue();
        },
        onTapCancel: () => setState(() => _isButtonPressed = false),
        child: AnimatedScale(
          scale: _isButtonPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isButtonPressed
                    ? [
                        Colors.blue.shade600,
                        Colors.purple.shade600,
                      ]
                    : [
                        Colors.blue.shade500,
                        Colors.purple.shade500,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(_isButtonPressed ? 0.3 : 0.4),
                  blurRadius: _isButtonPressed ? 15 : 20,
                  offset: Offset(0, _isButtonPressed ? 4 : 8),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.continueLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isButtonPressed ? 0.1 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 24,
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

