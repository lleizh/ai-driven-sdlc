# Risks（リスク）

**Feature ID**: FEATURE-33  
**Last Updated**: 2025-12-27  
**Overall Risk Level**（総合リスクレベル）: LOW

---

## Risk Assessment Summary（リスク評価サマリー）

| Risk ID | リスク | レベル | ステータス |
|---------|--------|--------|-----------|
| R001 | ISSUE_URL が存在しない場合のエラー | Low | Open |
| R002 | GitHub API レート制限 | Low | Open |
| R003 | 権限不足による Issue クローズ失敗 | Low | Open |

---

## Risk Level Criteria（リスクレベル基準）

### Low Risk（低リスク）
**Definition**（定義）:
- 既存ワークフローへの影響が限定的
- 新しいステップの追加のみ
- GitHub CLI の標準機能を使用
- エラーハンドリングを適切に実装すれば安全
- いつでもステップを削除して元に戻せる

**Review Requirements**（レビュー要件）:
- コードレビューのみ
- 基本的なテストカバレッジ

---

## Detailed Risk Analysis（詳細リスク分析）

### Risk R001: ISSUE_URL が存在しない場合のエラー

**Level**（レベル）: LOW  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2025-12-27

#### Description（説明）

`.metadata` ファイルに ISSUE_URL が存在しない、または無効な形式の場合、Issue 番号の抽出に失敗し、workflow がエラーになる可能性があります。

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: Issue が自動的にクローズされない
- **System**（システム）: workflow が失敗する可能性
- **Business**（ビジネス）: 手動での Issue クローズが必要
- **Data**（データ）: 影響なし

**Likelihood**（発生確率）: Low (<10%)

#### Impact Assessment（影響評価）
- **Severity**（深刻度）: Minor
- **Scope**（範囲）: Component
- **Recovery Time**（復旧時間）: 即座（手動でクローズ）
- **Data Loss Risk**（データ喪失リスク）: No

#### Root Cause（根本原因）

- `.metadata` ファイルが手動で編集された場合
- `/sdlc-init` が正しく実行されなかった場合
- ISSUE_URL の形式が変更された場合

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Reduce

**Actions**（アクション）:
1. **ISSUE_URL の存在確認を実装**
   - Description（説明）: `.metadata` から ISSUE_URL を抽出する前に存在確認
   - Owner（担当者）: TBD
   - Due Date（期限）: 実装時
   - Status（ステータス）: Planned

2. **エラーハンドリングを実装**
   - Description（説明）: ISSUE_URL が存在しない場合は警告を出してスキップ
   - Owner（担当者）: TBD
   - Due Date（期限）: 実装時
   - Status（ステータス）: Planned

**Residual Risk**（残存リスク）: Very Low

#### Contingency Plan（緊急対応計画）
1. workflow ログを確認
2. 手動で Issue をクローズ
3. `.metadata` の ISSUE_URL を修正

#### Monitoring（監視）
- **Metrics**（メトリクス）: workflow 実行結果
- **Alerts**（アラート）: workflow 失敗時の GitHub Actions 通知
- **Review Frequency**（レビュー頻度）: 毎回の実行時

---

### Risk R002: GitHub API レート制限

**Level**（レベル）: LOW  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2025-12-27

#### Description（説明）

GitHub Actions の `GITHUB_TOKEN` には API レート制限があり、短時間に多数の PR がマージされた場合、Issue のクローズに失敗する可能性があります。

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: Issue が自動的にクローズされない
- **System**（システム）: workflow が一時的に失敗
- **Business**（ビジネス）: 手動での Issue クローズが必要
- **Data**（データ）: 影響なし

**Likelihood**（発生確率）: Low (<10%)

#### Impact Assessment（影響評価）
- **Severity**（深刻度）: Minor
- **Scope**（範囲）: Component
- **Recovery Time**（復旧時間）: 自動（レート制限リセット後）
- **Data Loss Risk**（データ喪失リスク）: No

#### Root Cause（根本原因）

- 短時間に多数の PR がマージされた場合
- GitHub Actions の API レート制限

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Accept

**Actions**（アクション）:
1. **レート制限エラーのハンドリング**
   - Description（説明）: レート制限エラー時は警告を出してスキップ
   - Owner（担当者）: TBD
   - Due Date（期限）: 実装時
   - Status（ステータス）: Planned

**Residual Risk**（残存リスク）: Very Low

#### Contingency Plan（緊急対応計画）
1. レート制限がリセットされるまで待つ（通常1時間）
2. 手動で Issue をクローズ

#### Monitoring（監視）
- **Metrics**（メトリクス）: API レート制限の残量
- **Alerts**（アラート）: レート制限エラー時のログ
- **Review Frequency**（レビュー頻度）: 必要に応じて

---

### Risk R003: 権限不足による Issue クローズ失敗

**Level**（レベル）: LOW  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2025-12-27

#### Description（説明）

GitHub Actions の `GITHUB_TOKEN` に `issues: write` 権限が付与されていない場合、Issue のクローズに失敗します。

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: Issue が自動的にクローズされない
- **System**（システム）: workflow が失敗
- **Business**（ビジネス）: 手動での Issue クローズが必要
- **Data**（データ）: 影響なし

**Likelihood**（発生確率）: Low (<10%)

#### Impact Assessment（影響評価）
- **Severity**（深刻度）: Minor
- **Scope**（範囲）: Component
- **Recovery Time**（復旧時間）: 即座（権限追加後）
- **Data Loss Risk**（データ喪失リスク）: No

#### Root Cause（根本原因）

- workflow ファイルに `issues: write` 権限が追加されていない
- リポジトリの設定で GitHub Actions の権限が制限されている

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Reduce

**Actions**（アクション）:
1. **permissions に issues: write を追加**
   - Description（説明）: workflow ファイルに明示的に権限を追加
   - Owner（担当者）: TBD
   - Due Date（期限）: 実装時
   - Status（ステータス）: Planned

2. **権限エラーのハンドリング**
   - Description（説明）: 権限エラー時は明確なエラーメッセージを出力
   - Owner（担当者）: TBD
   - Due Date（期限）: 実装時
   - Status（ステータス）: Planned

**Residual Risk**（残存リスク）: Very Low

#### Contingency Plan（緊急対応計画）
1. workflow ファイルに `issues: write` 権限を追加
2. 手動で Issue をクローズ

#### Monitoring（監視）
- **Metrics**（メトリクス）: workflow 実行結果
- **Alerts**（アラート）: workflow 失敗時の GitHub Actions 通知
- **Review Frequency**（レビュー頻度）: 毎回の実行時

---

## Risk Categories（リスクカテゴリー）

### Technical Risks（技術的リスク）
| リスク | レベル | ステータス | 軽減策 |
|--------|--------|-----------|--------|
| ISSUE_URL が存在しない場合のエラー | Low | Open | 存在確認とエラーハンドリング |
| 権限不足による Issue クローズ失敗 | Low | Open | permissions に issues: write を追加 |

### Operational Risks（運用リスク）
| リスク | レベル | ステータス | 軽減策 |
|--------|--------|-----------|--------|
| GitHub API レート制限 | Low | Open | レート制限エラーのハンドリング |

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
- **Medium**（中）: 0
- **Low**（低）: 3 - R001, R002, R003

---

## Notes（備考）

- すべてのリスクは Low レベルで、適切なエラーハンドリングを実装すれば十分に管理可能
- 既存の FEATURE-19 の実装パターンを参考にできる
- workflow の失敗時は GitHub Actions の通知で即座に気づける
