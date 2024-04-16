import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeWidget extends StatelessWidget {
  final DateTime dateTime;

  const TimeWidget({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat('h:mm a').format(dateTime),
      style: TextStyle(fontSize: 14, color: Colors.grey.shade900),
    );
  }
}
