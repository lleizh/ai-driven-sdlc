---
description: 現在の対話内容を基に GitHub Issue を作成する
---

# Command: /sdlc-issue

現在の対話内容を基に GitHub Issue を作成します。

## 使用方法

```
/sdlc-issue
```

## 前提

- ユーザーと AI が既に問題について対話している
- AI は問題の内容を理解している

## 実行内容

### 1. 対話内容を分析

現在の対話から以下を抽出：
- **Why**: なぜこの機能/修正が必要か
- **What**: 何を実現するか
- **How**: どうやって実現するか（議論していれば）
- **Risk Level**: 対話内容から判定（High/Medium/Low）

### 2. Issue 内容を生成

`.github/ISSUE_TEMPLATE/feature.md` のフォーマットで生成：

```markdown
## Why (なぜこの機能が必要か)
{対話から抽出}

## What (何を実現するか)
{対話から抽出}

## How (どうやって実現するか - 初期案)
{対話から抽出、なければ空欄}

## Risk Level (初期リスク評価)
- [x] **{判定した Level}**: {理由}

### リスク評価の理由
{なぜこのリスクレベルか}

## Feature ID
FEATURE-TBD

## 関連情報
{あれば}

## 受け入れ基準（Acceptance Criteria）
- [ ] {基準1}
- [ ] {基準2}
```

### 3. GitHub Issue 作成

Feature ID を `FEATURE-TBD` として Issue を作成：

```bash
issue_url=$(gh issue create \
  --title "[FEATURE] {タイトル}" \
  --body "{生成した内容}" \
  --label "feature" \
  --label "sdlc:track")
```

注：`sdlc:track` ラベルを追加することで、Issue が自動的に GitHub Projects の Backlog に追加されます。

### 4. Feature ID を更新

Issue 番号を取得し、Feature ID を更新：

```bash
# Issue 番号を取得
issue_number=$(echo "$issue_url" | grep -oE '[0-9]+$')

# Issue 本文を取得し、FEATURE-TBD を置換
updated_body=$(gh issue view "$issue_number" --json body -q .body | sed "s/FEATURE-TBD/FEATURE-$issue_number/g")

# Issue を更新
echo "$updated_body" | gh issue edit "$issue_number" --body-file -
```

---

## 完了後の次のステップ

Issue 作成後：
```
次のステップ:
/sdlc-init https://github.com/owner/repo/issues/{issue_number}
```

---

## エラー処理

- GitHub CLI 未認証 → gh がエラー表示、`gh auth login` を実行
- 対話内容が不明確 → 不足している情報を質問
- Issue 作成失敗 → gh エラーメッセージを表示
