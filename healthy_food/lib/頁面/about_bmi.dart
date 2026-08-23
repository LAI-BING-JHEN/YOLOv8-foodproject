import 'package:flutter/material.dart';

class AboutBmiPage extends StatelessWidget {
  const AboutBmiPage({super.key});

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
          'About BMI',
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
                '關於 BMI｜About BMI',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'images/什麼是bmi-02_0.jpg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '身體質量指數（Body Mass Index，BMI），是透過個人的身高計算出理想的體重區間，其中身高的計算單位為公尺，體重的計算單位為公斤，計算公式說明如下：',
                style: TextStyle(
                  fontSize: 18,
                  height: 1.8,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                '• BMI = 體重(公斤) ÷ 身高(公尺) ÷ 身高(公尺)',
                style: TextStyle(
                  fontSize: 18,
                  height: 1.8,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                '衛生福利部國民健康署建議 BMI 值應介於 18.5～24 之間。'
                '如果 BMI 值小於 18.5 表示體重過輕；若 BMI 值超過 24，需多加注意肥胖與健康風險問題。',
                style: TextStyle(
                  fontSize: 18,
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