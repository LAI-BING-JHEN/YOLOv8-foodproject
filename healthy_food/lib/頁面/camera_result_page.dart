import 'dart:io';
import 'package:flutter/material.dart';
import 'user_info_page.dart';
import 'recommend_page.dart';

class CameraResultPage extends StatelessWidget {
  final File imageFile;
  final Map<String, dynamic> result;

  const CameraResultPage({
    super.key,
    required this.imageFile,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final source = result['source'] ?? 'unknown';

    // YOLO 用
    final foodName = result['food'] ?? 'Unknown Food';

    // ChatGPT / 後端總營養資料
    final List foods = result['foods'] ?? [];

    final totalCalories = result['total_calories'] ?? result['calories'] ?? 0;
    final totalCarbs = result['total_carbs'] ?? result['carbs'] ?? 0;
    final totalProtein = result['total_protein'] ?? result['protein'] ?? 0;
    final totalFat = result['total_fat'] ?? result['fat'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFEBDCFB),
                  Color(0xFFDDEBFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.help_outline,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecommendPage(
                                       recommendation:
                                          result['recommendation'] ?? '目前沒有健康建議',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(
                    imageFile,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source == 'chatgpt' ? 'AI 食物分析' : foodName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Calories',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2F6BFF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$totalCalories kcal',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF2F6BFF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (foods.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        const Text(
                          '辨識到的食物',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ...foods.map((food) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  food['name'].toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${food['calories']} kcal',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF2F6BFF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],

                      if (foods.isEmpty && source == 'chatgpt') ...[
                        const SizedBox(height: 22),
                        const Text(
                          '⚠️ 無法辨識食物',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],

                      const SizedBox(height: 22),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _nutritionRow(' 總熱量', '$totalCalories kcal'),
                            _nutritionRow(' 總碳水', '$totalCarbs g'),
                            _nutritionRow(' 總蛋白質', '$totalProtein g'),
                            _nutritionRow(' 總脂肪', '$totalFat g'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circle(String value, String label, Color color) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 0.75,
            strokeWidth: 8,
            color: color,
            backgroundColor: color.withOpacity(0.18),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nutritionRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}