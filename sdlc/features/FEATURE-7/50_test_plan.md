# Test Plan

**Feature ID**: FEATURE-7  
**Last Updated**: 2025-12-26  
**Test Owner**: TBD

## Test Strategy

**Testing Levels**:
- Unit Testing: 80% coverage target
- Integration Testing: GitHub API との統合、CLI コマンドの動作確認
- E2E Testing: SDLC ワークフロー全体の動作確認
- Performance Testing: Required（API レート制限、実行時間）
- Security Testing: Required（認証、トークン管理）

## Test Scope

### In Scope

- `setup-project` コマンドの動作（自動作成、既存 Project 使用）
- `sync-github` コマンドの動作（単一 Feature、全 Feature）
- GitHub Actions ワークフローのトリガーと実行
- `.metadata` の変更検出
- GitHub Projects v2 API との統合
- カスタムフィールドの作成と更新
- エラーハンドリングとリトライ
- 既存 SDLC コマンドとの統合

### Out of Scope

- GitHub Projects v2 の UI テスト（GitHub が管理）
- GitHub API 自体の信頼性テスト
- 複数リポジトリでの Project 共有（将来の機能）

## Unit Tests

### Component: setup-project コマンド

**File**: `tests/setup_project_test.sh` または `tests/setup_project_test.go`

#### Test Case 1: Project 自動作成
- **Description**: `--auto` オプションで Project を作成
- **Input**: `./sdlc-cli setup-project --auto`
- **Expected Output**: 
  - Project が作成される
  - `.sdlc-config` に PROJECT_ID が保存される
  - カスタムフィールド ID が保存される
- **Edge Cases**: 
  - GitHub 認証が未設定
  - 既に Project が存在する場合

#### Test Case 2: 既存 Project の使用
- **Description**: `--url` オプションで既存 Project を指定
- **Input**: `./sdlc-cli setup-project --url https://github.com/users/USERNAME/projects/1`
- **Expected Output**: 
  - Project ID が取得される
  - 必要なカスタムフィールドが確認される
  - 不足フィールドが作成される
- **Edge Cases**: 
  - 無効な URL
  - アクセス権限がない Project
  - カスタムフィールドが部分的に存在

#### Test Case 3: 認証エラー
- **Description**: GitHub 認証が失敗する場合
- **Input**: GITHUB_TOKEN を未設定で実行
- **Expected Output**: 
  - エラーメッセージ表示
  - Exit code 1
- **Edge Cases**: 
  - トークンが無効
  - トークンの権限が不足

### Component: sync-github コマンド

**File**: `tests/sync_github_test.sh`

#### Test Case 1: 単一 Feature の同期
- **Description**: 指定した Feature を同期
- **Input**: `./sdlc-cli sync-github FEATURE-7`
- **Expected Output**: 
  - Issue が Project に追加される
  - カスタムフィールドが更新される
  - 成功メッセージが表示される
- **Edge Cases**: 
  - Feature が存在しない
  - .metadata が不正な形式
  - Issue URL が無効

#### Test Case 2: 全 Feature の同期
- **Description**: `--all` で全 Feature を同期
- **Input**: `./sdlc-cli sync-github --all`
- **Expected Output**: 
  - 全 Feature が Project に反映される
  - 各 Feature の結果が表示される
- **Edge Cases**: 
  - Feature が 0 件
  - 一部の Feature でエラー

#### Test Case 3: API レート制限
- **Description**: レート制限に達した場合
- **Input**: レート制限を超える API コールを実行
- **Expected Output**: 
  - リトライが実行される
  - 適切なエラーメッセージ
- **Edge Cases**: 
  - リトライ後も失敗

### Component: 変更検出ロジック

**File**: `tests/change_detection_test.sh`

#### Test Case 1: .metadata の変更検出
- **Description**: git diff で変更された .metadata を検出
- **Input**: FEATURE-7/.metadata を変更して commit
- **Expected Output**: 
  - FEATURE-7 が検出される
  - 他の Feature は検出されない
- **Edge Cases**: 
  - 複数 Feature の同時変更
  - .metadata の削除
  - 新規 Feature の追加

## Integration Tests

### Integration 1: CLI + GitHub API

**Scope**: setup-project + sync-github + GitHub Projects v2 API

#### Test Case 1: エンドツーエンドセットアップ
- **Description**: Project セットアップから同期まで
- **Setup**: 
  - テスト用リポジトリを作成
  - GitHub トークンを設定
- **Steps**: 
  1. `./sdlc-cli setup-project --auto` を実行
  2. `.sdlc-config` を確認
  3. `./sdlc-cli sync-github FEATURE-7` を実行
  4. GitHub Project UI で確認
- **Expected Result**: 
  - Project が作成される
  - FEATURE-7 が Project に表示される
  - カスタムフィールドが正しく設定される
- **Cleanup**: 
  - テスト用 Project を削除
  - `.sdlc-config` をリセット

#### Test Case 2: 既存 Project との統合
- **Description**: 既存 Project に Feature を追加
- **Setup**: 
  - 事前に Project を手動作成
- **Steps**: 
  1. `./sdlc-cli setup-project --url <project-url>` を実行
  2. `./sdlc-cli sync-github --all` を実行
  3. Project を確認
- **Expected Result**: 
  - 既存 Project に Feature が追加される
  - 既存データは保持される
- **Cleanup**: 
  - 追加した Item を削除

### Integration 2: GitHub Actions + sync-github

**Scope**: GitHub Actions ワークフロー + CLI コマンド

#### Test Case 1: push トリガーによる自動同期
- **Description**: .metadata 変更を push すると自動同期される
- **Setup**: 
  - GitHub Actions ワークフローを設定
  - Project をセットアップ
- **Steps**: 
  1. FEATURE-7/.metadata を変更
  2. git commit & push
  3. GitHub Actions のログを確認
  4. Project を確認
- **Expected Result**: 
  - Actions が自動的にトリガーされる
  - 変更された Feature のみ同期される
  - Project に反映される
- **Cleanup**: 
  - テストコミットを revert

#### Test Case 2: 複数 Feature の同時変更
- **Description**: 複数の .metadata を同時に変更
- **Setup**: 
  - FEATURE-1, FEATURE-3, FEATURE-7 を準備
- **Steps**: 
  1. 3 つの .metadata を変更
  2. git commit & push
  3. Actions ログを確認
- **Expected Result**: 
  - 3 つの Feature が全て同期される
  - 同期時間が許容範囲内（< 5 分）
- **Cleanup**: 
  - テストコミットを revert

## E2E Tests

### User Flow 1: 新規 Feature の追加と進捗管理

**Scenario**: Issue から Feature を作成し、Project で進捗を追跡

#### Test Case 1: Happy Path
- **User Actions**: 
  1. `/sdlc-init https://github.com/user/repo/issues/10` を実行
  2. FEATURE-10 が作成される
  3. Project を確認（Status: Planning）
  4. `/sdlc-decision FEATURE-10` で Decision を確定
  5. Project を確認（Decision Status: Confirmed）
  6. `/sdlc-coding FEATURE-10` で実装開始
  7. Project を確認（Status: Implementing）
  8. `/sdlc-pr-code FEATURE-10` で PR 作成
  9. Project を確認（PR Link が追加される）
- **Expected Behavior**: 
  - 各ステップで Project が自動更新される
  - Status と Decision Status が正しく遷移する
- **Verification Points**: 
  - GitHub Project UI で各フィールドを確認
  - Board View でカンバンの移動を確認

#### Test Case 2: 手動同期パス
- **User Actions**: 
  1. .metadata を手動編集
  2. git commit（push しない）
  3. `./sdlc-cli sync-github FEATURE-10` を実行
  4. Project を確認
- **Expected Behavior**: 
  - 手動同期でも正しく反映される
  - GitHub Actions を使わなくても動作する
- **Verification Points**: 
  - Project に変更が反映される

### User Flow 2: Project セットアップ

**Scenario**: 新しいリポジトリで GitHub Projects v2 統合を設定

#### Test Case 1: 自動セットアップ
- **User Actions**: 
  1. `./install.sh` を実行（または手動で sdlc-cli をインストール）
  2. `./sdlc-cli setup-project --auto` を実行
  3. 既存の Feature を確認（`ls sdlc/features/`）
  4. `./sdlc-cli sync-github --all` で既存 Feature をインポート
  5. GitHub Project を確認
- **Expected Behavior**: 
  - Project が自動作成される
  - 全 Feature が Project に表示される
- **Verification Points**: 
  - `.sdlc-config` の内容確認
  - Project URL の取得と確認

#### Test Case 2: 既存 Project の使用
- **User Actions**: 
  1. GitHub UI で Project を手動作成
  2. Project URL をコピー
  3. `./sdlc-cli setup-project --url <project-url>` を実行
  4. `./sdlc-cli sync-github --all` を実行
- **Expected Behavior**: 
  - カスタムフィールドが自動作成される
  - 既存 Feature が追加される
- **Verification Points**: 
  - 手動作成した Project に Feature が追加される

## API Tests

### Endpoint: GitHub Projects v2 GraphQL API

#### Test Case 1: Project 作成
- **Request**: 
```graphql
mutation {
  createProjectV2(input: {
    ownerId: "test_owner_id"
    title: "Test SDLC Project"
  }) {
    projectV2 { id }
  }
}
```
- **Expected Response**: Status 200
```json
{
  "data": {
    "createProjectV2": {
      "projectV2": {
        "id": "PVT_xxxxx"
      }
    }
  }
}
```

#### Test Case 2: カスタムフィールド作成
- **Request**: 
```graphql
mutation {
  createProjectV2Field(input: {
    projectId: "test_project_id"
    dataType: SINGLE_SELECT
    name: "Status"
  }) {
    projectV2Field { id }
  }
}
```
- **Expected Response**: Status 200

#### Test Case 3: 認証エラー
- **Request**: 無効なトークンで API 呼び出し
- **Expected Response**: Status 401
```json
{
  "message": "Bad credentials"
}
```

## Performance Tests

### Load Test 1: 大量 Feature の同期

- **Objective**: 100 Features を同期する際のパフォーマンス測定
- **Load Profile**: 100 Features を `sync-github --all` で同期
- **Success Criteria**: 
  - 全体の実行時間 < 10 分
  - API レート制限に到達しない
  - 成功率 > 95%

### Load Test 2: GitHub Actions の実行時間

- **Objective**: 複数 Feature の変更時の Actions 実行時間
- **Load Profile**: 10 Features を同時に変更して push
- **Success Criteria**: 
  - 実行時間 < 5 分
  - エラー率 < 5%
  - 全 Feature が正しく同期される

### Stress Test 1: API レート制限の確認

- **Objective**: レート制限に達した場合の挙動確認
- **Load Profile**: 短時間に大量の API コールを実行
- **Success Criteria**: 
  - レート制限エラーを適切に検出
  - リトライロジックが動作
  - 最終的に全て同期される

## Security Tests

### Test 1: 認証

- [x] Test invalid credentials: 無効なトークンでエラーになるか
- [x] Test expired tokens: 期限切れトークンでエラーになるか
- [x] Test token refresh: N/A（PAT は自動リフレッシュなし）

### Test 2: 認可

- [x] Test unauthorized access: write 権限がない Project へのアクセスでエラー
- [x] Test role-based access: Organization の権限設定が正しく機能するか
- [x] Test resource ownership: 他人の Project を操作できないか

### Test 3: Input Validation

- [x] Test SQL injection: N/A（GraphQL API）
- [x] Test XSS: Feature ID やフィールド値に特殊文字を含めてテスト
- [x] Test command injection: N/A（CLI コマンドは bash injection のリスクあり）

### Test 4: トークン管理

- [x] トークンが `.sdlc-config` に平文保存されないか
- [x] 環境変数 `GITHUB_TOKEN` が正しく使用されるか
- [x] ログにトークンが出力されないか

## Data Tests

### Test 1: .metadata の整合性

- **Scenario**: .metadata のフォーマットが正しく解析されるか
- **Test Data**: 
  - 正常な .metadata
  - 不正な形式（キー欠損、値が空、改行なし）
  - 特殊文字を含む値
- **Verification**: 
  - [ ] 正常なデータは正しく解析される
  - [ ] 不正なデータはエラーメッセージが表示される
  - [ ] 特殊文字がエスケープされる

### Test 2: カスタムフィールドのマッピング

- **Scenario**: .metadata のフィールドが Project のカスタムフィールドに正しくマッピングされるか
- **Test Cases**: 
  - STATUS: planning → Status: Planning
  - RISK_LEVEL: medium → Risk Level: Medium
  - DECISION_STATUS: confirmed → Decision Status: Confirmed
  - 未定義の値（例: STATUS=unknown）
- **Verification**: 
  - [ ] マッピングが正しく動作
  - [ ] 未定義の値はエラーまたはデフォルト値

## Regression Tests

- [ ] Test 1: 既存の `./sdlc-cli report` が引き続き動作する
- [ ] Test 2: `/sdlc-init` が既存の動作を維持する
- [ ] Test 3: `/sdlc-decision` が既存の動作を維持する
- [ ] Test 4: `/sdlc-coding` が既存の動作を維持する
- [ ] Test 5: `/sdlc-pr-code` が既存の動作を維持する

## Test Environment

### Setup Requirements

- Database: N/A
- External Services: GitHub Projects v2 API
- Test Data: テスト用リポジトリ、テスト用 Issue、テスト用 Project
- Configuration: 
  - GITHUB_TOKEN 環境変数
  - テスト用の `.sdlc-config`

### Test Data

```
Test Repo: lleizh/ai-driven-sdlc-test
Test Issues: #1, #2, #3
Test Features: FEATURE-TEST-1, FEATURE-TEST-2, FEATURE-TEST-3
Test Project: "Test SDLC Project"
```

## Test Execution

### Automated Tests

- **Command**: `make test` または `./tests/run_all_tests.sh`
- **CI/CD Integration**: GitHub Actions でテストを自動実行
- **Coverage Threshold**: 80%

### Manual Tests

- **Test Cases**: E2E テストとセキュリティテストは手動で実施
- **Tester**: TBD
- **Environment**: テスト用リポジトリ

## Test Coverage

### Coverage Targets

- Unit Test Coverage: ≥ 80%
- Integration Test Coverage: ≥ 70%
- Critical Paths: 100%（setup-project, sync-github の基本フロー）

### Coverage Reports

- **Tool**: `go test -cover` または `bash coverage`
- **Report Location**: `tests/coverage/`

## Risk-Based Testing

| Risk Area | Priority | Test Type | Coverage |
|-----------|----------|-----------|----------|
| API 統合の複雑性 | High | Integration | 100% |
| レート制限 | High | Performance | 100% |
| 認証・認可 | High | Security | 100% |
| 既存ワークフローへの影響 | Medium | Regression | 90% |
| データ整合性 | Medium | Data | 80% |

## Test Schedule

```
Phase 1: Unit tests（setup-project, sync-github の基本機能）
Phase 2: Integration tests（GitHub API との統合）
Phase 3: E2E tests（SDLC ワークフロー全体）
Phase 4: Performance & Security tests
```

## Exit Criteria

- [ ] All planned tests executed
- [ ] Coverage targets met (Unit: 80%, Integration: 70%, Critical: 100%)
- [ ] No critical bugs open
- [ ] Performance benchmarks passed（同期時間 < 5 分、成功率 > 95%）
- [ ] Security tests passed（認証、トークン管理）
- [ ] Regression tests passed（既存機能が正常動作）

## Test Results

### Execution Summary

- **Date**: TBD
- **Total Tests**: TBD
- **Passed**: TBD
- **Failed**: TBD
- **Skipped**: TBD
- **Coverage**: TBD

### Defects Found

| ID | Severity | Description | Status |
|----|----------|-------------|--------|
| - | - | - | - |

## Notes

- GitHub Projects v2 はプレビュー機能のため、API の変更に注意
- テスト用の Project は GitHub UI から手動削除する必要がある場合がある
- レート制限のテストは本番環境では実施しない（別の test org で実施）
