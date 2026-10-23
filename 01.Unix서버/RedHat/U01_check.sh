#!/bin/bash
# ============================================================================
# @Project: KISA-CIIP-2026 Vulnerability Assessment Scripts
# @Copyright: Copyright (c) 2026 Yang Uhyeok (양우혁). All rights reserved.
# @Version: 1.0.1
# @Last Updated: 2026-04-20
# ============================================================================
# [점검 항목 상세]
# @ID          : U-01
# @Category    : UNIX > 1. 계정 관리
# @Platform    : SOLARIS, LINUX, AIX, HP-UX 등
# @Severity    : (Cao)
# @Title       : Hạn chế đăng nhập từ xa bằng tài khoản root
# @Description : Kiểm tra việc ngăn đăng nhập trực tiếp bằng root qua kết nối từ xa
# @Reference   : 2026 KISA 주요정보통신기반시설 기술적 KHÔNG ĐẠT점 분석·평가 상세 가이드
# ==============================================================================

set -euo pipefail

# 스크립트 디렉토리 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../../lib"

# 필수 라이브러리 로드
source "${LIB_DIR}/common.sh"
source "${LIB_DIR}/result_manager.sh"
source "${LIB_DIR}/output_mode.sh"
source "${LIB_DIR}/metadata_parser.sh"

ITEM_ID="U-01"
ITEM_NAME="Hạn chế đăng nhập từ xa bằng tài khoản root"
SEVERITY="(Cao)"

# 가이드라인 정보
GUIDELINE_PURPOSE="Ngăn truy cập trực tiếp trái phép bằng root từ xa, giảm nguy cơ chiếm quyền quản trị hệ thống"
GUIDELINE_THREAT="Tài khoản root có toàn quyền trên hệ thống. Cho phép đăng nhập trực tiếp từ xa làm tăng nguy cơ dò mật khẩu, chiếm quyền và thay đổi cấu hình"
GUIDELINE_CRITERIA_GOOD="Không sử dụng dịch vụ truy cập từ xa hoặc đã chặn đăng nhập trực tiếp bằng root"
GUIDELINE_CRITERIA_BAD="Dịch vụ truy cập từ xa cho phép đăng nhập trực tiếp bằng root"
GUIDELINE_REMEDIATION="Cấu hình dịch vụ truy cập từ xa để không cho phép đăng nhập trực tiếp bằng root"

diagnose() {
    local status="ĐẠT"
    diagnosis_result="GOOD"
    local inspection_summary="Hạn chế đăng nhập từ xa bằng tài khoản root được cấu hình phù hợp."
    local command_result=""
    local command_executed="systemctl is-active sshd; grep -i 'PermitRootLogin' /etc/ssh/sshd_config"

    local newline=$'\n'

    # ==========================================================================
    # 1. Kiểm tra trạng thái dịch vụ
    # ==========================================================================
    local ssh_active=false
    local telnet_active=false

    # SSH 서비스 확인
    if systemctl is-active --quiet sshd 2>/dev/null; then
        ssh_active=true
    elif ps aux 2>/dev/null | grep -E "[s]shd" >/dev/null 2>&1; then
        ssh_active=true
    fi

    # Telnet 서비스 확인
    if systemctl is-active --quiet telnetd 2>/dev/null || systemctl is-active --quiet xinetd 2>/dev/null; then
        telnet_active=true
    elif ps aux 2>/dev/null | grep -E "in\.telnetd|telnetd" | grep -v grep >/dev/null 2>&1; then
        telnet_active=true
    fi

    # ==========================================================================
    # 2. 서비스 미사용 시 ĐẠT 판정
    # ==========================================================================
    if [ "$ssh_active" = false ] && [ "$telnet_active" = false ]; then
        command_result="[SSH] dịch vụ không chạy${newline}[Telnet] dịch vụ không chạy"
        save_dual_result \
            "${ITEM_ID}" "${ITEM_NAME}" "${status}" "${diagnosis_result}" \
            "${inspection_summary}" "${command_result}" "${command_executed}" \
            "${GUIDELINE_PURPOSE}" "${GUIDELINE_THREAT}" \
            "${GUIDELINE_CRITERIA_GOOD}" "${GUIDELINE_CRITERIA_BAD}" "${GUIDELINE_REMEDIATION}"
        verify_result_saved "${ITEM_ID}"
        return 0
    fi

    # ==========================================================================
    # 3. Kiểm tra chi tiết khi dịch vụ đang chạy
    # ==========================================================================
    local ssh_secure=true
    local telnet_secure=true
    local details=""

    # --- SSH 진단 ---
    if [ "$ssh_active" = true ]; then
        local sshd_config="/etc/ssh/sshd_config"
        if [ -f "$sshd_config" ]; then
            local ssh_val=$(grep -i "^PermitRootLogin" "$sshd_config" 2>/dev/null | awk '{print $2}' | head -1 || true)
            if [ -z "$ssh_val" ]; then
                # 설정 라인이 없으면 주석이나 미설정 → 기본값 확인 필요
                ssh_secure=false
                details="${details}[SSH] PermitRootLogin chưa cấu hình (giá trị mặc định). "
            else
                case "$ssh_val" in
                    no|prohibit-password|without-password)
                        details="${details}[SSH] PermitRootLogin=${ssh_val} (ĐẠT). "
                        ;;
                    yes)
                        ssh_secure=false
                        details="${details}[SSH] PermitRootLogin=yes (KHÔNG ĐẠT). "
                        ;;
                    *)
                        ssh_secure=false
                        details="${details}[SSH] PermitRootLogin=${ssh_val} (cần kiểm tra). "
                        ;;
                esac
            fi
        else
            # sshd_config 파일 자체가 없음 → MANUAL 처리
            diagnosis_result="MANUAL"
            status="KIỂM TRA THỦ CÔNG"
            inspection_summary="SSH tệp cấu hình(${sshd_config})이 없습니다."
            command_result="[SSH] tệp cấu hình 없음"
            save_dual_result \
                "${ITEM_ID}" "${ITEM_NAME}" "${status}" "${diagnosis_result}" \
                "${inspection_summary}" "${command_result}" "${command_executed}" \
                "${GUIDELINE_PURPOSE}" "${GUIDELINE_THREAT}" \
                "${GUIDELINE_CRITERIA_GOOD}" "${GUIDELINE_CRITERIA_BAD}" "${GUIDELINE_REMEDIATION}"
            verify_result_saved "${ITEM_ID}"
            return 0
        fi
    fi

    # --- Telnet 진단 ---
    if [ "$telnet_active" = true ]; then
        local securetty_pts=$(grep -E "^pts/" /etc/securetty 2>/dev/null || true)
        if [ -n "$securetty_pts" ]; then
            telnet_secure=false
            details="${details}[Telnet] /etc/securetty에 pts có cấu hình (KHÔNG ĐẠT). "
        else
            details="${details}[Telnet] /etc/securetty에 pts không có cấu hình (ĐẠT). "
        fi
    fi

    # ==========================================================================
    # 4. Đánh giá tổng hợp
    # ==========================================================================
    if [ "$ssh_secure" = true ] && [ "$telnet_secure" = true ]; then
        status="ĐẠT"
        diagnosis_result="GOOD"
        inspection_summary="Hạn chế đăng nhập từ xa bằng tài khoản root 적절 (${details})"
    else
        status="KHÔNG ĐẠT"
        diagnosis_result="VULNERABLE"
        inspection_summary="Hạn chế đăng nhập từ xa bằng tài khoản root chưa cấu hình hoặc cấu hình không phù hợp (${details})"
    fi

    command_result="${details}"

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
    [ "$EUID" -ne 0 ] && { echo "Yêu cầu quyền root."; exit 1; }
    diagnose
    show_diagnosis_complete "${ITEM_ID}" "${diagnosis_result}"
    exit 0
}

main "$@"
