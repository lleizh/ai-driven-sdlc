# Risks（リスク）

**Feature ID**: FEATURE-45  
**Last Updated**: 2026-01-09  
**Overall Risk Level**（総合リスクレベル）: LOW

---

## Risk Assessment Summary（リスク評価サマリー）

| Risk ID | リスク | レベル | ステータス |
|---------|--------|--------|-----------|
| R001 | 既存のインストール動作の破壊 | Medium | Open |
| R002 | 非対話モードの誤検出 | Low | Open |
| R003 | Organization 権限の問題 | Low | Open |

---

## Risk Level Criteria（リスクレベル基準）

### Low Risk（低リスク）
**Definition**（定義）:
- 最小限の影響、局所的な変更
- 簡単にロールバック可能

**Review Requirements**（レビュー要件）:
- Code Review のみ
- 基本的なテストカバレッジ

---

## Detailed Risk Analysis（詳細リスク分析）

### Risk R001: 既存のインストール動作の破壊

**Level**（レベル）: MEDIUM  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2026-01-09

#### Description（説明）

`install.sh` の確認処理や GitHub API 呼び出しロジックを変更することで、既存の動作環境（対話型インストール、個人リポジトリでの使用）で予期しない動作が発生する可能性があります。

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: 既存のインストール方法が動作しなくなる
- **System**（システム）: インストールプロセスが失敗し、SDLC セットアップができない
- **Business**（ビジネス）: ユーザー体験の悪化、プロジェクトの信頼性低下

**Likelihood**（発生確率）: Low (<10%)

#### Root Cause（根本原因）

- 複数の独立した修正（パイプ実行、Organization サポート、macOS 互換性）を同時に実施する
- 既存のコードパスへの影響が完全には予測できない

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Reduce

**Actions**（アクション）:
- [x] 各修正を独立した関数やブロックに分離する
- [ ] 既存の動作（対話型インストール、個人リポジトリ）の regression テストを実施
- [ ] パイプ実行と対話実行の両方でテスト
- [ ] macOS と Linux の両方でテスト

**Residual Risk**（残存リスク）: Low

#### Contingency Plan（緊急対応計画）

1. 修正前のバージョンの `install.sh` を保存しておく
2. 問題が報告された場合、即座に元のバージョンに戻す
3. 問題の原因を特定し、修正を再実施

#### Monitoring（監視）

- **Metrics**（メトリクス）: GitHub Issues での報告、インストール失敗のレポート
- **Review Frequency**（レビュー頻度）: リリース後1週間は毎日チェック

---

### Risk R002: 非対話モードの誤検出

**Level**（レベル）: LOW  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2026-01-09

#### Description（説明）

`[[ -t 0 ]]` による非対話モードの検出が、特定の環境で誤動作する可能性があります（例: リダイレクトされた stdin を持つ環境）。

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: 確認プロンプトが表示されない、または予期しない動作
- **System**（システム）: インストールが意図しない方法で続行される
- **Business**（ビジネス）: 軽微な UX の問題

**Likelihood**（発生確率）: Low (<10%)

#### Root Cause（根本原因）

- stdin の状態検出は環境依存
- 全てのエッジケースをテストすることは困難

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Accept + Reduce

**Actions**（アクション）:
- [ ] 複数の環境（ターミナル、tmux、screen、CI/CD）でテスト
- [ ] 非対話モードで続行する場合、明確なメッセージを表示
- [ ] README で推奨インストール方法を明示

**Residual Risk**（残存リスク）: Low

#### Contingency Plan（緊急対応計画）

1. 報告された環境を記録
2. 該当環境での動作を修正（必要に応じて追加の条件分岐）
3. テストケースに追加

---

### Risk R003: Organization 権限の問題

**Level**（レベル）: LOW  
**Status**（ステータス）: OPEN  
**Owner**（担当者）: TBD  
**Identified Date**（特定日）: 2026-01-09

#### Description（説明）

ユーザーが Organization に対する GitHub Project 作成権限を持っていない場合、インストールが失敗する可能性があります。

#### Impact（影響）
**If this risk materializes**（このリスクが現実化した場合）:
- **Users**（ユーザー）: GitHub Project のセットアップが失敗
- **System**（システム）: SDLC の一部機能が使用できない（GitHub Projects 連携）
- **Business**（ビジネス）: インストール体験の悪化

**Likelihood**（発生確率）: Medium (10-50%)

#### Root Cause（根本原因）

- Organization の権限設定はリポジトリごとに異なる
- GitHub API が権限エラーを返す可能性

#### Mitigation Strategy（軽減戦略）

**Approach**（アプローチ）: Reduce

**Actions**（アクション）:
- [ ] GitHub API エラーを適切にキャッチし、わかりやすいメッセージを表示
- [ ] 権限が不足している場合、Project セットアップをスキップし、他の機能は正常にインストール
- [ ] README に必要な権限を明示

**Residual Risk**（残存リスク）: Low

#### Contingency Plan（緊急対応計画）

1. エラーメッセージを表示し、手動での GitHub Project セットアップ手順を提示
2. README に Organization での権限要件を追記

---

## Risk Categories（リスクカテゴリー）

### Technical Risks（技術的リスク）
- stdin 状態検出の環境依存性
- GitHub API の権限エラー
- 複数の修正による予期しない相互作用

### Operational Risks（運用リスク）
- 既存ユーザーへの影響（インストール動作の変更）
- ドキュメント更新の必要性

### Security Risks（セキュリティリスク）
- なし（この修正はセキュリティに影響しない）

### Data Risks（データリスク）
- なし（データの変更や移行は伴わない）

### Dependency Risks（依存関係リスク）
- GitHub API の動作に依存（`repositoryOwner` クエリの動作）
- bash の標準的な機能に依存（`[[ -t 0 ]]`）

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
- **Medium**（中）: 1 - R001
- **Low**（低）: 2 - R002, R003

---

## Accepted Risks（受け入れたリスク）

（現時点で受け入れたリスクはありません。決定後に更新予定）

---

## Risk Review History（リスクレビュー履歴）

| 日付 | レビュアー | 変更内容 | 備考 |
|------|-----------|---------|------|
| 2026-01-09 | AI | 初期リスク評価 | Issue #45 の内容から抽出 |

---

## Notes（備考）

- この機能は既存のインストールスクリプトの修正であり、新規機能ではありません
- リスクレベル Low と評価されていますが、インストールプロセスはユーザーの最初の接点であるため、慎重なテストが重要です
- 各修正は独立しているため、段階的にリリースすることも可能です
