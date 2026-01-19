import 'package:flutter/material.dart';

class AuthSeparator extends StatelessWidget {
  final String text;

  const AuthSeparator({
    super.key,
    this.text = "OR",
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.withOpacity(0.4),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey.withOpacity(0.4),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
