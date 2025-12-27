# Risks（リスク）

**Feature ID**: FEATURE-19  
**Last Updated**: 2025-12-27  
**Overall Risk Level**（総合リスクレベル）: LOW

---

## Risk Assessment Summary（リスク評価サマリー）

| Risk ID | リスク | レベル | ステータス |
|---------|--------|--------|-----------|
| R001 | GitHub Actions 実行失敗時の手動リカバリー | Low | Open |
| R002 | 既存 Workflow との実行タイミング競合 | Low | Open |
| R003 | FEATURE-20 未完了状態での実装 | Medium | Open |

---

## Risk Level Criteria（リスクレベル基準）

### Low Risk（低リスク）
**Definition**（定義）: 
- 既存機能への影響なし、GitHub Actions の追加のみ
- GitHub Actions が失敗しても、手動で STATUS を更新できる
- feature/* ブランチのマージのみが対象で、影響範囲が限定的
- ファイル更新のロジックがシンプル（sed による単純な置換）

**Review Requirements**（レビュー要件）:
- Code review only（コードレビューのみ）
- Basic test coverage（基本的なテストカバレッジ）
- GitHub Actions の動作確認

---

## Detailed Risk Analysis（詳細リスク分析）

### Risk R001: GitHub Actions 実行失敗時の手動リカバリー

**Level**（レベル）: LOW  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2025-12-27

#### Description（説明）

GitHub Actions Workflow が実行に失敗した場合、`.metadata` の STATUS が自動更新されず、手動で更新する必要がある。失敗の原因としては：
- GitHub API の一時的な障害
- 権限エラー
- ブランチ保護設定の変更
- スクリプトのバグ

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: 開発者が手動で STATUS を更新する必要がある
- **System**（システム）: Feature のステータスが一時的に不正確になる
- **Business**（ビジネス）: 最小限（手動リカバリー可能）
- **Data**（データ）: データ喪失なし

**Likelihood**（発生確率）: Low (<10%)

#### Impact Assessment（影響評価）
- **Severity**（深刻度）: Minor
- **Scope**（範囲）: Component（単一の Feature のみ）
- **Recovery Time**（復旧時間）: 1-5 分（手動更新）
- **Data Loss Risk**（データ喪失リスク）: No

#### Root Cause（根本原因）

GitHub Actions は外部サービスであり、完全な可用性を保証できない。また、実装バグやインフラ変更によって失敗する可能性がある。

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Accept（受け入れ）

**Actions**（アクション）:
1. **明確なエラーログ出力**
   - Description（説明）: 失敗時に詳細なエラーメッセージをログに出力
   - Owner（担当者）: TBD
   - Due Date（期限）: 実装時
   - Status（ステータス）: Pending

2. **ドキュメント化**
   - Description（説明）: 手動リカバリー手順をドキュメント化
   - Owner（担当者）: TBD
   - Due Date（期限）: 実装時
   - Status（ステータス）: Pending

**Residual Risk**（残存リスク）: Low

#### Contingency Plan（緊急対応計画）

1. GitHub Actions のログを確認して失敗原因を特定
2. 手動で `.metadata` の STATUS を `implementing` → `completed` に更新
3. Git commit & push
4. 必要に応じて Workflow を再実行

#### Monitoring（監視）

- **Metrics**（メトリクス）: GitHub Actions の実行成功率
- **Alerts**（アラート）: Workflow 失敗時の GitHub 通知
- **Review Frequency**（レビュー頻度）: 毎週

---

### Risk R002: 既存 Workflow との実行タイミング競合

**Level**（レベル）: LOW  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2025-12-27

#### Description（説明）

PR マージ時に複数の GitHub Actions Workflow が同時実行される可能性があり、`sync-projects.yml` や他の Workflow と競合する可能性がある。特に：
- 同じファイル（`.metadata`）を同時に更新しようとする
- Git push のタイミングが重なる

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: Workflow が失敗し、再実行が必要
- **System**（システム）: 一時的な実行エラー
- **Business**（ビジネス）: 最小限（自動リトライ可能）
- **Data**（データ）: データ喪失なし（Git で管理）

**Likelihood**（発生確率）: Low (<10%)

#### Impact Assessment（影響評価）
- **Severity**（深刻度）: Minor
- **Scope**（範囲）: Component
- **Recovery Time**（復旧時間）: 1 分未満（自動リトライ）
- **Data Loss Risk**（データ喪失リスク）: No

#### Root Cause（根本原因）

複数の Workflow が同じタイミングでトリガーされ、同じファイルを更新しようとする。

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Reduce（削減）

**Actions**（アクション）:
1. **Workflow の実行順序を設計**
   - Description（説明）: `sync-projects.yml` は push イベントで自動的にトリガーされるため、先に `.metadata` を更新すれば順次実行される
   - Owner（担当者）: TBD
   - Due Date（期限）: 設計時
   - Status（ステータス）: Pending

**Residual Risk**（残存リスク）: Very Low

#### Contingency Plan（緊急対応計画）

1. Git push が競合した場合、GitHub Actions が自動的にリトライ
2. 失敗した場合は手動で Workflow を再実行

#### Monitoring（監視）

- **Metrics**（メトリクス）: 競合エラーの発生率
- **Alerts**（アラート）: Workflow 失敗通知
- **Review Frequency**（レビュー頻度）: 初期導入後 1 ヶ月間は毎週、その後は月次

---

### Risk R003: FEATURE-20 未完了状態での実装

**Level**（レベル）: MEDIUM  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2025-12-27

#### Description（説明）

FEATURE-19 は FEATURE-20（GitHub Projects Status 字段統一）の完了を前提としている。FEATURE-20 が未完了の状態で FEATURE-19 を実装すると：
- `sync-projects.yml` が期待通り動作しない可能性
- Status 字段の不一致が発生する可能性

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: GitHub Projects の Status が正しく更新されない
- **System**（システム）: ステータス同期の不整合
- **Business**（ビジネス）: Feature 管理の混乱
- **Data**（データ）: Status データの不整合

**Likelihood**（発生確率）: Medium (10-50%)（実装順序に依存）

#### Impact Assessment（影響評価）
- **Severity**（深刻度）: Major
- **Scope**（範囲）: Subsystem（SDLC 全体のステータス管理）
- **Recovery Time**（復旧時間）: 数時間（手動修正）
- **Data Loss Risk**（データ喪失リスク）: No

#### Root Cause（根本原因）

FEATURE-19 の実装が FEATURE-20 の完了に依存している。

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Avoid（回避）

**Actions**（アクション）:
1. **実装順序の厳守**
   - Description（説明）: FEATURE-20 が完了してから FEATURE-19 の実装を開始する
   - Owner（担当者）: TBD
   - Due Date（期限）: 実装前
   - Status（ステータス）: Pending

2. **依存関係のチェック**
   - Description（説明）: FEATURE-19 の実装開始前に FEATURE-20 の完了を確認
   - Owner（担当者）: TBD
   - Due Date（期限）: 実装前
   - Status（ステータス）: Pending

**Residual Risk**（残存リスク）: Low（実装順序を守れば回避可能）

#### Contingency Plan（緊急対応計画）

1. FEATURE-20 が未完了の場合、FEATURE-19 の実装を延期
2. または FEATURE-20 の完了を優先して実施

#### Monitoring（監視）

- **Metrics**（メトリクス）: FEATURE-20 の進捗状況
- **Alerts**（アラート）: なし（プロジェクト管理レベル）
- **Review Frequency**（レビュー頻度）: 実装前の確認のみ

---

## Risk Categories（リスクカテゴリー）

### Technical Risks（技術的リスク）
| リスク | レベル | ステータス | 軽減策 |
|--------|--------|-----------|--------|
| GitHub Actions 実行失敗 | Low | Open | エラーログ出力、ドキュメント化 |
| Workflow タイミング競合 | Low | Open | 実行順序の設計 |

### Operational Risks（運用リスク）
| リスク | レベル | ステータス | 軽減策 |
|--------|--------|-----------|--------|
| 手動リカバリーの手間 | Low | Open | ドキュメント化 |

### Dependency Risks（依存関係リスク）
| リスク | レベル | ステータス | 軽減策 |
|--------|--------|-----------|--------|
| FEATURE-20 未完了 | Medium | Open | 実装順序の厳守 |

---

## Risk Matrix（リスクマトリックス）

|           | 低影響 | 中影響 | 高影響 |
|-----------|--------|--------|--------|
| **高確率** | Medium | High | Critical |
| **中確率** | Low | Medium | High |
| **低確率** | Low | Low | Medium |

### Current Risks Plotted（現在のリスクプロット）
- **Critical**（クリティカル）: 0
- **High**（高）: 0
- **Medium**（中）: 1 - R003
- **Low**（低）: 2 - R001, R002

---

## Accepted Risks（受け入れたリスク）

### Risk: GitHub Actions 実行失敗時の手動リカバリー
**Reason for Acceptance**（受け入れ理由）:
- 手動リカバリーが簡単（1-5 分で対応可能）
- 発生確率が低い
- 自動化によるメリットが手動リカバリーのコストを上回る

**Conditions**（条件）:
- 手動リカバリー手順がドキュメント化されている
- エラーログが明確に出力される

**Approver**（承認者）: TBD  
**Date**（日付）: 2025-12-27

---

## Closed Risks（クローズ済みリスク）

（まだクローズ済みリスクなし）

---

## Risk Review History（リスクレビュー履歴）

| 日付 | レビュアー | 新規リスク | 更新リスク | クローズリスク | 備考 |
|------|-----------|-----------|-----------|---------------|------|
| 2025-12-27 | - | R001, R002, R003 | - | - | 初期リスク評価 |

---

## Notes（備考）

- Low Risk Feature であり、既存機能への影響は最小限
- FEATURE-20 の完了を待ってから実装することで、Medium Risk の R003 を回避可能
- GitHub Actions の失敗時は手動リカバリーで対応可能
