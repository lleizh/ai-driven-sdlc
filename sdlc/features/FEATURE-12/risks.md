# Risks

**Feature ID**: FEATURE-12  
**Last Updated**: 2025-12-26  
**Overall Risk Level**: LOW

---

## Risk Assessment Summary

| Risk ID | Risk | Level | Status |
|---------|------|-------|--------|
| R001 | パースロジックのバグによる誤検出 | Low | Open |
| R002 | 既存の `/sdlc-check` への影響 | Low | Open |
| R003 | Implementation Plan のフォーマット多様性 | Medium | Open |

---

## Risk Level Criteria

### Low Risk
**Definition**: 
- `/sdlc-check` コマンドの拡張なので、既存の動作には影響しない
- 実装は bash スクリプトのパース処理追加のみで複雑度は低い
- 失敗しても手動でタスク確認すれば問題ない

**Review Requirements**:
- Code review only
- Basic test coverage

---

## Detailed Risk Analysis

### Risk R001: パースロジックのバグによる誤検出

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description
Implementation Plan のタスクをパースする際、正規表現やパターンマッチングのバグにより、完了済みタスクを未完了と誤検出したり、逆に未完了タスクを見逃したりする可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: 誤った警告やブロッカーが表示され、混乱する
- **System**: `/sdlc-check` の信頼性が低下
- **Business**: PR プロセスが混乱する可能性（誤検出による不要な修正作業）
- **Data**: なし

**Likelihood**: Low (<10%)

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component（`/sdlc-check` コマンドのみ）
- **Recovery Time**: 即座（手動確認で回避可能）
- **Data Loss Risk**: No

#### Root Cause
bash スクリプトでの正規表現パースは複雑な構造に対応しづらく、エッジケースで誤動作する可能性がある。

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **既存の Implementation Plan でのテスト**
   - Description: FEATURE-7 など既存の Plan でパースロジックをテスト
   - Owner: TBD
   - Due Date: 実装時
   - Status: Pending

2. **エッジケースのテスト追加**
   - Description: ネストされたタスク、複数行タスクなどのテストケース作成
   - Owner: TBD
   - Due Date: 実装時
   - Status: Pending

**Residual Risk**: Very Low

#### Contingency Plan
1. バグが発見された場合は、該当のパース処理を無効化または修正
2. 手動でのタスク確認を案内

#### Monitoring
- **Metrics**: `/sdlc-check` 実行結果のレビュー
- **Alerts**: なし
- **Review Frequency**: 実装後の初回使用時

---

### Risk R002: 既存の `/sdlc-check` への影響

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description
新しいチェックロジックを追加する際、既存の `/sdlc-check` の動作（Context、Decisions、Risks のチェック）に影響を与える可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: 既存のチェックが動作しなくなり、品質保証プロセスが機能しない
- **System**: `/sdlc-check` 全体の信頼性が低下
- **Business**: 既存の SDLC ワークフローが停止
- **Data**: なし

**Likelihood**: Very Low (<5%)

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component
- **Recovery Time**: 即座（コミットの revert）
- **Data Loss Risk**: No

#### Root Cause
スクリプトの論理エラーや変数の上書きなどによる意図しない副作用。

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **既存機能のテスト**
   - Description: 新機能追加前後で既存のチェック結果が同じか確認
   - Owner: TBD
   - Due Date: 実装時
   - Status: Pending

**Residual Risk**: Very Low

#### Contingency Plan
1. 既存機能への影響が確認された場合、即座に revert
2. 修正後に再度マージ

#### Monitoring
- **Metrics**: `/sdlc-check` の全チェック項目の結果
- **Alerts**: なし
- **Review Frequency**: 実装直後

---

### Risk R003: Implementation Plan のフォーマット多様性

**Level**: MEDIUM  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description
既存の Implementation Plan は人によって記載フォーマットが異なる可能性があり（セクション名の違い、タスクの記載方法の違いなど）、統一的にパースできない可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: 特定の Plan でのみチェックが動作せず、混乱する
- **System**: `/sdlc-check` の有用性が低下
- **Business**: 一部の Feature でタスク完成度が検証されない
- **Data**: なし

**Likelihood**: Medium (10-50%)

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Subsystem（一部の Implementation Plan）
- **Recovery Time**: フォーマット標準化で対応
- **Data Loss Risk**: No

#### Root Cause
Implementation Plan のテンプレートが柔軟で、開発者が自由に構造を変更できる。

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **フォーマット調査**
   - Description: 既存の Implementation Plan のフォーマットを調査し、共通パターンを特定
   - Owner: TBD
   - Due Date: 実装前
   - Status: Pending

2. **柔軟なパースロジック実装**
   - Description: 複数のフォーマットに対応できるパース処理を実装
   - Owner: TBD
   - Due Date: 実装時
   - Status: Pending

3. **フォーマットガイドラインの作成**
   - Description: 将来的に Implementation Plan のフォーマットを標準化
   - Owner: TBD
   - Due Date: 本機能実装後
   - Status: Pending

**Residual Risk**: Low

#### Contingency Plan
1. パースできない Plan が発見された場合、警告を表示して手動確認を促す
2. フォーマットの標準化を推進

#### Monitoring
- **Metrics**: `/sdlc-check` でのパース成功率
- **Alerts**: なし
- **Review Frequency**: 月次

---

## Risk Categories

### Technical Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| パースロジックのバグによる誤検出 | Low | Open | 既存 Plan でのテスト |
| 既存の `/sdlc-check` への影響 | Low | Open | 既存機能のテスト |

### Operational Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| Implementation Plan のフォーマット多様性 | Medium | Open | 柔軟なパースロジック、フォーマット標準化 |

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
- **Medium**: 1 - R003
- **Low**: 2 - R001, R002

---

## Notes
全体的にリスクは低く、既存の動作を破壊しない限定的な機能追加のため、Low Risk と評価。最大のリスクは Implementation Plan のフォーマット多様性だが、これも柔軟なパース実装で対応可能。
