#!/usr/bin/env bash
#
# check-branch.sh - ブランチ検証の統一処理
#
# このスクリプトは、現在のgitブランチが指定されたFeature IDに対応する
# 正しいブランチ（feature/<FEATURE_ID>）であるかを検証します。
#
# 使用方法:
#   ./scripts/check-branch.sh <FEATURE_ID>
#
# 例:
#   ./scripts/check-branch.sh FEATURE-29
#
# Exit codes:
#   0 - 正しいブランチ
#   1 - 誤ったブランチ
#   2 - ブランチ情報取得失敗

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# 共通関数を読み込み
# shellcheck source=scripts/common-functions.sh
source "${SCRIPT_DIR}/common-functions.sh"

#######################################
# メイン処理
#######################################
main() {
    # 引数チェック
    if [[ $# -ne 1 ]]; then
        log_error "Error: Invalid number of arguments"
        log_error "   Context: このスクリプトは1つの引数を必要とします"
        log_error "   Action: ./scripts/check-branch.sh <FEATURE_ID>"
        exit 2
    fi

    local feature_id="$1"
    local expected_branch="feature/${feature_id}"

    # Feature ID形式の検証
    if ! validate_feature_id "$feature_id"; then
        exit 2
    fi

    # 現在のブランチを取得
    local current_branch
    if ! current_branch=$(get_current_branch); then
        exit 2
    fi

    # ブランチの一致確認
    if [[ "$current_branch" != "$expected_branch" ]]; then
        log_error "Error: Wrong branch"
        log_error "   Context: Expected branch: ${expected_branch}"
        log_error "   Context: Current branch:  ${current_branch}"
        log_error "   Action: git checkout ${expected_branch}"
        return 1
    fi

    log_success "Correct branch: ${current_branch}"
    return 0
}

# メイン処理実行
main "$@"
