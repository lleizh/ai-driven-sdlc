#!/usr/bin/env bats
#
# test_update_metadata.bats - update-metadata.sh の単体テスト
#
# 実行方法:
#   bats tests/unit/test_update_metadata.bats

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

@test "update-metadata.sh updates existing key" {
    local feature_id="FEATURE-991"
    local feature_dir=$(create_test_feature "$feature_id")

    cd "$TEST_TEMP_DIR" || return 1

    # STATUS を更新 (PROJECT_ROOT環境変数を設定)
    export PROJECT_ROOT="$TEST_TEMP_DIR"
    run "${SCRIPTS_DIR}/update-metadata.sh" "$feature_id" "STATUS" "implementing"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Updated existing key: STATUS"* ]]
    [[ "$output" == *"Metadata updated: STATUS=implementing"* ]]

    # 更新されたことを確認
    run grep "^STATUS=" "${feature_dir}/.metadata"
    [ "$status" -eq 0 ]
    [ "$output" = "STATUS=implementing" ]
}

@test "update-metadata.sh adds new key" {
    local feature_id="FEATURE-992"
    local feature_dir=$(create_test_feature "$feature_id")

    cd "$TEST_TEMP_DIR" || return 1

    # 新しいキーを追加 (PROJECT_ROOT環境変数を設定)
    export PROJECT_ROOT="$TEST_TEMP_DIR"
    run "${SCRIPTS_DIR}/update-metadata.sh" "$feature_id" "NEW_KEY" "new_value"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Added new key: NEW_KEY"* ]]
    [[ "$output" == *"Metadata updated: NEW_KEY=new_value"* ]]

    # 追加されたことを確認
    run grep "^NEW_KEY=" "${feature_dir}/.metadata"
    [ "$status" -eq 0 ]
    [ "$output" = "NEW_KEY=new_value" ]
}

@test "update-metadata.sh updates LAST_UPDATED" {
    local feature_id="FEATURE-993"
    local feature_dir=$(create_test_feature "$feature_id")

    cd "$TEST_TEMP_DIR" || return 1

    # LAST_UPDATED を更新 (PROJECT_ROOT環境変数を設定)
    export PROJECT_ROOT="$TEST_TEMP_DIR"
    run "${SCRIPTS_DIR}/update-metadata.sh" "$feature_id" "LAST_UPDATED" "2025-12-30"
    [ "$status" -eq 0 ]

    # 更新されたことを確認
    run grep "^LAST_UPDATED=" "${feature_dir}/.metadata"
    [ "$status" -eq 0 ]
    [ "$output" = "LAST_UPDATED=2025-12-30" ]
}

@test "update-metadata.sh handles values with special characters" {
    local feature_id="FEATURE-994"
    local feature_dir=$(create_test_feature "$feature_id")

    cd "$TEST_TEMP_DIR" || return 1

    # 特殊文字を含む値を設定 (PROJECT_ROOT環境変数を設定)
    export PROJECT_ROOT="$TEST_TEMP_DIR"
    local url="https://github.com/test/repo/issues/123"
    run "${SCRIPTS_DIR}/update-metadata.sh" "$feature_id" "ISSUE_URL" "$url"
    [ "$status" -eq 0 ]

    # 設定されたことを確認
    run grep "^ISSUE_URL=" "${feature_dir}/.metadata"
    [ "$status" -eq 0 ]
    [ "$output" = "ISSUE_URL=${url}" ]
}

# =====================================================
# エラーケーステスト
# =====================================================

@test "update-metadata.sh fails with insufficient arguments" {
    cd "$TEST_TEMP_DIR" || return 1

    # 引数が不足している場合
    run "${SCRIPTS_DIR}/update-metadata.sh" "FEATURE-1" "KEY"
    [ "$status" -eq 4 ]
    [[ "$output" == *"Invalid number of arguments"* ]]
}

@test "update-metadata.sh fails for non-existing feature" {
    cd "$TEST_TEMP_DIR" || return 1
    mkdir -p sdlc/features

    export PROJECT_ROOT="$TEST_TEMP_DIR"
    run "${SCRIPTS_DIR}/update-metadata.sh" "FEATURE-999" "STATUS" "implementing"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Feature not found"* ]]
}

@test "update-metadata.sh fails for invalid feature ID format" {
    cd "$TEST_TEMP_DIR" || return 1

    run "${SCRIPTS_DIR}/update-metadata.sh" "INVALID-FORMAT" "STATUS" "implementing"
    [ "$status" -eq 1 ]
    [[ "$output" == *"不正なFeature ID形式"* ]]
}

@test "update-metadata.sh fails when .metadata is missing" {
    cd "$TEST_TEMP_DIR" || return 1
    local feature_id="FEATURE-995"
    mkdir -p "sdlc/features/${feature_id}"

    export PROJECT_ROOT="$TEST_TEMP_DIR"
    run "${SCRIPTS_DIR}/update-metadata.sh" "$feature_id" "STATUS" "implementing"
    # check_feature_exists が .metadata の存在も確認するため、exit code 1 になる
    [ "$status" -eq 1 ]
    [[ "$output" == *"Metadata file not found"* ]]
}

# =====================================================
# 複数更新テスト
# =====================================================

@test "update-metadata.sh can update multiple keys in sequence" {
    local feature_id="FEATURE-996"
    local feature_dir=$(create_test_feature "$feature_id")

    cd "$TEST_TEMP_DIR" || return 1

    export PROJECT_ROOT="$TEST_TEMP_DIR"
    # 複数のキーを順次更新
    run "${SCRIPTS_DIR}/update-metadata.sh" "$feature_id" "STATUS" "implementing"
    [ "$status" -eq 0 ]

    run "${SCRIPTS_DIR}/update-metadata.sh" "$feature_id" "DECISION_STATUS" "confirmed"
    [ "$status" -eq 0 ]

    run "${SCRIPTS_DIR}/update-metadata.sh" "$feature_id" "LAST_UPDATED" "2025-12-30"
    [ "$status" -eq 0 ]

    # 全ての更新を確認
    assert_file_contains "${feature_dir}/.metadata" "STATUS=implementing"
    assert_file_contains "${feature_dir}/.metadata" "DECISION_STATUS=confirmed"
    assert_file_contains "${feature_dir}/.metadata" "LAST_UPDATED=2025-12-30"
}

@test "update-metadata.sh overwrites previous value correctly" {
    local feature_id="FEATURE-997"
    local feature_dir=$(create_test_feature "$feature_id")

    cd "$TEST_TEMP_DIR" || return 1

    export PROJECT_ROOT="$TEST_TEMP_DIR"
    # 最初の値を設定
    run "${SCRIPTS_DIR}/update-metadata.sh" "$feature_id" "STATUS" "planning"
    [ "$status" -eq 0 ]

    # 同じキーを別の値で更新
    run "${SCRIPTS_DIR}/update-metadata.sh" "$feature_id" "STATUS" "implementing"
    [ "$status" -eq 0 ]

    # 最新の値のみが存在することを確認
    run grep "^STATUS=" "${feature_dir}/.metadata"
    [ "$status" -eq 0 ]
    [ "$output" = "STATUS=implementing" ]

    # 古い値が残っていないことを確認
    run grep -c "^STATUS=" "${feature_dir}/.metadata"
    [ "$status" -eq 0 ]
    [ "$output" = "1" ]
}
