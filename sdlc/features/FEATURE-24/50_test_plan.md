# Test Plan（テスト計画）

**Feature ID**: FEATURE-24  
**Last Updated**: 2025-12-27  
**Test Owner**（テスト責任者）: TBD

## Test Strategy（テスト戦略）

この機能は GitHub Actions Workflow であるため、主に統合テストと E2E テストに焦点を当てる。

**Testing Levels**（テストレベル）:
- Unit Testing（ユニットテスト）: N/A（Workflow script のみ）
- Integration Testing（統合テスト）: 必須（Workflow + GitHub API）
- E2E Testing（E2Eテスト）: 必須（ラベル操作 → Projects 反映）
- Performance Testing（パフォーマンステスト）: オプション（負荷テスト）
- Security Testing（セキュリティテスト）: 必須（PAT 権限、API アクセス）

## Test Scope（テスト範囲）

### In Scope（範囲内）

- ラベル追加時の Projects への自動追加
- ラベル削除時の智能的な削除ロジック（`.metadata` 有無による分岐）
- 重複防止機構
- 既存 `sync-projects.yml` との共存
- エラーハンドリング（API レート制限、`.sdlc-config` 不在など）
- Workflow ログの適切な出力

### Out of Scope（範囲外）

- Issue 本体の機能（GitHub の責任範囲）
- GitHub Projects の UI（GitHub の責任範囲）
- PAT の生成と管理（管理者の責任範囲）
- `install.sh` の他の機能（既存テストでカバー）

## Integration Tests（統合テスト）

### Integration 1: add-to-project + GitHub API

**Scope**（範囲）: add-to-project Job + GitHub Projects v2 API

#### Test Case 1: 新規 Issue をラベルで追加

- **Description**（説明）: Issue に `sdlc:track` ラベルを追加すると、Projects に追加される
- **Setup**（セットアップ）: 
  - テスト用 Issue を作成（ラベルなし）
  - `.sdlc-config` を設定
- **Steps**（手順）: 
  1. Issue に `sdlc:track` ラベルを追加
  2. Workflow が起動するまで待機（最大 5 分）
  3. Projects を確認
- **Expected Result**（期待結果）: 
  - Issue が Projects に追加されている
  - Status が "Backlog"（Decision により決定）
  - Workflow ログに成功メッセージ
- **Cleanup**（クリーンアップ）: 
  - Projects から Issue を削除
  - テスト用 Issue を削除

#### Test Case 2: 既に Projects にある Issue に再度ラベル追加

- **Description**（説明）: 重複防止機構が動作する
- **Setup**（セットアップ）: 
  - テスト用 Issue を作成
  - Issue を手動で Projects に追加
- **Steps**（手順）: 
  1. Issue に `sdlc:track` ラベルを追加
  2. Workflow が起動するまで待機
  3. Projects を確認
- **Expected Result**（期待結果）: 
  - Issue が重複して追加されていない
  - Workflow ログに "Already exists, skipping" メッセージ
- **Cleanup**（クリーンアップ）: 
  - Projects から Issue を削除
  - テスト用 Issue を削除

#### Test Case 3: `.sdlc-config` が存在しない場合

- **Description**（説明）: Workflow がスキップされる
- **Setup**（セットアップ）: 
  - `.sdlc-config` を一時的にリネーム
  - テスト用 Issue を作成
- **Steps**（手順）: 
  1. Issue に `sdlc:track` ラベルを追加
  2. Workflow が起動するまで待機
- **Expected Result**（期待結果）: 
  - Workflow がスキップされる
  - Workflow ログに "Skipping: .sdlc-config not found" メッセージ
- **Cleanup**（クリーンアップ）: 
  - `.sdlc-config` を復元
  - テスト用 Issue を削除

### Integration 2: remove-from-project + Repository Checkout + GitHub API

**Scope**（範囲）: remove-from-project Job + Repository Checkout + GitHub Projects v2 API

#### Test Case 1: `/sdlc-init` 未実行の Issue からラベル削除

- **Description**（説明）: `.metadata` がない場合、Projects から削除される
- **Setup**（セットアップ）: 
  - テスト用 Issue を作成（タイトルに "FEATURE-999" を含める）
  - Issue に `sdlc:track` ラベルを追加して Projects に追加
  - `.metadata` ファイルは作成しない
- **Steps**（手順）: 
  1. Issue から `sdlc:track` ラベルを削除
  2. Workflow が起動するまで待機
  3. Projects を確認
- **Expected Result**（期待結果）: 
  - Issue が Projects から削除されている
  - Workflow ログに "Removed from Projects (no .metadata)" メッセージ
- **Cleanup**（クリーンアップ）: 
  - テスト用 Issue を削除

#### Test Case 2: `/sdlc-init` 実行済みの Feature からラベル削除

- **Description**（説明）: `.metadata` がある場合、Projects に保持される
- **Setup**（セットアップ）: 
  - テスト用 Issue を作成（タイトルに "FEATURE-888" を含める）
  - Issue に `sdlc:track` ラベルを追加して Projects に追加
  - `sdlc/features/FEATURE-888/.metadata` を作成
- **Steps**（手順）: 
  1. Issue から `sdlc:track` ラベルを削除
  2. Workflow が起動するまで待機
  3. Projects を確認
- **Expected Result**（期待結果）: 
  - Issue が Projects に保持されている
  - Workflow ログに "Kept in Projects (.metadata exists)" メッセージ
- **Cleanup**（クリーンアップ）: 
  - `sdlc/features/FEATURE-888/` ディレクトリを削除
  - Projects から Issue を削除
  - テスト用 Issue を削除

#### Test Case 3: Feature ID を抽出できない Issue からラベル削除

- **Description**（説明）: Feature ID がない場合、未初期化と判断して削除
- **Setup**（セットアップ）: 
  - テスト用 Issue を作成（Feature ID を含まないタイトル）
  - Issue に `sdlc:track` ラベルを追加して Projects に追加
- **Steps**（手順）: 
  1. Issue から `sdlc:track` ラベルを削除
  2. Workflow が起動するまで待機
  3. Projects を確認
- **Expected Result**（期待結果）: 
  - Issue が Projects から削除されている
  - Workflow ログに "Could not extract FEATURE_ID, assuming not initialized" メッセージ
- **Cleanup**（クリーンアップ）: 
  - テスト用 Issue を削除

### Integration 3: 既存 `sync-projects.yml` との共存

**Scope**（範囲）: 新規 Workflow + 既存 Workflow

#### Test Case 1: 両方の Workflow が同時実行

- **Description**（説明）: 競合せずに正常に動作する
- **Setup**（セットアップ）: 
  - テスト用 Issue を作成
  - `/sdlc-init` を実行して `.metadata` を作成
- **Steps**（手順）: 
  1. Issue に `sdlc:track` ラベルを追加（新規 Workflow 起動）
  2. `.metadata` を更新（既存 Workflow 起動）
  3. 両方の Workflow が完了するまで待機
  4. Projects を確認
- **Expected Result**（期待結果）: 
  - Issue が Projects に 1 つだけ存在する（重複なし）
  - Status などのフィールドが `.metadata` の内容と一致
  - 両方の Workflow が成功
- **Cleanup**（クリーンアップ）: 
  - `sdlc/features/FEATURE-XXX/` ディレクトリを削除
  - Projects から Issue を削除
  - テスト用 Issue を削除

## E2E Tests（E2Eテスト）

### User Flow 1: 新規 Issue のライフサイクル（低リスク）

**Scenario**（シナリオ）: PM が新規 Issue を作成し、開発者が `/sdlc-init` を実行するまでの流れ

#### Test Case 1: Happy Path（正常系）

- **User Actions**（ユーザー操作）: 
  1. PM が Issue を作成
  2. PM が `sdlc:track` ラベルを追加
  3. 開発者が Projects で Issue を確認（Status = Backlog）
  4. 開発者が `/sdlc-init` を実行
  5. `sync-projects.yml` が Status を Planning に更新
- **Expected Behavior**（期待動作）: 
  - Step 2 後: Issue が Projects に追加され、Status = Backlog
  - Step 5 後: Status = Planning に更新
- **Verification Points**（検証ポイント）: 
  - Projects での Issue の存在
  - Status の遷移（Backlog → Planning）
  - `.metadata` の作成

### User Flow 2: Issue をキャンセル

**Scenario**（シナリオ）: PM が Issue を作成したが、後でキャンセルする

#### Test Case 1: `/sdlc-init` 実行前にキャンセル

- **User Actions**（ユーザー操作）: 
  1. PM が Issue を作成
  2. PM が `sdlc:track` ラベルを追加
  3. PM が後で `sdlc:track` ラベルを削除（キャンセル）
- **Expected Behavior**（期待動作）: 
  - Step 2 後: Issue が Projects に追加
  - Step 3 後: Issue が Projects から削除
- **Verification Points**（検証ポイント）: 
  - Issue が Projects から削除されている
  - Issue 本体は残っている

#### Test Case 2: `/sdlc-init` 実行後にラベル削除

- **User Actions**（ユーザー操作）: 
  1. PM が Issue を作成
  2. PM が `sdlc:track` ラベルを追加
  3. 開発者が `/sdlc-init` を実行
  4. PM が誤って `sdlc:track` ラベルを削除
- **Expected Behavior**（期待動作）: 
  - Step 4 後: Issue が Projects に保持される（`.metadata` があるため）
- **Verification Points**（検証ポイント）: 
  - Issue が Projects に残っている
  - Workflow ログに "Kept in Projects" メッセージ

## API Tests（APIテスト）

### GraphQL API: addProjectV2ItemById

#### Test Case 1: Valid Request（正常なリクエスト）

- **Request**（リクエスト）: 
```graphql
mutation {
  addProjectV2ItemById(input: {
    projectId: "PVT_xxxxxxxxxx"
    contentId: "I_kwDOxxxxxx"
  }) {
    item {
      id
    }
  }
}
```
- **Expected Response**（期待レスポンス）: Status 200
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

#### Test Case 2: Invalid Project ID（不正な Project ID）

- **Request**（リクエスト）: 
```graphql
mutation {
  addProjectV2ItemById(input: {
    projectId: "INVALID_ID"
    contentId: "I_kwDOxxxxxx"
  }) {
    item {
      id
    }
  }
}
```
- **Expected Response**（期待レスポンス）: Status 200（GraphQL は常に 200）
```json
{
  "errors": [
    {
      "message": "Could not resolve to a node with the global id of 'INVALID_ID'"
    }
  ]
}
```

#### Test Case 3: Unauthorized（未認証）

- **Request**（リクエスト）: PAT なしでリクエスト
- **Expected Response**（期待レスポンス）: Status 401
```json
{
  "message": "Requires authentication"
}
```

### GraphQL API: deleteProjectV2Item

#### Test Case 1: Valid Request（正常なリクエスト）

- **Request**（リクエスト）: 
```graphql
mutation {
  deleteProjectV2Item(input: {
    projectId: "PVT_xxxxxxxxxx"
    itemId: "PVTI_xxxxxxxx"
  }) {
    deletedItemId
  }
}
```
- **Expected Response**（期待レスポンス）: Status 200
```json
{
  "data": {
    "deleteProjectV2Item": {
      "deletedItemId": "PVTI_xxxxxxxx"
    }
  }
}
```

## Performance Tests（パフォーマンステスト）

### Load Test 1: 複数 Issue の同時ラベル追加

- **Objective**（目的）: API レート制限内で複数の Issue を処理できることを確認
- **Load Profile**（負荷プロファイル）: 10 件の Issue に同時にラベルを追加
- **Success Criteria**（成功基準）: 
  - すべての Issue が 5 分以内に Projects に追加される
  - Workflow の失敗率 < 5%
  - API レート制限に達しない

### Stress Test 1: API レート制限への到達

- **Objective**（目的）: レート制限に達したときの挙動を確認
- **Load Profile**（負荷プロファイル）: 100 件の Issue に短時間でラベルを追加
- **Success Criteria**（成功基準）: 
  - Retry 機構が動作する
  - レート制限リセット後、処理が再開される
  - データの不整合が発生しない

## Security Tests（セキュリティテスト）

### Test 1: PAT の権限

- [ ] PAT に `repo` スコープがある場合、Workflow が成功する
- [ ] PAT に `project` スコープがある場合、Workflow が成功する
- [ ] PAT にスコープがない場合、Workflow が失敗し適切なエラーメッセージが出力される

### Test 2: PAT の漏洩防止

- [ ] Workflow ログに PAT が出力されない
- [ ] GraphQL リクエストのヘッダーがログに出力されない

### Test 3: 入力値の検証

- [ ] Issue node ID が不正な形式の場合、Workflow が適切にエラーハンドリング
- [ ] ラベル名が不正な場合、Workflow がスキップされる

## Data Tests（データテスト）

### Test 1: `.metadata` ファイルの確認

- **Scenario**（シナリオ）: 様々な `.metadata` の状態でラベル削除時の挙動を確認
- **Test Cases**（テストケース）: 
  - `.metadata` が存在する → Projects に保持
  - `.metadata` が存在しない → Projects から削除
  - `.metadata` のパスが間違っている → Projects から削除（未初期化と判断）
  - `.metadata` の内容が不正 → Projects に保持（ファイルの存在のみチェック）

### Test 2: Feature ID の抽出

- **Scenario**（シナリオ）: 様々な Issue タイトル/本文から Feature ID を抽出
- **Test Cases**（テストケース）: 
  - タイトル: "[FEATURE-123] Add feature" → FEATURE-123
  - タイトル: "FEATURE-456: Fix bug" → FEATURE-456
  - 本文: "Feature ID: FEATURE-789" → FEATURE-789
  - タイトルと本文に異なる ID → タイトルを優先
  - Feature ID なし → 抽出失敗（未初期化と判断）

## Regression Tests（リグレッションテスト）

- [ ] 既存の `sync-projects.yml` が引き続き正常に動作する
- [ ] `/sdlc-init` コマンドが引き続き正常に動作する
- [ ] 既存の Feature（`.metadata` あり）が影響を受けない
- [ ] 手動で Projects に追加した Issue が影響を受けない（新規 Workflow と無関係）

## Test Environment（テスト環境）

### Setup Requirements（セットアップ要件）

- GitHub repository（テスト用または本番）
- GitHub Projects（テスト用）
- `secrets.GH_PAT`（`repo` と `project` スコープ）
- `.sdlc-config`（テスト用 Project ID を設定）

### Test Data（テストデータ）

```
Test Issue 1: タイトル "FEATURE-999: Test Issue (no .metadata)"
Test Issue 2: タイトル "FEATURE-888: Test Issue (with .metadata)"
Test Issue 3: タイトル "Test Issue (no FEATURE_ID)"
Test .metadata: sdlc/features/FEATURE-888/.metadata
```

## Test Execution（テスト実行）

### Automated Tests（自動テスト）

- **Command**（コマンド）: 現時点では手動テスト（将来的に自動化を検討）
- **CI/CD Integration**: N/A（Workflow 自体が CI/CD）

### Manual Tests（手動テスト）

- **Test Cases**（テストケース）: 上記のすべてのテストケース
- **Tester**（テスター）: TBD
- **Environment**（環境）: 本番環境（または専用のテスト repository）

**手動テスト手順:**
1. テスト用 Issue を作成
2. 各テストケースに従ってラベル操作を実行
3. Workflow ログを確認
4. Projects の状態を確認
5. 結果を記録
6. クリーンアップ

## Test Coverage（テストカバレッジ）

### Coverage Targets（カバレッジ目標）

- Integration Test Coverage（統合テストカバレッジ）: ≥ 90%（主要な処理パス）
- E2E Test Coverage（E2Eテストカバレッジ）: ≥ 80%（ユーザーフロー）
- Critical Paths（クリティカルパス）: 100%（ラベル追加/削除、`.metadata` チェック）

### Coverage Reports（カバレッジレポート）

- **Tool**（ツール）: 手動チェックリスト
- **Report Location**（レポート場所）: このファイルの「Test Results」セクション

## Risk-Based Testing（リスクベーステスト）

| リスク領域 | 優先度 | テスト種別 | カバレッジ |
|-----------|--------|-----------|----------|
| `.metadata` ファイル確認ロジック | High | Integration, E2E | 100% |
| API レート制限 | High | Performance, Stress | 90% |
| `sync-projects.yml` との競合 | Medium | Integration, Regression | 80% |
| ラベル誤削除 | Low | E2E | 50% |

## Test Schedule（テストスケジュール）

```
Week 1: 
- 設計レビュー完了後
- 統合テスト（add-to-project, remove-from-project）

Week 2: 
- E2E テスト（ユーザーフロー）
- API テスト

Week 3: 
- パフォーマンステスト
- セキュリティテスト
- リグレッションテスト

Week 4: 
- バグ修正と再テスト
- 最終確認
```

## Exit Criteria（終了基準）

- [ ] すべての P0 統合テストが成功
- [ ] すべての E2E テストが成功
- [ ] 重大なバグがない（Critical bugs = 0）
- [ ] API レート制限のテストが成功
- [ ] 既存 `sync-projects.yml` とのリグレッションテストが成功
- [ ] セキュリティテスト（PAT 権限）が成功
- [ ] テスト結果が文書化されている

## Test Results（テスト結果）

### Execution Summary（実行サマリー）

- **Date**（日付）: TBD
- **Total Tests**（総テスト数）: TBD
- **Passed**（成功）: TBD
- **Failed**（失敗）: TBD
- **Skipped**（スキップ）: TBD
- **Coverage**（カバレッジ）: TBD

### Defects Found（発見された欠陥）

| ID | 重要度 | 説明 | ステータス |
|----|--------|------|-----------|
| | | | |

## Notes（備考）

- このテスト計画は Medium リスク機能に適した内容
- Workflow のテストは本番環境で行う必要がある（GitHub Actions の制約）
- テスト用 Issue と `.metadata` は必ずクリーンアップすること
- API レート制限のテストは慎重に実施（本番環境への影響を考慮）
