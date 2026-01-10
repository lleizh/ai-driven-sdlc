---
description: 実装 PR（Code Review PR）を作成する
---

# Command: /sdlc-pr-code

実装 PR（Code Review PR）を作成します。

## 使用方法

```
/sdlc-pr-code <feature-id>
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

### 2. メタデータ更新

**共有スクリプトを使用**：
```bash
scripts/update-metadata.sh "$FEATURE_ID" "STATUS" "review"
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

### 3. Commit & Push

```bash
ISSUE_NUMBER=$(get_metadata_value "$FEATURE_ID" "ISSUE_URL" | grep -oE '[0-9]+$')

git add "sdlc/features/${FEATURE_ID}/.metadata"
git commit -m "chore(${FEATURE_ID}): update STATUS to review

Related: #${ISSUE_NUMBER}"

git push origin "feature/${FEATURE_ID}"
```

### 4. Feature ドキュメント読取

以下のファイルを読み取る：
- `.metadata`
- `00_context.md`
- `decisions.md`
- `30_implementation_plan.md`（存在する場合）
- `50_test_plan.md`（存在する場合）

### 5. PR Description 生成

以下のセクションを含む Markdown を生成：

**🎯 実装内容**：
- Context の Goals
- Issue URL
- Design PR へのリンク

**📝 実装説明**：
- Implementation Plan から主な変更点
- 実装したコンポーネント
- 技術スタック

**✅ 確定済み Decisions**（表形式）：

| Decision | Chosen Option | Rationale |
|----------|---------------|-----------|
| {決定事項} | {選択} | {理由} |

**🧪 テスト**：
- Test Plan からテスト概要
- テストカバレッジ
- テスト実行結果

**⚠️ Breaking Changes**：
（ある場合のみ）
- 互換性のない変更
- マイグレーション手順

**📚 関連ドキュメント**：
- Issue: #{ISSUE_NUMBER}
- Design PR: #{DESIGN_PR_NUMBER}
- Feature Docs: `sdlc/features/{FEATURE_ID}/`

**✅ マージ条件**：
- [ ] CI チェック通過
- [ ] コードレビュー承認
- [ ] ドキュメント更新完了

### 6. PR 作成

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

---

## 完了後の次のステップ

PR 作成後：
1. CI チェックを確認
2. コードレビューを依頼
3. レビューコメントに対応
4. approve されたらマージ

---

## 共有スクリプトの活用

このコマンドは以下の共有機能を使用：
- `check_feature_exists()` - Feature 存在確認
- `check-branch.sh` - ブランチ検証
- `get_metadata_value()` - Metadata 値取得
- `display_error()` - エラー表示
- `update-metadata.sh` - Metadata 更新

---

## エラー処理

- Feature 不存在 → `check_feature_exists()` がエラー表示
- ブランチ不一致 → `check-branch.sh` がエラー表示
- Decision 未確定 → Design PR 完了を促す
- gh 未認証 → `gh auth login` を促す
- PR 作成失敗 → エラー詳細を表示
