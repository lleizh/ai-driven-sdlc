# Test Plan（テスト計画）

**Feature ID**: {FEATURE_ID}  
**Last Updated**: {DATE}  
**Test Owner**（テスト責任者）: {NAME}

## Test Strategy（テスト戦略）
<!-- テスト戦略の概要 -->

**Testing Levels**（テストレベル）:
- Unit Testing（ユニットテスト）: {coverage target}
- Integration Testing（統合テスト）: {scope}
- E2E Testing（E2Eテスト）: {scope}
- Performance Testing（パフォーマンステスト）: {required/optional}
- Security Testing（セキュリティテスト）: {required/optional}

## Test Scope（テスト範囲）

### In Scope（範囲内）
- 
- 

### Out of Scope（範囲外）
- 
- 

## Unit Tests（ユニットテスト）

### Component: {名前}
**File**: `path/to/test/file_test.go`

#### Test Case 1: {名前}
- **Description**（説明）: 
- **Input**（入力）: 
- **Expected Output**（期待出力）: 
- **Edge Cases**（エッジケース）: 

#### Test Case 2: {名前}
- **Description**（説明）: 
- **Input**（入力）: 
- **Expected Output**（期待出力）: 
- **Edge Cases**（エッジケース）: 

### Component: {名前}
**File**: `path/to/test/file_test.go`

#### Test Case 1: {名前}
- **Description**（説明）: 
- **Input**（入力）: 
- **Expected Output**（期待出力）: 
- **Edge Cases**（エッジケース）: 

## Integration Tests（統合テスト）

### Integration 1: {名前}
**Scope**（範囲）: Components A + B + Database

#### Test Case 1: {名前}
- **Description**（説明）: 
- **Setup**（セットアップ）: 
- **Steps**（手順）: 
  1. 
  2. 
- **Expected Result**（期待結果）: 
- **Cleanup**（クリーンアップ）: 

#### Test Case 2: {名前}
- **Description**（説明）: 
- **Setup**（セットアップ）: 
- **Steps**（手順）: 
  1. 
  2. 
- **Expected Result**（期待結果）: 
- **Cleanup**（クリーンアップ）: 

## E2E Tests（E2Eテスト）

### User Flow 1: {名前}
**Scenario**（シナリオ）: 

#### Test Case 1: Happy Path（正常系）
- **User Actions**（ユーザー操作）: 
  1. 
  2. 
- **Expected Behavior**（期待動作）: 
- **Verification Points**（検証ポイント）: 

#### Test Case 2: Error Path（異常系）
- **User Actions**（ユーザー操作）: 
  1. 
  2. 
- **Expected Behavior**（期待動作）: 
- **Verification Points**（検証ポイント）: 

## API Tests（APIテスト）

### Endpoint: {METHOD} {PATH}

#### Test Case 1: Valid Request（正常なリクエスト）
- **Request**（リクエスト）: 
```json
{
  "example": "request"
}
```
- **Expected Response**（期待レスポンス）: Status 200
```json
{
  "example": "response"
}
```

#### Test Case 2: Invalid Request（不正なリクエスト）
- **Request**（リクエスト）: 
```json
{
  "invalid": "data"
}
```
- **Expected Response**（期待レスポンス）: Status 400
```json
{
  "error": "message"
}
```

#### Test Case 3: Unauthorized（未認証）
- **Request**（リクエスト）: No auth token
- **Expected Response**（期待レスポンス）: Status 401

## Performance Tests（パフォーマンステスト）

### Load Test 1: {名前}
- **Objective**（目的）: 
- **Load Profile**（負荷プロファイル）: {users/sec, duration}
- **Success Criteria**（成功基準）: 
  - Response time < {ms} at p95
  - Error rate < {%}
  - Throughput > {req/sec}

### Stress Test 1: {名前}
- **Objective**（目的）: 
- **Load Profile**（負荷プロファイル）: {ramp-up strategy}
- **Success Criteria**（成功基準）: 
  - System remains stable up to {load}（システムは{load}まで安定）
  - Graceful degradation after {load}（{load}以降は段階的な性能低下）

## Security Tests（セキュリティテスト）

### Test 1: Authentication（認証）
- [ ] Test invalid credentials（無効な認証情報のテスト）
- [ ] Test expired tokens（期限切れトークンのテスト）
- [ ] Test token refresh（トークンリフレッシュのテスト）

### Test 2: Authorization（認可）
- [ ] Test unauthorized access（未認可アクセスのテスト）
- [ ] Test role-based access（ロールベースアクセスのテスト）
- [ ] Test resource ownership（リソース所有権のテスト）

### Test 3: Input Validation（入力検証）
- [ ] Test SQL injection（SQLインジェクションのテスト）
- [ ] Test XSS
- [ ] Test command injection（コマンドインジェクションのテスト）

### Test 4: Rate Limiting（レート制限）
- [ ] Test rate limit enforcement（レート制限の実施テスト）
- [ ] Test rate limit bypass attempts（レート制限回避試行のテスト）

## Data Tests（データテスト）

### Test 1: Data Migration（データマイグレーション）
- **Scenario**（シナリオ）: 
- **Test Data**（テストデータ）: 
- **Verification**（検証）: 
  - [ ] Data integrity（データ整合性）
  - [ ] Data completeness（データ完全性）
  - [ ] Performance impact（パフォーマンス影響）

### Test 2: Data Validation（データ検証）
- **Scenario**（シナリオ）: 
- **Test Cases**（テストケース）: 
  - Valid data formats（有効なデータ形式）
  - Invalid data formats（無効なデータ形式）
  - Boundary values（境界値）

## Regression Tests（リグレッションテスト）
<!-- 既存機能への影響確認 -->
- [ ] Test 1: {existing feature}
- [ ] Test 2: {existing feature}
- [ ] Test 3: {existing feature}

## Test Environment（テスト環境）

### Setup Requirements（セットアップ要件）
- Database（データベース）: 
- External Services（外部サービス）: 
- Test Data（テストデータ）: 
- Configuration（設定）: 

### Test Data（テストデータ）
```
User 1: {credentials}
User 2: {credentials}
Test Dataset: {location}
```

## Test Execution（テスト実行）

### Automated Tests（自動テスト）
- **Command**（コマンド）: `make test`
- **CI/CD Integration**: {pipeline name}
- **Coverage Threshold**（カバレッジ閾値）: {percentage}

### Manual Tests（手動テスト）
- **Test Cases**（テストケース）: {list or link}
- **Tester**（テスター）: {name}
- **Environment**（環境）: {staging/qa}

## Test Coverage（テストカバレッジ）

### Coverage Targets（カバレッジ目標）
- Unit Test Coverage（ユニットテストカバレッジ）: ≥ {percentage}
- Integration Test Coverage（統合テストカバレッジ）: ≥ {percentage}
- Critical Paths（クリティカルパス）: 100%

### Coverage Reports（カバレッジレポート）
- **Tool**（ツール）: {coverage tool}
- **Report Location**（レポート場所）: {path or url}

## Risk-Based Testing（リスクベーステスト）
<!-- リスクに基づくテスト優先度 -->
| リスク領域 | 優先度 | テスト種別 | カバレッジ |
|-----------|--------|-----------|----------|
| | High | | |
| | Medium | | |
| | Low | | |

## Test Schedule（テストスケジュール）
<!-- テストのスケジュール -->
```
Week 1: Unit tests（ユニットテスト）
Week 2: Integration tests（統合テスト）
Week 3: E2E tests（E2Eテスト）
Week 4: Performance & Security tests（パフォーマンス・セキュリティテスト）
```

## Exit Criteria（終了基準）
<!-- テスト完了の基準 -->
- [ ] All planned tests executed（全計画テストが実行された）
- [ ] Coverage targets met（カバレッジ目標を達成）
- [ ] No critical bugs open（クリティカルバグなし）
- [ ] Performance benchmarks passed（パフォーマンス基準を通過）
- [ ] Security tests passed（セキュリティテストを通過）

## Test Results（テスト結果）
<!-- テスト結果記録用 -->

### Execution Summary（実行サマリー）
- **Date**（日付）: 
- **Total Tests**（総テスト数）: 
- **Passed**（成功）: 
- **Failed**（失敗）: 
- **Skipped**（スキップ）: 
- **Coverage**（カバレッジ）: 

### Defects Found（発見された欠陥）
| ID | 重要度 | 説明 | ステータス |
|----|--------|------|-----------|
| | | | |

## Notes（備考）
<!-- その他のメモ -->

