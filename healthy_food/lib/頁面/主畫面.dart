import 'package:flutter/material.dart';
import 'about_bmi.dart';
import 'about_calories.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'camera_result_page.dart';
import '../services/yolo_api_service.dart';
import 'user_info_page.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

   class _OnboardingState extends State<Onboarding> {

  int selectedIndex = 0;

  final List<String> foodImages = [
    'images/health_food.jpg',
    'images/health_food2.jpg',
    'images/health_food3.jpg',
    'images/health_food4.jpg',
    'images/health_food5.jpg',
    'images/health_food6.jpg',
    'images/health_food7.jpg',
    'images/health_food8.jpg',
    'images/health_food9.jpg',
    'images/health_food10.jpg',
  ];

  File? cameraImage;
final ImagePicker picker = ImagePicker();

Future<void> openCamera() async {
  final XFile? image = await picker.pickImage(
    source: ImageSource.camera,
  );

  if (image == null) return;

  final imageFile = File(image.path);

  if (!mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserInfoPage(
        imageFile: imageFile,
      ),
    ),
  );
} 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0DC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===== 最上方區域 =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
  const Icon(Icons.menu, color: Colors.black87),

  IconButton(
    icon: const Icon(
      Icons.camera_alt_outlined,
      color: Colors.black87,
    ),
    onPressed: openCamera,
  ),
],
                ),
              ),

              // ===== Logo =====
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF4E4B6),
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'images/品牌.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // ===== 第一區 BMI =====
              _buildSectionTitle(
                titleZh: '計算 BMI',
                titleEn: 'Calculate BMI',
                onIconTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutBmiPage(),
      ),
    );
  },
              ),
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'images/bmi.jpg',
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '成人體重分級標準 [臺灣衛福部]',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '• 體重過輕： BMI < 18.5\n'
                      '• 正常範圍： 18.5 ≤ BMI < 24\n'
                      '• 過重： 24 ≤ BMI < 27\n'
                      '• 肥胖： 27 ≤ BMI < 30',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ===== 第二區 熱量估算 =====
              _buildSectionTitle(
                titleZh: '估算卡路里',
                titleEn: 'Calculate Calories',
                onIconTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutCaloriesPage(),
      ),
    );
  },

              ),
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'images/calories.jpg',
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '食物卡路里估算（王大智營養師）',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '• 飯大約含有：1克 = 4大卡\n'
                      '• 蛋白質：1克 = 4大卡\n'
                      '• 脂肪：1克 = 9大卡',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ===== 第三區 健康飲食 =====
             _buildSectionCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Image.asset(
    foodImages[selectedIndex],
    width: double.infinity,
    fit: BoxFit.cover,
  ),
),
      const SizedBox(height: 12),

     SizedBox(
  height: 120,
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: foodImages.length,
    separatorBuilder: (context, index) => const SizedBox(width: 10),
    itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedIndex == index
    ? const Color(0xFF66AB54)
    : Colors.transparent,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              foodImages[index],
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    },
  ),
),
    ],
  ),
),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required String titleZh,
    required String titleEn,
    VoidCallback? onIconTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$titleZh  |  $titleEn',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              InkWell(
              onTap: onIconTap,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.help_outline,
                  size: 20,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
          const SizedBox(height: 8),
          const Divider(
            thickness: 1,
            color: Colors.black38,
            height: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0DC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}