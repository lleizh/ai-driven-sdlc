# /sdlc-pr-code - Refined Flow Analysis

## コマンド概要
実装 PR（Code Review PR）を作成します

## 使用方法
```bash
/sdlc-pr-code <feature-id>
```

## 現在の構造
- **ステップ数**: 9
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
        "Decisions が CONFIRMED ではありません" \
        "現在: ${DECISION_STATUS}" \
        "/sdlc-pr-design ${FEATURE_ID} で Design Review PR を完了してください"
    exit 1
fi
```

**共有スクリプト**:
- `check_feature_exists()` - Feature 存在確認
- `scripts/check-branch.sh` - ブランチ検証
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示

---

### Step 2: メタデータ更新

**目的**: STATUS を review に更新

**実行内容**:
```bash
scripts/update-metadata.sh "$FEATURE_ID" "STATUS" "review"
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

**共有スクリプト**:
- `scripts/update-metadata.sh` - Metadata 更新

---

### Step 3: Commit & Push

**目的**: Metadata の変更を commit & push

**実行内容**:
```bash
ISSUE_NUMBER=$(get_metadata_value "$FEATURE_ID" "ISSUE_URL" | grep -oE '[0-9]+$')

git add "sdlc/features/${FEATURE_ID}/.metadata"
git commit -m "chore(${FEATURE_ID}): update STATUS to review

Related: #${ISSUE_NUMBER}"

git push origin "feature/${FEATURE_ID}"
```

**共有スクリプト**:
- `get_metadata_value()` - Metadata 値取得

---

### Step 4: Feature ドキュメント読取

**目的**: PR Description 生成に必要な情報を収集

**読取ドキュメント**:
```bash
FEATURE_DIR="sdlc/features/${FEATURE_ID}"

# 必須
- ${FEATURE_DIR}/.metadata
- ${FEATURE_DIR}/00_context.md
- ${FEATURE_DIR}/decisions.md

# オプション
- ${FEATURE_DIR}/30_implementation_plan.md
- ${FEATURE_DIR}/50_test_plan.md
```

**抽出する情報**:
- Issue URL、Feature ID
- Context: Goals、Why、What
- Decisions: Chosen Options（CONFIRMED のみ）
- Implementation Plan: 主な変更点、タスク完成度
- Test Plan: テスト概要、カバレッジ

---

### Step 5: PR Description 生成

**目的**: Code Review PR の説明文を生成

**生成内容**:

#### 🎯 実装内容
- Context の Goals
- Issue URL
- Design PR へのリンク

#### 📝 実装説明
- Implementation Plan から主な変更点
- 実装したコンポーネント
- 技術スタック

#### ✅ 確定済み Decisions

| Decision | Chosen Option | Rationale |
|----------|---------------|-----------|
| {決定事項} | {選択} | {理由} |

#### 🧪 テスト
- Test Plan からテスト概要
- テストカバレッジ
- テスト実行結果

#### ⚠️ Breaking Changes
（ある場合のみ）
- 互換性のない変更
- マイグレーション手順

#### 📚 関連ドキュメント
- Issue: #{ISSUE_NUMBER}
- Design PR: #{DESIGN_PR_NUMBER}
- Feature Docs: `sdlc/features/{FEATURE_ID}/`

#### ✅ マージ条件
- [ ] CI チェック通過
- [ ] コードレビュー承認
- [ ] ドキュメント更新完了

---

### Step 6: PR 作成

**目的**: GitHub に Code Review PR を作成

**実行内容**:
```bash
# Extract title from context
TITLE=$(get_metadata_value "$FEATURE_ID" "TITLE")
ISSUE_NUMBER=$(get_metadata_value "$FEATURE_ID" "ISSUE_URL" | grep -oE '[0-9]+$')

# Create PR
gh pr create \
  --title "${FEATURE_ID}: ${TITLE}" \
  --body "{生成した PR Description}" \
  --label "implementation" \
  --base develop

# Get PR URL
PR_URL=$(gh pr view --json url -q .url)
```

**共有スクリプト**:
- `get_metadata_value()` - Metadata 値取得

**完了メッセージ**（出力のみ、ステップではない）:
```
✅ Implementation PR を作成しました

📋 PR 情報:
- URL: {GitHub PR URL}
- Branch: feature/{FEATURE_ID}
- Label: implementation
- Status: review

次のステップ:
- CI チェックを確認
- コードレビューを依頼
```

---

## 最適化提案

### 現在の問題点

1. **命名不統一**: 
   - Step 1: "前提チェック" → "前提確認" に変更すべき

2. **Rebase 不要**:
   - 前提確認は「検査」のみ
   - Rebase は削除すべき

3. **Commit/Push 独立**:
   - Metadata 更新と Commit/Push を分離
   - 各ステップの職責を明確化

4. **ステップの粒度**:
   - Step 2 "ブランチ確認" は Step 1 に統合
   - Step 3 "Rebase" は削除
   - Step 5 "Commit と Push" は削除
   - Step 9 "完了メッセージ" は出力のみ

### 最適化案

**9 Steps → 6 Steps**

```
1. 前提確認（Feature 存在 + Decision Status + ブランチ確認）
2. メタデータ更新（STATUS=review）
3. Commit & Push
4. Feature ドキュメント読取
5. PR Description 生成
6. PR 作成
```

**変更内容**:
- Step 1 "前提チェック" → "前提確認" に変更（命名統一）
- Step 2 "ブランチ確認" を Step 1 に統合
- Step 3 "Rebase with develop" を削除（前提確認は検査のみ）
- Step 3 Commit & Push を独立させる
- Step 9 "完了メッセージ" を削除（出力のみ）

---

## エラーハンドリング

| エラー状況 | 処理 | 使用機能 |
|-----------|------|---------|
| Feature 不存在 | エラー表示して終了 | `check_feature_exists()` |
| ブランチ不一致 | エラー表示して終了 | `check-branch.sh` |
| Decision 未確定 | Design PR 完了を促す | `display_error()` |
| gh 未認証 | `gh auth login` を促す | - |
| PR 作成失敗 | エラー詳細を表示 | - |

---

## 共有スクリプト活用状況

✅ **完全対応** - すべての共有スクリプトを適切に使用

- `check_feature_exists()` - Feature 存在確認
- `scripts/check-branch.sh` - ブランチ検証
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示
- `scripts/update-metadata.sh` - Metadata 更新

**削除推奨**:
- `scripts/rebase-with-develop.sh` - Rebase は不要

**sed 使用**: ❌ なし（完全に `update-metadata.sh` を使用）

---

## /sdlc-pr-design との比較

| 項目 | /sdlc-pr-design | /sdlc-pr-code |
|-----|----------------|---------------|
| 目的 | Design Review PR | Code Review PR |
| Base Branch | develop | develop |
| Label | design-review | implementation |
| STATUS | design | review |
| 前提条件 | Feature 存在 | Decision CONFIRMED |
| Rebase | なし | なし（削除） |
| Commit/Push | なし | なし（削除） |

**一貫性**: 両コマンドは同じ構造を持つべき

---

## 次のステップ

PR 作成後:
1. CI チェックを確認
2. コードレビューを依頼
3. レビューコメントに対応
4. approve されたらマージ

---

## 結論

**現状**: 共有スクリプトの使用は完璧だが、ステップの命名と構造に改善の余地あり

**推奨変更**:
1. "前提チェック" → "前提確認" に変更
2. ブランチ確認を統合
3. Rebase を削除（前提確認は検査のみ）
4. Commit & Push を独立させる（PR 作成前に必要）
5. "完了メッセージ" を削除（出力のみ）

**最終ステップ数**: 9 → **6**

**注意**: `/sdlc-pr-design` も同様に Commit & Push を追加する必要がある
