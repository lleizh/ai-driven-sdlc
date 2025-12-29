#!/usr/bin/env bash
#
# update-metadata.sh - Metadata更新の統一処理
#
# このスクリプトは、Feature の .metadata ファイルを更新します。
# macOS/Linux 両対応で、互換性のあるコマンドのみを使用します。
#
# 使用方法:
#   ./scripts/update-metadata.sh <FEATURE_ID> <KEY> <VALUE>
#
# 例:
#   ./scripts/update-metadata.sh FEATURE-29 STATUS implementing
#   ./scripts/update-metadata.sh FEATURE-29 DECISION_STATUS confirmed
#
# Exit codes:
#   0 - 成功
#   1 - Feature ディレクトリが存在しない
#   2 - Metadata ファイルが存在しない
#   3 - 書き込み失敗
#   4 - 引数エラー

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
    if [[ $# -ne 3 ]]; then
        log_error "Error: Invalid number of arguments"
        log_error "   Context: このスクリプトは3つの引数を必要とします"
        log_error "   Action: ./scripts/update-metadata.sh <FEATURE_ID> <KEY> <VALUE>"
        exit 4
    fi

    local feature_id="$1"
    local key="$2"
    local value="$3"

    # プロジェクトルートに移動
    cd "$PROJECT_ROOT"

    # Feature 存在確認
    if ! check_feature_exists "$feature_id"; then
        exit 1
    fi

    local metadata_file="sdlc/features/${feature_id}/.metadata"

    # Metadata ファイル存在確認
    if [[ ! -f "$metadata_file" ]]; then
        log_error "Error: Metadata file not found"
        log_error "   Context: ファイル '${metadata_file}' が存在しません"
        log_error "   Action: /sdlc-init ${feature_id} を先に実行してください"
        exit 2
    fi

    # キーの存在確認と更新処理
    if grep -q "^${key}=" "$metadata_file"; then
        # キーが存在する場合は更新
        update_existing_key "$metadata_file" "$key" "$value"
    else
        # キーが存在しない場合は追加
        add_new_key "$metadata_file" "$key" "$value"
    fi

    log_success "Metadata updated: ${key}=${value}"
    return 0
}

#######################################
# 既存のキーの値を更新
# Arguments:
#   $1 - Metadata ファイルパス
#   $2 - キー名
#   $3 - 新しい値
#######################################
update_existing_key() {
    local metadata_file="$1"
    local key="$2"
    local value="$3"
    local temp_file="${metadata_file}.tmp"

    # sed で置換（macOS/Linux 互換の方法）
    if sed "s|^${key}=.*|${key}=${value}|" "$metadata_file" > "$temp_file"; then
        if mv "$temp_file" "$metadata_file"; then
            log_info "Updated existing key: ${key}"
            return 0
        else
            log_error "Error: Failed to replace metadata file"
            rm -f "$temp_file"
            exit 3
        fi
    else
        log_error "Error: Failed to update metadata"
        rm -f "$temp_file"
        exit 3
    fi
}

#######################################
# 新しいキーを追加
# Arguments:
#   $1 - Metadata ファイルパス
#   $2 - キー名
#   $3 - 値
#######################################
add_new_key() {
    local metadata_file="$1"
    local key="$2"
    local value="$3"

    # ファイル末尾に追加
    if echo "${key}=${value}" >> "$metadata_file"; then
        log_info "Added new key: ${key}"
        return 0
    else
        log_error "Error: Failed to add key to metadata"
        exit 3
    fi
}

# メイン処理実行
main "$@"
