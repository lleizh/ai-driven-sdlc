# Command: /sdlc-pr-code

実装 PR を作成します。

## 使用方法

```
/sdlc-pr-code <feature-id>
```

## 実行内容

### 1. 前提チェック

Decision Status が CONFIRMED か確認：
```bash
grep "Status.*: CONFIRMED" sdlc/features/{FEATURE_ID}/decisions.md
```

CONFIRMED でない場合、**エラー終了**：
```
❌ エラー: Decisions が CONFIRMED ではありません

現在: PENDING

まず Design Review PR で Decisions を確定してください:
/sdlc-pr-design {FEATURE_ID}
```

### 2. ブランチ確認

現在のブランチを確認：
```bash
current_branch=$(git branch --show-current)

if [ "$current_branch" != "feature/${FEATURE_ID}" ]; then
  echo "⚠️ 警告: 現在のブランチは feature/${FEATURE_ID} ではありません"
  echo "現在: $current_branch"
  echo ""
  echo "このまま続行しますか？ (y/N)"
  read -r response
  if [ "$response" != "y" ]; then
    exit 1
  fi
fi
```

### 3. Rebase with develop

develop から最新を取得して rebase：
```bash
echo "📊 Rebasing with develop..."
git fetch origin develop
git rebase origin/develop

# コンフリクトがある場合
if [ $? -ne 0 ]; then
  echo "⚠️ Rebase conflicts detected. Please resolve and run:"
  echo "   git rebase --continue"
  echo "   Then re-run /sdlc-pr-code {FEATURE_ID}"
  exit 1
fi
```

### 4. メタデータ更新

`.metadata` を更新：
```bash
# STATUS を review に変更
sed -i '' 's/^STATUS=.*/STATUS=review/' sdlc/features/${FEATURE_ID}/.metadata

# LAST_UPDATED を更新
current_date=$(date +%Y-%m-%d)
if grep -q "^LAST_UPDATED=" sdlc/features/${FEATURE_ID}/.metadata; then
  sed -i '' "s/^LAST_UPDATED=.*/LAST_UPDATED=${current_date}/" sdlc/features/${FEATURE_ID}/.metadata
else
  echo "LAST_UPDATED=${current_date}" >> sdlc/features/${FEATURE_ID}/.metadata
fi
```

### 5. Commit と Push

```bash
# .metadata の変更を commit
git add sdlc/features/${FEATURE_ID}/.metadata
git commit -m "chore(${FEATURE_ID}): update STATUS to review

Related: #<issue-number>"

# Force push（rebase したため -f が必要）
git push origin feature/${FEATURE_ID} -f
```

### 6. Feature ドキュメント読取

以下のファイルを読み取る：
- `sdlc/features/{FEATURE_ID}/.metadata`
- `sdlc/features/{FEATURE_ID}/00_context.md`
- `sdlc/features/{FEATURE_ID}/decisions.md`
- `sdlc/features/{FEATURE_ID}/30_implementation_plan.md`（存在する場合）
- `sdlc/features/{FEATURE_ID}/50_test_plan.md`（存在する場合）

### 7. PR Description 生成

以下のセクションを含む Markdown を生成：

**🎯 実装内容**
- Context の Goals
- Issue URL
- Design PR へのリンク（GitHub で検索: `is:pr label:design-review {FEATURE_ID}`）

**📝 実装説明**
- Implementation Plan から主な変更点を抽出

**✅ 確定済み Decisions**（表形式）
- Decision | 選択した Option | 理由

**🧪 テスト**
- Test Plan からテスト概要
- テストカバレッジ（Unit/Integration/E2E）

**⚠️ Breaking Changes**
- Breaking Changes がある場合のみ記載

**📚 関連ドキュメント**
- Issue URL とファイルパス

**✅ マージ条件**
- テスト通過
- コードレビュー承認
- ドキュメント更新

### 8. PR 作成

```bash
# PR を作成
gh pr create \
  --title "{FEATURE_ID}: {タイトル}" \
  --body "{生成した PR Description}" \
  --label "implementation" \
  --base develop
```

### 9. 完了メッセージ

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

## エラー処理

- Feature 不存在 → `❌ /sdlc-init <issue-url> を先に実行`
- Decision 未確定 → `❌ まず /sdlc-pr-design で Design PR を完了`
- gh 未認証 → `❌ gh auth login を実行`
- ブランチ不一致 → 警告表示、続行確認
- PR 作成失敗 → push 確認、gh auth status 確認
