"""
Prevent Window 기능 테스트 스크립트
다양한 시나리오로 prevent window 로직을 테스트합니다.
"""
import os
from datetime import datetime, time
from dotenv import load_dotenv

# 환경 변수 로드
load_dotenv()


def is_in_prevent_window_test(check_time: datetime, prevent_start: str, prevent_end: str) -> bool:
    """
    테스트용 prevent window 체크 함수

    Args:
        check_time: 확인할 시간
        prevent_start: 예방 시작 시간 (HH:MM)
        prevent_end: 예방 종료 시간 (HH:MM)

    Returns:
        True if in prevent window, False otherwise
    """
    if not prevent_start or not prevent_end:
        return False

    try:
        current_time = check_time.time()

        # 예방 윈도우 시작 및 종료 시간 파싱
        prevent_start_hour, prevent_start_min = map(int, prevent_start.split(":"))
        prevent_end_hour, prevent_end_min = map(int, prevent_end.split(":"))

        prevent_start_time = time(prevent_start_hour, prevent_start_min)
        prevent_end_time = time(prevent_end_hour, prevent_end_min)

        # 자정을 넘어가는 경우 처리 (예: 23:00 ~ 04:00)
        if prevent_start_time > prevent_end_time:
            # 시작 시간 이후이거나 종료 시간 이전인 경우
            return current_time >= prevent_start_time or current_time < prevent_end_time
        else:
            # 일반적인 경우 (시작 시간과 종료 시간 사이)
            return prevent_start_time <= current_time < prevent_end_time

    except (ValueError, AttributeError) as e:
        print(f"ERROR: Invalid prevent window format: {e}")
        return False


def run_tests():
    """다양한 시나리오로 prevent window 테스트 실행"""
    print("=" * 80)
    print("Prevent Window 기능 테스트")
    print("=" * 80)
    print()

    test_cases = [
        # 테스트 케이스: (시나리오 설명, 체크 시간, 시작 시간, 종료 시간, 예상 결과)
        ("일반 케이스 - 윈도우 내부 (09:00 in 08:00-17:00)",
         datetime.now().replace(hour=9, minute=0), "08:00", "17:00", True),

        ("일반 케이스 - 윈도우 외부 (18:00 not in 08:00-17:00)",
         datetime.now().replace(hour=18, minute=0), "08:00", "17:00", False),

        ("자정 넘김 - 윈도우 내부 (23:30 in 23:00-04:00)",
         datetime.now().replace(hour=23, minute=30), "23:00", "04:00", True),

        ("자정 넘김 - 윈도우 내부 (02:00 in 23:00-04:00)",
         datetime.now().replace(hour=2, minute=0), "23:00", "04:00", True),

        ("자정 넘김 - 윈도우 외부 (05:00 not in 23:00-04:00)",
         datetime.now().replace(hour=5, minute=0), "23:00", "04:00", False),

        ("자정 넘김 - 윈도우 외부 (22:00 not in 23:00-04:00)",
         datetime.now().replace(hour=22, minute=0), "23:00", "04:00", False),

        ("경계값 - 시작 시간 정확히 (23:00 in 23:00-04:00)",
         datetime.now().replace(hour=23, minute=0), "23:00", "04:00", True),

        ("경계값 - 종료 시간 직전 (03:59 in 23:00-04:00)",
         datetime.now().replace(hour=3, minute=59), "23:00", "04:00", True),

        ("경계값 - 종료 시간 정확히 (04:00 not in 23:00-04:00)",
         datetime.now().replace(hour=4, minute=0), "23:00", "04:00", False),

        ("설정 없음 - 윈도우 미설정 (None, None)",
         datetime.now().replace(hour=12, minute=0), None, None, False),
    ]

    passed = 0
    failed = 0

    for scenario, check_time, start, end, expected in test_cases:
        result = is_in_prevent_window_test(check_time, start, end)
        status = "✓ PASS" if result == expected else "✗ FAIL"

        if result == expected:
            passed += 1
        else:
            failed += 1

        window_str = f"{start}-{end}" if start and end else "Not configured"
        print(f"{status} | {scenario}")
        print(f"        시간: {check_time.strftime('%H:%M')}, "
              f"윈도우: {window_str}, "
              f"결과: {result}, 예상: {expected}")
        print()

    print("=" * 80)
    print(f"테스트 결과: {passed} passed, {failed} failed")
    print("=" * 80)

    return failed == 0


if __name__ == "__main__":
    success = run_tests()
    exit(0 if success else 1)
