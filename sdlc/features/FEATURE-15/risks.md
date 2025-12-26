# Risks

**Feature ID**: FEATURE-15  
**Last Updated**: 2025-12-26  
**Overall Risk Level**: LOW

---

## Risk Assessment Summary

| Risk ID | Risk | Level | Status |
|---------|------|-------|--------|
| R001 | Workflow トリガーの設定ミスによる同期失敗 | Low | Open |
| R002 | GitHub Actions 実行回数の増加によるコスト | Low | Open |
| R003 | 既存 PR の base 変更による混乱 | Low | Open |

---

## Risk Level Criteria

### High Risk
**Definition**: 
- Critical impact to system stability, security, or data integrity
- Affects multiple systems or large user base
- Difficult or impossible to rollback
- Requires executive approval

**Review Requirements**:
- Design review mandatory
- Security review required
- Multiple reviewers
- Detailed implementation plan
- Comprehensive test plan
- Release plan with rollback strategy

### Medium Risk
**Definition**:
- Significant but contained impact
- Affects specific subsystem or user segment
- Can be rolled back with reasonable effort
- Standard approval process

**Review Requirements**:
- Design review recommended
- Tech lead approval
- Standard test coverage
- Deployment plan

### Low Risk
**Definition**:
- Minimal impact
- Localized changes
- Easy to rollback
- Standard code review sufficient

**Review Requirements**:
- Code review only
- Basic test coverage

---

## Detailed Risk Analysis

### Risk R001: Workflow トリガーの設定ミスによる同期失敗

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description

`.github/workflows/sync-projects.yml` の branches 設定を誤ると、特定のブランチでの `.metadata` 変更が GitHub Projects に同期されない可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: 開発者がプロジェクトの進捗を正確に追跡できない
- **System**: GitHub Projects のデータが古くなる
- **Business**: プロジェクト管理の可視性が低下
- **Data**: データ損失はなし（Workflow が動かないだけ）

**Likelihood**: Low (<10%)

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component（GitHub Projects 同期のみ）
- **Recovery Time**: 数分（設定を修正して再実行）
- **Data Loss Risk**: No

#### Root Cause

YAML の構文エラーや branches パターンの指定ミス。

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **テストブランチでの動作確認**
   - Description: feature/test ブランチを作成し、.metadata を変更して同期をテスト
   - Owner: TBD
   - Due Date: 実装時
   - Status: Pending

2. **Workflow の構文チェック**
   - Description: GitHub Actions の YAML 構文チェックツールを使用
   - Owner: TBD
   - Due Date: 実装時
   - Status: Pending

**Residual Risk**: Very Low

#### Contingency Plan

1. Workflow ログを確認してエラー原因を特定
2. YAML 設定を修正して再度 push
3. 必要に応じて手動で GitHub Projects を更新

#### Monitoring

- **Metrics**: Workflow の実行成功率
- **Alerts**: GitHub Actions の失敗通知
- **Review Frequency**: 初回実装後 1 週間は毎日確認

---

### Risk R002: GitHub Actions 実行回数の増加によるコスト

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description

すべてのブランチ（master, develop, feature/**, design/**）で Workflow がトリガーされるため、GitHub Actions の実行回数が増加し、無料枠を超える可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: 影響なし
- **System**: 影響なし
- **Business**: GitHub Actions の追加コストが発生
- **Data**: 影響なし

**Likelihood**: Low (<10%)

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component（GitHub Actions のみ）
- **Recovery Time**: 即座（課金で対応可能）
- **Data Loss Risk**: No

#### Root Cause

`.metadata` の変更頻度と Workflow の実行時間による。

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **現在の実行回数を確認**
   - Description: GitHub Actions の usage を確認し、無料枠の残りを把握
   - Owner: TBD
   - Due Date: 実装前
   - Status: Pending

2. **Workflow の実行時間を最適化**
   - Description: 不要なステップを削減し、実行時間を短縮
   - Owner: TBD
   - Due Date: 実装時
   - Status: Pending

**Residual Risk**: Very Low

#### Contingency Plan

1. GitHub Actions の usage を定期的にモニタリング
2. 無料枠を超えそうな場合は課金プランを検討
3. または Workflow のトリガー条件を見直し（例: develop と master のみに限定）

#### Monitoring

- **Metrics**: GitHub Actions の月間実行時間
- **Alerts**: 無料枠の 80% を超えたら通知
- **Review Frequency**: 月次

---

### Risk R003: 既存 PR の base 変更による混乱

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description

既存の PR（例: #14）の base を master から develop に変更すると、レビュワーや PR 作成者が混乱する可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: PR 作成者とレビュワーが一時的に混乱
- **System**: 影響なし
- **Business**: レビュープロセスの遅延
- **Data**: 影響なし

**Likelihood**: Medium (10-50%)

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component（特定の PR のみ）
- **Recovery Time**: 数時間〜1 日（説明とコミュニケーション）
- **Data Loss Risk**: No

#### Root Cause

ブランチ戦略の変更を事前に周知しないこと。

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **チームへの事前周知**
   - Description: develop ブランチの作成と PR base 変更の方針をチームに説明
   - Owner: TBD
   - Due Date: 実装前
   - Status: Pending

2. **README の更新**
   - Description: develop ブランチの説明と使い方を README に追加
   - Owner: TBD
   - Due Date: 実装時
   - Status: Pending

**Residual Risk**: Very Low

#### Contingency Plan

1. PR 作成者とレビュワーに個別に連絡
2. base 変更の理由を説明
3. 必要に応じて Slack や GitHub Issue でフォローアップ

#### Monitoring

- **Metrics**: PR の base 変更後のコメント数
- **Alerts**: PR で混乱の兆候があれば即座に対応
- **Review Frequency**: base 変更後 1 週間

---

## Risk Categories

### Technical Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| Workflow トリガーの設定ミス | Low | Open | テストブランチでの動作確認 |

### Operational Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| GitHub Actions 実行回数の増加 | Low | Open | Usage の定期モニタリング |

### Security Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| （なし） | - | - | - |

### Performance Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| （なし） | - | - | - |

### Data Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| （なし） | - | - | - |

### Dependency Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| （なし） | - | - | - |

---

## Risk Matrix

|           | Low Impact | Medium Impact | High Impact |
|-----------|------------|---------------|-------------|
| **High Likelihood** | Medium | High | Critical |
| **Medium Likelihood** | Low | Medium | High |
| **Low Likelihood** | Low | Low | Medium |

### Current Risks Plotted
- **Critical**: 0
- **High**: 0
- **Medium**: 0
- **Low**: 3 - R001, R002, R003

---

## Accepted Risks
（まだ受け入れたリスクはありません）

---

## Closed Risks
（まだクローズしたリスクはありません）

---

## Risk Review History

| Date | Reviewer | New Risks | Updated Risks | Closed Risks | Notes |
|------|----------|-----------|---------------|--------------|-------|
| 2025-12-26 | TBD | 3 | 0 | 0 | 初回リスク評価 |

---

## Notes

### 全体的なリスク評価

このFeatureは **Low Risk** と判定されています。理由：
- **既存機能への影響なし**: 新しいトリガー条件を追加するのみ
- **Workflow の変更**: シンプルで、branch pattern の追加のみ
- **Rollback**: 簡単（workflow を元に戻すだけ）
- **テスト**: feature ブランチで push して Project 更新を確認するだけ

すべてのリスクは軽減可能で、影響範囲も限定的です。
