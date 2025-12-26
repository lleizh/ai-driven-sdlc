# Risks

**Feature ID**: FEATURE-10  
**Last Updated**: 2025-12-26  
**Overall Risk Level**: LOW

---

## Risk Assessment Summary

| Risk ID | Risk | Level | Status |
|---------|------|-------|--------|
| R001 | `/sdlc-test` と既存コマンドの責任境界の混乱 | Low | Open |
| R002 | テストフレームワークの多様性への対応不足 | Low | Open |
| R003 | テスト実行時間による開発体験の低下 | Low | Open |

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

### Risk R001: `/sdlc-test` と既存コマンドの責任境界の混乱

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description
新しい `/sdlc-test` コマンドを追加することで、開発者が「どのコマンドがテストを実行するのか」「`/sdlc-coding` はテストを含むのか」といった点で混乱する可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: 開発者がテスト実行のタイミングを誤解し、テストをスキップする可能性
- **System**: テストされていないコードが PR される可能性
- **Business**: 品質低下のリスク
- **Data**: なし

**Likelihood**: Low (<10%)

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component（SDLC ワークフローのみ）
- **Recovery Time**: 即座（ドキュメント修正とコミュニケーション）
- **Data Loss Risk**: No

#### Root Cause
新しいコマンドの導入により、既存のワークフローに対する理解が不完全になる可能性がある。

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **ドキュメントの明確化**
   - Description: `AI_SDLC.md` または `README.md` に各コマンドの責任範囲を明記
   - Owner: TBD
   - Due Date: 実装完了時
   - Status: Pending

2. **コマンド完了メッセージの改善**
   - Description: `/sdlc-coding` の完了メッセージに「次のステップ: /sdlc-test でテストを実行」を追加
   - Owner: TBD
   - Due Date: 実装完了時
   - Status: Pending

**Residual Risk**: Negligible

#### Contingency Plan
1. チームミーティングで新しいワークフローを説明
2. 必要に応じてコマンドの説明を拡充

#### Monitoring
- **Metrics**: 開発者からのフィードバック、PR での未テストコードの発生率
- **Alerts**: なし
- **Review Frequency**: 最初の数週間は毎週レビュー

---

### Risk R002: テストフレームワークの多様性への対応不足

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description
プロジェクトによってテストフレームワークが異なる（npm test, go test, cargo test, pytest など）ため、すべてのフレームワークに対応できない可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: 一部のプロジェクトで `/sdlc-test` が使えない
- **System**: なし（手動でテスト実行は可能）
- **Business**: 一部のプロジェクトでワークフローが不統一になる
- **Data**: なし

**Likelihood**: Medium (10-50%)

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component（特定のプロジェクトタイプのみ）
- **Recovery Time**: 1-2日（新しいフレームワークのサポート追加）
- **Data Loss Risk**: No

#### Root Cause
テストフレームワークの種類が多く、すべてをカバーすることが困難。

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **主要フレームワークの優先サポート**
   - Description: npm, go, cargo, pytest など主要フレームワークを最初にサポート
   - Owner: TBD
   - Due Date: 初期実装時
   - Status: Pending

2. **拡張可能な設計**
   - Description: 新しいフレームワークのサポートを追加しやすい設計にする
   - Owner: TBD
   - Due Date: 初期実装時
   - Status: Pending

**Residual Risk**: Low

#### Contingency Plan
1. サポートされていないフレームワークの場合はエラーメッセージで手動実行を案内
2. 必要に応じてフレームワークサポートを追加

#### Monitoring
- **Metrics**: サポートされていないフレームワークのエラー発生率
- **Alerts**: なし
- **Review Frequency**: 四半期ごと

---

### Risk R003: テスト実行時間による開発体験の低下

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description
E2E テストなど時間のかかるテストがデフォルトで実行されると、開発サイクルが遅くなり開発体験が低下する可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: 開発者がテスト実行を避けるようになる
- **System**: なし
- **Business**: 開発速度の低下
- **Data**: なし

**Likelihood**: Low (<10%)

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component（開発体験のみ）
- **Recovery Time**: 即座（設定変更）
- **Data Loss Risk**: No

#### Root Cause
E2E テストなど時間のかかるテストの実行戦略が不適切な場合。

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **E2E テストの実行オプション化**
   - Description: Decision で E2E テストのデフォルト動作を決定
   - Owner: TBD
   - Due Date: Decision 確定時
   - Status: Pending

2. **テスト実行時間の表示**
   - Description: テスト結果に実行時間を表示し、開発者が判断できるようにする
   - Owner: TBD
   - Due Date: 実装時
   - Status: Pending

**Residual Risk**: Negligible

#### Contingency Plan
1. デフォルト設定を変更してテスト実行時間を短縮
2. 必要に応じて並列実行の検討

#### Monitoring
- **Metrics**: テスト実行時間、開発者のフィードバック
- **Alerts**: なし
- **Review Frequency**: 最初の1ヶ月は毎週レビュー

---

## Risk Categories

### Technical Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| テストフレームワークの多様性への対応不足 | Low | Open | 主要フレームワーク優先、拡張可能な設計 |

### Operational Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| `/sdlc-test` と既存コマンドの責任境界の混乱 | Low | Open | ドキュメント明確化、完了メッセージ改善 |
| テスト実行時間による開発体験の低下 | Low | Open | E2E テストのオプション化、実行時間表示 |

### Security Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| （なし） | - | - | - |

### Performance Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| テスト実行時間による開発体験の低下 | Low | Open | E2E テストのオプション化、実行時間表示 |

### Data Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| （なし） | - | - | - |

### Dependency Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| テストフレームワークの多様性への対応不足 | Low | Open | 主要フレームワーク優先、拡張可能な設計 |

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
（なし）

---

## Closed Risks
（なし）

---

## Risk Review History

| Date | Reviewer | New Risks | Updated Risks | Closed Risks | Notes |
|------|----------|-----------|---------------|--------------|-------|
| 2025-12-26 | TBD | 3 (R001, R002, R003) | 0 | 0 | 初期リスク評価 |

---

## Notes
このFeatureは低リスクと評価されています。主なリスクは運用面（ワークフローの混乱、開発体験）であり、技術的リスクは限定的です。既存のコマンドには一切変更を加えないため、システムへの影響は最小限です。
