# Risks（リスク）

**Feature ID**: FEATURE-27  
**Last Updated**: 2025-12-27  
**Overall Risk Level**（総合リスクレベル）: LOW

---

## Risk Assessment Summary（リスク評価サマリー）

| Risk ID | リスク | レベル | ステータス |
|---------|--------|--------|-----------|
| R001 | 誤った Feature のアーカイブ | Low | Open |
| R002 | Git 履歴の喪失 | Low | Mitigated |
| R003 | アーカイブ後の参照困難 | Low | Accepted |

---

## Risk Level Criteria（リスクレベル基準）

### Low Risk（低リスク）
**Definition**（定義）:
- 新規コマンド追加のみで既存機能に影響なし
- ファイル移動のみ（削除ではない）
- Git 操作は安全（`git mv` 使用）
- いつでも復元可能

**Review Requirements**（レビュー要件）:
- Code review のみ
- 基本的なテストカバレッジ

---

## Detailed Risk Analysis（詳細リスク分析）

### Risk R001: 誤った Feature のアーカイブ

**Level**（レベル）: LOW  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: Developer  
**Identified Date**（特定日）: 2025-12-27

#### Description（説明）

`STATUS=completed` でない Feature や、完了後の日数が基準に達していない Feature が誤ってアーカイブされる可能性。

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: アクティブな Feature が見つからなくなる
- **System**（システム）: 影響なし
- **Business**（ビジネス）: 開発の混乱
- **Data**（データ）: データ喪失なし（`git mv` で復元可能）

**Likelihood**（発生確率）: Low (<10%)

#### Impact Assessment（影響評価）
- **Severity**（深刻度）: Minor
- **Scope**（範囲）: Component
- **Recovery Time**（復旧時間）: 数分（`git mv` で復元）
- **Data Loss Risk**（データ喪失リスク）: No

#### Root Cause（根本原因）

- `.metadata` ファイルの STATUS 判定ロジックのバグ
- 日付計算ロジックのバグ

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Reduce

**Actions**（アクション）:
1. **Dry-run モードの実装**
   - Description（説明）: `--dry-run` オプションで実際の移動前に確認
   - Owner（担当者）: Developer
   - Due Date（期限）: 実装時
   - Status（ステータス）: Pending

2. **詳細なログ出力**
   - Description（説明）: どの Feature が移動されるか明示
   - Owner（担当者）: Developer
   - Due Date（期限）: 実装時
   - Status（ステータス）: Pending

**Residual Risk**（残存リスク）: Very Low

#### Contingency Plan（緊急対応計画）

1. `git mv` で元の場所に復元
2. `.metadata` の STATUS を確認・修正

#### Monitoring（監視）

- **Metrics**（メトリクス）: アーカイブされた Feature 数
- **Alerts**（アラート）: なし
- **Review Frequency**（レビュー頻度）: 実行時に手動確認

---

### Risk R002: Git 履歴の喪失

**Level**（レベル）: LOW  
**Status**（ステータス）: MITIGATED  
**Owner**（担当者）: Developer  
**Identified Date**（特定日）: 2025-12-27

#### Description（説明）

Feature を移動する際に Git 履歴が失われる可能性。

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: 過去の変更履歴が追跡できなくなる
- **System**（システム）: 影響なし
- **Business**（ビジネス）: 監査証跡の喪失
- **Data**（データ）: 履歴情報の喪失

**Likelihood**（発生確率）: Low (<10%)

#### Impact Assessment（影響評価）
- **Severity**（深刻度）: Minor
- **Scope**（範囲）: Component
- **Recovery Time**（復旧時間）: 復元不可能
- **Data Loss Risk**（データ喪失リスク）: Yes (history only)

#### Root Cause（根本原因）

- `mv` コマンドを使用すると Git が新しいファイルとして認識
- `cp` + `rm` も同様の問題

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Avoid

**Actions**（アクション）:
1. **git mv の使用**
   - Description（説明）: `mv` ではなく `git mv` を使用
   - Owner（担当者）: Developer
   - Due Date（期限）: 実装時
   - Status（ステータス）: Planned

**Residual Risk**（残存リスク）: None

#### Contingency Plan（緊急対応計画）

（軽減策により発生しない）

#### Monitoring（監視）

- **Metrics**（メトリクス）: Git 履歴の継続性
- **Alerts**（アラート）: なし
- **Review Frequency**（レビュー頻度）: 初回実行時に確認

---

### Risk R003: アーカイブ後の参照困難

**Level**（レベル）: LOW  
**Status**（ステータス）: ACCEPTED  
**Owner**（担当者）: Team  
**Identified Date**（特定日）: 2025-12-27

#### Description（説明）

アーカイブされた Feature を参照したいときに見つけにくくなる。

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: 過去の Feature を探すのに時間がかかる
- **System**（システム）: 影響なし
- **Business**（ビジネス）: 軽微な生産性低下
- **Data**（データ）: データ喪失なし

**Likelihood**（発生確率）: Medium (10-50%)

#### Impact Assessment（影響評価）
- **Severity**（深刻度）: Minor
- **Scope**（範囲）: Component
- **Recovery Time**（復旧時間）: N/A
- **Data Loss Risk**（データ喪失リスク）: No

#### Root Cause（根本原因）

- アーカイブディレクトリが別の場所にある
- 検索が2箇所（features/ と archive/）必要

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Accept

**Actions**（アクション）:
（軽減アクションなし。このリスクは受け入れる）

**Residual Risk**（残存リスク）: Low

#### Contingency Plan（緊急対応計画）

1. `git mv` で features/ に復元
2. `find` や `grep` コマンドで検索

#### Monitoring（監視）

- **Metrics**（メトリクス）: なし
- **Alerts**（アラート）: なし
- **Review Frequency**（レビュー頻度）: なし

---

## Risk Categories（リスクカテゴリー）

### Technical Risks（技術的リスク）
| リスク | レベル | ステータス | 軽減策 |
|--------|--------|-----------|--------|
| 誤った Feature のアーカイブ | Low | Open | Dry-run モード |
| Git 履歴の喪失 | Low | Mitigated | `git mv` 使用 |

### Operational Risks（運用リスク）
| リスク | レベル | ステータス | 軽減策 |
|--------|--------|-----------|--------|
| アーカイブ後の参照困難 | Low | Accepted | なし |

---

## Accepted Risks（受け入れたリスク）

### Risk: アーカイブ後の参照困難

**Reason for Acceptance**（受け入れ理由）:
- 影響が軽微（数分の検索時間）
- Git や `find` コマンドで十分対応可能
- アーカイブのメリット（ディレクトリの整理）の方が大きい

**Conditions**（条件）:
- README.md にアーカイブディレクトリ構造を記載する
- `git mv` で簡単に復元できることを確認

**Approver**（承認者）: TBD  
**Date**（日付）: TBD

---

## Notes（備考）

このFeature は Low Risk なので、Design Review は不要。Code Review のみで実装可能。
