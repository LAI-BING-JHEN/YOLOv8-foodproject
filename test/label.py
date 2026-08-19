import os
import torch
from PIL import Image
from ultralytics import YOLO

# 加载预训练的YOLOv8模型
model = YOLO('yolov8s.pt')

def detect_and_label(image_path, label_path):
    image = Image.open(image_path)
    results = model(image)

    # 获取图像尺寸
    img_width, img_height = image.size

    # 处理检测结果
    labels = []
    for result in results[0].boxes:
        x_min, y_min, x_max, y_max = result.xyxy[0]
        conf = result.conf[0]
        cls = result.cls[0]
        x_center = (x_min + x_max) / 2 / img_width
        y_center = (y_min + y_max) / 2 / img_height
        width = (x_max - x_min) / img_width
        height = (y_max - y_min) / img_height
        labels.append(f"{int(cls)} {x_center} {y_center} {width} {height}\n")

    # 保存标签文件
    with open(label_path, "w") as f:
        f.writelines(labels)

def process_directory(image_folder, label_folder):
    for root, _, files in os.walk(image_folder):
        for image_file in files:
            if image_file.endswith(".jpg"):
                image_path = os.path.join(root, image_file)
                relative_path = os.path.relpath(root, image_folder)
                label_subfolder = os.path.join(label_folder, relative_path)
                os.makedirs(label_subfolder, exist_ok=True)
                label_path = os.path.join(label_subfolder, image_file.replace(".jpg", ".txt"))
                detect_and_label(image_path, label_path)

def main():
    train_image_folder = "images/train"
    val_image_folder = "images/val"
    train_label_folder = "labels/train"
    val_label_folder = "labels/val"

    print("🔄 正在处理训练集图片...")
    process_directory(train_image_folder, train_label_folder)

    print("🔄 正在处理验证集图片...")
    process_directory(val_image_folder, val_label_folder)

    print("✅ 自动标记完成！")

if __name__ == "__main__":
    main()