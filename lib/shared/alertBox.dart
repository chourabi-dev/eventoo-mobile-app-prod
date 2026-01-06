import 'package:flutter/material.dart';

class AlertBox extends StatelessWidget {
  final String text;
  final String type;
  const AlertBox({super.key, required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: type == 'danger' ?  Colors.red[100] :  Colors.green[100] , // light red background
        border: Border.all(color: type == 'danger' ?  Colors.red :  Colors.green ), // red border
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color:  type == 'danger' ?  Colors.red :  Colors.green ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color:  type == 'danger' ?  Colors.red[800]  :  Colors.green[800] ,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}