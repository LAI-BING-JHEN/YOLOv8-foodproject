from ultralytics import YOLO

def test_model():
    # 加載訓練好的模型
    model = YOLO("runs/detect/train7/weights/best.pt")

    # 測試圖片
    results = model("500.jpg", conf=0.3, save=True)

    # 或測試影片
    # results = model("video.mp4", save=True)

    # 在驗證集上評估 mAP，但不存檔
    metrics = model.val(batch=1, workers=0, save_json=False, save_hybrid=False, save_conf=False)

    # 顯示 mAP 結果
    print(f"mAP50: {metrics.box.map50:.4f}")  # IoU = 0.5 IoU 是預測框與真實框的重疊程度
    print(f"mAP75: {metrics.box.map75:.4f}")  # IoU = 0.75 mAP@50 高就代表你能抓到食物本體，mAP@75 和 mAP@50-95 則顯示模型有沒有把位置抓準、邊界收得好。
    print(f"mAP50-95: {metrics.box.map:.4f}")  # COCO 標準

if __name__ == "__main__":
    from multiprocessing import freeze_support
    freeze_support()
    test_model()