# /sdlc-test - Refined Flow Analysis

## コマンド概要
50_test_plan.md に基づいてテストを実行する

## 使用方法
```bash
/sdlc-test <feature-id>
```

## 現在の構造
- **ステップ数**: 9
- **共有スクリプト使用**: ✅ 完全対応
- **命名統一性**: ⚠️ "前提チェック" → "前提確認" に変更必要
- **ブランチ確認**: ❌ 欠落

---

## 詳細フロー

### Step 1: 前提確認

**目的**: Feature 存在、ブランチ、Test Plan の確認

**実行内容**:
```bash
source scripts/common-functions.sh

# Feature 存在確認
check_feature_exists "$FEATURE_ID" || exit 1

# ブランチ確認
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

**共有スクリプト**:
- `check_feature_exists()` - Feature 存在確認
- `scripts/check-branch.sh` - ブランチ検証
- `display_error()` - エラー表示

---

### Step 2: テスト計画読み込み

**目的**: Test Plan からテスト実行コマンドを抽出

**実行内容**:
```bash
# Read Test Plan
TEST_PLAN_CONTENT=$(cat "$TEST_PLAN")

# Extract test commands
UNIT_TEST_CMD=$(echo "$TEST_PLAN_CONTENT" | grep -A 1 "## Unit Tests" | grep "Command:" | cut -d':' -f2-)
INTEGRATION_TEST_CMD=$(echo "$TEST_PLAN_CONTENT" | grep -A 1 "## Integration Tests" | grep "Command:" | cut -d':' -f2-)
E2E_TEST_CMD=$(echo "$TEST_PLAN_CONTENT" | grep -A 1 "## E2E Tests" | grep "Command:" | cut -d':' -f2-)

# Check if E2E should run by default
RUN_E2E_DEFAULT=$(echo "$TEST_PLAN_CONTENT" | grep -A 1 "## E2E Tests" | grep "Run by default:" | cut -d':' -f2- | tr -d ' ')

# Ask user if E2E tests should run (if not default)
if [[ "$RUN_E2E_DEFAULT" == "No" ]]; then
    # Prompt user for confirmation
    SKIP_E2E=true
fi
```

**抽出する情報**:
- Unit Tests コマンド
- Integration Tests コマンド
- E2E Tests コマンド
- E2E Tests の実行判断（Run by default: Yes/No）

---

### Step 3: メタデータ更新（テスト開始）

**目的**: STATUS を testing に更新

**実行内容**:
```bash
scripts/update-metadata.sh "$FEATURE_ID" "STATUS" "testing"
scripts/update-metadata.sh "$FEATURE_ID" "TEST_START_TIME" "$(date +%Y-%m-%d\ %H:%M:%S)"
```

**共有スクリプト**:
- `scripts/update-metadata.sh` - Metadata 更新

---

### Step 4: テスト実行 & 結果収集

**目的**: テストを実行し、結果を収集

**実行内容**:
```bash
# Initialize counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
FAILED_DETAILS=""

# Run Unit Tests
log_info "Running Unit Tests..."
if eval "$UNIT_TEST_CMD"; then
    UNIT_RESULT="PASS"
    # Parse output to count tests (implementation specific)
else
    UNIT_RESULT="FAIL"
    FAILED_DETAILS+="Unit Tests failed\n"
fi

# Run Integration Tests
log_info "Running Integration Tests..."
if eval "$INTEGRATION_TEST_CMD"; then
    INTEGRATION_RESULT="PASS"
else
    INTEGRATION_RESULT="FAIL"
    FAILED_DETAILS+="Integration Tests failed\n"
fi

# Run E2E Tests (conditional)
if [[ "$SKIP_E2E" != "true" ]]; then
    log_info "Running E2E Tests..."
    if eval "$E2E_TEST_CMD"; then
        E2E_RESULT="PASS"
    else
        E2E_RESULT="FAIL"
        FAILED_DETAILS+="E2E Tests failed\n"
    fi
fi

# Display summary (output only)
echo "========================================"
echo "Test Results Summary"
echo "========================================"
echo ""
echo "📊 統計:"
echo "  Total:   $TOTAL_TESTS tests"
echo "  Passed:  $PASSED_TESTS tests"
echo "  Failed:  $FAILED_TESTS tests"
if [[ $FAILED_TESTS -gt 0 ]]; then
    echo ""
    echo "❌ 失敗したテスト:"
    echo "$FAILED_DETAILS"
fi
```

**実行の原則**:
- 一部のテストが失敗しても、全てのテストスイートを実行
- 結果を収集（Total/Passed/Failed）
- 失敗したテストの詳細を記録

---

### Step 5: Test Plan への結果記録

**目的**: Test Plan に実行結果を追記

**実行内容**:
```bash
# Update Test Results section in 50_test_plan.md
# Use Write tool or append to file

TEST_RESULT_SECTION="
## Test Results

### Run on $(date +%Y-%m-%d\ %H:%M:%S)
- **Branch**: feature/${FEATURE_ID}
- **Total Tests**: $TOTAL_TESTS
- **Passed**: $PASSED_TESTS
- **Failed**: $FAILED_TESTS
- **Success Rate**: ${SUCCESS_RATE}%

#### Unit Tests: $UNIT_RESULT
#### Integration Tests: $INTEGRATION_RESULT
#### E2E Tests: $E2E_RESULT

${FAILED_DETAILS:+#### Failed Tests:\n$FAILED_DETAILS}
"

# Append to Test Plan (or use Write tool to update)
```

**記録する内容**:
- 実行日時
- Branch 名
- 統計情報（Total/Passed/Failed/Success Rate）
- 各テストスイートの結果
- 失敗したテストの詳細

---

### Step 6: メタデータ更新（テスト完了）

**目的**: テスト結果を metadata に記録

**実行内容**:
```bash
# Calculate test result
TEST_RESULT=$([ $FAILED_TESTS -eq 0 ] && echo "PASS" || echo "FAIL")

# Update metadata
scripts/update-metadata.sh "$FEATURE_ID" "TEST_END_TIME" "$(date +%Y-%m-%d\ %H:%M:%S)"
scripts/update-metadata.sh "$FEATURE_ID" "TEST_RESULT" "$TEST_RESULT"
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

**共有スクリプト**:
- `scripts/update-metadata.sh` - Metadata 更新

**完了メッセージ**（出力のみ、ステップではない）:

**テスト成功時**:
```
✅ テスト実行完了

📊 結果:
- Total:   {数} tests ({成功率}%)
- Failed:  0 tests

次のステップ:
1. /sdlc-check {FEATURE_ID} で最終確認
2. /sdlc-pr-code {FEATURE_ID} で PR 作成
```

**テスト失敗時**:
```
❌ テスト実行完了（失敗あり）

📊 結果:
- Total:   {数} tests ({成功率}%)
- Failed:  {数} tests

次のステップ:
1. 失敗したテストを修正
2. /sdlc-test {FEATURE_ID} で再テスト
```

---

## 最適化提案

### 現在の問題点

1. **命名不統一**: 
   - Step 1: "前提チェック" → "前提確認" に変更すべき

2. **ブランチ確認欠落**:
   - Branch check がない

3. **Commit/Push 不要**:
   - `/sdlc-coding` と同様、Command は metadata 更新のみ
   - Commit/Push は削除すべき

4. **ステップの粒度**:
   - Step 2 "メタデータ更新（テスト開始）" は Step 3 の一部
   - Step 5 "結果サマリー表示" は出力のみ、ステップではない
   - Step 9 "完了メッセージ" は出力のみ

### 最適化案

**9 Steps → 6 Steps**

```
1. 前提確認（Feature 存在 + ブランチ確認 + Test Plan 存在）
2. テスト計画読み込み（コマンド抽出、E2E 実行判断）
3. メタデータ更新（テスト開始、STATUS=testing）
4. テスト実行 & 結果収集
5. Test Plan への結果記録
6. メタデータ更新（テスト完了、TEST_RESULT）
```

**変更内容**:
- Step 1 "前提チェック" → "前提確認" に変更（命名統一）
- ブランチ確認を追加（`check-branch.sh`）
- Step 3 メタデータ更新（テスト開始）を独立させる
- "結果サマリー表示" を削除（出力のみ）
- Commit/Push を削除（Command は metadata 更新のみ）
- "完了メッセージ" を削除（出力のみ）

---

## エラーハンドリング

| エラー状況 | 処理 | 使用機能 |
|-----------|------|---------|
| Feature 不存在 | エラー表示して終了 | `check_feature_exists()` |
| ブランチ不一致 | エラー表示して終了 | `check-branch.sh` |
| Test Plan 不存在 | Low Risk Feature の可能性を示唆 | `display_error()` |
| テスト失敗 | 詳細を表示、修正を促す | - |
| 全テストスイート失敗 | TEST_RESULT=FAIL を記録 | - |

---

## 共有スクリプト活用状況

✅ **完全対応** - すべての共有スクリプトを適切に使用

- `check_feature_exists()` - Feature 存在確認
- `scripts/check-branch.sh` - ブランチ検証（追加推奨）
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示
- `log_info()`, `log_error()` - ログ出力
- `scripts/update-metadata.sh` - Metadata 更新

**sed 使用**: ❌ なし（完全に `update-metadata.sh` を使用）

---

## 次のステップ

テスト完了後、Risk Level に応じて:

**テスト成功**:
1. `/sdlc-check {FEATURE_ID}` - 最終確認
2. `/sdlc-pr-code {FEATURE_ID}` - Code Review PR 作成

**テスト失敗**:
1. 失敗したテストを修正
2. `/sdlc-test {FEATURE_ID}` - 再テスト

---

## 結論

**現状**: 共有スクリプトの使用は完璧だが、ステップ構造と命名に改善の余地あり

**推奨変更**:
1. "前提チェック" → "前提確認" に変更
2. ブランチ確認を追加
3. Commit/Push を削除（metadata 更新のみ）
4. 出力のみのステップを削除

**最終ステップ数**: 9 → **6**
