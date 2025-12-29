# /sdlc-coding - Refined Flow Analysis

## コマンド概要
Decision 確定後、実装を開始する

## 使用方法
```bash
/sdlc-coding <feature-id>
```

## 現在の構造
- **ステップ数**: 7
- **共有スクリプト使用**: ✅ 完全対応
- **命名統一性**: ⚠️ "前提チェック" → "前提確認" に変更必要

---

## 詳細フロー

### Step 1: 前提確認

**目的**: Feature 存在、Decision Status、ブランチの確認

**実行内容**:
```bash
source scripts/common-functions.sh

# Feature 存在確認
check_feature_exists "$FEATURE_ID" || exit 1

# ブランチ確認
scripts/check-branch.sh "$FEATURE_ID" || exit 1

# Decision Status 確認
DECISION_STATUS=$(get_metadata_value "$FEATURE_ID" "DECISION_STATUS")

if [[ "$DECISION_STATUS" != "confirmed" ]]; then
    display_error \
        "Decision が CONFIRMED ではありません" \
        "現在: ${DECISION_STATUS}" \
        "/sdlc-decision ${FEATURE_ID} で Decision を確定してください"
    exit 1
fi
```

**共有スクリプト**:
- `check_feature_exists()` - Feature 存在確認
- `scripts/check-branch.sh` - ブランチ検証
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示

---

### Step 2: ドキュメント読取

**目的**: 実装に必要な情報を収集

**必須ドキュメント**:
- `.metadata` - Feature メタデータ
- `00_context.md` - 背景と目的
- `decisions.md` - 確定済み Decision（CONFIRMED のみ）
- `risks.md` - リスク情報

**オプションドキュメント**:
- `20_design.md` - 設計詳細（存在する場合）
- `30_implementation_plan.md` - 実装計画（存在する場合）

**注意点**:
- `decisions.md` の **Chosen Options** に厳密に従う
- **Rejected Options** は使用しない
- **Non-Negotiables** を必ず守る

---

### Step 3: 実装

**目的**: Chosen Options に基づいてコードを実装

**実行内容**:
1. **コード実装**
   - 新規ファイル作成
   - 既存ファイル修正
   - `CLAUDE.md` のコーディング規約に従う

2. **テストコード作成**
   - ユニットテスト
   - 統合テスト（必要に応じて）

3. **テスト実行**
   - すべてのテストを実行
   - 結果を確認

4. **ビルド確認**
   - プロジェクトのビルド
   - エラーがないことを確認

**実装の原則**:
- Chosen Options に厳密に従う
- Rejected Options は使用しない
- Non-Negotiables を守る
- 設計を再議論しない

**Design Drift 検出**:
- 実装中に Decision と矛盾が発生した場合
- 実装を停止し、`/sdlc-revise` を促す

---

### Step 4: メタデータ更新

**目的**: STATUS を implementing に更新

**実行内容**:
```bash
scripts/update-metadata.sh "$FEATURE_ID" "STATUS" "implementing"
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

**共有スクリプト**:
- `scripts/update-metadata.sh` - Metadata 更新

**完了メッセージ**（出力のみ、ステップではない）:
```
✅ 実装が完了しました

ブランチ: feature/{FEATURE_ID}

ファイル変更:
- 新規: {count} ファイル
- 修正: {count} ファイル

テスト結果: PASS/FAIL
ビルド結果: PASS/FAIL

次のステップ: 
{Medium/High リスクの場合}
1. /sdlc-test {FEATURE_ID} でテストを実行
2. /sdlc-check {FEATURE_ID} で最終確認
3. /sdlc-pr-code {FEATURE_ID} でPR作成

{Low リスクの場合}
1. /sdlc-check {FEATURE_ID} で最終確認
2. /sdlc-pr-code {FEATURE_ID} でPR作成
```

---

## 最適化提案

### 現在の問題点

1. **命名不統一**: 
   - Step 1: "前提チェック" → "前提確認" に変更すべき

2. **Rebase 不要**:
   - 前提確認は「検査」のみ
   - Rebase は「操作」であり、前提確認に含めるべきではない

3. **完了メッセージ**:
   - 独立したステップとしてカウントされている
   - 出力であり、実行ステップではない

### 最適化案

**7 Steps → 4 Steps**

```
1. 前提確認（Feature 存在 + Decision Status + ブランチ確認）
2. ドキュメント読取（decisions.md の Chosen Options を中心に）
3. 実装（コード + テスト + ビルド確認）
4. メタデータ更新（STATUS=implementing）
```

**変更内容**:
- Step 1 "前提チェック" → "前提確認" に変更（命名統一）
- Rebase を削除（前提確認は検査のみ）
- Step 2 (ブランチ確認と更新) を削除（Step 1 に統合）
- Commit/Push を削除（Command は metadata 更新のみ）
- Step 7 "完了メッセージ" を削除（出力のみ）

---

## エラーハンドリング

| エラー状況 | 処理 | 使用機能 |
|-----------|------|---------|
| Feature 不存在 | エラー表示して終了 | `check_feature_exists()` |
| Decision 未確定 | ガイダンス表示 | `display_error()` |
| ブランチ不一致 | エラー表示して終了 | `check-branch.sh` |
| Rebase 失敗 | ガイダンス表示 | `rebase-with-develop.sh` |
| テスト失敗 | 実装を修正 | - |
| ビルド失敗 | 実装を修正 | - |
| Design Drift 検出 | `/sdlc-revise` を促す | - |

---

## 共有スクリプト活用状況

✅ **完全対応** - すべての共有スクリプトを適切に使用

- `check_feature_exists()` - Feature 存在確認
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示
- `scripts/check-branch.sh` - ブランチ検証
- `scripts/rebase-with-develop.sh` - Rebase 処理
- `scripts/update-metadata.sh` - Metadata 更新

**sed 使用**: ❌ なし（完全に `update-metadata.sh` を使用）

---

## 次のステップ

実装完了後、Risk Level に応じて:

**Medium/High Risk**:
1. `/sdlc-test {FEATURE_ID}` - テスト実行
2. `/sdlc-check {FEATURE_ID}` - 最終確認
3. `/sdlc-pr-code {FEATURE_ID}` - Code Review PR 作成

**Low Risk**:
1. `/sdlc-check {FEATURE_ID}` - 最終確認
2. `/sdlc-pr-code {FEATURE_ID}` - Code Review PR 作成

---

## 結論

**現状**: 共有スクリプトの使用は完璧だが、ステップの命名と構造に改善の余地あり

**推奨変更**:
1. "前提チェック" → "前提確認" に変更
2. Step 1 と Step 2 を統合（Branch check と Rebase を含む）
3. "完了メッセージ" を独立ステップから削除

**最終ステップ数**: 7 → **5**
