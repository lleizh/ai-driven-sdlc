# Risks

**Feature ID**: FEATURE-5  
**Last Updated**: 2025-12-26  
**Overall Risk Level**: LOW

---

## Risk Assessment Summary

| Risk ID | Risk | Level | Status |
|---------|------|-------|--------|
| R001 | 条件判定の追加漏れによる他の除算エラー見逃し | Low | Open |
| R002 | 既存動作への意図しない影響 | Low | Open |

---

## Risk Level Criteria

### Low Risk
**Definition**:
- Minimal impact
- Localized changes
- Easy to rollback
- Standard code review sufficient

**Review Requirements**:
- Code review only
- Basic test coverage

**このFeatureが Low Risk である理由**:
- 既存機能への影響なし（条件を厳密化するのみ）
- 1行の条件追加で修正可能
- エッジケース（Feature が0件）のハンドリング改善
- テストも簡単（Feature がない状態で `./sdlc-cli report` を実行）
- ロールバックが容易

---

## Detailed Risk Analysis

### Risk R001: 条件判定の追加漏れによる他の除算エラー見逃し

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description
今回の修正は958行目の特定箇所のみを対象としている。sdlc-cli スクリプト内の他の箇所で同様の除算エラーが潜在している可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: 別の条件で同様のエラーに遭遇する可能性
- **System**: スクリプトの一部機能が使用できない
- **Business**: ツールの信頼性低下
- **Data**: なし（データ破損のリスクはない）

**Likelihood**: Low (<10%)  
理由：現時点で他の箇所での除算エラーは報告されていない

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component
- **Recovery Time**: 数分（同様の修正を適用）
- **Data Loss Risk**: No

#### Root Cause
コード全体の包括的なレビューを行っていない

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **スクリプト全体のgrep検査**
   - Description: `calc` 関数の呼び出し箇所を全て検索し、除算が安全か確認
   - Owner: TBD
   - Due Date: 実装時
   - Status: Pending

**Residual Risk**: Very Low

#### Contingency Plan
1. 同様のエラーが発見された場合、同じパターンで修正
2. 必要に応じて共通の安全な除算関数を作成

#### Monitoring
- **Metrics**: ユーザーからのエラーレポート
- **Alerts**: なし
- **Review Frequency**: 次回の機能追加時

---

### Risk R002: 既存動作への意図しない影響

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description
条件判定を追加することで、Feature が存在する場合の既存の動作に意図しない影響を与える可能性。

#### Impact
**If this risk materializes**:
- **Users**: 従来表示されていた情報が表示されなくなる
- **System**: レポート機能の情報量減少
- **Business**: ユーザー体験の低下
- **Data**: なし

**Likelihood**: Very Low (<5%)  
理由：条件を厳密化するのみで、既存のロジックは変更しない

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component
- **Recovery Time**: 数分（修正をrevert）
- **Data Loss Risk**: No

#### Root Cause
条件判定の論理エラー

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **リグレッションテスト**
   - Description: Feature が存在する状態で `./sdlc-cli report` を実行し、従来通りの表示を確認
   - Owner: TBD
   - Due Date: 実装時
   - Status: Pending

2. **コードレビュー**
   - Description: 条件判定のロジックが正しいことを確認
   - Owner: TBD
   - Due Date: 実装時
   - Status: Pending

**Residual Risk**: Very Low

#### Contingency Plan
1. 問題が発見された場合、修正をrevert
2. 条件判定を見直して再実装

#### Monitoring
- **Metrics**: 既存のFeature環境でのテスト結果
- **Alerts**: なし
- **Review Frequency**: 実装時の1回

---

## Risk Categories

### Technical Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| 条件判定の追加漏れによる他の除算エラー見逃し | Low | Open | スクリプト全体のgrep検査 |
| 既存動作への意図しない影響 | Low | Open | リグレッションテスト |

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
- **Low**: 2 - R001, R002

---

## Notes
- このFeatureは防御的プログラミングの一環として、エッジケースへの対応を強化するもの
- リスクは非常に限定的で、既存機能への影響は最小限
- 簡単にロールバック可能なため、リスクは許容範囲内
