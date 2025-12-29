#!/usr/bin/env bash
#
# rebase-with-develop.sh - rebase処理の統一
#
# このスクリプトは、現在のfeatureブランチをmasterブランチと
# rebaseします。コンフリクトが発生した場合は適切に処理します。
#
# 使用方法:
#   ./scripts/rebase-with-develop.sh <FEATURE_ID>
#
# 例:
#   ./scripts/rebase-with-develop.sh FEATURE-29
#
# Exit codes:
#   0 - Rebase成功
#   1 - コンフリクト発生
#   2 - その他のエラー

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
        log_error "   Action: ./scripts/rebase-with-develop.sh <FEATURE_ID>"
        exit 2
    fi

    local feature_id="$1"
    local base_branch="develop"  # 主ブランチはdevelop

    # プロジェクトルートに移動
    cd "$PROJECT_ROOT"

    # Feature ID形式の検証
    if ! validate_feature_id "$feature_id"; then
        exit 2
    fi

    # 現在のブランチ確認
    local current_branch
    if ! current_branch=$(get_current_branch); then
        exit 2
    fi

    local expected_branch="feature/${feature_id}"
    if [[ "$current_branch" != "$expected_branch" ]]; then
        log_error "Error: Not on correct branch"
        log_error "   Context: Expected ${expected_branch}, but on ${current_branch}"
        log_error "   Action: git checkout ${expected_branch}"
        exit 2
    fi

    log_info "Fetching latest ${base_branch}..."

    # 最新のmasterブランチを取得
    if ! git fetch origin "$base_branch" 2>&1; then
        log_error "Error: Failed to fetch ${base_branch}"
        log_error "   Context: リモートブランチの取得に失敗しました"
        log_error "   Action: ネットワーク接続を確認してください"
        exit 2
    fi

    log_info "Rebasing with origin/${base_branch}..."

    # Rebaseを実行
    if git rebase "origin/${base_branch}" 2>&1; then
        log_success "Rebase completed successfully"
        return 0
    else
        # Rebase失敗（コンフリクト発生）
        local rebase_status=$?

        # コンフリクトファイルを取得
        local conflict_files
        conflict_files=$(git diff --name-only --diff-filter=U 2>/dev/null || echo "")

        if [[ -n "$conflict_files" ]]; then
            log_error "Error: Rebase conflicts detected"
            log_error "   Context: 以下のファイルでコンフリクトが発生しました:"
            while IFS= read -r file; do
                log_error "      - ${file}"
            done <<< "$conflict_files"
            log_error "   Action: コンフリクトを解決してから以下を実行:"
            log_error "      1. コンフリクトを手動で解決"
            log_error "      2. git add <解決したファイル>"
            log_error "      3. git rebase --continue"
            log_error "   または、rebaseを中止する場合:"
            log_error "      git rebase --abort"
        else
            log_error "Error: Rebase failed"
            log_error "   Context: 予期しないエラーが発生しました"
            log_error "   Action: git rebase --abort でrebaseを中止してください"
        fi

        return 1
    fi
}

# メイン処理実行
main "$@"
