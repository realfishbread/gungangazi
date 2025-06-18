# 건강하지?! (Gungangazi)

> 감정형 캐릭터 **‘강하지’**를 통해 건강 상태를 시각화하는  
> **Flutter 기반 Web/App 헬스케어 앱**  
> (Spring Boot + AWS 기반 서버 연동)

---

## 🐾 핵심 기능

- 수면/수분/영양제/혈압/생리주기 등 건강 기록
- 건강 상태에 따라 캐릭터 표정/상태 변화
- 개인 맞춤 건강 캘린더 생성
- 실시간 Google OAuth 로그인 (웹 대응)
- JWT 인증 및 토큰 갱신 구조 적용
- 이메일 인증 (Redis)
- AWS EC2 + Nginx + GitHub Actions 기반 CI/CD 구성

---

## 🛠️ 기술 스택

| 구분 | 기술 |
|------|------|
| **Frontend** | Flutter (Web + App), Provider 상태관리, 반응형 UI |
| **Backend** | Spring Boot, JWT, Google OAuth2, Redis, RDB |
| **DevOps** | AWS EC2, Nginx, GitHub Actions, SecureStorage, HttpOnly Cookie |
| **기타** | Flask 기반 Rule-Based AI (현재 보류) |

---

## 🔐 구조 개선 및 리팩토링 요약

| 항목 | 개선 방향 |
|------|------------|
| 인증 로직 | 클라이언트 idToken → 백엔드 Google 검증 + JWT 발급 |
| 토큰 저장 | SharedPreferences → SecureStorage / HttpOnly Cookie |
| 코드 구조 | 기능 섞인 구조 → `auth`, `user`, `health` 디렉토리 분리 |
| 로직 책임 | 혼재 → `service`, `repository`, `viewmodel` 분리 적용 |

---

## 🎨 디자인 요소

- 감정형 캐릭터 **강하지** 직접 제작
- 사용자 상태에 따라 표정/대사/움직임 변화
- 정서적 연결을 통한 지속적 자기관리 유도

---

## 🚧 현재 상태

- ✅ MVP 기능 구현 및 배포 완료
- 🔧 구조 개선 및 리팩토링 단계적 진행 중
- 🎯 기능 테스트 및 UX 고도화 반영 예정

---

## 🧪 AI 기능 (보류)

- Flask 기반 Rule-Based 질병 예측 알고리즘 개발
- 데이터셋 부족으로 현재 비활성화
- 추후 삼성 헬스 연동 계획

---

## 👤 기여자

- 🧑‍💻 Full-stack 개발: [@realfishbread](https://github.com/realfishbread)  
- 🤖 AI 알고리즘: rlaxogml  
- 🎨 캐릭터 디자인: Cyan

---

## 🚧 Known Issues

- 캐릭터 UI 반응 애니메이션 최적화 미흡
- 컴포넌트 유지보수 빈약

---

## 🌐 배포 링크

- 웹 앱 주소: [https://gungangazi.site](https://gungangazi.site)
