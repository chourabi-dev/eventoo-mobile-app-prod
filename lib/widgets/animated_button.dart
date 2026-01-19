import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Gradient gradient;
  final IconData? icon;
  final Color? textColor; 
  final double height;
  final double width;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.gradient,
    this.icon,
    this.height = 60,
    this.width = double.infinity, this.textColor,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playPressAnimation() {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _releasePressAnimation() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _playPressAnimation(),
      onPointerUp: (_) => _releasePressAnimation(),
      onPointerCancel: (_) => _releasePressAnimation(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(20),
                /*boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isPressed ? 0.3 : 0.5),
                    blurRadius: _isPressed ? 8 : 20,
                    offset: Offset(0, _isPressed ? 2 : 8),
                  ),
                ],*/
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.05),
                  onTap: widget.onPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: widget.textColor == null ? Colors.white : widget.textColor, size: 24),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          widget.text,
                          style:  TextStyle(
                            color: widget.textColor == null ? Colors.white : widget.textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
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
