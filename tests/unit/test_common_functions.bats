#!/usr/bin/env bats
#
# test_common_functions.bats - common-functions.sh の単体テスト
#
# 実行方法:
#   bats tests/unit/test_common_functions.bats

load ../test_helper

setup() {
    setup_test
    # 共通関数を読み込み
    source "${SCRIPTS_DIR}/common-functions.sh"
}

teardown() {
    teardown_test
}

# =====================================================
# get_os_type のテスト
# =====================================================

@test "get_os_type returns 'macos' on Darwin" {
    # macOS環境でのみ実行
    if [[ "$(uname -s)" == "Darwin" ]]; then
        run get_os_type
        [ "$status" -eq 0 ]
        [ "$output" = "macos" ]
    else
        skip "Not running on macOS"
    fi
}

@test "get_os_type returns 'linux' on Linux" {
    # Linux環境でのみ実行
    if [[ "$(uname -s)" == "Linux" ]]; then
        run get_os_type
        [ "$status" -eq 0 ]
        [ "$output" = "linux" ]
    else
        skip "Not running on Linux"
    fi
}

# =====================================================
# validate_feature_id のテスト
# =====================================================

@test "validate_feature_id accepts valid FEATURE-123 format" {
    run validate_feature_id "FEATURE-123"
    [ "$status" -eq 0 ]
}

@test "validate_feature_id accepts valid FEATURE-1 format" {
    run validate_feature_id "FEATURE-1"
    [ "$status" -eq 0 ]
}

@test "validate_feature_id rejects invalid format without hyphen" {
    run validate_feature_id "FEATURE123"
    [ "$status" -eq 1 ]
    [[ "$output" == *"不正なFeature ID形式"* ]]
}

@test "validate_feature_id rejects invalid format with letters after hyphen" {
    run validate_feature_id "FEATURE-ABC"
    [ "$status" -eq 1 ]
    [[ "$output" == *"不正なFeature ID形式"* ]]
}

@test "validate_feature_id rejects empty string" {
    run validate_feature_id ""
    [ "$status" -eq 1 ]
}

# =====================================================
# check_feature_exists のテスト
# =====================================================

@test "check_feature_exists succeeds for existing feature" {
    # テスト用のFeatureを作成
    local feature_id="TEST-FEATURE-1"
    local feature_dir=$(create_test_feature "$feature_id")

    # SDLCディレクトリを一時的に変更
    cd "$TEST_TEMP_DIR" || return 1

    run check_feature_exists "$feature_id"
    [ "$status" -eq 0 ]
}

@test "check_feature_exists fails for non-existing feature" {
    cd "$TEST_TEMP_DIR" || return 1
    mkdir -p sdlc/features

    run check_feature_exists "FEATURE-999"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Feature not found"* ]]
}

@test "check_feature_exists fails when .metadata is missing" {
    cd "$TEST_TEMP_DIR" || return 1
    local feature_id="TEST-FEATURE-2"
    mkdir -p "sdlc/features/${feature_id}"

    run check_feature_exists "$feature_id"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Metadata file not found"* ]]
}

# =====================================================
# get_current_branch のテスト
# =====================================================

@test "get_current_branch returns current branch name" {
    local test_repo="${TEST_TEMP_DIR}/test-repo"
    create_test_git_repo "$test_repo"
    create_test_branch "$test_repo" "feature/TEST-1"

    cd "$test_repo" || return 1
    run get_current_branch
    [ "$status" -eq 0 ]
    [ "$output" = "feature/TEST-1" ]
}

@test "get_current_branch fails outside git repository" {
    cd "$TEST_TEMP_DIR" || return 1

    run get_current_branch
    [ "$status" -eq 1 ]
    [[ "$output" == *"Failed to get current branch"* ]]
}

# =====================================================
# get_metadata_value のテスト
# =====================================================

@test "get_metadata_value returns correct value" {
    local feature_id="TEST-FEATURE-3"
    local feature_dir=$(create_test_feature "$feature_id")

    cd "$TEST_TEMP_DIR" || return 1

    run get_metadata_value "$feature_id" "STATUS"
    [ "$status" -eq 0 ]
    [ "$output" = "planning" ]
}

@test "get_metadata_value fails for non-existing key" {
    local feature_id="TEST-FEATURE-4"
    local feature_dir=$(create_test_feature "$feature_id")

    cd "$TEST_TEMP_DIR" || return 1

    run get_metadata_value "$feature_id" "NON_EXISTING_KEY"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Key 'NON_EXISTING_KEY' not found"* ]]
}

@test "get_metadata_value fails for non-existing feature" {
    cd "$TEST_TEMP_DIR" || return 1
    mkdir -p sdlc/features

    run get_metadata_value "FEATURE-999" "STATUS"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Metadata file not found"* ]]
}

# =====================================================
# ログ関数のテスト
# =====================================================

@test "log_info outputs info message" {
    run log_info "Test info message"
    [ "$status" -eq 0 ]
    # 色コードを除去して確認
    local stripped=$(strip_colors "$output")
    [[ "$stripped" == *"ℹ️  Test info message"* ]]
}

@test "log_error outputs error message to stderr" {
    run log_error "Test error message"
    [ "$status" -eq 0 ]
    # 色コードを除去して確認
    local stripped=$(strip_colors "$output")
    [[ "$stripped" == *"❌ Test error message"* ]]
}

@test "log_success outputs success message" {
    run log_success "Test success message"
    [ "$status" -eq 0 ]
    # 色コードを除去して確認
    local stripped=$(strip_colors "$output")
    [[ "$stripped" == *"✅ Test success message"* ]]
}

@test "log_warning outputs warning message" {
    run log_warning "Test warning message"
    [ "$status" -eq 0 ]
    # 色コードを除去して確認
    local stripped=$(strip_colors "$output")
    [[ "$stripped" == *"⚠️  Test warning message"* ]]
}
