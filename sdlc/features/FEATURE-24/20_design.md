# Design（設計）

**Feature ID**: FEATURE-24  
**Last Updated**: 2025-12-27  
**Status**: DRAFT

## Overview（概要）

この機能は、Issue にラベルを追加することで自動的に GitHub Projects に追加し、ラベル削除時には `.metadata` の有無に基づいて智能的に削除または保持する GitHub Actions Workflow を実装する。

**主要コンポーネント：**
1. **auto-add-issues.yml**: ラベル操作をトリガーとする新規 Workflow
2. **install.sh の更新**: `sdlc:track` ラベルと "Backlog" Status の追加
3. **README.md の更新**: 只読ベストプラクティスの追加

**設計原則：**
- 既存の `sync-projects.yml` との競合を避ける
- API レート制限を考慮した retry 機構
- `.metadata` を唯一の真実の源として尊重
- ロールバック可能な設計

## Architecture（アーキテクチャ）

### System Architecture（システムアーキテクチャ）

```
┌─────────────────────────────────────────────────────────────┐
│                        GitHub Issue                         │
│                    (Label: sdlc:track)                      │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ Trigger: issues.labeled / issues.unlabeled
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│               auto-add-issues.yml (新規)                     │
│  ┌──────────────────┐         ┌──────────────────┐          │
│  │ add-to-project   │         │ remove-from-     │          │
│  │ (on labeled)     │         │ project          │          │
│  │                  │         │ (on unlabeled)   │          │
│  └────────┬─────────┘         └────────┬─────────┘          │
│           │                            │                    │
│           │ 1. Read .sdlc-config       │ 1. Extract FEATURE_ID │
│           │ 2. Check existing          │ 2. Checkout repo   │
│           │ 3. Add if not exists       │ 3. Check .metadata │
│           │                            │ 4. Delete if not exists │
└───────────┼────────────────────────────┼────────────────────┘
            │                            │
            ▼                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   GitHub Projects v2 API                     │
│  - addProjectV2ItemById (add)                               │
│  - deleteProjectV2Item (remove)                             │
│  - Query existing items (check duplicates)                  │
└─────────────────────────────────────────────────────────────┘
            │
            │ Sync on .metadata change
            ▼
┌─────────────────────────────────────────────────────────────┐
│             sync-projects.yml (既存)                         │
│  - Update Status, Feature ID, Risk Level, etc.              │
│  - Only triggered by .metadata file changes                 │
└─────────────────────────────────────────────────────────────┘
```

### Component Design（コンポーネント設計）

#### Component: add-to-project Job

**Responsibility**（責務）: Issue にラベルが追加されたときに、Projects に追加する

**Interfaces**（インターフェース）:
- Input: GitHub Event（`issues.labeled`）
- Output: Projects に Issue を追加

**Dependencies**（依存関係）:
- `.sdlc-config`: Project ID とフィールド ID
- `secrets.GH_PAT`: Projects v2 API アクセス権限
- GitHub Projects v2 API

**処理フロー:**
```yaml
1. Trigger: issues.labeled, label.name == 'sdlc:track'
2. Read .sdlc-config
3. Get Issue node ID
4. Query Projects to check if Issue already exists
5. If not exists:
   a. Add Issue to Projects
   b. Set Status to "Backlog" (if Backlog is confirmed)
6. Log result
```

#### Component: remove-from-project Job

**Responsibility**（責務）: Issue からラベルが削除されたときに、`.metadata` の有無に基づいて Projects から削除または保持する

**Interfaces**（インターフェース）:
- Input: GitHub Event（`issues.unlabeled`）
- Output: Projects から Issue を削除（条件付き）

**Dependencies**（依存関係）:
- `.sdlc-config`: Project ID
- `secrets.GH_PAT`: Projects v2 API アクセス権限
- Repository checkout: `.metadata` ファイルの確認
- GitHub Projects v2 API

**処理フロー:**
```yaml
1. Trigger: issues.unlabeled, label.name == 'sdlc:track'
2. Extract FEATURE_ID from Issue title/body (regex: FEATURE-\d+)
3. Checkout repository
4. Check if .metadata exists at sdlc/features/{FEATURE_ID}/.metadata
5. If .metadata does NOT exist:
   a. Query Projects to find Item ID
   b. Delete Item from Projects
   c. Log "Removed from Projects (no .metadata)"
6. If .metadata exists:
   a. Log "Kept in Projects (.metadata exists)"
   b. Do not delete
```

#### Component: install.sh Updates

**Responsibility**（責務）: プロジェクトセットアップ時に必要なラベルと Status オプションを作成

**Interfaces**（インターフェース）:
- Input: なし（スクリプト実行）
- Output: GitHub ラベルと Projects Status フィールドの更新

**Dependencies**（依存関係）:
- `gh` CLI
- GitHub API

**変更内容:**
```bash
# initialize_labels() 関数に追加
LABELS=(
  # ... existing labels ...
  "sdlc:track:1d76db:SDLC 管理対象（Projects に自動追加）"
)

# create_project_fields() 関数の Status options に追加
STATUS_OPTIONS='[
  {"name": "Backlog"},     # ← 追加
  {"name": "Planning"},
  # ... existing statuses ...
]'
```

#### Component: README.md Updates

**Responsibility**（責務）: GitHub Projects の只読ベストプラクティスをドキュメント化

**Interfaces**（インターフェース）:
- Input: なし（ドキュメント）
- Output: チームメンバーへの教育

**変更内容:**
- 新規セクション「GitHub Projects の使い方」を追加
- Projects を只読として使用する理由と方法を説明
- 正しいワークフロー（`.metadata` 編集 → commit → 自動同期）を明記
- 推奨設定（Projects の基本権限を Read に設定）を記載

## Data Design（データ設計）

### Database Schema Changes（スキーマ変更）

データベース変更なし（GitHub Projects の既存スキーマを使用）

### Migration Strategy（マイグレーション戦略）

マイグレーション不要

### Data Flow（データフロー）

#### Add Flow（追加フロー）

```
User adds 'sdlc:track' label
    ↓
GitHub Event: issues.labeled
    ↓
auto-add-issues.yml: add-to-project job
    ↓
Read .sdlc-config (Project ID)
    ↓
Query Projects (check existing)
    ↓
GraphQL: addProjectV2ItemById
    ↓
Issue appears in Projects with Status="Backlog"
```

#### Remove Flow（削除フロー）

```
User removes 'sdlc:track' label
    ↓
GitHub Event: issues.unlabeled
    ↓
auto-add-issues.yml: remove-from-project job
    ↓
Extract FEATURE_ID from Issue
    ↓
Checkout repository
    ↓
Check sdlc/features/{FEATURE_ID}/.metadata
    ↓
If .metadata NOT exists:
    Query Projects (find Item ID)
    ↓
    GraphQL: deleteProjectV2Item
    ↓
    Issue removed from Projects
    
If .metadata exists:
    Log and keep in Projects
    ↓
    No action
```

## API Design（API設計）

### Workflow API: add-to-project

**Purpose**（目的）: Issue を Projects に追加

**Trigger**（トリガー）:
```yaml
on:
  issues:
    types: [labeled]
```

**Conditions**（条件）:
```yaml
if: github.event.label.name == 'sdlc:track'
```

**Steps**（ステップ）:
1. Read `.sdlc-config`
2. Get Issue node ID: `${{ github.event.issue.node_id }}`
3. Check if Issue already exists in Projects (GraphQL query)
4. If not exists, add Issue to Projects (GraphQL mutation)
5. Optionally set Status to "Backlog"

**Error Handling**（エラー処理）:
- `.sdlc-config` not found → Skip workflow
- GraphQL API error → Retry with exponential backoff
- Rate limit → Wait and retry

### Workflow API: remove-from-project

**Purpose**（目的）: Issue を Projects から削除（条件付き）

**Trigger**（トリガー）:
```yaml
on:
  issues:
    types: [unlabeled]
```

**Conditions**（条件）:
```yaml
if: github.event.label.name == 'sdlc:track'
```

**Steps**（ステップ）:
1. Extract FEATURE_ID from Issue title/body (regex)
2. Checkout repository
3. Check if `.metadata` exists
4. If not exists:
   - Query Projects to find Item ID
   - Delete Item from Projects (GraphQL mutation)
5. If exists:
   - Log "Kept in Projects"

**Error Handling**（エラー処理）:
- FEATURE_ID not found → Assume not initialized, delete
- `.metadata` check fails → Log error, skip deletion
- GraphQL API error → Retry with exponential backoff

## Security Considerations（セキュリティの考慮事項）

- [x] Input validation（入力検証）: Issue node ID と label name は GitHub から提供されるため信頼可能
- [x] Authentication/Authorization（認証・認可）: `secrets.GH_PAT` を使用、`repo` と `project` スコープが必要
- [x] Data encryption（データ暗号化）: GitHub API は HTTPS で暗号化
- [x] Rate limiting（レート制限）: Retry 機構を実装、API レート制限を考慮
- [x] Audit logging（監査ログ）: Workflow のログに詳細を記録

**追加のセキュリティ考慮事項:**
- PAT のスコープを最小限に制限（`repo:read`, `project:write`）
- Workflow は public repository でも安全に動作（機密情報なし）
- `.metadata` ファイルの内容は検証しない（read-only）

## Error Handling（エラー処理）

| エラー種別 | 処理方針 | ユーザーメッセージ |
|------------|----------|-------------------|
| `.sdlc-config` not found | Skip workflow | "Skipping: .sdlc-config not found" |
| Invalid label name | Skip workflow | "Skipping: Label is not 'sdlc:track'" |
| GraphQL API error (4xx) | Log and fail | "Error: API request failed - {error}" |
| GraphQL API error (429) | Retry 3 times with backoff | "Rate limit reached, retrying..." |
| `.metadata` check failed | Assume not initialized | "Could not check .metadata, assuming not initialized" |
| FEATURE_ID extraction failed | Assume not initialized | "Could not extract FEATURE_ID from Issue" |
| Issue already in Projects | Skip add | "Issue already in Projects, skipping" |
| Item not found in Projects | Skip delete | "Issue not in Projects, skipping" |

**Retry Strategy:**
```yaml
Retry on: 429 (Rate Limit), 502 (Bad Gateway), 503 (Service Unavailable)
Max retries: 3
Backoff: Exponential (1s, 2s, 4s)
```

## Performance Considerations（パフォーマンスの考慮事項）

- Caching strategy（キャッシュ戦略）: なし（GitHub API のレスポンスはキャッシュしない）
- Database indexes（データベースインデックス）: なし（GitHub Projects が管理）
- Query optimization（クエリ最適化）:
  - GraphQL query で必要なフィールドのみ取得
  - 既存チェックは Issue number でフィルタリング
- Async processing（非同期処理）: GitHub Actions の並行実行を活用

**Performance Targets:**
- Workflow 実行時間: < 2 分（add）, < 3 分（remove with checkout）
- API 呼び出し回数: add = 2-3 回, remove = 3-4 回
- 想定負荷: 10-50 件/日 → API レート制限内

## Scalability Considerations（スケーラビリティの考慮事項）

- Horizontal scaling（水平スケーリング）: GitHub Actions が自動的にスケール
- Load balancing（負荷分散）: GitHub Actions が自動的に処理
- Resource limits（リソース制限）: GitHub Actions の無料枠（2000 分/月）内で動作

**スケーラビリティの見積もり:**
- 現在の想定負荷: 10-50 件/日 = 2-10 分/日
- 将来的な負荷: 100 件/日 = 20 分/日（無料枠内）
- リミット到達時: 手動実行または PAT のレート制限緩和を検討

## Monitoring & Observability（監視と可観測性）

### Metrics（メトリクス）

- Workflow 実行回数（add / remove）
- Workflow 成功/失敗率
- Workflow 実行時間
- API レート制限使用率

### Logs（ログ）

**add-to-project:**
```
[INFO] Label 'sdlc:track' added to Issue #24
[INFO] Reading .sdlc-config...
[INFO] Project ID: PVT_xxxxxxxxxx
[INFO] Checking if Issue #24 already exists in Projects...
[INFO] Issue not found, adding to Projects...
[SUCCESS] Issue #24 added to Projects with Item ID: PVTI_xxxxxxxx
```

**remove-from-project:**
```
[INFO] Label 'sdlc:track' removed from Issue #24
[INFO] Extracting FEATURE_ID from Issue...
[INFO] FEATURE_ID: FEATURE-24
[INFO] Checking if .metadata exists at sdlc/features/FEATURE-24/.metadata...
[INFO] .metadata NOT found, removing from Projects...
[INFO] Querying Projects to find Item ID...
[SUCCESS] Issue #24 removed from Projects (Item ID: PVTI_xxxxxxxx)
```

または

```
[INFO] .metadata found, keeping Issue #24 in Projects
[INFO] No action taken
```

### Alerts（アラート）

- Workflow 失敗時: GitHub Actions のデフォルト通知
- API レート制限到達時: ログに警告を出力
- 連続失敗（3 回以上）: 手動調査が必要

## Alternative Designs Considered（検討した代替設計）

### Alternative 1: webhook を使用した外部サーバー

**Pros**（長所）: 
- より柔軟な処理が可能
- 複雑なロジックを実装しやすい

**Cons**（短所）: 
- インフラストラクチャが必要（サーバー、データベース）
- コストが高い
- セキュリティ管理が複雑

**Why Rejected**（却下理由）: GitHub Actions で十分に実現可能、追加のインフラ不要

### Alternative 2: GitHub App を使用

**Pros**（長所）: 
- より細かい権限管理が可能
- ユーザーごとの PAT が不要

**Cons**（短所）: 
- GitHub App の作成とインストールが必要
- より複雑なセットアップ

**Why Rejected**（却下理由）: PAT で十分、既存の `sync-projects.yml` も PAT を使用

### Alternative 3: ラベル削除時に常に Projects から削除

**Pros**（長所）: 
- シンプルな実装
- `.metadata` チェック不要

**Cons**（短所）: 
- `/sdlc-init` 実行済みの Feature も削除される
- `sync-projects.yml` が再度追加するため不整合が発生

**Why Rejected**（却下理由）: Issue の要件（智能的な削除）を満たさない

## Open Questions（未解決の問題）

- [ ] ラベル名は `sdlc:track` で確定か？（Decision 1）
- [ ] Backlog 状態を追加するか？（Decision 3）
- [ ] README.md のセクション構成は？（Decision 4）
- [ ] Workflow のログレベルは DEBUG が必要か？
- [ ] ラベル追加/削除時に Issue にコメントを追加するか？（P2 要件）

## References（参考資料）

- GitHub Actions ドキュメント: https://docs.github.com/en/actions
- GitHub Projects v2 API: https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-api-to-manage-projects
- 既存 Workflow: `.github/workflows/sync-projects.yml`
- Issue: https://github.com/lleizh/ai-driven-sdlc/issues/24
