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

### 2. Feature ドキュメント読取

以下のファイルを読み取る：
- `sdlc/features/{FEATURE_ID}/.metadata`
- `sdlc/features/{FEATURE_ID}/00_context.md`
- `sdlc/features/{FEATURE_ID}/decisions.md`
- `sdlc/features/{FEATURE_ID}/30_implementation_plan.md`（存在する場合）
- `sdlc/features/{FEATURE_ID}/50_test_plan.md`（存在する場合）

### 3. PR Description 生成

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

### 4. ブランチ確認と Rebase

現在のブランチを確認：
- `feature/{FEATURE_ID}` → OK
- それ以外 → 警告表示

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

### 5. メタデータ更新

`.metadata` を更新：
```
STATUS=review
LAST_UPDATED={YYYY-MM-DD}
```

### 6. Push と PR 作成

```bash
# feature ブランチを push
git push origin feature/{FEATURE_ID} -f

# PR を作成
gh pr create \
  --title "{FEATURE_ID}: {タイトル}" \
  --body "{生成した PR Description}" \
  --label "implementation" \
  --base develop
```

注：rebase 後は `-f` (force push) が必要です。

### 7. 完了メッセージ

```
✅ Implementation PR を作成しました

📋 PR 情報:
- URL: {GitHub PR URL}
- Branch: feature/{FEATURE_ID}
- Label: implementation
- Status: review

⚠️ GitHub Branch Protection:
PR マージ前に、GitHub が自動的に branch が up-to-date か確認します。
数日後に develop が進んだ場合、GitHub UI の "Update branch" をクリックしてください。

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
