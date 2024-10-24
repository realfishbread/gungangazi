from flask import Flask, request, jsonify
import pandas as pd

# Flask 애플리케이션 초기화
app = Flask(__name__)

# CSV 파일을 불러옴 (서버가 실행될 때 데이터 로드)
df = pd.read_csv(r'C:\Users\gkimt\Downloads\main_ver2.csv')

# 오차 범위 계산 함수
def calculate_error_margin(num_symptoms):
    min_margin = 5
    max_margin = 20

    if num_symptoms >= 10:
        return min_margin
    elif num_symptoms <= 2:
        return max_margin
    else:
        # 선형적으로 오차 범위 감소
        margin = max_margin - ((num_symptoms - 2) * (max_margin - min_margin) / 8)
        return margin

# 증상을 입력받아 해당 질환을 찾는 함수
def find_diseases(symptoms, df):
    # 입력된 증상 중 실제로 데이터에 있는 증상 열만 선택
    valid_symptoms = [symptom for symptom in symptoms if symptom in df.columns]

    if not valid_symptoms:
        return "입력한 증상과 일치하는 열이 없습니다."

    # 해당 증상이 있는 질환만 필터링
    matching_diseases = df[df[valid_symptoms].sum(axis=1) > 0]

    if matching_diseases.empty:
        return "해당 증상과 연관된 질환이 없습니다."

    # '라벨' 열을 제외한 증상 열 이름들
    symptom_columns = df.columns.drop('라벨')

    # 각 질환별 전체 증상 수 계산 (증상 값이 1인 것의 합)
    total_disease_symptoms = matching_diseases[symptom_columns].sum(axis=1)

    # 입력한 증상 중 각 질환과 매칭된 증상 수 계산
    matched_symptom_counts = matching_diseases[valid_symptoms].sum(axis=1)

    # 입력한 총 증상 수
    total_input_symptoms = len(valid_symptoms)

    # 비율 계산
    ratio_input = matched_symptom_counts / total_input_symptoms  # 입력한 증상 대비 매칭 비율
    ratio_disease = matched_symptom_counts / total_disease_symptoms  # 질환의 증상 대비 매칭 비율

    # Division by zero 방지
    ratio_disease = ratio_disease.fillna(0)

    # 두 비율의 평균을 계산하여 최종 확률로 사용
    combined_ratio = (ratio_input + ratio_disease) / 2 * 100  # 퍼센트로 변환

    # 확률을 기준으로 내림차순 정렬
    probable_diseases = combined_ratio.sort_values(ascending=False)

    # 입력한 증상의 수에 따른 오차 범위 계산
    num_symptoms = len(valid_symptoms)
    error_margin = calculate_error_margin(num_symptoms)

    # 가장 높은 확률 값
    max_prob = probable_diseases.iloc[0]

    # 동적 오차 범위를 적용하여 질환 선택
    threshold = max_prob - error_margin
    similar_diseases = probable_diseases[probable_diseases >= threshold]

    # 최대 3개까지만 선택
    final_diseases = similar_diseases.head(3)

    # 결과 데이터프레임 생성
    result_df = df.loc[final_diseases.index, '라벨'].to_frame()
    result_df['확률'] = final_diseases.values

    return result_df


@app.route('/predict', methods=['POST'])
def predict():
    try:
        # 클라이언트로부터 증상 데이터를 JSON 형식으로 받음
        symptoms = request.json.get('symptoms', [])

        if not symptoms:
            return jsonify({"error": "증상이 입력되지 않았습니다."}), 400

        # AI 모델을 호출하여 결과를 계산
        result_df = find_diseases(symptoms, df)

        if isinstance(result_df, str):
            return jsonify({"error": result_df}), 404

        # 결과를 JSON 형태로 반환
        result = {
            "diseases": result_df['라벨'].tolist(),
            "probabilities": result_df['확률'].tolist()
        }

        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Flask 애플리케이션 실행
if __name__ == '__main__':
    app.run(debug=True)