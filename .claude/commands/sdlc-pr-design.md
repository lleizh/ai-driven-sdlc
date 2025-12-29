# Command: /sdlc-pr-design

設計レビュー PR を作成します。

## 使用方法

```
/sdlc-pr-design <feature-id>
```

## 実行内容

### 1. ブランチ確認

**共有スクリプトを使用**：
```bash
source scripts/common-functions.sh

# Feature 存在確認
check_feature_exists "$FEATURE_ID" || exit 1

# ブランチ検証（存在しない場合は作成）
scripts/check-branch.sh "$FEATURE_ID" || {
    echo "ブランチを作成・切り替えますか？ (y/N)"
    read -r response
    if [[ "$response" == "y" ]]; then
        git checkout -b "feature/${FEATURE_ID}" 2>/dev/null || git checkout "feature/${FEATURE_ID}"
    else
        exit 1
    fi
}
```

### 2. Rebase with develop

**共有スクリプトを使用**：
```bash
scripts/rebase-with-develop.sh "$FEATURE_ID" || exit 1
```

### 3. メタデータ更新

**共有スクリプトを使用**：
```bash
scripts/update-metadata.sh "$FEATURE_ID" "STATUS" "design"
scripts/update-metadata.sh "$FEATURE_ID" "LAST_UPDATED" "$(date +%Y-%m-%d)"
```

### 4. Commit と Push

```bash
ISSUE_NUMBER=$(get_metadata_value "$FEATURE_ID" "ISSUE_URL" | grep -oE '[0-9]+$')

git add "sdlc/features/${FEATURE_ID}/.metadata"
git commit -m "chore(${FEATURE_ID}): update STATUS to design

Related: #${ISSUE_NUMBER}"

# 新しいブランチの場合は -u、既存の場合は通常 push
git push origin "feature/${FEATURE_ID}" || git push -u origin "feature/${FEATURE_ID}"
```

### 5. Feature ドキュメント読取

以下のファイルを読み取る：
- `.metadata`
- `00_context.md`
- `decisions.md`
- `risks.md`
- `10_requirements.md`（存在する場合）
- `20_design.md`（存在する場合）

### 6. PR Description 生成

以下のセクションを含む Markdown を生成：

**📖 レビュアーへ：必読ファイル**：
```
✅ 必読（これだけ読めばOK）:
  - Issue（GitHub）
  - decisions.md（PENDING 状態）
  - risks.md
  - 20_design.md（DRAFT 状態、存在する場合）

📎 参考（optional）:
  - 00_context.md
  - 10_requirements.md
```

**🎯 目標**（3行以内）：
- Context の Goals から抽出

**📋 背景**：
- Background と Problem Statement
- Issue URL と Risk Level

**🔑 主要な決定事項**（最大3つ）：
- 各 Decision の Options
- Status: PENDING
- 確認が必要な内容

**🏗️ 設計方案**：
- 推奨方案（あれば）
- Trade-offs（利点と制約）

**⚠️ リスク評価**（Top 5）：
- Risk ID, リスク, レベル, 緩和策（表形式）

**👀 レビュアーへ：重点確認事項**（3つ）：
- Decisions/Risks から最も議論が必要な問題

**📚 関連ドキュメント**：
- Issue URL とファイルパス

**✅ マージ条件**：
- Decisions が CONFIRMED
- チーム合意

### 7. PR 作成

```bash
gh pr create \
  --title "Design: ${FEATURE_ID} - {タイトル}" \
  --body "{生成した PR Description}" \
  --label "design-review" \
  --base develop
```

### 8. 完了メッセージ

```
✅ Design Review PR を作成しました

📋 PR 情報:
- URL: {GitHub PR URL}
- Branch: feature/{FEATURE_ID}
- Label: design-review
- Status: design

次のステップ:
- チームメンバーをレビュアーに追加
- Decisions を議論・確定
- decisions.md の Status を CONFIRMED に更新
- PR をマージ
```

---

## 共有スクリプトの活用

このコマンドは以下の共有機能を使用：
- `check_feature_exists()` - Feature 存在確認
- `get_metadata_value()` - Metadata 値取得
- `check-branch.sh` - ブランチ検証
- `rebase-with-develop.sh` - Rebase 処理
- `update-metadata.sh` - Metadata 更新

---

## エラー処理

- Feature 不存在 → `check_feature_exists()` がエラー表示
- gh 未認証 → `gh auth login` を促す
- Rebase 失敗 → `rebase-with-develop.sh` がガイダンス表示
