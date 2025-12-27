# Command: /sdlc-pr-design

設計レビュー PR を作成します。

## 使用方法

```
/sdlc-pr-design <feature-id>
```

## 実行内容

### 1. Feature ドキュメント読取

以下のファイルを読み取る：
- `sdlc/features/{FEATURE_ID}/.metadata`
- `sdlc/features/{FEATURE_ID}/00_context.md`
- `sdlc/features/{FEATURE_ID}/decisions.md`
- `sdlc/features/{FEATURE_ID}/risks.md`
- `sdlc/features/{FEATURE_ID}/10_requirements.md`（存在する場合）
- `sdlc/features/{FEATURE_ID}/20_design.md`（存在する場合）

### 2. PR Description 生成

以下のセクションを含む Markdown を生成：

**📖 レビュアーへ：必読ファイル（最小セット）**
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

**🎯 目標**（3行以内）
- Context の Goals から抽出

**📋 背景**
- Background と Problem Statement
- Issue URL と Risk Level

**🔑 主要な決定事項**（最大3つ）
- 各 Decision の Options
- Status: PENDING
- 確認が必要な内容

**🏗️ 設計方案**
- 推奨方案（あれば）
- Trade-offs（利点と制約）

**⚠️ リスク評価**（Top 5）
- Risk ID, リスク, レベル, 緩和策（表形式）

**👀 レビュアーへ：重点確認事項**（3つ）
- Decisions/Risks から最も議論が必要な問題

**📚 関連ドキュメント**
- Issue URL とファイルパス

**✅ マージ条件**
- Decisions が CONFIRMED
- チーム合意

### 3. ブランチ確認

現在のブランチを確認：
- `design/{FEATURE_ID}` → OK
- それ以外 → 警告表示、続行確認

ブランチが存在しない場合：
```bash
git checkout -b design/{FEATURE_ID}
```

### 4. メタデータ更新

`.metadata` を更新：
```
STATUS=design
LAST_UPDATED={YYYY-MM-DD}
```

### 5. PR 作成

```bash
gh pr create \
  --title "Design: {FEATURE_ID} - {タイトル}" \
  --body "{生成した PR Description}" \
  --label "design-review" \
  --base develop
```

### 6. 完了メッセージ

```
✅ Design Review PR を作成しました

📋 PR 情報:
- URL: {GitHub PR URL}
- Branch: design/{FEATURE_ID}
- Label: design-review
- Status: design

次のステップ:
- チームメンバーをレビュアーに追加
- Decisions を議論・確定
- decisions.md の Status を CONFIRMED に更新
- PR をマージ
```

---

## エラー処理

- Feature 不存在 → `❌ /sdlc-init <issue-url> を先に実行`
- gh 未認証 → `❌ gh auth login を実行`
- ブランチ不一致 → 警告表示、新ブランチ作成を提案
- PR 作成失敗 → push 確認、gh auth status 確認
