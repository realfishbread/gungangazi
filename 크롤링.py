from urllib.request import urlopen
from urllib.error import HTTPError
from bs4 import BeautifulSoup

# base URL 설정
base_url = "http://www.snuh.org/health/SelfDgs/Chart/Chart"

# Chart 번호 범위 설정
chart_start = 1
chart_end = 70

for chart_num in range(chart_start, chart_end + 1):
    question_num = 1  # 질문 번호 초기화
    
    # 파일 열기 (각 Chart별로 파일 생성)
    with open(f"Chart_{chart_num}_결과.txt", "w", encoding="utf-8") as file:
        while True:
            # URL 생성 (한 자리와 두 자리 숫자 모두 처리)
            if question_num < 10:
                url = f"{base_url}{chart_num}/Ch{chart_num}_Qt_0{question_num}.do"
            else:
                url = f"{base_url}{chart_num}/Ch{chart_num}_Qt_{question_num}.do"
            
            print(f"크롤링 주소: {url}")
            
            try:
                # URL에 대한 요청 및 응답 받기
                response = urlopen(url)
                soup = BeautifulSoup(response, "html.parser")
                
                # 질문 찾기
                ask_html = soup.find("td", {"class": "Quest_View"})
                if ask_html:
                    ask = ask_html.text.strip()
                    file.write(f"질문: {ask}\n")  # 질문을 파일에 기록
                else:
                    file.write("질문을 찾을 수 없습니다.\n")
                
                # onfocus="blur()" 속성을 가진 모든 <a> 태그 찾기
                anser_html = soup.find_all("a", {"onfocus": "blur()"})
                
                # 답변 출력
                if anser_html:
                    a = 1
                    for ansers in anser_html:
                        anser = ansers.text.strip()  # 각 <a> 태그의 텍스트 추출
                        file.write(f"{a}: {anser}\n")  # 답변을 파일에 기록
                        a += 1
                else:
                    file.write("답변을 찾을 수 없습니다.\n")
                
                file.write("\n" + "="*40 + "\n")  # 각 URL 간 구분선 추가
            
            except HTTPError:
                # URL 요청에 실패하면 현재 Chart의 질문 반복 종료
                print(f"URL {url}에 접근할 수 없습니다. 다음 질문으로 넘어갑니다.\n")
                break  # 질문 번호의 반복 종료
            
            question_num += 1  # 다음 질문 번호로 넘어가기
    
    print(f"Chart {chart_num} 크롤링 완료 및 결과 저장")
