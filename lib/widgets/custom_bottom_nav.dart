import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class CustomBottomNav extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onCenterButtonPressed;
  final int notifications;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onCenterButtonPressed, required this.notifications,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );

    _fabRotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Main navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.surfaceColor.withOpacity(0.9),
                        AppTheme.cardColor.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home_rounded, 0),
                      _buildNavItem(Icons.search_rounded, 1),
                      const SizedBox(width: 70), // Space for FAB
                      _buildNavItem(Icons.notifications_rounded, 2,showBadge: true,badgeCount: widget.notifications),
                      _buildNavItem(Icons.person_rounded, 3),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating action button (center)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 40,
            top: 0,
            child: AnimatedBuilder(
              animation: _fabController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabScaleAnimation.value,
                  child: Transform.rotate(
                    angle: _fabRotationAnimation.value,
                    child: GestureDetector(
                      onTapDown: (_) => _fabController.forward(),
                      onTapUp: (_) {
                        _fabController.reverse();
                        widget.onCenterButtonPressed();
                      },
                      onTapCancel: () => _fabController.reverse(),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.qr_code_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNavItem(
  IconData icon,
  int index, {
  bool showBadge = false,
  int badgeCount = 0,
}) {
  final isSelected = widget.selectedIndex == index;

  return GestureDetector(
    onTap: () => widget.onItemSelected(index),
    child: TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          padding: EdgeInsets.all(12 + (value * 4)),
          decoration: BoxDecoration(
            gradient: isSelected
                ? RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.3 * value),
                      Colors.transparent,
                    ],
                  )
                : null,
            shape: BoxShape.circle,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Animated background circle
              if (isSelected)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                ),

              // Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : const Color.fromARGB(255, 35, 109, 149).withOpacity(0.5),
                  size: 24 + (value * 4),
                ),
              ),

              // Badge
              if (showBadge && badgeCount > 0)
                Positioned(
                  top: -15,
                  right: -10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}

}