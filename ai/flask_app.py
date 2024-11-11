from flask import Flask, request, jsonify
from flask_cors import CORS
from sentence_transformers import SentenceTransformer
import pickle
import re
from sklearn.metrics.pairwise import cosine_similarity

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# 모델과 증상 목록 로드
with open('model.pkl', 'rb') as f:
    model = pickle.load(f)

with open('symptoms.pkl', 'rb') as f:
    all_symptoms = pickle.load(f)

# 증상 정제 및 임베딩 생성 (유사 증상 검색을 위해 필요)
unique_symptoms = list(set([re.sub(r'[^\w\s]', '', symptom).strip() for symptom in all_symptoms if symptom.strip()]))
embedding_model = SentenceTransformer('jhgan/ko-sroberta-multitask')
symptom_embeddings = embedding_model.encode(unique_symptoms)

def find_similar_symptoms(input_symptoms, top_k=5):
    input_symptoms = [re.sub(r'[^\w\s]', '', symptom).strip() for symptom in input_symptoms if symptom.strip()]
    input_embeddings = embedding_model.encode(input_symptoms)
    similarities = cosine_similarity(input_embeddings, symptom_embeddings)
    average_similarities = similarities.mean(axis=0)

    # 유사도가 1인 항목이 있는지 확인
    exact_matches = [unique_symptoms[idx] for idx, score in enumerate(average_similarities) if score == 1.0]
    if exact_matches:
        return exact_matches  # 유사도가 1인 증상만 반환

    # 유사도가 1인 항목이 없으면 상위 top_k개 반환
    top_k_idx = average_similarities.argsort()[-top_k:][::-1]
    similar_symptoms = [unique_symptoms[idx] for idx in top_k_idx]
    return similar_symptoms

def symptoms_to_features(symptoms):
    feature_vector = [1 if symptom in symptoms else 0 for symptom in all_symptoms]
    return feature_vector

@app.route('/similar_symptoms', methods=['POST'])
def get_similar_symptoms():
    data = request.json
    input_symptoms = data.get('symptoms', [])
    try:
        similar = find_similar_symptoms(input_symptoms)
        return jsonify(similar), 200  # 증상 이름 리스트만 반환
    except ValueError as ve:
        return jsonify({"error": str(ve)}), 400

@app.route('/predict_disease', methods=['POST'])
def predict_disease():
    data = request.get_json()
    input_symptoms = data.get('symptoms', [])
    try:
        # 입력 증상을 정제하고 모델 입력 형식으로 변환
        input_symptoms = [re.sub(r'[^\w\s]', '', symptom).strip() for symptom in input_symptoms if symptom.strip()]
        X_input = symptoms_to_features(input_symptoms)

        # 예측 수행 (확률과 함께)
        probabilities = model.predict_proba([X_input])[0]
        diseases = model.classes_

        # 확률 높은 순으로 정렬
        sorted_indices = probabilities.argsort()[::-1]
        highest_probability = probabilities[sorted_indices[0]]
        top_diseases = []

        # 조건에 따라 결과 필터링 및 추가
        for i in range(len(diseases)):
            idx = sorted_indices[i]
            probability = probabilities[idx]
            disease = diseases[idx]
            
            # 최소 확률 10% 조건
            if probability < 0.1:
                break

            # 확률 차이가 10% 미만이거나 가장 높은 확률이 10% 미만일 경우
            if probability >= highest_probability * 0.9 or highest_probability < 0.1:
                top_diseases.append({"disease": disease, "probability": probability})
            else:
                break  # 확률 차이가 10% 이상이면 종료

            # 최대 3개까지만 결과 추가
            if len(top_diseases) == 3:
                break

        # 만약 가장 높은 확률이 10% 미만이라면 하나의 결과만 포함
        if highest_probability < 0.1:
            top_diseases = [top_diseases[0]]

        # 결과 반환
        return jsonify({"predictions": top_diseases}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True)
