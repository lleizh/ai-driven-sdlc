#!/usr/bin/env bats
#
# test_check_branch.bats - check-branch.sh の単体テスト
#
# 実行方法:
#   bats tests/unit/test_check_branch.bats

load ../test_helper

setup() {
    setup_test
}

teardown() {
    teardown_test
}

# =====================================================
# 正常系テスト
# =====================================================

@test "check-branch.sh succeeds on correct branch" {
    local feature_id="TEST-FEATURE-1"
    local test_repo="${TEST_TEMP_DIR}/test-repo"

    # テスト用のgitリポジトリとブランチを作成
    create_test_git_repo "$test_repo"
    create_test_branch "$test_repo" "feature/${feature_id}"

    cd "$test_repo" || return 1

    # スクリプトを実行
    run "${SCRIPTS_DIR}/check-branch.sh" "$feature_id"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Correct branch: feature/${feature_id}"* ]]
}

@test "check-branch.sh succeeds for FEATURE-29" {
    local feature_id="FEATURE-29"
    local test_repo="${TEST_TEMP_DIR}/test-repo"

    create_test_git_repo "$test_repo"
    create_test_branch "$test_repo" "feature/${feature_id}"

    cd "$test_repo" || return 1

    run "${SCRIPTS_DIR}/check-branch.sh" "$feature_id"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Correct branch: feature/${feature_id}"* ]]
}

# =====================================================
# エラーケーステスト
# =====================================================

@test "check-branch.sh fails on wrong branch" {
    local feature_id="TEST-FEATURE-2"
    local test_repo="${TEST_TEMP_DIR}/test-repo"

    # 異なるブランチを作成
    create_test_git_repo "$test_repo"
    create_test_branch "$test_repo" "feature/OTHER-FEATURE"

    cd "$test_repo" || return 1

    # スクリプトを実行
    run "${SCRIPTS_DIR}/check-branch.sh" "$feature_id"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Wrong branch"* ]]
    [[ "$output" == *"Expected branch: feature/${feature_id}"* ]]
    [[ "$output" == *"Current branch:  feature/OTHER-FEATURE"* ]]
    [[ "$output" == *"git checkout feature/${feature_id}"* ]]
}

@test "check-branch.sh fails on main branch" {
    local feature_id="TEST-FEATURE-3"
    local test_repo="${TEST_TEMP_DIR}/test-repo"

    # mainブランチ（デフォルト）のまま
    create_test_git_repo "$test_repo"

    cd "$test_repo" || return 1

    run "${SCRIPTS_DIR}/check-branch.sh" "$feature_id"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Wrong branch"* ]]
}

@test "check-branch.sh fails with invalid feature ID format" {
    local test_repo="${TEST_TEMP_DIR}/test-repo"
    create_test_git_repo "$test_repo"

    cd "$test_repo" || return 1

    run "${SCRIPTS_DIR}/check-branch.sh" "INVALID-FORMAT"
    [ "$status" -eq 2 ]
    [[ "$output" == *"不正なFeature ID形式"* ]]
}

@test "check-branch.sh fails with no arguments" {
    local test_repo="${TEST_TEMP_DIR}/test-repo"
    create_test_git_repo "$test_repo"

    cd "$test_repo" || return 1

    run "${SCRIPTS_DIR}/check-branch.sh"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Invalid number of arguments"* ]]
}

@test "check-branch.sh fails outside git repository" {
    cd "$TEST_TEMP_DIR" || return 1

    run "${SCRIPTS_DIR}/check-branch.sh" "FEATURE-1"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Failed to get current branch"* ]]
}

# =====================================================
# ブランチ名バリエーションテスト
# =====================================================

@test "check-branch.sh handles single digit feature ID" {
    local feature_id="FEATURE-1"
    local test_repo="${TEST_TEMP_DIR}/test-repo"

    create_test_git_repo "$test_repo"
    create_test_branch "$test_repo" "feature/${feature_id}"

    cd "$test_repo" || return 1

    run "${SCRIPTS_DIR}/check-branch.sh" "$feature_id"
    [ "$status" -eq 0 ]
}

@test "check-branch.sh handles large feature ID numbers" {
    local feature_id="FEATURE-99999"
    local test_repo="${TEST_TEMP_DIR}/test-repo"

    create_test_git_repo "$test_repo"
    create_test_branch "$test_repo" "feature/${feature_id}"

    cd "$test_repo" || return 1

    run "${SCRIPTS_DIR}/check-branch.sh" "$feature_id"
    [ "$status" -eq 0 ]
}

# =====================================================
# エラーメッセージ詳細テスト
# =====================================================

@test "check-branch.sh provides helpful error message" {
    local feature_id="FEATURE-100"
    local test_repo="${TEST_TEMP_DIR}/test-repo"

    create_test_git_repo "$test_repo"
    create_test_branch "$test_repo" "develop"

    cd "$test_repo" || return 1

    run "${SCRIPTS_DIR}/check-branch.sh" "$feature_id"
    [ "$status" -eq 1 ]

    # エラーメッセージの詳細を確認
    [[ "$output" == *"Error: Wrong branch"* ]]
    [[ "$output" == *"Context:"* ]]
    [[ "$output" == *"Action:"* ]]
    [[ "$output" == *"git checkout"* ]]
}
