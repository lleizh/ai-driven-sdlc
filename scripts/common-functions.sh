#!/usr/bin/env bash
#
# common-functions.sh - SDLC共通ユーティリティ関数
#
# このスクリプトは、全てのSDLCコマンドで共有される汎用関数を提供します。
#
# 使用方法:
#   source scripts/common-functions.sh
#
# 関数一覧:
#   - log_info, log_error, log_success: ログ出力
#   - get_os_type: OS判定
#   - check_feature_exists: Feature存在確認
#   - check_gh_auth: GitHub認証確認

set -euo pipefail

# カラーコード定義
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

#######################################
# 情報ログを出力
# Arguments:
#   $1 - メッセージ
# Outputs:
#   stdout に青色でメッセージを出力
#######################################
log_info() {
    local message="$1"
    echo -e "${COLOR_BLUE}ℹ️  ${message}${COLOR_RESET}"
}

#######################################
# エラーログを出力
# Arguments:
#   $1 - メッセージ
# Outputs:
#   stderr に赤色でメッセージを出力
#######################################
log_error() {
    local message="$1"
    echo -e "${COLOR_RED}❌ ${message}${COLOR_RESET}" >&2
}

#######################################
# 成功ログを出力
# Arguments:
#   $1 - メッセージ
# Outputs:
#   stdout に緑色でメッセージを出力
#######################################
log_success() {
    local message="$1"
    echo -e "${COLOR_GREEN}✅ ${message}${COLOR_RESET}"
}

#######################################
# 警告ログを出力
# Arguments:
#   $1 - メッセージ
# Outputs:
#   stdout に黄色でメッセージを出力
#######################################
log_warning() {
    local message="$1"
    echo -e "${COLOR_YELLOW}⚠️  ${message}${COLOR_RESET}"
}

#######################################
# OS種別を判定
# Outputs:
#   stdout に "macos", "linux", または "unknown" を出力
# Returns:
#   0 - 成功
#######################################
get_os_type() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

#######################################
# Feature IDの形式を検証
# Arguments:
#   $1 - Feature ID (例: FEATURE-29)
# Returns:
#   0 - 正しい形式
#   1 - 不正な形式
#######################################
validate_feature_id() {
    local feature_id="$1"

    if [[ ! "$feature_id" =~ ^FEATURE-[0-9]+$ ]]; then
        log_error "Error: 不正なFeature ID形式: ${feature_id}"
        log_error "   Context: Feature IDは 'FEATURE-数字' の形式である必要があります"
        log_error "   Action: 正しい形式で指定してください（例: FEATURE-29）"
        return 1
    fi

    return 0
}

#######################################
# Featureディレクトリの存在を確認
# Arguments:
#   $1 - Feature ID (例: FEATURE-29)
# Returns:
#   0 - 存在する
#   1 - 存在しない
#######################################
check_feature_exists() {
    local feature_id="$1"
    local feature_dir="sdlc/features/${feature_id}"

    # Feature ID形式の検証
    if ! validate_feature_id "$feature_id"; then
        return 1
    fi

    # ディレクトリの存在確認
    if [[ ! -d "$feature_dir" ]]; then
        log_error "Error: Feature not found: ${feature_id}"
        log_error "   Context: ディレクトリ '${feature_dir}' が存在しません"
        log_error "   Action: /sdlc-init ${feature_id} を先に実行してください"
        return 1
    fi

    # .metadataファイルの存在確認
    if [[ ! -f "${feature_dir}/.metadata" ]]; then
        log_error "Error: Metadata file not found for ${feature_id}"
        log_error "   Context: ファイル '${feature_dir}/.metadata' が存在しません"
        log_error "   Action: Feature構造が壊れている可能性があります"
        return 1
    fi

    return 0
}

#######################################
# GitHub CLIの認証状態を確認
# Returns:
#   0 - 認証済み
#   1 - 認証されていない
#######################################
check_gh_auth() {
    if ! command -v gh &> /dev/null; then
        log_error "Error: GitHub CLI (gh) not found"
        log_error "   Context: このコマンドはGitHub CLIを必要とします"
        log_error "   Action: https://cli.github.com/ からインストールしてください"
        return 1
    fi

    if ! gh auth status &> /dev/null; then
        log_error "Error: GitHub authentication required"
        log_error "   Context: GitHub CLIが認証されていません"
        log_error "   Action: 'gh auth login' を実行して認証してください"
        return 1
    fi

    return 0
}

#######################################
# Gitの設定（user.name, user.email）を確認
# Returns:
#   0 - 設定済み
#   1 - 設定されていない
#######################################
check_git_config() {
    local user_name
    local user_email

    user_name=$(git config user.name 2>/dev/null || echo "")
    user_email=$(git config user.email 2>/dev/null || echo "")

    if [[ -z "$user_name" ]] || [[ -z "$user_email" ]]; then
        log_error "Error: Git user configuration missing"
        log_error "   Context: git config user.name または user.email が設定されていません"
        log_error "   Action: 以下のコマンドで設定してください"
        log_error "      git config --global user.name \"Your Name\""
        log_error "      git config --global user.email \"your.email@example.com\""
        return 1
    fi

    return 0
}

#######################################
# 現在のgitブランチ名を取得
# Outputs:
#   stdout にブランチ名を出力
# Returns:
#   0 - 成功
#   1 - 失敗
#######################################
get_current_branch() {
    local branch
    branch=$(git branch --show-current 2>/dev/null)

    if [[ -z "$branch" ]]; then
        log_error "Error: Failed to get current branch"
        log_error "   Context: gitブランチ情報の取得に失敗しました"
        log_error "   Action: gitリポジトリ内で実行しているか確認してください"
        return 1
    fi

    echo "$branch"
    return 0
}

#######################################
# .metadataファイルから値を取得
# Arguments:
#   $1 - Feature ID
#   $2 - キー名
# Outputs:
#   stdout に値を出力
# Returns:
#   0 - 成功
#   1 - 失敗
#######################################
get_metadata_value() {
    local feature_id="$1"
    local key="$2"
    local metadata_file="sdlc/features/${feature_id}/.metadata"

    if [[ ! -f "$metadata_file" ]]; then
        log_error "Error: Metadata file not found: ${metadata_file}"
        return 1
    fi

    local value
    value=$(grep "^${key}=" "$metadata_file" | cut -d'=' -f2- || echo "")

    if [[ -z "$value" ]]; then
        log_error "Error: Key '${key}' not found in metadata"
        return 1
    fi

    echo "$value"
    return 0
}

#######################################
# 標準化されたエラーメッセージを表示
# Arguments:
#   $1 - エラー概要
#   $2 - 文脈情報 (オプション)
#   $3 - アクション (オプション)
#######################################
display_error() {
    local error_summary="$1"
    local context="${2:-}"
    local action="${3:-}"

    log_error "Error: ${error_summary}"

    if [[ -n "$context" ]]; then
        log_error "   Context: ${context}"
    fi

    if [[ -n "$action" ]]; then
        log_error "   Action: ${action}"
    fi
}

# スクリプトが直接実行された場合（テスト用）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    log_info "common-functions.sh - SDLC共通ユーティリティ関数"
    log_info "このスクリプトは source コマンドで読み込んで使用してください"
    log_info ""
    log_info "使用例:"
    log_info "  source scripts/common-functions.sh"
    log_info "  log_info \"情報メッセージ\""
    log_info "  check_feature_exists FEATURE-29"
fi
