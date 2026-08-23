import 'package:flutter/material.dart';

class RecommendPage extends StatelessWidget {
  final String recommendation;

  const RecommendPage({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("健康建議"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            recommendation,
            style: const TextStyle(
              fontSize: 18,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}