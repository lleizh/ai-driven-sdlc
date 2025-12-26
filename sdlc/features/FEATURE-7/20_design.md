# Design

**Feature ID**: FEATURE-7  
**Last Updated**: 2025-12-26  
**Status**: FROZEN

## Overview

GitHub Projects v2 と SDLC システムを統合し、CLI ベースの進捗管理を GitHub UI でも可視化できるようにする。この設計では、既存の SDLC ワークフロー（`/sdlc-init`, `/sdlc-decision`, `/sdlc-coding` など）を維持しながら、commit/push された `.metadata` ファイルの変更を GitHub Actions で自動的に GitHub Project に同期する仕組みを提供する。

**重要な設計原則**: 同期は commit/push された変更のみに限定し、作業中の未コミット変更は同期しない。これにより git 履歴と Project の状態を一致させ、変更の追跡とロールバックを可能にする。

実装は 2 つのフェーズに分けて段階的に行い、Phase 1 で install.sh による Project セットアップと GitHub Actions ワークフロー作成、Phase 2 で自動同期ロジックの実装を完了する。

## Architecture

### System Architecture

```
┌─────────────────┐
│   Developer     │
│   (Local CLI)   │
└────────┬────────┘
         │
         │ ./install.sh (初回のみ)
         │ /sdlc-init, /sdlc-decision, etc.
         │
         ▼
┌─────────────────────────────────────────┐
│  SDLC System                            │
│  - install.sh: Project セットアップ      │
│  - sdlc-init: Issue → .metadata         │
│  - sdlc-decision: Update .metadata      │
│  - sdlc-coding: Update .metadata        │
│  - sdlc-pr-code: Update .metadata       │
└────────┬────────────────────────────────┘
         │
         │ git commit & push
         │
         ▼
┌─────────────────────────────────────────┐
│  GitHub Repository                      │
│  - sdlc/features/FEATURE-X/.metadata    │
│  - .sdlc-config                         │
│  - .github/workflows/sync-projects.yml  │
└────────┬────────────────────────────────┘
         │
         │ triggers on push (sdlc/features/**)
         │
         ▼
┌─────────────────────────────────────────┐
│  GitHub Actions Workflow                │
│  1. Detect changed Features (git diff)  │
│  2. For each changed Feature:           │
│     - Read .metadata                    │
│     - Parse Issue URL                   │
│     - Sync to Project via GraphQL       │
└────────┬────────────────────────────────┘
         │
         │ GraphQL API calls
         │
         ▼
┌─────────────────────────────────────────┐
│  GitHub Projects v2 API                 │
│  - Create/Update Project Items          │
│  - Update Custom Fields                 │
│  - Query Field IDs                      │
└────────┬────────────────────────────────┘
         │
         │
         ▼
┌─────────────────────────────────────────┐
│  GitHub Project (UI)                    │
│  - Board View (Status カンバン)         │
│  - Table View (全フィールド一覧)        │
│  - Risk View (Risk Level グループ)      │
└─────────────────────────────────────────┘
```

### Component Design

#### Component: install.sh による Project セットアップ

**Responsibility**: GitHub Project の作成・設定、カスタムフィールドの初期化、GitHub Actions ワークフローの作成

**Interfaces**:
- CLI: `./install.sh`
- Output: 
  - `.sdlc-config` に Project ID とフィールド ID を保存
  - `.github/workflows/sync-projects.yml` を作成

**Dependencies**:
- GitHub GraphQL API
- `.sdlc-config` ファイル
- gh CLI または GITHUB_TOKEN

**処理フロー**:
1. 既存の install.sh の処理を実行
2. GitHub 認証確認（gh CLI または GITHUB_TOKEN）
3. GitHub Project を自動作成
4. カスタムフィールドを作成（Status, Risk Level, Decision Status, Feature ID, Branch, PR Link）
5. フィールド ID を `.sdlc-config` に保存
6. `.github/workflows/sync-projects.yml` を生成
7. 動作確認メッセージを表示

#### Component: GitHub Actions 同期ロジック

**Responsibility**: .metadata の変更を検出し、GitHub Project に同期

**Interfaces**:
- Trigger: GitHub Actions (push event)
- Input: `.metadata` ファイル、`.sdlc-config`
- Output: Project Item の作成・更新

**Dependencies**:
- GitHub GraphQL API
- `.metadata` ファイル
- `.sdlc-config` ファイル
- git diff

**処理フロー**:
1. `.sdlc-config` から Project ID とフィールド ID を読み込み
2. git diff で変更された .metadata を検出
3. 各変更された Feature について:
   - `.metadata` から Feature 情報を読み込み（Feature ID, Status, Risk Level, etc.）
   - Issue URL から Issue の node_id を取得
   - Project に Item が存在するか確認
   - 存在しない場合: `addProjectV2ItemById` で追加
   - 存在する場合: Item ID を取得
   - 各カスタムフィールドを `updateProjectV2ItemFieldValue` で更新
4. エラー時はリトライ（最大 3 回、指数バックオフ）
5. 結果をログに出力

#### Component: GitHub Actions ワークフロー

**Responsibility**: push 時に変更された Feature を自動的に同期

**Interfaces**:
- Trigger: `push` event with `paths: sdlc/features/**`
- Output: GitHub Actions ログ

**Dependencies**:
- GitHub GraphQL API
- git diff
- `.sdlc-config` と `.metadata` ファイル

**処理フロー**:
```yaml
on:
  push:
    paths:
      - 'sdlc/features/**'

jobs:
  sync-projects:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        with:
          fetch-depth: 2  # git diff のため
      
      - name: Detect changed features
        id: changed
        run: |
          # git diff で変更された .metadata を検出
          CHANGED_FEATURES=$(git diff HEAD~1 --name-only | \
            grep 'sdlc/features/.*/\.metadata' | \
            sed 's|sdlc/features/\(.*\)/\.metadata|\1|' | \
            uniq)
          echo "features=$CHANGED_FEATURES" >> $GITHUB_OUTPUT
      
      - name: Sync to GitHub Projects
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          # .sdlc-config から Project ID とフィールド ID を読み込み
          source .sdlc-config
          
          for feature in ${{ steps.changed.outputs.features }}; do
            echo "Syncing $feature..."
            
            # .metadata を読み込み
            source sdlc/features/$feature/.metadata
            
            # GraphQL で Issue の node_id を取得
            # Project に Item を追加/更新
            # カスタムフィールドを更新
            
            # 実装は別途 sync スクリプトまたは CLI ツールで行う
          done
```

#### Component: 既存 SDLC コマンド（変更なし）

**Responsibility**: `/sdlc-init`, `/sdlc-decision`, `/sdlc-coding`, `/sdlc-pr-code` で `.metadata` を更新

**Interfaces**:
- 既存の CLI コマンド（変更なし）

**Dependencies**:
- `.metadata` ファイル

**処理フロー**（例: `/sdlc-decision`）:
1. Decision を CONFIRMED に更新
2. `.metadata` の `DECISION_STATUS=confirmed` を更新
3. git add, commit
4. ユーザーに完了メッセージ表示
5. **ユーザーが push すると GitHub Actions が自動的に Project を更新**

**重要**: SDLC コマンド自体は変更せず、commit/push 後に GitHub Actions が自動同期を行う

## Data Design

### Database Schema Changes

GitHub Projects v2 はクラウドサービスのため、ローカルでのスキーマ変更はなし。

### Migration Strategy

既存の Feature を Project にインポートする手順:
1. `./sdlc-cli setup-project --auto` で Project を作成
2. `./sdlc-cli sync-github --all` で全 Feature を一括同期
3. Project UI で確認

### Data Flow

```
[.metadata 更新] 
    → [git commit/push] 
    → [GitHub Actions トリガー] 
    → [変更検出 (git diff)] 
    → [sync-github 実行] 
    → [GraphQL API 呼び出し] 
    → [Project Item 更新] 
    → [GitHub Project UI に反映]
```

## API Design

### install.sh の拡張

```bash
./install.sh

# 実行内容:
# 1. 既存の install.sh 処理
# 2. GitHub 認証確認
# 3. GitHub Project 自動作成
# 4. カスタムフィールド設定
# 5. .sdlc-config に保存
# 6. .github/workflows/sync-projects.yml 生成
```

**Exit Codes**:
- 0: 成功
- 1: 認証エラー
- 2: Project 作成エラー
- 3: カスタムフィールド設定エラー
- 4: ワークフローファイル作成エラー

**注**: 初回インストール時に自動実行。日常的な同期は GitHub Actions が自動実行

### GitHub GraphQL API Usage

主要な API 呼び出し:

1. **Project 作成**: `createProjectV2`
2. **フィールド作成**: `createProjectV2Field`
3. **Item 追加**: `addProjectV2ItemById`
4. **Item 更新**: `updateProjectV2ItemFieldValue`
5. **フィールド ID 取得**: `projectV2.fields` クエリ

詳細は `10_requirements.md` の API Specification を参照。

## Security Considerations

- [x] Input validation: Feature ID、URL、フィールド値のバリデーション
- [x] Authentication/Authorization: GitHub PAT または gh CLI の認証を使用、write 権限確認
- [ ] Data encryption: トークンは環境変数 `GITHUB_TOKEN` で管理（平文保存しない）
- [ ] Rate limiting: API レート制限を監視、超過時はエラーメッセージ表示
- [x] Audit logging: GitHub Actions ログに同期結果を記録

## Error Handling

| Error Type | Handling Strategy | User Message |
|------------|-------------------|--------------|
| 認証エラー | すぐに終了 | "GitHub authentication failed. Run 'gh auth login' or set GITHUB_TOKEN." |
| Project 未設定 | セットアップを促す | "Project not configured. Run './sdlc-cli setup-project --auto' first." |
| API レート制限 | リトライ（指数バックオフ） | "GitHub API rate limit exceeded. Retrying in X seconds..." |
| フィールド ID 不一致 | 再取得を試みる | "Custom field ID mismatch. Re-fetching field IDs..." |
| GraphQL エラー | ログ出力して次へ | "Failed to sync FEATURE-X: [error details]" |

## Performance Considerations

- Caching strategy: `.sdlc-config` にフィールド ID をキャッシュ、変更時のみ再取得
- Database indexes: N/A（GitHub Projects はクラウドサービス）
- Query optimization: 複数フィールドの更新を単一の GraphQL mutation でバッチ化
- Async processing: GitHub Actions で非同期実行、開発フローをブロックしない

## Scalability Considerations

- Horizontal scaling: N/A（GitHub API がスケーリングを担当）
- Load balancing: N/A
- Resource limits: API レート制限（5,000 req/hour）を考慮し、変更された Feature のみ同期

## Monitoring & Observability

### Metrics

- 同期成功数 / 失敗数（Feature 単位）
- API レート制限残数
- GitHub Actions 実行時間
- エラー率（連続失敗回数）

### Logs

- GitHub Actions ログ: 各 Feature の同期結果
- CLI 実行ログ: `sync-github` コマンドの成功/失敗、API エラー詳細
- エラーログ: GraphQL エラーメッセージ、スタックトレース

### Alerts

- 連続 3 回の同期失敗
- API レート制限残が 10% 以下
- GitHub Actions の実行時間が 5 分超過

## Alternative Designs Considered

### Alternative 1: REST API を使用

**Pros**: 
- REST API の方が馴染みがある
- ドキュメントが充実

**Cons**: 
- GitHub Projects v2 は GraphQL API のみサポート
- REST API では Projects v2 の機能を使えない

**Why Rejected**: Projects v2 は GraphQL API 必須のため選択肢なし

### Alternative 2: GitHub App を作成

**Pros**: 
- より細かい権限管理
- Organization 全体で使いやすい
- Webhook でリアルタイム同期

**Cons**: 
- 実装が複雑（OAuth フロー、Webhook サーバーなど）
- セットアップが大変
- 個人リポジトリでは過剰

**Why Rejected**: MVP としては PAT または gh CLI で十分、将来的に検討可能

### Alternative 3: 全 push で全 Feature を同期

**Pros**: 
- 実装がシンプル
- 同期漏れがない

**Cons**: 
- API コール数が多すぎる
- レート制限に引っかかりやすい
- パフォーマンスが悪い

**Why Rejected**: スケーラビリティとコストの観点から不適切

## Open Questions

- [ ] GitHub Organization の共有 Project を使用する場合の権限設定は？
- [ ] 複数のリポジトリで同じ Project を使用するケースはあるか？
- [ ] PR マージ時の自動更新（Status → Completed）は Phase 5 で実装するか？
- [ ] Issue のラベルと Project のフィールドを双方向同期する必要はあるか？

## References

- GitHub Projects v2 API ドキュメント: https://docs.github.com/en/graphql/reference/mutations#createprojectv2
- GitHub Actions ドキュメント: https://docs.github.com/en/actions
- 既存 sdlc-cli の実装: `sdlc-cli` スクリプト
- `.metadata` 形式: `sdlc/features/*/\.metadata`
