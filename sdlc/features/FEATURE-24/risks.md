# Risks（リスク）

**Feature ID**: FEATURE-24  
**Last Updated**: 2025-12-27  
**Overall Risk Level**（総合リスクレベル）: MEDIUM

---

## Risk Assessment Summary（リスク評価サマリー）

| Risk ID | リスク | レベル | ステータス |
|---------|--------|--------|-----------|
| R001 | `.metadata` ファイル確認の実装複雑性 | Medium | Open |
| R002 | GitHub API レート制限 | Medium | Open |
| R003 | `sync-projects.yml` との競合 | Low | Open |
| R004 | ラベル誤削除によるデータ不整合 | Low | Open |

---

## Risk Level Criteria（リスクレベル基準）

### Medium Risk（中リスク）
**Definition**（定義）:
- Significant but contained impact（重大だが限定的な影響）
- Affects specific subsystem or user segment（特定のサブシステムまたはユーザーセグメントに影響）
- Can be rolled back with reasonable effort（合理的な労力でロールバック可能）
- Standard approval process（標準承認プロセス）

**Review Requirements**（レビュー要件）:
- Design review recommended（設計レビュー推奨）
- Tech lead approval（テックリード承認）
- Standard test coverage（標準テストカバレッジ）
- Deployment plan（デプロイ計画）

**This Feature is Medium Risk because**（本機能が中リスクである理由）:
- GitHub Actions の新規追加だが、既存 workflow のパターンを踏襲
- `sync-projects.yml` との競合リスクは検証済み（重複防止機構あり）
- 削除ロジックが複雑（`.metadata` 存在確認が必要）
- ロールバック可能（workflow ファイルを削除すれば元に戻る）

---

## Detailed Risk Analysis（詳細リスク分析）

### Risk R001: `.metadata` ファイル確認の実装複雑性

**Level**（レベル）: MEDIUM  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2025-12-27

#### Description（説明）

ラベル削除時に `.metadata` ファイルの存在を確認する必要があるが、これには以下の技術的課題がある：
- Repository checkout が必要（API 呼び出しが増える）
- Feature ID の抽出方法（Issue タイトル/本文からの正規表現）
- ファイルパスの構築（`sdlc/features/{FEATURE_ID}/.metadata`）
- ファイル存在確認のエラーハンドリング

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: ラベル削除時の動作が予期しないものになる
- **System**（システム）: Workflow が失敗する可能性
- **Business**（ビジネス）: Projects のデータが不整合になる
- **Data**（データ）: Issue が誤って削除または保持される

**Likelihood**（発生確率）: Medium (10-50%)

#### Impact Assessment（影響評価）
- **Severity**（深刻度）: Major
- **Scope**（範囲）: Subsystem（ラベル削除時のみ）
- **Recovery Time**（復旧時間）: < 1 hour（Workflow を修正して再実行）
- **Data Loss Risk**（データ喪失リスク）: No（Issue 本体は影響を受けない）

#### Root Cause（根本原因）

智能的な削除ロジックを実現するために、ファイルシステムへのアクセスが必要だが、GitHub Actions の context にはファイル情報が含まれていない。

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Reduce

**Actions**（アクション）:
1. **既存の実装パターンを参考にする**
   - Description（説明）: `sync-projects.yml` の Feature ID 抽出ロジックを再利用
   - Owner（担当者）: TBD
   - Due Date（期限）: TBD
   - Status（ステータス）: Pending

2. **エラーハンドリングを実装**
   - Description（説明）: ファイルが見つからない場合のフォールバック処理を実装
   - Owner（担当者）: TBD
   - Due Date（期限）: TBD
   - Status（ステータス）: Pending

3. **統合テストを実施**
   - Description（説明）: 複数のシナリオで動作確認（`.metadata` あり/なし）
   - Owner（担当者）: TBD
   - Due Date（期限）: TBD
   - Status（ステータス）: Pending

**Residual Risk**（残存リスク）: Low（十分なテストと既存パターンの再利用）

#### Contingency Plan（緊急対応計画）

1. Workflow を無効化（ラベルトリガーを削除）
2. 手動で Projects を修正
3. 問題を修正して Workflow を再有効化

#### Monitoring（監視）
- **Metrics**（メトリクス）: Workflow の成功/失敗率
- **Alerts**（アラート）: Workflow 失敗時に通知
- **Review Frequency**（レビュー頻度）: Weekly

---

### Risk R002: GitHub API レート制限

**Level**（レベル）: MEDIUM  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2025-12-27

#### Description（説明）

新規 Workflow が以下の API 呼び出しを行うため、レート制限に達する可能性がある：
- Issue 情報の取得
- Projects への追加/削除
- `.sdlc-config` の読み込み
- Repository checkout（`.metadata` 確認時）

特に、多数の Issue に対して短時間でラベル操作を行うと、レート制限に達する可能性が高い。

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: ラベル操作後、Projects への反映が遅延
- **System**（システム）: Workflow が失敗またはスキップされる
- **Business**（ビジネス）: Projects のデータが最新でなくなる
- **Data**（データ）: 一時的な不整合が発生

**Likelihood**（発生確率）: Low (<10%)

#### Impact Assessment（影響評価）
- **Severity**（深刻度）: Minor
- **Scope**（範囲）: Subsystem（Workflow のみ）
- **Recovery Time**（復旧時間）: < 30 minutes（レート制限がリセットされるまで待機）
- **Data Loss Risk**（データ喪失リスク）: No

#### Root Cause（根本原因）

GitHub API にはレート制限があり、短時間に多数のリクエストを送ると制限に達する。

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Reduce

**Actions**（アクション）:
1. **Retry 機構を実装**
   - Description（説明）: 既存の `sync-projects.yml` と同様の retry 処理を実装
   - Owner（担当者）: TBD
   - Due Date（期限）: TBD
   - Status（ステータス）: Pending

2. **API 呼び出しを最小化**
   - Description（説明）: 重複チェックを効率化、不要な API 呼び出しを削減
   - Owner（担当者）: TBD
   - Due Date（期限）: TBD
   - Status（ステータス）: Pending

**Residual Risk**（残存リスク）: Low（既存の retry 機構を踏襲）

#### Contingency Plan（緊急対応計画）

1. Workflow の実行頻度を監視
2. レート制限に達した場合は、待機してから再実行
3. 必要に応じて PAT の権限を確認

#### Monitoring（監視）
- **Metrics**（メトリクス）: API レート制限の使用率
- **Alerts**（アラート）: レート制限の 80% に達したら通知
- **Review Frequency**（レビュー頻度）: Weekly

---

### Risk R003: `sync-projects.yml` との競合

**Level**（レベル）: LOW  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2025-12-27

#### Description（説明）

新規 Workflow と既存の `sync-projects.yml` が同じ Projects を操作するため、競合が発生する可能性がある。特に、以下のシナリオで競合が考えられる：
- 両方の Workflow が同時に実行される
- 新規 Workflow が Issue を追加し、`sync-projects.yml` が同じ Issue を更新

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: Projects のデータが一時的に不整合になる
- **System**（システム）: Workflow が失敗する可能性
- **Business**（ビジネス）: 影響は限定的（最終的に `sync-projects.yml` が修正）
- **Data**（データ）: 一時的な不整合のみ

**Likelihood**（発生確率）: Low (<10%)

#### Impact Assessment（影響評価）
- **Severity**（深刻度）: Minor
- **Scope**（範囲）: Component（Projects のみ）
- **Recovery Time**（復旧時間）: < 5 minutes（`sync-projects.yml` が自動修正）
- **Data Loss Risk**（データ喪失リスク）: No

#### Root Cause（根本原因）

複数の Workflow が同じリソース（GitHub Projects）を操作するため、タイミングによっては競合が発生する。

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Reduce

**Actions**（アクション）:
1. **重複防止機構を実装**
   - Description（説明）: GraphQL で既存チェックを必須にする
   - Owner（担当者）: TBD
   - Due Date（期限）: TBD
   - Status（ステータス）: Pending

2. **統合テストを実施**
   - Description（説明）: 両方の Workflow を同時に実行して動作確認
   - Owner（担当者）: TBD
   - Due Date（期限）: TBD
   - Status（ステータス）: Pending

**Residual Risk**（残存リスク）: Very Low（Issue に記載された検証済みのパターン）

#### Contingency Plan（緊急対応計画）

1. `sync-projects.yml` を手動で実行してデータを修正
2. 新規 Workflow を一時的に無効化
3. 競合の原因を調査して修正

#### Monitoring（監視）
- **Metrics**（メトリクス）: Workflow の成功/失敗率
- **Alerts**（アラート）: 競合が検出された場合に通知
- **Review Frequency**（レビュー頻度）: Weekly

---

### Risk R004: ラベル誤削除によるデータ不整合

**Level**（レベル）: LOW  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2025-12-27

#### Description（説明）

チームメンバーが誤って `sdlc:track` ラベルを削除すると、以下の影響がある：
- `/sdlc-init` 未実行の Issue は Projects から削除される（期待通り）
- `/sdlc-init` 実行済みの Feature は Projects に保持される（期待通り）

ただし、誤削除に気づかない場合、Issue が一時的に Projects から削除される可能性がある。

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: Issue が一時的に Projects から見えなくなる
- **System**（システム）: 影響なし
- **Business**（ビジネス）: 影響は限定的（ラベルを再追加すれば復元）
- **Data**（データ）: Issue 本体は影響を受けない

**Likelihood**（発生確率）: Low (<10%)

#### Impact Assessment（影響評価）
- **Severity**（深刻度）: Minor
- **Scope**（範囲）: Component（個別の Issue のみ）
- **Recovery Time**（復旧時間）: < 5 minutes（ラベルを再追加）
- **Data Loss Risk**（データ喪失リスク）: No

#### Root Cause（根本原因）

人為的なミス（ラベルの誤削除）。

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Accept

**Actions**（アクション）:
1. **ドキュメントで周知**
   - Description（説明）: README.md にラベルの意味と使い方を記載
   - Owner（担当者）: TBD
   - Due Date（期限）: TBD
   - Status（ステータス）: Pending

**Residual Risk**（残存リスク）: Very Low（影響が限定的で復旧が容易）

#### Contingency Plan（緊急対応計画）

1. ラベルを再追加
2. `sync-projects.yml` を実行してデータを修正

#### Monitoring（監視）
- **Metrics**（メトリクス）: なし（影響が限定的）
- **Alerts**（アラート）: なし
- **Review Frequency**（レビュー頻度）: なし

---

## Risk Categories（リスクカテゴリー）

### Technical Risks（技術的リスク）
| リスク | レベル | ステータス | 軽減策 |
|--------|--------|-----------|--------|
| `.metadata` ファイル確認の実装複雑性 | Medium | Open | 既存パターン再利用、エラーハンドリング |
| GitHub API レート制限 | Medium | Open | Retry 機構、API 呼び出し最小化 |

### Operational Risks（運用リスク）
| リスク | レベル | ステータス | 軽減策 |
|--------|--------|-----------|--------|
| `sync-projects.yml` との競合 | Low | Open | 重複防止機構、統合テスト |
| ラベル誤削除によるデータ不整合 | Low | Open | ドキュメント周知 |

### Security Risks（セキュリティリスク）
| リスク | レベル | ステータス | 軽減策 |
|--------|--------|-----------|--------|
| （なし） | - | - | - |

### Performance Risks（パフォーマンスリスク）
| リスク | レベル | ステータス | 軽減策 |
|--------|--------|-----------|--------|
| （なし） | - | - | - |

### Data Risks（データリスク）
| リスク | レベル | ステータス | 軽減策 |
|--------|--------|-----------|--------|
| （なし） | - | - | - |

### Dependency Risks（依存関係リスク）
| リスク | レベル | ステータス | 軽減策 |
|--------|--------|-----------|--------|
| `secrets.GH_PAT` の権限不足 | Low | Open | 事前確認、エラーハンドリング |

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
- **Medium**（中）: 2 - R001, R002
- **Low**（低）: 2 - R003, R004

---

## Accepted Risks（受け入れたリスク）

### Risk: ラベル誤削除によるデータ不整合
**Reason for Acceptance**（受け入れ理由）:
- 影響が限定的（個別の Issue のみ）
- 復旧が容易（ラベルを再追加すれば復元）
- 発生確率が低い（人為的なミス）

**Conditions**（条件）:
- ドキュメントでラベルの使い方を周知
- 復旧手順を明確にする

**Approver**（承認者）: TBD  
**Date**（日付）: 2025-12-27

---

## Closed Risks（クローズ済みリスク）

（まだクローズ済みリスクなし）

---

## Risk Review History（リスクレビュー履歴）

| 日付 | レビュアー | 新規リスク | 更新リスク | クローズリスク | 備考 |
|------|-----------|-----------|-----------|---------------|------|
| 2025-12-27 | TBD | 4 | 0 | 0 | 初期リスク評価 |

---

## Notes（備考）

- すべてのリスクは Issue に記載されたリスク評価に基づいている
- Medium リスクの 2 つ（R001, R002）は技術的な課題だが、既存のパターンを踏襲することで軽減可能
- Low リスクの 2 つ（R003, R004）は運用上の懸念だが、影響が限定的で復旧が容易
- 全体として、Medium リスクとしての評価は妥当である
