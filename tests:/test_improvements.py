#!/usr/bin/env python3
"""
개선사항 테스트 스크립트
재시도 로직, 타임아웃, 레이트 리미팅 등을 테스트합니다
"""
import os
import sys
import asyncio
from datetime import datetime

# 프로젝트 루트를 path에 추가
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import (
    cleanup_stale_processes,
    enforce_rate_limit,
    query_claude_with_retry,
    last_api_call_time,
)
from claude_agent_sdk import ClaudeAgentOptions


async def test_process_cleanup():
    """프로세스 정리 함수 테스트"""
    print("=" * 60)
    print("테스트 1: 프로세스 정리")
    print("=" * 60)

    try:
        await cleanup_stale_processes()
        print("✓ 프로세스 정리 함수 정상 작동\n")
        return True
    except Exception as e:
        print(f"✗ 프로세스 정리 실패: {e}\n")
        return False


async def test_rate_limiting():
    """레이트 리미팅 테스트"""
    print("=" * 60)
    print("테스트 2: 레이트 리미팅")
    print("=" * 60)

    try:
        # 첫 번째 호출
        start1 = datetime.now()
        await enforce_rate_limit()
        elapsed1 = (datetime.now() - start1).total_seconds()
        print(f"첫 번째 호출: {elapsed1:.2f}초 대기")

        # 두 번째 호출 (즉시)
        start2 = datetime.now()
        await enforce_rate_limit()
        elapsed2 = (datetime.now() - start2).total_seconds()
        print(f"두 번째 호출: {elapsed2:.2f}초 대기")

        if elapsed2 >= 4.5:  # MIN_CALL_INTERVAL(5) - 약간의 여유
            print("✓ 레이트 리미팅 정상 작동\n")
            return True
        else:
            print(f"! 레이트 리미팅이 예상보다 짧음 (예상: ~5초, 실제: {elapsed2:.2f}초)\n")
            return False

    except Exception as e:
        print(f"✗ 레이트 리미팅 테스트 실패: {e}\n")
        return False


async def test_retry_with_timeout():
    """재시도 및 타임아웃 테스트"""
    print("=" * 60)
    print("테스트 3: 정상 Claude 쿼리 (타임아웃 및 재시도 포함)")
    print("=" * 60)

    try:
        options = ClaudeAgentOptions(
            system_prompt="You are a helpful assistant. Answer in 5 words or less.",
            max_turns=1,
            allowed_tools=[],
        )

        print("Claude에 'test' 메시지 전송 중...")
        start = datetime.now()

        response = await query_claude_with_retry("Say 'test successful'", options)

        elapsed = (datetime.now() - start).total_seconds()

        print(f"응답: {response}")
        print(f"소요 시간: {elapsed:.1f}초")

        if response:
            print("✓ Claude 쿼리 성공\n")
            return True
        else:
            print("✗ 빈 응답 수신\n")
            return False

    except Exception as e:
        print(f"✗ Claude 쿼리 실패: {e}\n")
        return False


async def test_all():
    """모든 테스트 실행"""
    print("\n" + "=" * 60)
    print("Claude Greeter 개선사항 테스트")
    print("=" * 60 + "\n")

    results = []

    # 테스트 1: 프로세스 정리
    results.append(await test_process_cleanup())
    await asyncio.sleep(1)

    # 테스트 2: 레이트 리미팅
    results.append(await test_rate_limiting())
    await asyncio.sleep(1)

    # 테스트 3: Claude 쿼리 (타임아웃 및 재시도)
    print("주의: 테스트 3은 실제 API를 호출하므로 시간이 걸립니다.")
    print("테스트를 건너뛰려면 Ctrl+C를 누르세요.\n")

    try:
        await asyncio.sleep(2)  # 사용자가 취소할 시간 제공
        results.append(await test_retry_with_timeout())
    except KeyboardInterrupt:
        print("\n테스트 3 건너뜀\n")
        results.append(None)

    # 결과 요약
    print("=" * 60)
    print("테스트 결과 요약")
    print("=" * 60)

    test_names = ["프로세스 정리", "레이트 리미팅", "Claude 쿼리"]

    for i, (name, result) in enumerate(zip(test_names, results), 1):
        if result is True:
            status = "✓ 통과"
        elif result is False:
            status = "✗ 실패"
        else:
            status = "- 건너뜀"

        print(f"{i}. {name}: {status}")

    print("=" * 60)

    passed = sum(1 for r in results if r is True)
    total = sum(1 for r in results if r is not None)

    if total > 0:
        print(f"\n{passed}/{total} 테스트 통과")
    else:
        print("\n실행된 테스트 없음")

    return all(r is not False for r in results)


if __name__ == "__main__":
    try:
        result = asyncio.run(test_all())
        sys.exit(0 if result else 1)
    except KeyboardInterrupt:
        print("\n\n테스트 중단됨")
        sys.exit(130)
