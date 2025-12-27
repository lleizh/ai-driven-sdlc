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

1. **前提チェック**
   - Feature と `50_test_plan.md` の存在確認

2. **メタデータ更新**
   
   `.metadata` を更新：
   ```
   STATUS=testing
   LAST_UPDATED={YYYY-MM-DD}
   ```

3. **テスト計画読み込み**
   - `50_test_plan.md` から Test Execution Commands を抽出
   - E2E Test の Run by default 設定を確認

4. **テスト実行**
   - Unit Tests → Integration Tests → E2E Tests (条件付き)
   - 失敗しても続行してレポート

5. **結果レポート**
   - サマリー (Total/Passed/Failed/Skipped)
   - 失敗したテストの詳細 (ファイル名/行番号/エラー)

6. **結果記録**
   - `50_test_plan.md` の Test Results セクションを更新

## 出力例

成功時:
```
✅ テスト実行完了
Total: 45 tests | Passed: 45 | Failed: 0
次のステップ: /sdlc-check FEATURE-10
```

失敗時:
```
❌ テスト実行完了（失敗あり）
Total: 45 tests | Passed: 42 | Failed: 3

失敗したテスト:
  ✗ TestCalculateTotal (calculator_test.go:42)
    Error: expected 100, got 95

次のステップ: 失敗を修正後、再実行
```
