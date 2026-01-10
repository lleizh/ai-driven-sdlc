---
description: 50_test_plan.md に基づいてテストを実行する
---

# Command: /sdlc-test

`50_test_plan.md` で定義されたテストを実行し、結果をレポートします。

## 使用方法

```
/sdlc-test <feature-id>
```

## 実行内容

### 1. 前提確認

**共有スクリプトを使用**：
```bash
source scripts/common-functions.sh

# Feature 存在確認
check_feature_exists "$FEATURE_ID" || exit 1

# ブランチ検証
scripts/check-branch.sh "$FEATURE_ID" || exit 1

# Test Plan 存在確認
TEST_PLAN="sdlc/features/${FEATURE_ID}/50_test_plan.md"
if [[ ! -f "$TEST_PLAN" ]]; then
    display_error \
        "Test Plan が見つかりません" \
        "Low Risk Feature の可能性があります" \
        "Medium/High Risk の Feature では 50_test_plan.md が必要です"
    exit 1
fi
```

### 2. テスト計画読み込み

`50_test_plan.md` から以下を抽出：

**テスト実行コマンド**：
- Unit Tests コマンド
- Integration Tests コマンド  
- E2E Tests コマンド

**E2E Tests の実行判断**：
- "Run by default: Yes/No" を確認
- No の場合、ユーザーに確認

### 3. メタデータ更新（テスト開始）

**共有スクリプトを使用**：
```bash
scripts/update-metadata.sh "$FEATURE_ID" "STATUS" "testing"
scripts/update-metadata.sh "$FEATURE_ID" "TEST_START_TIME" "$(date +%Y-%m-%d\ %H:%M:%S)"
```

### 4. テスト実行 & 結果収集

テストを順番に実行：

```bash
# Initialize counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
FAILED_DETAILS=""

# Unit Tests
log_info "Running Unit Tests..."
if eval "$UNIT_TEST_CMD"; then
    UNIT_RESULT="PASS"
else
    UNIT_RESULT="FAIL"
    FAILED_DETAILS+="Unit Tests failed\n"
fi

# Integration Tests
log_info "Running Integration Tests..."
if eval "$INTEGRATION_TEST_CMD"; then
    INTEGRATION_RESULT="PASS"
else
    INTEGRATION_RESULT="FAIL"
    FAILED_DETAILS+="Integration Tests failed\n"
fi

# E2E Tests (conditional)
if [[ "$SKIP_E2E" != "true" ]]; then
    log_info "Running E2E Tests..."
    if eval "$E2E_TEST_CMD"; then
        E2E_RESULT="PASS"
    else
        E2E_RESULT="FAIL"
        FAILED_DETAILS+="E2E Tests failed\n"
    fi
fi
```

**結果を収集**：
- Total tests、Passed、Failed をカウント
- 失敗したテストの詳細を記録
- 一部のテストが失敗しても、全てのテストスイートを実行

### 5. Test Plan への結果記録

`50_test_plan.md` の `## Test Results` セクションを更新：

```markdown
## Test Results

### Run on $(date +%Y-%m-%d\ %H:%M:%S)
- **Branch**: feature/${FEATURE_ID}
- **Total Tests**: {数}
- **Passed**: {数}
- **Failed**: {数}
- **Success Rate**: {率}%

#### Unit Tests: PASS/FAIL
#### Integration Tests: PASS/FAIL
#### E2E Tests: PASS/FAIL

#### Failed Tests:
{詳細（失敗がある場合のみ）}
```

### 6. メタデータ更新（テスト完了）

**共有スクリプトを使用**：
```bash
# Calculate test result
TEST_RESULT=$([ $FAILED_TESTS -eq 0 ] && echo "PASS" || echo "FAIL")

# Update metadata
scripts/update-metadata.sh "$FEATURE_ID" "TEST_END_TIME" "$(date +%Y-%m-%d\ %H:%M:%S)"
scripts/update-metadata.sh "$FEATURE_ID" "TEST_RESULT" "$TEST_RESULT"
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

---

## 完了後の次のステップ

**テスト成功時**：
1. `/sdlc-check {FEATURE_ID}` で最終確認
2. `/sdlc-pr-code {FEATURE_ID}` で PR 作成

**テスト失敗時**：
1. 失敗したテストを修正
2. `/sdlc-test {FEATURE_ID}` で再テスト

---

## 共有スクリプトの活用

このコマンドは以下の共有機能を使用：
- `check_feature_exists()` - Feature 存在確認
- `check-branch.sh` - ブランチ検証
- `display_error()` - エラー表示
- `get_metadata_value()` - Metadata 値取得
- `log_info()`, `log_error()` - ログ出力
- `update-metadata.sh` - Metadata 更新

---

## 制約

- **失敗時も続行**：一部のテストが失敗しても、全てのテストスイートを実行
- **結果を記録**：Test Plan に結果を書き込み、履歴を残す
- **自動修正しない**：テストが失敗してもコードを自動修正しない
- **Test Plan への結果記録は開発者自身が commit/push する**

---

## エラー処理

- Feature 不存在 → `check_feature_exists()` がエラー表示
- ブランチ不一致 → `check-branch.sh` がエラー表示
- Test Plan 不存在 → Low Risk Feature の可能性を示唆
- テストコマンド失敗 → 詳細を表示、修正を促す
