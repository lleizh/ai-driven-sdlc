#!/usr/bin/env bash
#
# test_helper.sh - BATS テストヘルパー関数
#
# このスクリプトは、BATS テストで使用される共通のヘルパー関数を提供します。
#
# 使用方法:
#   load test_helper

# プロジェクトルートの取得
export PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SCRIPTS_DIR="${PROJECT_ROOT}/scripts"
export SDLC_DIR="${PROJECT_ROOT}/sdlc"

# テスト用の一時ディレクトリ
export TEST_TEMP_DIR="${PROJECT_ROOT}/tests/.tmp"

#######################################
# テスト前の準備処理
# テスト用の一時ディレクトリを作成します
#######################################
setup_test() {
    mkdir -p "$TEST_TEMP_DIR"
}

#######################################
# テスト後のクリーンアップ処理
# テスト用の一時ディレクトリを削除します
#######################################
teardown_test() {
    if [[ -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

#######################################
# テスト用のFeatureディレクトリを作成
# Arguments:
#   $1 - Feature ID (例: TEST-FEATURE-1)
#######################################
create_test_feature() {
    local feature_id="$1"
    local feature_dir="${TEST_TEMP_DIR}/sdlc/features/${feature_id}"

    mkdir -p "$feature_dir"

    # .metadata ファイルを作成
    cat > "${feature_dir}/.metadata" <<EOF
FEATURE_ID=${feature_id}
RISK_LEVEL=low
STATUS=planning
CREATED_DATE=2025-12-29
DECISION_STATUS=pending
ISSUE_URL=https://github.com/test/repo/issues/1
BRANCH=feature/${feature_id}
LAST_UPDATED=2025-12-29
EOF

    echo "$feature_dir"
}

#######################################
# テスト用のGitリポジトリを作成
# Arguments:
#   $1 - リポジトリディレクトリ
#######################################
create_test_git_repo() {
    local repo_dir="$1"

    mkdir -p "$repo_dir"
    cd "$repo_dir" || return 1

    git init
    git config user.name "Test User"
    git config user.email "test@example.com"

    # 初期コミット
    echo "# Test Repo" > README.md
    git add README.md
    git commit -m "Initial commit"

    cd - > /dev/null || return 1
}

#######################################
# テスト用のブランチを作成
# Arguments:
#   $1 - リポジトリディレクトリ
#   $2 - ブランチ名
#######################################
create_test_branch() {
    local repo_dir="$1"
    local branch_name="$2"

    cd "$repo_dir" || return 1
    git checkout -b "$branch_name"
    cd - > /dev/null || return 1
}

#######################################
# テスト出力から色コードを削除
# Arguments:
#   $1 - 出力文字列
# Outputs:
#   色コードが削除された文字列
#######################################
strip_colors() {
    echo "$1" | sed -E 's/\x1B\[[0-9;]*[mK]//g'
}

#######################################
# 文字列が部分文字列を含むかチェック
# Arguments:
#   $1 - チェックする文字列
#   $2 - 期待される部分文字列
# Returns:
#   0 - 含む
#   1 - 含まない
#######################################
assert_output_contains() {
    local output="$1"
    local expected="$2"

    if [[ "$output" == *"$expected"* ]]; then
        return 0
    else
        echo "Expected output to contain: $expected"
        echo "Actual output: $output"
        return 1
    fi
}

#######################################
# ファイルが存在するかチェック
# Arguments:
#   $1 - ファイルパス
# Returns:
#   0 - 存在する
#   1 - 存在しない
#######################################
assert_file_exists() {
    local file="$1"

    if [[ -f "$file" ]]; then
        return 0
    else
        echo "Expected file to exist: $file"
        return 1
    fi
}

#######################################
# ファイルが存在しないかチェック
# Arguments:
#   $1 - ファイルパス
# Returns:
#   0 - 存在しない
#   1 - 存在する
#######################################
assert_file_not_exists() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        return 0
    else
        echo "Expected file to not exist: $file"
        return 1
    fi
}

#######################################
# ファイルの内容が期待される文字列を含むかチェック
# Arguments:
#   $1 - ファイルパス
#   $2 - 期待される文字列
# Returns:
#   0 - 含む
#   1 - 含まない
#######################################
assert_file_contains() {
    local file="$1"
    local expected="$2"

    if [[ ! -f "$file" ]]; then
        echo "File does not exist: $file"
        return 1
    fi

    if grep -q "$expected" "$file"; then
        return 0
    else
        echo "Expected file $file to contain: $expected"
        echo "File contents:"
        cat "$file"
        return 1
    fi
}

#######################################
# Exit codeが期待される値かチェック
# Arguments:
#   $1 - 実際のexit code
#   $2 - 期待されるexit code
# Returns:
#   0 - 一致
#   1 - 不一致
#######################################
assert_exit_code() {
    local actual="$1"
    local expected="$2"

    if [[ "$actual" -eq "$expected" ]]; then
        return 0
    else
        echo "Expected exit code: $expected"
        echo "Actual exit code: $actual"
        return 1
    fi
}
