# Review Findings（レビュー結果）

**Feature ID**: {FEATURE_ID}  
**Review Type**（レビュー種別）: Design Review | Code Review  
**Review Date**（レビュー日）: {DATE}  
**Reviewers**（レビュアー）: {NAMES}

---

## Review Summary（レビュー概要）

**Status**（ステータス）: APPROVED | APPROVED_WITH_CONDITIONS | CHANGES_REQUIRED | BLOCKED

**Overall Assessment**（総合評価）:
<!-- レビューの総括 -->


**Decision**（決定）:
- [ ] ✅ Approved（承認） - Proceed to next phase（次フェーズへ進む）
- [ ] ⚠️ Approved with conditions（条件付き承認） - {conditions}
- [ ] 🔄 Changes required（変更が必要） - See critical issues below（下記の重大な問題を参照）
- [ ] ❌ Blocked（ブロック） - {reason}

---

## Critical Issues（重大な問題）
<!-- 必ず対応が必要な問題（ブロッカー） -->

### Issue 1: {タイトル}
**Description**（説明）:


**Impact**（影響）:
- **Severity**（深刻度）: Critical | High | Medium
- **Affected Areas**（影響範囲）: 

**Recommendation**（推奨対応）:


**Owner**（担当者）: {name}  
**Status**（ステータス）: ⬜ Open | 🔄 In Progress | ✅ Resolved

---

### Issue 2: {タイトル}
**Description**（説明）:


**Impact**（影響）:
- **Severity**（深刻度）: Critical | High | Medium
- **Affected Areas**（影響範囲）: 

**Recommendation**（推奨対応）:


**Owner**（担当者）: {name}  
**Status**（ステータス）: ⬜ Open | 🔄 In Progress | ✅ Resolved

---

## Important Considerations（重要な考慮事項）
<!-- 重要だが必須ではない指摘 -->

### Consideration 1: {タイトル}
**Rationale**（理由）:


**Suggestion**（提案）:


**Owner**（担当者）: {name} (optional)

---

### Consideration 2: {タイトル}
**Rationale**（理由）:


**Suggestion**（提案）:


**Owner**（担当者）: {name} (optional)

---

## Design Review Findings（設計レビュー結果）
<!-- Design Review の場合のみ記入 -->

### Architecture（アーキテクチャ）
- [ ] Architecture is sound（アーキテクチャが健全）
- [ ] Component boundaries are clear（コンポーネント境界が明確）
- [ ] Dependencies are manageable（依存関係が管理可能）
- [ ] Design patterns are appropriate（デザインパターンが適切）

**Comments**（コメント）:


---

### Scalability & Performance（スケーラビリティとパフォーマンス）
- [ ] Scales to expected load（想定負荷に対応可能）
- [ ] Resource usage is reasonable（リソース使用量が適切）
- [ ] Performance targets are achievable（パフォーマンス目標が達成可能）
- [ ] Bottlenecks identified and addressed（ボトルネックが特定され対処されている）

**Comments**（コメント）:


---

### Security（セキュリティ）
- [ ] Authentication/Authorization covered（認証・認可がカバーされている）
- [ ] Data protection addressed（データ保護が考慮されている）
- [ ] Input validation planned（入力検証が計画されている）
- [ ] Common vulnerabilities considered（一般的な脆弱性が考慮されている）

**Comments**（コメント）:


---

### Maintainability（保守性）
- [ ] Code organization is logical（コード構成が論理的）
- [ ] Complexity is manageable（複雑性が管理可能）
- [ ] Documentation is sufficient（ドキュメントが十分）
- [ ] Testing strategy is clear（テスト戦略が明確）

**Comments**（コメント）:


---

## Code Review Findings（コードレビュー結果）
<!-- Code Review の場合のみ記入 -->

### Code Quality（コード品質）
- [ ] Code follows style guidelines（コーディング規約に従っている）
- [ ] Naming is clear and consistent（命名が明確で一貫している）
- [ ] Logic is easy to understand（ロジックが理解しやすい）
- [ ] No obvious bugs or issues（明らかなバグや問題がない）

**Comments**（コメント）:


---

### Testing（テスト）
- [ ] Unit tests are comprehensive（ユニットテストが包括的）
- [ ] Test coverage meets target（テストカバレッジが目標達成）
- [ ] Edge cases are tested（エッジケースがテストされている）
- [ ] Tests are maintainable（テストが保守しやすい）

**Comments**（コメント）:


---

### Implementation vs Design（実装と設計の一致性）
- [ ] Follows approved design（承認された設計に従っている）
- [ ] Decisions are consistent（決定事項と一致している）
- [ ] No unapproved deviations（未承認の逸脱がない）

**Comments**（コメント）:


---

## Risk Review（リスクレビュー）

### Risk Assessment（リスク評価）
- [ ] All major risks documented（全主要リスクが文書化されている）
- [ ] Risk levels are appropriate（リスクレベルが適切）
- [ ] Mitigation strategies are defined（軽減策が定義されている）
- [ ] High risks have contingency plans（高リスクに緊急対応計画がある）

**Comments**（コメント）:


---

### New Risks Identified（新たに発見されたリスク）
<!-- レビュー中に発見した追加のリスク -->

#### Risk: {リスクタイトル}
**Description**（説明）:


**Level**（レベル）: High | Medium | Low  
**Likelihood**（発生確率）: High | Medium | Low

**Mitigation**（軽減策）:


**Owner**（担当者）: {name}

---

## Suggestions for Improvement（改善提案）
<!-- 必須ではないが推奨する改善点 -->

### Category: {カテゴリ名, e.g., Performance, Code Style, etc.}
- 
- 

### Category: {カテゴリ名}
- 
- 

---

## Action Items（アクション項目）
<!-- レビュー後に必要なアクション -->

| Action | Priority | Owner | Due Date | Status |
|--------|----------|-------|----------|--------|
| {Action 1} | Critical/High/Medium/Low | {name} | {date} | ⬜ Open |
| {Action 2} | Critical/High/Medium/Low | {name} | {date} | ⬜ Open |

---

## Follow-up Review（フォローアップレビュー）
<!-- 再レビューが必要な場合 -->

**Required**（必要）: Yes | No

**Reason**（理由）:
<!-- なぜフォローアップレビューが必要か -->


**Scope**（範囲）:
<!-- 何を再レビューするか -->


**Scheduled Date**（予定日）: {date}

---

## Approval（承認）

### Reviewers Sign-off（レビュアー承認）
<!-- 各レビュアーの承認 -->
- [ ] Reviewer 1: {Name} - {Date} - Status: Approved/Changes Requested
- [ ] Reviewer 2: {Name} - {Date} - Status: Approved/Changes Requested

### Final Decision（最終決定）
**Decision Maker**（意思決定者）: {name}  
**Date**（日付）: {date}  
**Decision**（決定）: {Approved/Approved with conditions/Changes required/Blocked}

**Conditions (if any)**（条件（該当する場合））:
- 
- 

---

## Notes（備考）
<!-- その他のメモや参考情報 -->
- 
- 
