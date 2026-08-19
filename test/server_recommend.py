import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from ultralytics import YOLO
from werkzeug.utils import secure_filename
from PIL import Image
import logging
import traceback
from flask import send_file
import qrcode
from io import BytesIO
import base64
from openai import OpenAI #多加的
import json
#import requests
#啟動ngrok 用cmd ngrok http 5000
#啟動伺服器要先進入test資料夾 cd test 再啟動 python server_recommend.py

# --- 初始化 ---
app = Flask(__name__)
CORS(app)
UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
logging.basicConfig(level=logging.INFO)

# --- 模型與 API Key 設定 ---
model = YOLO('runs/detect/train7/weights/best.pt')

# 🔥 讀取 API KEY
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# ❗ 檢查是否成功讀取
if not OPENAI_API_KEY:
    raise ValueError("❌ 沒有讀到 OPENAI_API_KEY，請確認環境變數")

# 🔥 初始化 client（只用這個）
client = OpenAI(api_key=OPENAI_API_KEY)

# 🔍 Debug（安全顯示前10碼）
print("✅ API KEY OK:", OPENAI_API_KEY[:10])
print("✅ 使用模型: gpt-4o-mini")


# --- 食物營養資料 ---
def get_nutrition(food_name):
    return {
        'rice': {'calories': 130, 'carbs': 28, 'protein': 2, 'fat': 0},#飯
        'eels on rice': {'calories': 600, 'carbs': 28.9, 'protein': 25, 'fat': 18.7},#鰻魚飯
        'pilaf':  {'calories': 300, 'carbs': 74, 'protein': 21, 'fat': 6},#燉飯
        'chicken egg on rice': {'calories': 500, 'carbs': 53, 'protein': 38, 'fat': 13},#雞蛋飯
        'pork cutlet on rice': {'calories': 700, 'carbs': 33, 'protein': 29, 'fat': 26},#豬排飯
        'beef curry': {'calories': 500, 'carbs': 33.8, 'protein': 11.69, 'fat': 12.9},#牛肉咖哩
        'sushi': {'calories': 300, 'carbs': 16, 'protein': 1.6, 'fat': 4.3},#壽司
        'chicken rice': {'calories': 400, 'carbs': 60, 'protein': 14.7, 'fat': 5.3},#雞肉飯
        'fried rice': {'calories': 600, 'carbs': 92.29, 'protein': 18.98, 'fat': 20.07},#炒飯
        'tempura bowl': {'calories': 700, 'carbs': 21.1, 'protein': 12.4, 'fat': 4.6},#天婦羅丼
        'bibimbap': {'calories': 500, 'carbs': 89.78, 'protein': 22.05, 'fat': 13.99},#拌飯
        'toast': {'calories': 80, 'carbs': 20, 'protein': 3, 'fat': 3},#土司
        'croissant': {'calories': 250, 'carbs': 47.1, 'protein': 8.8, 'fat': 26.1}, #可頌
        'roll bread': {'calories': 150, 'carbs': 50.5, 'protein': 7.2, 'fat': 14.9},#餐包
        'raisin bread': {'calories': 150, 'carbs': 52.3, 'protein': 7.9, 'fat': 4.4},#葡萄乾麵包
        'chip butty': {'calories': 500, 'carbs': 39.7, 'protein': 3.6, 'fat': 11},#薯條三明治
        'hamburger': {'calories': 300, 'carbs': 30, 'protein': 25.4, 'fat': 20.9},#漢堡
        'pizza': {'calories': 250, 'carbs': 38.5, 'protein': 14.8, 'fat': 12.8},#披薩
        'sandwiches': {'calories': 300, 'carbs': 35, 'protein': 15, 'fat': 15},#三明治
        'udon noodle': {'calories': 200, 'carbs': 37.8, 'protein': 4.1, 'fat': 1},#烏龍麵
        'tempura udon': {'calories': 400, 'carbs': 74.5, 'protein': 8, 'fat': 16},#天婦羅烏龍麵
        'soba noodle': {'calories': 200, 'carbs': 70.6, 'protein': 12.7, 'fat': 0.5},#蕎麥麵
        'ramen noodle': {'calories': 400, 'carbs': 62.1, 'protein': 9.1, 'fat': 0.8},#拉麵
        'beef noodle': {'calories': 500, 'carbs': 80, 'protein': 40, 'fat': 30},#牛肉麵
        'tensin noodle': {'calories': 500, 'carbs': 87.7, 'protein': 4.2, 'fat': 0.8},#天婦羅麵
        'fried noodle': {'calories': 600, 'carbs': 67, 'protein': 10, 'fat': 36},#炒麵
        'spaghetti': {'calories': 300, 'carbs': 40, 'protein': 10, 'fat': 3},#義大利麵
        'Japanese-style pancake': {'calories': 500, 'carbs': 48, 'protein': 6.3, 'fat': 4.6},#日式煎餅
        'takoyaki': {'calories': 300, 'carbs': 17, 'protein': 5.3, 'fat': 6},# 章魚燒
        'gratin': {'calories': 400, 'carbs': 25.8, 'protein': 7.5, 'fat': 19.9},#焗烤
        'sauteed vegetables': {'calories': 200, 'carbs': 4.8, 'protein': 2.24, 'fat': 2.42},#炒蔬菜
        'croquette': {'calories': 300, 'carbs': 19.8, 'protein': 2.4, 'fat': 9.5},#可樂餅
        'grilled eggplant': {'calories': 100, 'carbs': 9.45, 'protein': 1.05, 'fat': 3.18},#烤茄子
        'sauteed spinach': {'calories': 50, 'carbs': 2.6, 'protein': 1.9, 'fat': 0.3},#炒菠菜
        'vegetable tempura': {'calories': 200, 'carbs': 21.1, 'protein': 12.4, 'fat': 4.6},#蔬菜天婦羅
        'miso soup': {'calories': 50, 'carbs': 3, 'protein': 2, 'fat': 1},#味噌湯
        'potage': {'calories': 150, 'carbs': 74.4, 'protein': 4.4, 'fat': 5.9},#濃湯
        'sausage': {'calories': 150, 'carbs': 32, 'protein': 21, 'fat': 26.3},#香腸
        'oden': {'calories': 200, 'carbs': 32.18, 'protein': 21.92, 'fat': 16.74},#關東煮
        'omelet': {'calories': 200, 'carbs': 1, 'protein': 7, 'fat': 6},#煎蛋
        'ganmodoki': {'calories': 100, 'carbs': 20, 'protein': 15, 'fat': 10},#雜魚豆腐
        'jiaozi': {'calories': 60, 'carbs': 61, 'protein': 23, 'fat': 36},#餃子
        'stew': {'calories': 200, 'carbs': 6.6, 'protein': 3.9, 'fat': 5.4},#燉菜
        'teriyaki grilled fish': {'calories': 300, 'carbs': 5.6, 'protein': 20, 'fat': 11},#照燒魚
        'fried fish': {'calories': 400, 'carbs': 10.12, 'protein': 17.13, 'fat': 8.91},#炸魚
        'grilled salmon': {'calories': 350, 'carbs': 2, 'protein': 23, 'fat': 15},#烤鮭魚
        'salmon meuniere': {'calories': 400, 'carbs': 2, 'protein': 20.2, 'fat': 14.9},#鮭魚法式煎
        'sashimi': {'calories': 200, 'carbs': 2, 'protein': 20.2, 'fat': 14.9},#生魚片
        'grilled pacific saury': {'calories': 350, 'carbs': 4.1, 'protein': 18.8, 'fat': 25.9},#烤秋刀魚
        'sukiyaki': {'calories': 500, 'carbs': 20, 'protein': 30, 'fat': 19},#壽喜燒
        'sweet and sour pork': {'calories': 500, 'carbs': 5.39, 'protein': 18.74, 'fat': 21.62},#糖醋里肌
        'lightly roasted fish': {'calories': 250, 'carbs': 1, 'protein': 28.9, 'fat': 5.6},#輕烤魚
        'steamed egg hotchpotch': {'calories': 200, 'carbs': 1.3, 'protein': 4.5, 'fat': 3.6},#蒸蛋
        'tempura': {'calories': 200, 'carbs': 21.1, 'protein': 12.4, 'fat': 4.6},#天婦羅
        'fried chicken': {'calories': 400, 'carbs': 1.6, 'protein': 31.8, 'fat': 8.9},#炸雞
        'sirloin cutlet': {'calories': 500, 'carbs': 1, 'protein': 20, 'fat': 8},#牛排
        'nanbanzuke': {'calories': 400, 'carbs': 14, 'protein': 24, 'fat': 17},#南蠻漬
        'boiled fish': {'calories': 200, 'carbs': 2.2, 'protein': 19.3, 'fat': 3.3},#煮魚
        'seasoned beef with potatoes': {'calories': 500, 'carbs': 15.8, 'protein': 2.6, 'fat': 0.2},#肉土豆
        'hambarg steak': {'calories': 400, 'carbs': 6.3, 'protein': 14.4, 'fat': 18.5},#漢堡排
        'beef steak': {'calories': 500, 'carbs': 1.5, 'protein': 20.4, 'fat': 10.7},#牛排
        'dried fish': {'calories': 500, 'carbs': 1, 'protein': 69.2, 'fat': 4.4},#乾魚
        'ginger pork saute': {'calories': 400, 'carbs': 54, 'protein': 10.5, 'fat': 10.9},#薑燒豬肉
        'spicy chili-flavored tofu': {'calories': 400, 'carbs': 6.4, 'protein': 8.3, 'fat': 24.6},#麻辣豆腐
        'yakitori': {'calories': 150, 'carbs': 4.2, 'protein': 19.3, 'fat': 5},#烤雞肉串
        'cabbage roll': {'calories': 200, 'carbs': 20, 'protein': 10, 'fat': 15},#捲心菜捲
        'rolled omelet': {'calories': 200, 'carbs': 55.5, 'protein': 2.7, 'fat': 16},#日式捲蛋
        'egg sunny-side up': {'calories': 100, 'carbs': 1, 'protein': 7, 'fat': 7},#太陽蛋
        'fermented soybeans': {'calories': 200, 'carbs': 13, 'protein': 19, 'fat': 11},#納豆
        'cold tofu': {'calories': 100, 'carbs': 4.5, 'protein': 12.9, 'fat': 6.5},#冷豆腐
        'egg roll': {'calories': 200, 'carbs': 55.5, 'protein': 2.7, 'fat': 16},#蛋捲
        'chilled noodle': {'calories': 300, 'carbs': 80.2, 'protein': 14.4, 'fat': 27.5},#涼麵
        'stir-fried beef and peppers': {'calories': 400, 'carbs': 4.32, 'protein': 10.47, 'fat': 1.25},#青椒牛肉
        'simmered pork': {'calories': 400, 'carbs': 1, 'protein': 80, 'fat': 159.4},#紅燒肉
        'boiled chicken and vegetables': {'calories': 300, 'carbs': 0, 'protein': 23.3, 'fat': 2.1},#白斬雞
        'sashimi bowl': {'calories': 400, 'carbs': 69.8, 'protein': 15.7, 'fat': 17.2},#生魚片丼
        'sushi bowl': {'calories': 500, 'carbs': 8, 'protein': 1.6, 'fat': 4.3},#壽司丼
        'fish-shaped pancake with bean jam': {'calories': 200, 'carbs': 43.9, 'protein': 4.7, 'fat': 12.8},#鯛魚燒
        'shrimp with chili sauce': {'calories': 400, 'carbs': 19, 'protein': 69, 'fat': 5},#宮保蝦仁
        'roast chicken': {'calories': 350, 'carbs': 0, 'protein': 21.1, 'fat': 5.6},#烤雞
        'steamed meat dumpling': {'calories': 200, 'carbs': 4.75, 'protein': 2.88, 'fat': 1.9},#蒸肉包
        'omelet with fried rice': {'calories': 600, 'carbs': 17.7, 'protein': 3.69, 'fat': 3.69},#蛋包飯
        'cutlet curry': {'calories': 700, 'carbs': 27.9, 'protein': 13, 'fat': 17.5},#咖哩豬排
        'spaghetti meat sauce': {'calories': 500, 'carbs': 50, 'protein': 28, 'fat': 16},#肉醬義大利麵
        'fried shrimp': {'calories': 300, 'carbs': 11.07, 'protein': 21.39, 'fat': 12.28},#炸蝦
        'potato salad': {'calories': 150, 'carbs': 42, 'protein': 21, 'fat': 12},#馬鈴薯沙拉
        'green salad': {'calories': 50, 'carbs': 6.9, 'protein': 14.8, 'fat': 1.5},#綠色沙拉
        'macaroni salad': {'calories': 200, 'carbs': 70, 'protein': 14.5, 'fat': 1},#通心粉沙拉
        'Japanese tofu and vegetable chowder': {'calories': 150, 'carbs': 8.3, 'protein': 3.3, 'fat': 2.8},#日式豆腐蔬菜湯
        'pork miso soup': {'calories': 200, 'carbs': 11.5, 'protein': 5, 'fat': 5.4},#豬肉味噌湯
        'chinese soup': {'calories': 150, 'carbs': 0, 'protein': 3.7, 'fat': 1.5},#中式湯
        'beef bowl': {'calories': 500, 'carbs': 49.8, 'protein': 15.7, 'fat': 17.2},#牛肉飯
        'kinpira-style sauteed burdock': {'calories': 100, 'carbs': 19.1, 'protein': 2.5, 'fat': 0.4},#金平牛蒡
        'rice ball': {'calories': 200, 'carbs': 37, 'protein': 5, 'fat': 6},#飯糰
        'pizza toast': {'calories': 300, 'carbs': 30.3, 'protein': 21.4, 'fat': 17.5},#披薩土司
        'dipping noodles': {'calories': 300, 'carbs': 80.2, 'protein': 14.4, 'fat': 27.5},#沾麵
        'hot dog': {'calories': 250, 'carbs': 8.2, 'protein': 13.3, 'fat': 20.2},#熱狗
        'french fries': {'calories': 300, 'carbs': 45, 'protein': 4.7, 'fat': 20.9},#薯條
        'mixed rice': {'calories': 400, 'carbs': 22.72, 'protein': 26.11, 'fat': 21.2},#什錦飯
        'goya chanpuru': {'calories': 300, 'carbs': 3.7, 'protein': 1, 'fat': 0.17},#苦瓜炒蛋
    }.get(food_name, {'calories': 0, 'carbs': 0, 'protein': 0, 'fat': 0})

#當偵測不到食物時，會使用LLaVA分析圖片內容，並回傳分析結果（目前只是示範，實際上需要將圖片轉為base64格式並傳給LLaVA）
def analyze_with_chatgpt(image_path):
    try:
        print("🧠 使用 ChatGPT 分析圖片")

        with open(image_path, "rb") as img:
            base64_image = base64.b64encode(img.read()).decode("utf-8")

        print("image size:", len(base64_image))  # debug

        response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": """
Look at this food image carefully.

Identify ALL visible foods in the image.
Do not miss any items, including side dishes, vegetables, sauces, or small portions.

For each food item:
- Give a simple name
- Estimate its calories as an integer

Return ONLY valid JSON in this format:
{
  "foods": [
    {"name": "食材名稱", "calories": 數字}
  ],
  "total_calories": 數字,
  "total_fat": 數字,
  "total_carbs": 數字,
  "total_protein": 數字
}

Rules:
- Use Traditional Chinese for food names
- No explanation
- No extra text
- No markdown
- Do not wrap the answer in ```json
- Ensure the JSON is valid and parsable
"""
                },
                {
                    "type": "image_url",
                    "image_url": {
                        "url": f"data:image/jpeg;base64,{base64_image}"
                    }
                }
            ]
        }
    ],
    timeout=30
)

        text = response.choices[0].message.content
        print("📥 ChatGPT 回傳:", text)

        # 🔥 修 JSON 解析問題
        text = text.strip()

        if text.startswith("```"):
            text = text.replace("```json", "").replace("```", "").strip()

        try:
            data = json.loads(text)
        except:
            return {
                "source": "chatgpt",
                "foods": [],
                "total_calories": 0,
                "total_carbs": 0,
                "total_protein": 0,
                "total_fat": 0,
                "description": text
            }

        return {
            "source": "chatgpt",
            "foods": data.get("foods", []),
            "total_calories": data.get("total_calories", 0),
            "total_carbs": data.get("total_carbs", 0),
            "total_protein": data.get("total_protein", 0),
            "total_fat": data.get("total_fat", 0)
        }

    except Exception as e:
        print("🔥 ChatGPT error:", e)
        return {
            "source": "chatgpt",
            "foods": [],
            "total_calories": 0,
            "total_carbs": 0,
            "total_protein": 0,
            "total_fat": 0,
            "error": str(e)
        }

# --- BMI 計算 ---
def calculate_bmi(weight, height):
    height_m = height / 100
    return round(weight / (height_m ** 2), 2)

# --- 路由：上傳圖片並辨識 ---
#@app.route('/upload', methods=['POST'])
#def upload():
#    if 'image' not in request.files:
#        return jsonify({'error': '未提供圖片'}), 400
#    image_file = request.files['image']
#    if image_file.filename == '':
#        return jsonify({'error': '圖片檔名為空'}), 400
#
#    filename = secure_filename(image_file.filename)
#    image_path = os.path.join(UPLOAD_FOLDER, filename)
#    image_file.save(image_path)
#
#    image = Image.open(image_path)
#    results = model(image)
#    if not results[0].boxes:
#        return jsonify({'message': '未偵測到任何食物'}), 200
#
#   box = results[0].boxes[0]
#    cls = int(box.cls[0])
#    food_name = model.names[cls]
#    nutrition = get_nutrition(food_name)
#
#    return jsonify({
#        'food': food_name,
#        'calories': nutrition['calories'],
#        'carbs': nutrition['carbs'],
#        'protein': nutrition['protein'],
#       'fat': nutrition['fat']
#   })
#debug版本
@app.route('/upload', methods=['POST'])
def upload():
    try:
        print("\n🔥==== 1. 收到 /upload ====")

        if 'image' not in request.files:
            print("❌ 沒有 image")
            return jsonify({'error': '未提供圖片'}), 400

        image_file = request.files['image']
        print("📷 2. 檔案:", image_file.filename)

        if image_file.filename == '':
            print("❌ 空檔名")
            return jsonify({'error': '圖片檔名為空'}), 400

        # 存圖
        filename = secure_filename(image_file.filename)
        image_path = os.path.join(UPLOAD_FOLDER, filename)
        image_file.save(image_path)
        print("💾 3. 已存檔:", image_path)

        # 開圖
        try:
            print("🖼️ 4. 開啟圖片")
            image = Image.open(image_path).convert("RGB")
        except Exception as e:
            print("🔥 Image open error:", e)
            return jsonify({"error": "image read failed"}), 500

        # YOLO
        print("🤖 5. YOLO start")
        try:
            results = model(image)
        except Exception as e:
            print("🔥 YOLO error:", e)
            traceback.print_exc()
            return jsonify({"error": "YOLO crash", "detail": str(e)}), 500

        print("✅ 6. YOLO done")

        # 沒偵測到 → 直接走 LLaVA
        if not results[0].boxes:
            print("⚠️ YOLO 沒偵測到 → 用 ChatGPT")
            response = analyze_with_chatgpt(image_path)
            print("📤 8. response:", response)
            return jsonify(response)

        # 🔥 參數
        CONF_THRESHOLD = 0.8
        SUSPICIOUS_CLASSES = ["hot pot", "stew"]

        best_food = None
        best_conf = 0

        for r in results:
            for box in r.boxes:
                cls_id = int(box.cls[0])
                conf = float(box.conf[0])
                name = model.names[cls_id]

                if conf > best_conf:
                    best_conf = conf
                    best_food = name

        print("🍔 best:", best_food, "conf:", best_conf)

        # 🔥 判斷（最終穩定版）
        if best_food is None:
            print("👉 沒偵測到 → 用 ChatGPT")
            response = analyze_with_chatgpt(image_path)

        elif best_conf < CONF_THRESHOLD:
            print("👉 信心太低 → 用 ChatGPT")
            response = analyze_with_chatgpt(image_path)

        elif best_food in SUSPICIOUS_CLASSES and best_conf < 0.9:
            print("⚠️ 可疑分類且信心不高 → 用 ChatGPT")
            response = analyze_with_chatgpt(image_path)

        else:
            print("✅ 使用 YOLO 結果")
            nutrition = get_nutrition(best_food)

            response = {
                'source': 'yolo',
                'food': best_food,
                'confidence': best_conf,
                'calories': nutrition['calories'],
                'carbs': nutrition['carbs'],
                'protein': nutrition['protein'],
                'fat': nutrition['fat']
            }

        # 🔥 一定要 return（你原本少這行）
        print("📤 8. response:", response)
        return jsonify(response)

    except Exception as e:
        print("\n🔥🔥🔥 FATAL ERROR 🔥🔥🔥")
        print(e)
        traceback.print_exc()

        return jsonify({
            "error": "server crash",
            "detail": str(e)
        }), 500
    
# --- 路由：健康建議 ---
@app.route('/recommend', methods=['POST'])
def recommend():
    data = request.json
    height = data.get("height")
    weight = data.get("weight")
    age = data.get("age")
    gender = data.get("gender")
    food_name = data.get("food_name")
    calories = data.get("calories")

    if any(param is None for param in [height, weight, age, gender, food_name, calories]):
        return jsonify({"error": "缺少必要參數"}), 400

    try:
        weight = float(weight)
        height = float(height)
    except ValueError:
        return jsonify({"error": "體重或身高必須是數字"}), 400

    bmi = calculate_bmi(weight, height)

    if bmi < 18.5:
        advice = "你的體重偏輕，建議多補充蛋白質與健康脂肪，例如加些堅果、酪梨，提升體能與免疫力。"
    elif 18.5 <= bmi < 24:
        advice = "你的體重在正常範圍，維持均衡飲食即可，建議多攝取蔬菜與蛋白質、控制精緻澱粉。"
    elif 24 <= bmi < 27:
        advice = "你已屬於過重範圍，建議減少油炸類、甜食及澱粉攝取，並增加運動量。"
    else:
        advice = "你的 BMI 屬於肥胖，需控制總熱量攝取，選擇清淡、高纖、低油食物，並搭配運動。"

    # 製作建議回應內容
    recommendation = f"""你目前的 BMI 為 {bmi}，攝取的食物為「{food_name}」（{calories} kcal）。
{advice}"""

    return jsonify({"bmi": bmi, "recommendation": recommendation})

# --- 路由：下載 APK ---
@app.route('/download', methods=['GET'])
def download_apk():
    apk_path = os.path.join('uploads', 'apk', 'flutter-apk', 'app-release.apk')  # 根據你的實際路徑調整
    if not os.path.exists(apk_path):
        return jsonify({'error': 'APK 檔案不存在'}), 404
    return send_file(apk_path, as_attachment=True)

#QR code 產生器
@app.route('/qrcode')
def generate_qrcode():
    apk_url = request.host_url.rstrip('/') + '/download'  # 產生完整下載連結
    qr = qrcode.make(apk_url)
    buffer = BytesIO()
    qr.save(buffer, format="PNG")
    buffer.seek(0)
    return send_file(buffer, mimetype='image/png')

# --- 啟動 ---
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
