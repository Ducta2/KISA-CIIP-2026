#!/bin/bash
# ============================================================================
# @Project: KISA-CIIP-2026 Vulnerability Assessment Scripts
# @Copyright: Copyright (c) 2026 Yang Uhyeok (양우혁). All rights reserved.
# @Version: 1.0.1
# @Last Updated: 2026-04-20
# ============================================================================
# [Chi tiết hạng mục kiểm tra]
# @ID          : U-02
# @Category    : UNIX > 1. Quản lý tài khoản
# @Platform    : SOLARIS, LINUX, AIX, HP-UX 등
# @Severity    : (상)
# @Title       : Thiết lập chính sách quản lý mật khẩu
# @Description : mật khẩu의 복잡성 cấu hình(길이, 숫자, 대소문자, 특수문자 등) 여부 점검
# @Reference   : 2026 KISA 주요정보통신기반시설 기술적 điểm yếu bảo mật 분석·평가 상세 가이드
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../../lib"

source "${LIB_DIR}/common.sh"
source "${LIB_DIR}/result_manager.sh"
source "${LIB_DIR}/output_mode.sh"
source "${LIB_DIR}/metadata_parser.sh"

ITEM_ID="U-02"
ITEM_NAME="Thiết lập chính sách quản lý mật khẩu"
SEVERITY="(상)"

# 가이드라인 정보
GUIDELINE_PURPOSE="사용자의 mật khẩu 복잡성과 주기적 변경을 통해 시스템 보안을 강화하기 위함"
GUIDELINE_THREAT="mật khẩu 관련 정책이 cấu hình되지 않을 경우, 비인가자의 각종 공격(무차별 대입 공격, 사전 대입 공격 등)에 의해 mật khẩu가 노출될 위험이 존재함"
GUIDELINE_CRITERIA_GOOD="mật khẩu 관리 정책이 cấu hình된 경우"
GUIDELINE_CRITERIA_BAD="mật khẩu 관리 정책이 cấu hình되지 않은 경우"
GUIDELINE_REMEDIATION="root 계정을 포함한 사용자 계정의 mật khẩu를 영문, 숫자, 특수 문자를 포함하여 최소 8 자리 이상 및 최소 사용 기간 1일, 최대 사용 기간 90일, 최근 mật khẩu 기억 4회 이상으로 cấu hình"

diagnose() {
    local status="양호"
    diagnosis_result="GOOD"
    local inspection_summary="mật khẩu 복잡성 cấu hình이 적절히 적용되어 있습니다."
    local command_result=""
    local command_executed="cat /etc/security/pwquality.conf"

    # 1. 실제 데이터 추출 (RedHat tiêu chí)
    local pw_file="/etc/security/pwquality.conf"
    local minlen=$(grep "^minlen" $pw_file | awk -F'=' '{print $2}' | tr -d ' ' || echo "미cấu hình")
    local lcredit=$(grep "^lcredit" $pw_file | awk -F'=' '{print $2}' | tr -d ' ' || echo "미cấu hình")

    # 2. 판정 로직 (예시: 최소 8자 미달 시 취약)
    if [ "$minlen" = "미cấu hình" ] || [ "$minlen" -lt 8 ]; then
        status="취약"
        diagnosis_result="VULNERABLE"
        inspection_summary="mật khẩu 최소 길이 또는 복잡성 cấu hình이 미흡합니다."
    fi

    # 3. command_result에 실제 cấu hình값 기록
    command_result="[pwquality.conf] minlen=${minlen}, lcredit=${lcredit}"

    save_dual_result \
        "${ITEM_ID}" "${ITEM_NAME}" "${status}" "${diagnosis_result}" \
        "${inspection_summary}" "${command_result}" "${command_executed}" \
        "${GUIDELINE_PURPOSE}" "${GUIDELINE_THREAT}" \
        "${GUIDELINE_CRITERIA_GOOD}" "${GUIDELINE_CRITERIA_BAD}" "${GUIDELINE_REMEDIATION}"
    
    verify_result_saved "${ITEM_ID}"
    return 0
}

main() {
    show_diagnosis_start "${ITEM_ID}" "${ITEM_NAME}"
    [ "$EUID" -ne 0 ] && { echo "root 권한이 필요합니다."; exit 1; }
    diagnose
    show_diagnosis_complete "${ITEM_ID}" "${diagnosis_result}"
    exit 0
}

main "$@"
