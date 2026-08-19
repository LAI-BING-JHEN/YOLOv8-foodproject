import os
from ultralytics import YOLO
#train10以後開始訓練
def train_test():
    model = YOLO('yolov8m.pt')  # 使用中等版本 YOLOv8 模型，提升辨識能力

    data_yaml = r'c:/Users/USER/Desktop/測試/data.yaml'

    try:
        model.train(
            data=data_yaml,
            epochs=300,                 # 訓練 300 輪，提高學習機會
            batch=8,                    # 批次大小，可依據顯示卡 VRAM 調整
            imgsz=1280,                 # 提高圖片解析度，有助提升精度
            lr0=0.0015,                 # 初始學習率
            lrf=0.0001,                 # 最終學習率（線性遞減）
            optimizer='AdamW',          # AdamW 效果優於 SGD
            weight_decay=0.0005,        # 權重衰減（避免過擬合）
            warmup_epochs=5,            # 前幾輪先小步快跑
            patience=20,                # 若 20 輪無進步則停止

            # 資料增強參數（有助提升泛化能力）
            mosaic=0.7,                 
            mixup=0.3,
            degrees=30,
            scale=0.5,
            hsv_h=0.015,
            hsv_s=0.7,
            hsv_v=0.4,
            fliplr=0.5,
            flipud=0.2,

            # 加速與優化
            amp=True,                   # 混合精度訓練
            cache='disk',              # 快取圖片到磁碟
            cos_lr=True                # 使用 Cosine learning rate
        )

        # 驗證階段（測試準確度）
        model.val(imgsz=1280, augment=True)

    except Exception as e:
        print(f"訓練過程中發生錯誤: {e}")

if __name__ == "__main__":
    train_test()
