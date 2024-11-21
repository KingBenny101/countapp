import 'package:flutter/material.dart';
  
Widget buildStepCard(String step) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          step,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }