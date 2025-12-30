# Risks（リスク）

**Feature ID**: {FEATURE_ID}  
**Last Updated**: {DATE}  
**Overall Risk Level**（総合リスクレベル）: LOW | MEDIUM | HIGH

---

## Risk Assessment Summary（リスク評価サマリー）

| Risk ID | リスク | レベル | ステータス |
|---------|--------|--------|-----------|
| R001 | | High/Medium/Low | Open/Mitigated/Accepted |
| R002 | | High/Medium/Low | Open/Mitigated/Accepted |

---

## Risk Level Criteria（リスクレベル基準）

### High Risk（高リスク）
**Definition**（定義）: 
- システム安定性、セキュリティ、データ整合性への重大な影響
- 複数システムまたは大規模ユーザーに影響
- ロールバックが困難または不可能

**Review Requirements**（レビュー要件）:
- Design Review 必須
- Security Review 必須
- 詳細な実装計画とテスト計画
- ロールバック戦略を含むリリース計画

### Medium Risk（中リスク）
**Definition**（定義）:
- 重大だが限定的な影響
- 特定のサブシステムまたはユーザーセグメントに影響
- 合理的な労力でロールバック可能

**Review Requirements**（レビュー要件）:
- Design Review 推奨
- 標準テストカバレッジ
- デプロイ計画

### Low Risk（低リスク）
**Definition**（定義）:
- 最小限の影響、局所的な変更
- 簡単にロールバック可能

**Review Requirements**（レビュー要件）:
- Code Review のみ
- 基本的なテストカバレッジ

---

## Detailed Risk Analysis（詳細リスク分析）

### Risk R001: {リスクタイトル}

**Level**（レベル）: HIGH | MEDIUM | LOW  
**Status**（ステータス）: OPEN | MITIGATED | ACCEPTED | CLOSED  
**Owner**（担当者）: {NAME}  
**Identified Date**（特定日）: {DATE}

#### Description（説明）
<!-- リスクの詳細な説明 -->


#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: 
- **System**（システム）: 
- **Business**（ビジネス）: 
- **Data**（データ）: 

**Likelihood**（発生確率）: High (>50%) | Medium (10-50%) | Low (<10%)

#### Root Cause（根本原因）
<!-- なぜこのリスクが存在するのか -->


#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Avoid | Reduce | Transfer | Accept

**Actions**（アクション）:
- [ ] {Action 1 - 具体的な軽減策}
- [ ] {Action 2 - 具体的な軽減策}

**Residual Risk**（残存リスク）: {軽減後のレベル}

#### Contingency Plan（緊急対応計画）
<!-- リスクが現実化した場合の対応手順 -->
1. 
2. 

#### Monitoring（監視）
<!-- このリスクをどう監視するか -->
- **Metrics**（メトリクス）: 
- **Review Frequency**（レビュー頻度）: 

---

### Risk R002: {リスクタイトル}

**Level**（レベル）: HIGH | MEDIUM | LOW  
**Status**（ステータス）: OPEN | MITIGATED | ACCEPTED | CLOSED  
**Owner**（担当者）: {NAME}  
**Identified Date**（特定日）: {DATE}

#### Description（説明）


#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: 
- **System**（システム）: 
- **Business**（ビジネス）: 

**Likelihood**（発生確率）: High (>50%) | Medium (10-50%) | Low (<10%)

#### Root Cause（根本原因）


#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Avoid | Reduce | Transfer | Accept

**Actions**（アクション）:
- [ ] {Action 1}
- [ ] {Action 2}

**Residual Risk**（残存リスク）: {軽減後のレベル}

#### Contingency Plan（緊急対応計画）
1. 
2. 

---

## Risk Categories（リスクカテゴリー）

### Technical Risks（技術的リスク）
<!-- 技術的な実装、パフォーマンス、スケーラビリティに関するリスク -->
- 

### Operational Risks（運用リスク）
<!-- デプロイ、監視、保守に関するリスク -->
- 

### Security Risks（セキュリティリスク）
<!-- 認証、認可、データ保護に関するリスク -->
- 

### Data Risks（データリスク）
<!-- データ移行、整合性、損失に関するリスク -->
- 

### Dependency Risks（依存関係リスク）
<!-- 外部サービス、ライブラリ、他チームへの依存に関するリスク -->
- 

---

## Risk Matrix（リスクマトリックス）

|           | 低影響 | 中影響 | 高影響 |
|-----------|--------|--------|--------|
| **高確率** | Medium | High | Critical |
| **中確率** | Low | Medium | High |
| **低確率** | Low | Low | Medium |

### Current Risks Plotted（現在のリスクプロット）
- **Critical**（クリティカル）: {count} - {risk IDs}
- **High**（高）: {count} - {risk IDs}
- **Medium**（中）: {count} - {risk IDs}
- **Low**（低）: {count} - {risk IDs}

---

## Accepted Risks（受け入れたリスク）
<!-- 対応せずに受け入れることにしたリスク -->

### Risk: {タイトル}
**Reason for Acceptance**（受け入れ理由）:


**Conditions**（条件）:
- 
- 

**Approver**（承認者）: {NAME}  
**Date**（日付）: {DATE}

---

## Risk Review History（リスクレビュー履歴）

| 日付 | レビュアー | 変更内容 | 備考 |
|------|-----------|---------|------|
| | | 新規リスク追加、ステータス更新など | |

---

## Notes（備考）
<!-- リスク管理に関する補足情報 -->

