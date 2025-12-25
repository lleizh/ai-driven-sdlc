# Test Plan

**Feature ID**: {FEATURE_ID}  
**Last Updated**: {DATE}  
**Test Owner**: {NAME}

## Test Strategy
<!-- テスト戦略の概要 -->

**Testing Levels**:
- Unit Testing: {coverage target}
- Integration Testing: {scope}
- E2E Testing: {scope}
- Performance Testing: {required/optional}
- Security Testing: {required/optional}

## Test Scope

### In Scope
- 
- 

### Out of Scope
- 
- 

## Unit Tests

### Component: {Name}
**File**: `path/to/test/file_test.go`

#### Test Case 1: {Name}
- **Description**: 
- **Input**: 
- **Expected Output**: 
- **Edge Cases**: 

#### Test Case 2: {Name}
- **Description**: 
- **Input**: 
- **Expected Output**: 
- **Edge Cases**: 

### Component: {Name}
**File**: `path/to/test/file_test.go`

#### Test Case 1: {Name}
- **Description**: 
- **Input**: 
- **Expected Output**: 
- **Edge Cases**: 

## Integration Tests

### Integration 1: {Name}
**Scope**: Components A + B + Database

#### Test Case 1: {Name}
- **Description**: 
- **Setup**: 
- **Steps**: 
  1. 
  2. 
- **Expected Result**: 
- **Cleanup**: 

#### Test Case 2: {Name}
- **Description**: 
- **Setup**: 
- **Steps**: 
  1. 
  2. 
- **Expected Result**: 
- **Cleanup**: 

## E2E Tests

### User Flow 1: {Name}
**Scenario**: 

#### Test Case 1: Happy Path
- **User Actions**: 
  1. 
  2. 
- **Expected Behavior**: 
- **Verification Points**: 

#### Test Case 2: Error Path
- **User Actions**: 
  1. 
  2. 
- **Expected Behavior**: 
- **Verification Points**: 

## API Tests

### Endpoint: {METHOD} {PATH}

#### Test Case 1: Valid Request
- **Request**: 
```json
{
  "example": "request"
}
```
- **Expected Response**: Status 200
```json
{
  "example": "response"
}
```

#### Test Case 2: Invalid Request
- **Request**: 
```json
{
  "invalid": "data"
}
```
- **Expected Response**: Status 400
```json
{
  "error": "message"
}
```

#### Test Case 3: Unauthorized
- **Request**: No auth token
- **Expected Response**: Status 401

## Performance Tests

### Load Test 1: {Name}
- **Objective**: 
- **Load Profile**: {users/sec, duration}
- **Success Criteria**: 
  - Response time < {ms} at p95
  - Error rate < {%}
  - Throughput > {req/sec}

### Stress Test 1: {Name}
- **Objective**: 
- **Load Profile**: {ramp-up strategy}
- **Success Criteria**: 
  - System remains stable up to {load}
  - Graceful degradation after {load}

## Security Tests

### Test 1: Authentication
- [ ] Test invalid credentials
- [ ] Test expired tokens
- [ ] Test token refresh

### Test 2: Authorization
- [ ] Test unauthorized access
- [ ] Test role-based access
- [ ] Test resource ownership

### Test 3: Input Validation
- [ ] Test SQL injection
- [ ] Test XSS
- [ ] Test command injection

### Test 4: Rate Limiting
- [ ] Test rate limit enforcement
- [ ] Test rate limit bypass attempts

## Data Tests

### Test 1: Data Migration
- **Scenario**: 
- **Test Data**: 
- **Verification**: 
  - [ ] Data integrity
  - [ ] Data completeness
  - [ ] Performance impact

### Test 2: Data Validation
- **Scenario**: 
- **Test Cases**: 
  - Valid data formats
  - Invalid data formats
  - Boundary values

## Regression Tests
<!-- 既存機能への影響確認 -->
- [ ] Test 1: {existing feature}
- [ ] Test 2: {existing feature}
- [ ] Test 3: {existing feature}

## Test Environment

### Setup Requirements
- Database: 
- External Services: 
- Test Data: 
- Configuration: 

### Test Data
```
User 1: {credentials}
User 2: {credentials}
Test Dataset: {location}
```

## Test Execution

### Automated Tests
- **Command**: `make test`
- **CI/CD Integration**: {pipeline name}
- **Coverage Threshold**: {percentage}

### Manual Tests
- **Test Cases**: {list or link}
- **Tester**: {name}
- **Environment**: {staging/qa}

## Test Coverage

### Coverage Targets
- Unit Test Coverage: ≥ {percentage}
- Integration Test Coverage: ≥ {percentage}
- Critical Paths: 100%

### Coverage Reports
- **Tool**: {coverage tool}
- **Report Location**: {path or url}

## Risk-Based Testing
<!-- リスクに基づくテスト優先度 -->
| Risk Area | Priority | Test Type | Coverage |
|-----------|----------|-----------|----------|
| | High | | |
| | Medium | | |
| | Low | | |

## Test Schedule
<!-- テストのスケジュール -->
```
Week 1: Unit tests
Week 2: Integration tests
Week 3: E2E tests
Week 4: Performance & Security tests
```

## Exit Criteria
<!-- テスト完了の基準 -->
- [ ] All planned tests executed
- [ ] Coverage targets met
- [ ] No critical bugs open
- [ ] Performance benchmarks passed
- [ ] Security tests passed

## Test Results
<!-- テスト結果記録用 -->

### Execution Summary
- **Date**: 
- **Total Tests**: 
- **Passed**: 
- **Failed**: 
- **Skipped**: 
- **Coverage**: 

### Defects Found
| ID | Severity | Description | Status |
|----|----------|-------------|--------|
| | | | |

## Notes
<!-- その他のメモ -->


