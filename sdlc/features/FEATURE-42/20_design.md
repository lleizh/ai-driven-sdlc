# Design（設計）

**Feature ID**: FEATURE-42  
**Last Updated**: 2025-12-30  
**Status**: DRAFT

## Overview（概要）

`/sdlc-review-summary` コマンドは、GitHub PR の Review Comments を自動抽出し、構造化された `40_review_findings.md` を生成します。

設計の核心は「Convention over Configuration」：
- パラメータを極限まで削減（feature-id のみ）
- PR 番号、Review Type など全て自動推論
- 標準的なブランチ命名規則 (`feature/{FEATURE_ID}`) を前提
- 一般的なユースケースを最適化

Phase 1 で基礎実装を完成させ、Phase 2 で AI Review 統合を追加します。

## Architecture（アーキテクチャ）

### System Architecture（システムアーキテクチャ）

```
[User] --> [/sdlc-review-summary コマンド]
              |
              v
[1. PR 自動検出] --> GitHub API (gh pr list)
              |
              v
[2. Review Comments 取得] --> GitHub API (gh api)
              |
              v
[3. コメント分類] --> 規則ベース分類エンジン
              |
              v
[4. 40_review_findings.md 生成] --> Write Tool
```

### Component Design（コンポーネント設計）

#### Component: PR Detection Module
**Responsibility**（責務）: Feature ID から PR を自動検出
**Interfaces**（インターフェース）: 
- Input: `feature_id`
- Output: `pr_number`, `pr_state`, `pr_labels`
**Dependencies**（依存関係）: GitHub CLI (`gh`)

#### Component: Review Extraction Module
**Responsibility**（責務）: PR から Review Comments を取得
**Interfaces**（インターフェース）: 
- Input: `pr_number`
- Output: `reviews[]`, `comments[]`
**Dependencies**（依存関係）: GitHub API

#### Component: Classification Engine
**Responsibility**（責務）: コメントを Critical/Important/Suggestions に分類
**Interfaces**（インターフェース）: 
- Input: `comment_text`, `reviewer_state`, `emojis`
- Output: `category` (Critical/Important/Suggestions)
**Dependencies**（依存関係）: なし（規則ベース）

#### Component: Document Generator
**Responsibility**（責務）: `40_review_findings.md` を生成
**Interfaces**（インターフェース）: 
- Input: `classified_comments`, `metadata`
- Output: `40_review_findings.md`
**Dependencies**（依存関係）: Template, Write Tool

#### Component: AI Review Integrator (Phase 2)
**Responsibility**（責務）: AI Bot のコメントを統合
**Interfaces**（インターフェース）: 
- Input: `all_comments`
- Output: `human_comments`, `ai_comments`, `cross_analysis`
**Dependencies**（依存関係）: AI Bot 識別リスト

## Data Design（データ設計）

### Data Structures（データ構造）

```javascript
// PR 情報
PRInfo {
  number: int
  state: string  // "open" | "merged" | "closed"
  labels: string[]
  head_branch: string
  reviewers: string[]
}

// Review Comment
ReviewComment {
  id: string
  author: string
  body: string
  state: string  // "APPROVED" | "CHANGES_REQUESTED" | "COMMENTED"
  created_at: timestamp
  path: string  // inline comment の場合
  line: int     // inline comment の場合
}

// 分類結果
ClassifiedComment {
  category: string  // "Critical" | "Important" | "Suggestions"
  comment: ReviewComment
  reasoning: string  // 分類理由
}
```

### Data Flow（データフロー）

```
feature_id 
  --> gh pr list (branch filter)
  --> PRInfo
  --> gh api reviews + comments
  --> ReviewComment[]
  --> Classification Engine
  --> ClassifiedComment[]
  --> Template Mapping
  --> 40_review_findings.md
```

## API Design（API設計）

### Endpoint 1: PR 自動検出

**Purpose**（目的）: Feature ID から対応する PR を検出

**Command**（コマンド）:
```bash
gh pr list --head "feature/${FEATURE_ID}" --state open --json number,state,labels,headRefName
```

**Response**（レスポンス）:
```json
[
  {
    "number": 123,
    "state": "OPEN",
    "labels": [{"name": "design-review"}],
    "headRefName": "feature/FEATURE-42"
  }
]
```

**Business Logic**（ビジネスロジック）:
1. open PR を優先的に選択
2. なければ最新の merged PR を選択
3. それもなければエラーメッセージ

### Endpoint 2: Review Comments 取得

**Purpose**（目的）: PR から全ての Review Comments を取得

**Command**（コマンド）:
```bash
# Review comments
gh api repos/:owner/:repo/pulls/$PR_NUM/reviews

# Inline comments
gh api repos/:owner/:repo/pulls/$PR_NUM/comments
```

**Response**（レスポンス）:
```json
{
  "reviews": [
    {
      "id": 12345,
      "user": {"login": "reviewer1"},
      "body": "❌ Critical: This will cause data loss",
      "state": "CHANGES_REQUESTED"
    }
  ],
  "comments": [
    {
      "id": 67890,
      "user": {"login": "reviewer2"},
      "body": "💡 Suggestion: Consider using a cache here",
      "path": "src/main.go",
      "line": 42
    }
  ]
}
```

## Security Considerations（セキュリティの考慮事項）

- [ ] Input validation（入力検証）: Feature ID フォーマット検証
- [ ] Authentication/Authorization（認証・認可）: GitHub CLI の認証状態確認
- [ ] Data encryption（データ暗号化）: GitHub API は HTTPS
- [ ] Rate limiting（レート制限）: GitHub API rate limit の考慮
- [ ] Audit logging（監査ログ）: コマンド実行ログ

## Error Handling（エラー処理）

| エラー種別 | 処理方針 | ユーザーメッセージ |
|------------|----------|-------------------|
| Feature ディレクトリ不存在 | エラー終了 | "Error: Feature directory not found: sdlc/features/{FEATURE_ID}" |
| PR 未作成 | エラー終了 | "Error: No PR found for feature/{FEATURE_ID}. Please create a PR first." |
| GitHub CLI 未認証 | エラー終了 | "Error: GitHub CLI not authenticated. Run 'gh auth login'." |
| GitHub API エラー | エラー終了 | "Error: Failed to fetch PR data: {error_message}" |
| Template 読み込み失敗 | エラー終了 | "Error: Cannot find template: sdlc/templates/40_review_findings.md" |

## Performance Considerations（パフォーマンスの考慮事項）

- Caching strategy（キャッシュ戦略）: GitHub API レスポンスの一時保存（不要であればスキップ）
- API call optimization（API 呼び出し最適化）: 必要最小限の API 呼び出し
- Async processing（非同期処理）: Phase 1 では不要（逐次処理で十分）

## Classification Logic（分類ロジック）

### Critical Issues（クリティカル問題）

以下のいずれかに該当する場合、Critical に分類：

1. **Keyword-based**:
   - "critical", "blocker", "breaking", "data loss", "security"
   - "must fix", "cannot merge", "regression"

2. **Emoji-based**:
   - ❌, 🚫, 🔴, ⛔, 💥

3. **Reviewer State**:
   - `CHANGES_REQUESTED` state

### Important Considerations（重要な考慮事項）

以下のいずれかに該当する場合、Important に分類：

1. **Keyword-based**:
   - "important", "should", "recommend", "concern"
   - "consider", "warning", "careful"

2. **Emoji-based**:
   - ⚠️, 🟡, 🔶, ⚡

### Suggestions（提案）

Critical でも Important でもない場合、Suggestions に分類：

1. **Keyword-based**:
   - "suggestion", "nice to have", "could", "maybe"
   - "nit", "minor", "optional"

2. **Emoji-based**:
   - 💡, 💭, 🤔, ✨

### Default（デフォルト）

キーワードも Emoji も該当しない場合:
- Reviewer state が `APPROVED` → Suggestions
- それ以外 → Important

## AI Review Integration (Phase 2)（AI Review 統合）

### AI Bot Identification（AI Bot 識別）

```javascript
const AI_BOTS = [
  'coderabbitai',
  'github-actions[bot]',
  'copilot',
  'sourcery-ai[bot]',
  'qodo-ai[bot]'
];

function isAIBot(username) {
  return AI_BOTS.some(bot => username.includes(bot));
}
```

### Cross Analysis（クロス分析）

```
Human と AI 両方が発見 → 重要度が高い
Human のみ発見 → AI の限界を示す
AI のみ発見 → 自動化可能な問題
```

## Alternative Designs Considered（検討した代替設計）

### Alternative 1: Manual PR Selection（手動 PR 選択）

**Pros**（長所）: 
- 柔軟性が高い
- エッジケースに対応しやすい

**Cons**（短所）: 
- ユーザーが PR 番号を調べる必要がある
- コマンドが冗長になる（`/sdlc-review-summary FEATURE-42 --pr 123`）

**Why Rejected**（却下理由）: 
「Convention over Configuration」の原則に反する。標準的なワークフローでは PR は自動検出できる。

### Alternative 2: Review Type Manual Specification（Review Type 手動指定）

**Pros**（長所）: 
- 明示的で分かりやすい
- 誤判定のリスクがない

**Cons**（短所）: 
- ユーザーが `--design` or `--code` を指定する必要がある
- SDLC_FLOW.md により順序が保証されているため不要

**Why Rejected**（却下理由）: 
最新の open PR を選択すれば、Design PR と Code PR は時系列で自動判別可能。

### Alternative 3: Real-time Review Tracking（リアルタイム追跡）

**Pros**（長所）: 
- レビューの進行状況をリアルタイムで把握
- 通知機能と連携可能

**Cons**（短所）: 
- 実装が複雑（WebHook 等が必要）
- システム全体への影響が大きい（Medium → High Risk）
- 現在のニーズを超える

**Why Rejected**（却下理由）: 
現時点では「PR 完了後に Review Findings を記録する」ニーズのみ。リアルタイム追跡は将来の拡張として検討。

## References（参考資料）

- GitHub CLI Documentation: https://cli.github.com/manual/
- GitHub REST API: https://docs.github.com/en/rest/pulls
- SDLC_FLOW.md: Design Review と Code Review の順序
- AI_SDLC.md: 40_review_findings.md の位置づけ
