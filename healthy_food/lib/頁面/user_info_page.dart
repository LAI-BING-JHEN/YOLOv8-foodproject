import 'dart:io';
import 'package:flutter/material.dart';
import '../services/yolo_api_service.dart';
import 'camera_result_page.dart';
import 'package:healthy_food/services/image_utils.dart';

class UserInfoPage extends StatefulWidget {
  final File imageFile;

  const UserInfoPage({
    super.key,
    required this.imageFile,
  });

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();

  String gender = 'male';
  bool isLoading = false;

  Future<void> submitData() async {
    if (heightController.text.isEmpty ||
        weightController.text.isEmpty ||
        ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入完整身高、體重、年齡')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print(" 原圖: ${await widget.imageFile.length()}");

      final compressedFile = await compressImage(widget.imageFile);

      print(" 壓縮後: ${await compressedFile.length()}");

      final uploadResult = await ApiService.uploadImage(compressedFile);

      print(" uploadResult: $uploadResult");

      final List foods = uploadResult['foods'] ?? [];

      final foodName = uploadResult['food'] ??
          (foods.isNotEmpty
              ? foods.map((f) => f['name'].toString()).join('、')
              : 'AI食物分析');

      final calories =
          uploadResult['calories'] ?? uploadResult['total_calories'] ?? 0;

      final recommendResult = await ApiService.getRecommend(
        height: double.parse(heightController.text),
        weight: double.parse(weightController.text),
        age: int.parse(ageController.text),
        gender: gender,
        foodName: foodName,
        calories: calories,
      );

      print(" recommendResult: $recommendResult");

      final result = {
        ...uploadResult,
        ...recommendResult,
      };

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CameraResultPage(
            imageFile: widget.imageFile,
            result: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      print(" ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分析失敗：$e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF6F0DC),
          appBar: AppBar(
            title: const Text('輸入個人資料'),
            backgroundColor: const Color(0xFFF6F0DC),
            foregroundColor: Colors.black87,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(
                    widget.imageFile,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 24),

                _buildInputField(
                  controller: heightController,
                  label: '身高（cm）',
                  hint: '例如：170',
                ),

                const SizedBox(height: 16),

                _buildInputField(
                  controller: weightController,
                  label: '體重（kg）',
                  hint: '例如：60',
                ),

                const SizedBox(height: 16),

                _buildInputField(
                  controller: ageController,
                  label: '年齡',
                  hint: '例如：22',
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: gender,
                  decoration: _inputDecoration('性別'),
                  items: const [
                    DropdownMenuItem(
                      value: 'male',
                      child: Text('男'),
                    ),
                    DropdownMenuItem(
                      value: 'female',
                      child: Text('女'),
                    ),
                  ],
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              gender = value;
                            });
                          }
                        },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F6BFF),
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      isLoading ? '分析中...' : '開始分析',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.35),
            child: Center(
              child: Container(
                width: 180,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 18),
                    Text(
                      'AI 分析中...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '請稍候',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      enabled: !isLoading,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(label).copyWith(
        hintText: hint,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}