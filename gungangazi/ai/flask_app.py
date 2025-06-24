from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
import re
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# 베이즈 정리를 위한 PKL 파일 로드 및 전처리
try:
    # 가중치 데이터 로드 (PKL 파일 사용)
    weights_df = pd.read_pickle('weights.pkl')

    # 증상 데이터 로드 (PKL 파일 사용)
    symptoms_df = pd.read_pickle('data.pkl')  # 'data.pkl'에서 데이터 로드

    # 사전 확률 계산
    total_weight = weights_df['가중치'].sum()
    weights_df['사전확률'] = weights_df['가중치'] / total_weight

    # 사용 가능한 증상 목록
    all_symptoms = symptoms_df.columns.tolist()
    all_symptoms.remove('라벨')  # '라벨' 컬럼 제외

    # 증상 정제 및 임베딩 생성
    unique_symptoms = list(set([re.sub(r'[^\w\s]', '', symptom).strip() for symptom in all_symptoms if symptom.strip()]))
    embedding_model = SentenceTransformer('jhgan/ko-sroberta-multitask')
    symptom_embeddings = embedding_model.encode(unique_symptoms)
except Exception as e:
    print(f"데이터 로드 중 오류가 발생했습니다: {e}")
    exit()

def calculate_likelihood(disease_label, input_symptoms):
    # 특정 질환의 데이터 필터링
    disease_data = symptoms_df[symptoms_df['라벨'] == disease_label]
    total_cases = len(disease_data)

    if total_cases == 0:
        return 0

    symptom_present = False
    log_likelihood = 0  # 로그 우도 초기화

    for symptom in input_symptoms:
        # 증상이 나타난 사례 수 계산
        symptom_present_cases = disease_data[disease_data[symptom] == 1]
        count_symptom_present = len(symptom_present_cases)

        # 증상이 해당 질환에서 나타난 적이 있는지 확인
        if count_symptom_present > 0:
            symptom_present = True

        # 라플라스 스무딩 적용
        # P(증상|질환) = (증상이 나타난 사례 수 + 1) / (전체 사례 수 + 2)
        prob_symptom_given_disease = (count_symptom_present + 1) / (total_cases + 2)

        # 로그 우도에 더하기
        log_likelihood += np.log(prob_symptom_given_disease)

    # 증상이 하나도 나타나지 않으면 우도를 0으로 설정
    if not symptom_present:
        return 0

    # 최종 우도 계산 (로그 스케일에서 원래 스케일로 변환)
    likelihood = np.exp(log_likelihood)
    return likelihood

def calculate_posterior(input_symptoms):
    posterior_probs = {}
    evidence = 0  # P(증상)

    # 모든 질환에 대해 사전확률과 우도 계산
    for index, row in weights_df.iterrows():
        disease_label = row['라벨']
        prior = row['사전확률']
        likelihood = calculate_likelihood(disease_label, input_symptoms)

        # 우도가 0인 경우 제외
        if likelihood == 0:
            continue

        # 사후 확률 계산
        posterior = prior * likelihood
        posterior_probs[disease_label] = posterior
        evidence += posterior  # P(증상)

    # 계산에 포함된 질환이 없을 경우 예외 처리
    if evidence == 0:
        return {}

    # 사후 확률로 정규화
    for disease in posterior_probs:
        posterior_probs[disease] /= evidence

    return posterior_probs

# similar_symptoms 엔드포인트
@app.route('/similar_symptoms', methods=['POST'])
def get_similar_symptoms():
    data = request.json
    input_symptoms = data.get('symptoms', [])
    try:
        similar = find_similar_symptoms(input_symptoms)
        return jsonify(similar), 200  # 증상 이름 리스트만 반환
    except ValueError as ve:
        return jsonify({"error": str(ve)}), 400

# predict_disease 엔드포인트
@app.route('/predict_disease', methods=['POST'])
def predict_disease():
    data = request.get_json()
    input_symptoms = data.get('symptoms', [])
    try:
        # 입력된 증상 정제 및 검증
        input_symptoms = [re.sub(r'[^\w\s]', '', symptom).strip() for symptom in input_symptoms if symptom.strip()]
        for symptom in input_symptoms:
            if symptom not in all_symptoms:
                return jsonify({"error": f"입력하신 증상 '{symptom}'은 데이터에 존재하지 않습니다."}), 400

        # 사후 확률 계산
        posterior_probs = calculate_posterior(input_symptoms)

        if not posterior_probs:
            return jsonify({"predictions": []}), 200

        # 확률이 높은 순으로 정렬
        sorted_probs = sorted(posterior_probs.items(), key=lambda x: x[1], reverse=True)

        # 결과 구성 (최대 3개, 최고 확률에서 10% 이하 차이)
        top_diseases = []
        highest_probability = sorted_probs[0][1]
        threshold = highest_probability - 0.1  # 10% 차이 기준

        for disease, probability in sorted_probs:
            if probability >= threshold:
                top_diseases.append({"disease": disease, "probability": probability})
            else:
                break

            if len(top_diseases) == 3:
                break

        return jsonify({"predictions": top_diseases}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


# 필요한 함수 정의 (similar_symptoms 관련)
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

if __name__ == '__main__':
    app.run(debug=True)
