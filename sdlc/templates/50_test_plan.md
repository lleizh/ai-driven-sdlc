# Test Plan（テスト計画）

**Feature ID**: {FEATURE_ID}  
**Last Updated**: {DATE}  
**Test Owner**（テスト責任者）: {NAME}  
**Risk Level**: LOW | MEDIUM | HIGH

---

## Test Strategy Overview（テスト戦略概要）

**Testing Approach**（テストアプローチ）:
<!-- どのような方針でテストを実施するか -->


**Testing Levels**（テストレベル）:
- ✅ Unit Testing - {coverage target, e.g., ≥80%}
- ✅ Integration Testing - {scope}
- ⚠️ E2E Testing - {required for Medium/High Risk}
- ⚠️ Performance Testing - {required for High Risk}
- ⚠️ Security Testing - {required for High Risk}

---

## Test Scope（テスト範囲）

### In Scope（テスト対象）
- 
- 

### Out of Scope（テスト対象外）
- 
- 

### Key Test Areas（重点テスト領域）
<!-- 特に重点的にテストすべき領域 -->
- 
- 

---

## Unit Tests（ユニットテスト）

### Target Coverage（目標カバレッジ）
- **Overall**: ≥ {XX%}
- **Critical Functions**: 100%

### Test Cases（テストケース）
<!-- /sdlc-test コマンドで自動生成されます -->

**Example**（例）:
```
TestFunctionName:
- [ ] 正常系: {説明}
- [ ] 異常系: {説明}
- [ ] 境界値: {説明}
```

---

## Integration Tests（統合テスト）

### Test Scenarios（テストシナリオ）
<!-- 主要な統合テストシナリオ -->

#### Scenario 1: {シナリオ名}
**Description**（説明）:

**Steps**（手順）:
1. 
2. 
3. 

**Expected Result**（期待結果）:

**Status**: ⬜ Not Started | 🟡 In Progress | ✅ Passed | ❌ Failed

---

#### Scenario 2: {シナリオ名}
**Description**（説明）:

**Steps**（手順）:
1. 
2. 

**Expected Result**（期待結果）:

**Status**: ⬜ Not Started | 🟡 In Progress | ✅ Passed | ❌ Failed

---

## E2E Tests（E2Eテスト）
<!-- Medium/High Risk の場合のみ必須 -->

### User Scenarios（ユーザーシナリオ）

#### E2E-1: {シナリオ名}
**User Story**（ユーザーストーリー）:

**Steps**（手順）:
1. 
2. 
3. 

**Expected Result**（期待結果）:

**Status**: ⬜ Not Started | 🟡 In Progress | ✅ Passed | ❌ Failed

---

## Performance Tests（パフォーマンステスト）
<!-- High Risk の場合のみ必須 -->

### Performance Criteria（パフォーマンス基準）
- **Response Time**: {目標値, e.g., <200ms}
- **Throughput**: {目標値, e.g., >1000 req/s}
- **Resource Usage**: {目標値, e.g., CPU <50%, Memory <1GB}

### Test Cases（テストケース）
- [ ] Load Test: {説明}
- [ ] Stress Test: {説明}
- [ ] Spike Test: {説明}

---

## Security Tests（セキュリティテスト）
<!-- High Risk の場合のみ必須 -->

### Security Checklist（セキュリティチェックリスト）
- [ ] Authentication/Authorization testing
- [ ] Input validation testing
- [ ] SQL Injection testing
- [ ] XSS testing
- [ ] CSRF protection testing
- [ ] Sensitive data exposure testing

---

## Test Environment（テスト環境）

### Environment Setup（環境設定）
- **Database**: {database type and version}
- **External Services**: {mock/staging services}
- **Test Data**: {test data requirements}
- **Configuration**: {test-specific config}

### Dependencies（依存関係）
- 
- 

---

## Risk-Based Testing（リスクベーステスト）
<!-- risks.md の High/Medium Risk に対応 -->

| Risk ID | リスク領域 | 優先度 | テスト種別 | ステータス |
|---------|-----------|--------|-----------|-----------|
| R001 | | High | Unit + Integration + E2E | |
| R002 | | Medium | Unit + Integration | |

---

## Test Execution（テスト実行）

### Execution Plan（実行計画）
1. **Phase 1**: Unit Tests
   - Duration: {時間}
   - Owner: {担当者}

2. **Phase 2**: Integration Tests
   - Duration: {時間}
   - Owner: {担当者}

3. **Phase 3**: E2E Tests (if applicable)
   - Duration: {時間}
   - Owner: {担当者}

### Test Schedule（テストスケジュール）
```
Week 1: Unit Tests
Week 2: Integration Tests
Week 3: E2E + Performance Tests (if applicable)
```

---

## Exit Criteria（終了基準）

### Mandatory（必須）
- [ ] All planned tests executed（全計画テスト実行完了）
- [ ] Unit test coverage ≥ {target}%
- [ ] Integration test coverage ≥ {target}%
- [ ] No critical bugs open（クリティカルバグなし）
- [ ] All High priority bugs fixed（高優先度バグ修正完了）

### Risk-Level Specific（リスクレベル別）

**Medium/High Risk**:
- [ ] E2E tests passed（E2Eテスト成功）
- [ ] No high/medium bugs open（高・中バグなし）

**High Risk**:
- [ ] Performance tests passed（パフォーマンステスト成功）
- [ ] Security tests passed（セキュリティテスト成功）
- [ ] Load testing completed（負荷テスト完了）

---

## Test Results Summary（テスト結果サマリー）
<!-- /sdlc-test コマンド実行後に更新 -->

| テストタイプ | 実行数 | 成功 | 失敗 | カバレッジ |
|-------------|-------|------|------|-----------|
| Unit | | | | |
| Integration | | | | |
| E2E | | | | |
| Performance | | | | |

**Test Execution Date**（実行日）: {DATE}

---

## Known Issues（既知の問題）
<!-- テスト中に発見された問題 -->

| Issue ID | 説明 | 優先度 | ステータス | 担当者 |
|----------|------|--------|-----------|--------|
| | | Critical/High/Medium/Low | Open/In Progress/Fixed | |

---

## Notes（備考）
<!-- テスト実施に関する補足情報 -->
- 
- 
