# /sdlc-issue - 流程整理

## 文档依据

- **AI_SDLC.md**: Issue は唯一の入口（Single Entry Point）
- **SDLC_FLOW.md**: Step 1 - GitHub Issue 作成
- **STATUS_MANAGEMENT.md**: STATUS = Backlog（GitHub Projects）

---

## 命令目的

GitHub Issue を作成し、AI-driven SDLC の入口を確立する。

---

## 前提条件

**必須**:
- ✅ GitHub CLI (`gh`) がインストール済み
- ✅ `gh auth login` 実行済み
- ✅ ユーザーと AI が既に問題について対話している

**非必須**:
- Feature は未存在（新規作成）
- ブランチは未作成
- `.metadata` は未作成

---

## 実行フロー

### 1. 対話内容を分析

現在の対話から以下を抽出：

| 項目 | 説明 | 必須 |
|------|------|------|
| **Why** | なぜこの機能/修正が必要か | ✅ 必須 |
| **What** | 何を実現するか | ✅ 必須 |
| **How** | どうやって実現するか（初期案） | ⚠️ オプション |
| **Risk Level** | High/Medium/Low | ✅ 必須 |

**Risk Level 判定基準**（AI_SDLC.md 準拠）:
- **High**: データ損失リスク、セキュリティ影響、アーキテクチャ変更
- **Medium**: 複数モジュール影響、パフォーマンス影響
- **Low**: 単一モジュール、UI のみ、ドキュメント

---

### 2. Issue 内容を生成

**テンプレート**: `.github/ISSUE_TEMPLATE/feature.md`

**必須セクション**:
```markdown
## Why (なぜこの機能が必要か)
{対話から抽出した背景と理由}

## What (何を実現するか)
{具体的な目標とスコープ}

## How (どうやって実現するか - 初期案)
{対話していれば記載、なければ TBD}

## Risk Level (初期リスク評価)
- [x] **High**: {理由} / **Medium**: {理由} / **Low**: {理由}

### リスク評価の理由
{なぜこのリスクレベルと判断したか}

## Feature ID
FEATURE-TBD

## 関連情報
{関連 Issue、ドキュメント、参考資料}

## 受け入れ基準（Acceptance Criteria）
- [ ] {検証可能な基準1}
- [ ] {検証可能な基準2}
- [ ] {検証可能な基準3}
```

**原則**（AI_SDLC.md 準拠）:
- Why/What/Risk は明確に記載
- How は初期案のみ（詳細は設計フェーズで）
- Acceptance Criteria は検証可能な形式

---

### 3. GitHub Issue 作成

```bash
# Issue 作成（2つの label を付与）
issue_url=$(gh issue create \
  --title "[FEATURE] {タイトル}" \
  --body "{生成した内容}" \
  --label "feature" \
  --label "sdlc:track")

# Issue 番号を取得
issue_number=$(echo "$issue_url" | grep -o '[0-9]*$')
```

**重要**: `sdlc:track` ラベル追加
- **効果**: GitHub Actions (`auto-add-issues.yml`) が自動実行
- **結果**: Issue が GitHub Projects の **Backlog** に追加される
- **STATUS**: Projects の STATUS フィールドが **Backlog** に設定される

---

### 4. Feature ID を更新

Issue 本文の `FEATURE-TBD` を実際の Feature ID に置き換え：

```bash
# Issue 本文を取得して Feature ID を置き換え
gh issue view "$issue_number" --json body -q .body | \
  sed "s/FEATURE-TBD/FEATURE-$issue_number/g" | \
  gh issue edit "$issue_number" --body-file -
```

**結果**: Feature ID = `FEATURE-{issue_number}`

---

### 5. 完了メッセージ

```
✅ GitHub Issue を作成しました

📋 Issue 情報:
- URL: https://github.com/{owner}/{repo}/issues/{issue_number}
- Feature ID: FEATURE-{issue_number}
- Risk Level: {level}
- Labels: feature, sdlc:track

📊 GitHub Projects:
✅ Issue は自動的に Projects の Backlog に追加されました
   STATUS: Backlog

📝 次のステップ:
/sdlc-init https://github.com/{owner}/{repo}/issues/{issue_number}
```

---

## 状態変化

### GitHub Issue
- **作成前**: Issue 不存在
- **作成後**: Issue #{number} 作成済み、Labels: `feature`, `sdlc:track`

### GitHub Projects
- **自動追加**: `auto-add-issues.yml` が実行
- **STATUS**: **Backlog** に設定

### .metadata
- **変化なし**: このコマンドでは `.metadata` を作成しない
- **次のステップ**: `/sdlc-init` で `.metadata` を作成

---

## エラー処理

### GitHub CLI 未認証
```
❌ エラー: GitHub CLI が認証されていません

Action: gh auth login を実行してください
```

### 対話内容不足
```
⚠️ 警告: 情報が不足しています

以下の情報を教えてください:
- Why: なぜこの機能が必要ですか？
- What: 何を実現したいですか？
- Risk Level: リスクレベルは？（High/Medium/Low）
```

### Issue 作成失敗
```
❌ エラー: Issue の作成に失敗しました

Context: {エラー詳細}
Action: 
- gh auth status を確認
- Repository のアクセス権限を確認
```

---

## AI_SDLC.md との整合性

✅ **原則 1**: Issue は唯一の入口（Single Entry Point）
- このコマンドで Issue を作成 → すべての作業の起点

✅ **原則 3**: Decision は人間が行い、AI はドラフトと実行を担う
- このコマンドは Issue ドラフトを生成（AI）
- ユーザーが内容を確認・承認（人間）

✅ **三原則 1**: Issue がなければコードを書かない
- このコマンドで Issue を作成 → 以降の作業が可能に

---

## SDLC_FLOW.md との整合性

✅ **Step 1**: GitHub Issue (唯一の入口)
- Why/What/Risk を記述 → このコマンドで実現

✅ **次のステップ**: `/sdlc-init` (AI が SDLC 草稿を生成)
- Issue URL を使って SDLC 文書を生成

---

## STATUS_MANAGEMENT.md との整合性

✅ **STATUS 遷移**:
```
(Issue 不存在) → Backlog (Projects)
                    ↓
                /sdlc-issue + GitHub Actions
```

✅ **GitHub Actions 連携**:
- Workflow: `auto-add-issues.yml`
- トリガー: `sdlc:track` label 追加
- 動作: Issue を Projects の Backlog に追加

---

## 共有スクリプトの使用

**現状**: ❌ 共有スクリプトを使用していない

**改善案**: 
- このコマンドは Issue 作成のみ
- Feature 未存在のため `check_feature_exists()` は不要
- GitHub CLI 認証確認に `check_gh_auth()` を使用可能

**推奨**:
```bash
source scripts/common-functions.sh

# GitHub CLI 認証確認
check_gh_auth || exit 1

# Issue 作成
log_info "Creating GitHub Issue..."
issue_url=$(gh issue create ...)

log_success "Issue created: ${issue_url}"
```

---

## まとめ

### このコマンドの役割
1. AI-driven SDLC の**入口**を作成
2. Why/What/Risk を明確化
3. GitHub Projects の Backlog に自動追加

### 次のステップ
- `/sdlc-init` で SDLC 文書を生成
- `.metadata` を作成
- STATUS: Backlog → planning

### 重要な制約
- Issue がなければ以降の作業は開始できない（三原則）
- `sdlc:track` ラベルは必須（Projects 連携）
