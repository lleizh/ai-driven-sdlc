# Requirements

**Feature ID**: FEATURE-7  
**Last Updated**: 2025-12-26

## Functional Requirements

### Must Have (P0)

- [ ] `./install.sh` 実行時に GitHub Project が自動作成される
- [ ] カスタムフィールド（Status, Risk Level, Decision Status, Feature ID, Branch, PR Link）が自動設定される
- [ ] `.sdlc-config` に Project ID とカスタムフィールド ID が保存される
- [ ] `.github/workflows/sync-projects.yml` が自動作成される
- [ ] GitHub Actions ワークフローが `sdlc/features/**` の変更を検知する
- [ ] push 時に変更された Feature のみを Project に同期する
- [ ] `.metadata` の内容が Project のカスタムフィールドに正しく反映される
- [ ] `/sdlc-init` で作成した .metadata を commit/push すると Issue が Project に追加される（Status: Planning）
- [ ] `/sdlc-decision` で更新した .metadata を commit/push すると Decision Status が Confirmed に更新される
- [ ] `/sdlc-coding` で更新した .metadata を commit/push すると Status が Implementing に更新される
- [ ] `/sdlc-pr-code` で更新した .metadata を commit/push すると PR Link が追加される

### Should Have (P1)

- [ ] Project のカンバンボードで Status ごとに Feature が表示される
- [ ] Table View で全フィールドを一覧表示できる
- [ ] Risk Level でグループ化した Risk View が利用できる
- [ ] 同期エラー時に適切なエラーメッセージとログが出力される
- [ ] API レート制限に近づいた場合に警告が表示される

### Nice to Have (P2)

- [ ] PR マージ時に Status を自動的に Completed に更新
- [ ] GitHub Issues のラベル同期（risk level, status など）
- [ ] 週次レポートを Project のビューとして自動生成
- [ ] 同期失敗時の自動リトライと通知機能

## Non-Functional Requirements

### Performance

- Response time: Project 同期処理は 1 Feature あたり 2 秒以内
- Throughput: 10 Features を並行して 30 秒以内に同期完了
- Resource usage: GitHub Actions の実行時間は 5 分以内

### Security

- Authentication: GitHub Personal Access Token (PAT) または GitHub App トークンを使用
- Authorization: Project への write 権限が必要（セットアップ時に確認）
- Data protection: トークンは環境変数またはシークレットで管理、コードに含めない

### Scalability

- Expected load: リポジトリあたり最大 100 Features
- Growth projection: 月 10-20 Features の追加を想定

### Reliability

- Availability: GitHub API が利用可能な場合は 99% 以上の成功率
- Error rate: 同期エラー率 5% 以下
- Recovery time: エラー時は指数バックオフでリトライ（最大 3 回）

### Observability

- Logging: GitHub Actions のログに同期結果を出力（成功/失敗、Feature ID、エラー詳細）
- Metrics: 同期成功/失敗数、API レート制限残数
- Alerting: 連続 3 回の同期失敗、API レート制限が 10% 以下

## User Stories

### Story 1: install.sh による自動セットアップ

**As a** 開発者  
**I want** `./install.sh` 実行時に GitHub Project が自動的にセットアップされる  
**So that** 手動での Project 作成とフィールド設定の手間を省ける

**Acceptance Criteria**:
- [ ] `./install.sh` 実行で GitHub Project が自動作成される
- [ ] Status, Risk Level, Decision Status, Feature ID, Branch, PR Link のカスタムフィールドが設定される
- [ ] `.sdlc-config` に Project ID とフィールド ID が保存される
- [ ] `.github/workflows/sync-projects.yml` が自動作成される
- [ ] エラー時には分かりやすいメッセージが表示される

### Story 3: Feature の自動同期（commit/push 時）

**As a** 開発者  
**I want** `.metadata` を更新して commit/push すると自動的に Project が更新される  
**So that** 手動で Project を更新する手間がなくなり、git 履歴と Project の状態が一致する

**Acceptance Criteria**:
- [ ] `sdlc/features/**/.metadata` の変更を GitHub Actions が検知する
- [ ] 変更された Feature のみが Project に同期される
- [ ] Status, Risk Level, Decision Status, Branch などが正しく反映される
- [ ] 同期結果がログに出力される
- [ ] 作業中の未コミット変更は同期されない

### Story 2: Project での進捗確認

**As a** プロジェクトマネージャー  
**I want** GitHub Project のカンバンボードで SDLC の進捗を確認する  
**So that** チーム全体の状況を視覚的に把握できる

**Acceptance Criteria**:
- [ ] Board View で Status ごとに Feature がカンバン形式で表示される
- [ ] Table View で全フィールドが一覧表示される
- [ ] Risk View で Risk Level ごとにグループ化される
- [ ] Feature をクリックすると関連する Issue に遷移できる

## API Specification (if applicable)

### GitHub Projects v2 GraphQL API

この機能は GitHub の GraphQL API を使用します。

#### Project 作成

```graphql
mutation {
  createProjectV2(input: {
    ownerId: "node_id"
    title: "SDLC Project"
  }) {
    projectV2 {
      id
    }
  }
}
```

#### カスタムフィールド追加

```graphql
mutation {
  createProjectV2Field(input: {
    projectId: "project_id"
    dataType: SINGLE_SELECT
    name: "Status"
    singleSelectOptions: [
      {name: "Planning", color: GRAY},
      {name: "Designing", color: BLUE},
      {name: "Implementing", color: YELLOW},
      {name: "Reviewing", color: ORANGE},
      {name: "Completed", color: GREEN}
    ]
  }) {
    projectV2Field {
      id
    }
  }
}
```

#### Item 追加・更新

```graphql
mutation {
  addProjectV2ItemById(input: {
    projectId: "project_id"
    contentId: "issue_id"
  }) {
    item {
      id
    }
  }
}

mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "project_id"
    itemId: "item_id"
    fieldId: "field_id"
    value: {
      singleSelectOptionId: "option_id"
    }
  }) {
    projectV2Item {
      id
    }
  }
}
```

## Data Model (if applicable)

### .sdlc-config の拡張

```
# 既存フィールド
REPO_OWNER=lleizh
REPO_NAME=ai-driven-sdlc

# 新規追加
PROJECT_ID=PVT_xxxxx
PROJECT_NUMBER=1
FIELD_ID_STATUS=PVTSSF_xxxxx
FIELD_ID_RISK_LEVEL=PVTSSF_xxxxx
FIELD_ID_DECISION_STATUS=PVTSSF_xxxxx
FIELD_ID_FEATURE_ID=PVTF_xxxxx
FIELD_ID_BRANCH=PVTF_xxxxx
FIELD_ID_PR_LINK=PVTF_xxxxx
```

### .metadata の使用（変更なし）

```
FEATURE_ID=FEATURE-7
RISK_LEVEL=medium
STATUS=planning
CREATED_DATE=2025-12-26
DECISION_STATUS=pending
ISSUE_URL=https://github.com/lleizh/ai-driven-sdlc/issues/7
BRANCH=design/FEATURE-7
PR_URL=(空欄または URL)
```

## Dependencies

- GitHub Projects v2 API（GraphQL）
- GitHub Actions
- GitHub CLI (`gh` コマンド) または GraphQL クライアント
- 既存の sdlc-cli コマンド群
- `.metadata` ファイル形式

## Assumptions

- リポジトリは GitHub 上に存在する
- ユーザーは Project への write 権限を持つ
- GitHub API のレート制限は通常の開発で問題にならない程度（認証済み: 5,000 req/hour）
- Feature は Issue と 1:1 で対応する
- `.metadata` ファイルは常に最新の状態を反映している
