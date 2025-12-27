# Requirements（要件）

**Feature ID**: FEATURE-24  
**Last Updated**: 2025-12-27

## Functional Requirements（機能要件）

### Must Have (P0)（必須）

- [ ] Issue に `sdlc:track` ラベル（または決定されたラベル）を追加すると、自動的に GitHub Projects に追加される
- [ ] 既に Projects にある Issue に再度ラベルを追加しても、重複しない（重複防止機構）
- [ ] `/sdlc-init` を実行していない Issue からラベルを削除すると、Projects から削除される
- [ ] `/sdlc-init` を実行済みの Feature（`.metadata` あり）からラベルを削除しても、Projects に保持される
- [ ] `.sdlc-config` が存在しない場合、workflow はスキップされる
- [ ] Workflow が失敗した場合、適切なエラーメッセージをログに出力する

### Should Have (P1)（推奨）

- [ ] GitHub Projects の Status フィールドに "Backlog" オプションを追加（Decision により決定）
- [ ] ラベルで追加された Issue の初期 Status を "Backlog" に設定
- [ ] `install.sh` に `sdlc:track` ラベル（または決定されたラベル）を追加
- [ ] README.md に GitHub Projects を只読展示層として使用するベストプラクティスを追加
- [ ] Workflow のログに十分な情報を出力（デバッグ可能なレベル）

### Nice to Have (P2)（あれば良い）

- [ ] ラベル追加/削除時に Issue にコメントを追加（オプション、過剰な通知になる可能性）
- [ ] Workflow の実行統計を収集（成功/失敗率、実行時間など）

## Non-Functional Requirements（非機能要件）

### Performance（パフォーマンス）

- Response time（応答時間）: ラベル操作後、5 分以内に Projects に反映
- Throughput（スループット）: 複数の Issue に対するラベル操作を並行処理可能
- Resource usage（リソース使用量）: GitHub Actions の無料枠内で動作

### Security（セキュリティ）

- Authentication（認証）: `secrets.GH_PAT` を使用して Projects v2 API にアクセス
- Authorization（認可）: PAT には `repo` と `project` のスコープが必要
- Data protection（データ保護）: Issue 本体は変更しない（ラベル操作のみ）

### Scalability（スケーラビリティ）

- Expected load（想定負荷）: 1 日あたり 10-50 件のラベル操作
- Growth projection（成長予測）: 将来的に 100 件/日まで対応可能

### Reliability（信頼性）

- Availability（可用性）: GitHub Actions の可用性に依存
- Error rate（エラー率）: < 5%（API レート制限による失敗を除く）
- Recovery time（復旧時間）: 自動 retry により 5 分以内に復旧

### Observability（可観測性）

- Logging（ログ）: Workflow の各ステップで詳細なログを出力
- Metrics（メトリクス）: Workflow の成功/失敗率、実行時間
- Alerting（アラート）: Workflow 失敗時に通知（GitHub Actions のデフォルト機能）

## User Stories（ユーザーストーリー）

### Story 1: ラベルで Issue を Projects に追加

**As a**（〜として） PM または開発者  
**I want**（〜したい） Issue に `sdlc:track` ラベルを追加するだけで、Projects に表示したい  
**So that**（〜するために） Issue 作成時点から全体像を把握できる

**Acceptance Criteria**（受入基準）:
- [ ] Issue に `sdlc:track` ラベルを追加すると、5 分以内に GitHub Projects に追加される
- [ ] 追加された Issue の Status は "Backlog"（Decision により決定）
- [ ] 既に Projects にある場合は、重複しない

### Story 2: `/sdlc-init` 未実行の Issue をラベル削除で Projects から削除

**As a**（〜として） 開発者  
**I want**（〜したい） まだ `/sdlc-init` を実行していない Issue からラベルを削除すると、Projects からも削除したい  
**So that**（〜するために） 不要な Issue を Projects から整理できる

**Acceptance Criteria**（受入基準）:
- [ ] `/sdlc-init` を実行していない Issue からラベルを削除すると、Projects から削除される
- [ ] Issue 本体は削除されない（Projects から削除されるのみ）

### Story 3: `/sdlc-init` 実行済みの Feature はラベル削除でも保持

**As a**（〜として） 開発者  
**I want**（〜したい） `/sdlc-init` を実行済みの Feature からラベルを削除しても、Projects に保持したい  
**So that**（〜するために） 誤ってラベルを削除しても、Feature が Projects から消えない

**Acceptance Criteria**（受入基準）:
- [ ] `.metadata` ファイルが存在する Feature からラベルを削除しても、Projects に保持される
- [ ] Workflow のログに「`.metadata` が存在するため保持」と記録される

### Story 4: 既存 Workflow との共存

**As a**（〜として） システム管理者  
**I want**（〜したい） 新規 Workflow が既存の `sync-projects.yml` と正常に共存したい  
**So that**（〜するために） データの不整合や競合が発生しない

**Acceptance Criteria**（受入基準）:
- [ ] 新規 Workflow と `sync-projects.yml` が同時に実行されても、競合しない
- [ ] 重複防止機構により、Issue が重複して追加されない
- [ ] `sync-projects.yml` が引き続き `.metadata` に基づいて Projects を更新する

## API Specification（API仕様）

### GitHub Projects v2 GraphQL API

#### Query: 既存 Issue チェック

**Description**（説明）: Issue が既に Projects に存在するかチェック

**Request**（リクエスト）:
```graphql
query {
  node(id: "{PROJECT_ID}") {
    ... on ProjectV2 {
      items(first: 100) {
        nodes {
          content {
            ... on Issue {
              id
              number
            }
          }
        }
      }
    }
  }
}
```

**Response**（レスポンス）:
```json
{
  "data": {
    "node": {
      "items": {
        "nodes": [
          {
            "content": {
              "id": "I_kwDOxxxxxx",
              "number": 24
            }
          }
        ]
      }
    }
  }
}
```

#### Mutation: Issue を Projects に追加

**Description**（説明）: Issue を Projects に追加

**Request**（リクエスト）:
```graphql
mutation {
  addProjectV2ItemById(input: {
    projectId: "{PROJECT_ID}"
    contentId: "{ISSUE_ID}"
  }) {
    item {
      id
    }
  }
}
```

**Response**（レスポンス）:
```json
{
  "data": {
    "addProjectV2ItemById": {
      "item": {
        "id": "PVTI_xxxxxxxx"
      }
    }
  }
}
```

**Error Codes**（エラーコード）:
- 401: PAT の権限不足
- 404: Project または Issue が見つからない
- 429: API レート制限

#### Mutation: Issue を Projects から削除

**Description**（説明）: Issue を Projects から削除

**Request**（リクエスト）:
```graphql
mutation {
  deleteProjectV2Item(input: {
    projectId: "{PROJECT_ID}"
    itemId: "{ITEM_ID}"
  }) {
    deletedItemId
  }
}
```

**Response**（レスポンス）:
```json
{
  "data": {
    "deleteProjectV2Item": {
      "deletedItemId": "PVTI_xxxxxxxx"
    }
  }
}
```

**Error Codes**（エラーコード）:
- 401: PAT の権限不足
- 404: Item が見つからない
- 429: API レート制限

## Data Model（データモデル）

### `.sdlc-config` (既存)

```yaml
project_id: "PVT_xxxxxxxxxx"
status_field_id: "PVTF_xxxxxxxxx"
feature_id_field_id: "PVTF_xxxxxxxxx"
risk_level_field_id: "PVTF_xxxxxxxxx"
decision_status_field_id: "PVTF_xxxxxxxxx"
```

### `.metadata` (既存)

```
FEATURE_ID=FEATURE-24
RISK_LEVEL=medium
STATUS=planning
CREATED_DATE=2025-12-27
DECISION_STATUS=pending
ISSUE_URL=https://github.com/lleizh/ai-driven-sdlc/issues/24
BRANCH=design/FEATURE-24
```

### Workflow Input (新規)

```yaml
inputs:
  label: ${{ github.event.label.name }}
  issue_number: ${{ github.event.issue.number }}
  issue_node_id: ${{ github.event.issue.node_id }}
  issue_title: ${{ github.event.issue.title }}
  issue_body: ${{ github.event.issue.body }}
```

## Dependencies（依存関係）

- GitHub Actions: Workflow の実行環境
- GitHub Projects v2 API: Projects の操作
- `secrets.GH_PAT`: Projects v2 API へのアクセス権限
- `.sdlc-config`: Project ID とフィールド ID の取得
- `sync-projects.yml`: 既存の Projects 同期 Workflow（競合しないこと）
- Repository checkout: `.metadata` ファイルの存在確認（ラベル削除時のみ）

## Assumptions（前提条件）

- `.sdlc-config` ファイルが repository のルートに存在する
- `secrets.GH_PAT` が設定されており、`repo` と `project` のスコープを持つ
- Issue タイトルまたは本文に Feature ID が含まれている（`FEATURE-XXX` 形式）
- `.metadata` ファイルは `sdlc/features/{FEATURE_ID}/.metadata` に存在する
- GitHub Actions の無料枠内で動作する（想定負荷: 10-50 件/日）
