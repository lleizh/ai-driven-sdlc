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

```bash
gh issue create \
  --title "[FEATURE] {タイトル}" \
  --body "{生成した内容}" \
  --label "feature"
```

### 4. 完了メッセージ

```
✅ GitHub Issue を作成しました

Issue: https://github.com/owner/repo/issues/123
Feature ID: FEATURE-123

次のステップ:
/sdlc-init https://github.com/owner/repo/issues/123
```

---

## エラー処理

- GitHub CLI 未認証 → `gh auth login` を実行
- 対話内容が不明確 → 不足している情報を質問
