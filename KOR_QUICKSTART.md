# 빠른 시작 가이드

## 1분 설정

### 1단계: Node.js 설치
**Mac:** `brew install node`  
**Windows:** nodejs.org에서 다운로드

### 2단계: Claude Code CLI 설치
```bash
npm install -g @anthropic-ai/claude-code
```

### 3단계: 프로젝트 설정
```bash
# 가상 환경 생성
python3 -m venv venv

# 활성화 (Mac/Linux)
source venv/bin/activate

# 활성화 (Windows)
venv\Scripts\activate

# 의존성 설치
pip install -r requirements.txt
```

### 4단계: .env 설정
`.env` 파일 수정 (실행 시간 설정):
```env
-- 09:00 설정됐을 경우 09:00, 14:00, 19:00, 00:00 실행 주기
START_TIME=09:00
```

### 5단계: 설정 테스트 (선택 사항)
```bash
python test_setup.py
```

### 6단계: 실행!
```bash
python main.py
```

## 확인

http://localhost:8000 에 방문하세요.

다음과 같이 표시되어야 합니다:
```json
{
  "status": "running",
  "next_scheduled_run": "2025-10-23 14:00:00",
  "interval": "Every 5 hours"
}
```

## 수동 테스트

기다리지 않고 인사말을 트리거합니다:
```bash
curl -X POST http://localhost:8000/greet
```

## 동작 방식

- 서버가 시작됩니다.
- `START_TIME`으로부터 다음 5시간 간격을 계산합니다.
- 5시간마다 자동으로 Claude에게 인사합니다.
- 각 상호 작용을 콘솔에 기록합니다.

## 파일

- `main.py` - 메인 애플리케이션
- `.env` - 설정 파일
- `requirements.txt` - 의존성
- `README.md` - 전체 문서
- `test_setup.py` - 설정 확인
- `QUICKSTART.md` - 이 파일

완료! 🎉
