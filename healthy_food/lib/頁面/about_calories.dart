import 'package:flutter/material.dart';

class AboutCaloriesPage extends StatelessWidget {
  const AboutCaloriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE7CF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFE7CF),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'About Calories',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F5F0),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '關於卡路里｜ About Calories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'images/calories_info.jpg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '卡路里',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                '• 食物給我們的身體提供能量去支持身體\n'
                '  的基本機能和體力活動。而這個能量，\n'
                '  用單位「卡路里」來衡量。\n'
                '• 能量攝入小於消耗，體重就會下降，也就\n'
                '  是達到「負的」能量平衡。\n'
                '• 攝入大於消耗，多餘的卡路里會轉成脂\n'
                '  肪儲存在身體，這也就是「正的」能量\n'
                '  平衡。',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}