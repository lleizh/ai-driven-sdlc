# Decisions

**Feature ID**: FEATURE-10  
**Last Updated**: 2025-12-26

---

## Decision 1: テストの実行方法

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: lleizh

### Context
`50_test_plan.md` に定義されたテストを実際にどのように実行するか。Issue には bash スクリプトまたは既存 CLI ツールの呼び出しという記載があるが、具体的な実装方法を決定する必要がある。

### Options Considered

#### Option A: テストフレームワーク固有のコマンドを直接実行
**Pros**:
- シンプルで直接的
- 各プロジェクトのテストツールをそのまま使用
- 追加の抽象化レイヤーが不要

**Cons**:
- プロジェクトごとにテストコマンドが異なる（npm test, go test, cargo test など）
- `50_test_plan.md` からテストコマンドを自動抽出する必要がある
- テスト結果のフォーマットが統一されない可能性

**Cost/Effort**: Small

#### Option B: 共通のテスト実行スクリプトを作成
**Pros**:
- プロジェクト間で統一されたインターフェース
- テスト結果のフォーマットを標準化できる
- エラーハンドリングを一箇所で管理

**Cons**:
- 新しいスクリプトの作成と保守が必要
- 各言語/フレームワークへの対応が必要
- 複雑性が増す

**Cost/Effort**: Medium

#### Option C: `50_test_plan.md` にテスト実行コマンドを記載する規約を設ける
**Pros**:
- プロジェクトごとの柔軟性を保持
- テスト計画とテスト実行が同じドキュメントで管理される
- `/sdlc-test` はドキュメントからコマンドを読み取って実行するだけ

**Cons**:
- `50_test_plan.md` のフォーマットに制約が増える
- ドキュメントからコマンドを抽出するパーサーが必要

**Cost/Effort**: Small to Medium

### Decision
**Chosen Option**: Option C - `50_test_plan.md` にテスト実行コマンドを記載する規約を設ける

**Rejected Options**: 
- Option A: 自動抽出の複雑さとフォーマット不統一のリスク
- Option B: 過剰な抽象化と保守コスト

**Rationale**:
`50_test_plan.md` にテスト実行コマンドを記載することで、ドキュメントとテスト実行が一体化され、プロジェクトごとの柔軟性を保ちながらもテスト計画と実行の一貫性が確保できる。Option A では自動抽出のロジックが複雑になり、Option B では不要な抽象化レイヤーが追加される。Option C は最小限の実装でドキュメント駆動のアプローチを実現できる。

**Accepted Risks**:
- `50_test_plan.md` のフォーマットに制約が追加される
- ドキュメントからコマンドを抽出するパーサーの実装が必要

**Non-Negotiables**:
- 既存のコマンド（`/sdlc-coding`, `/sdlc-check`）に影響を与えない
- `50_test_plan.md` の構造を尊重する

### Impact
- **Technical**: `50_test_plan.md` のテンプレートにテスト実行コマンドのセクションを追加
- **Team**: テスト計画作成時にテスト実行コマンドも記載する必要がある
- **Timeline**: パーサー実装に1-2日
- **Cost**: Low

### Follow-up Actions
- [x] Option C を選択
- [ ] `50_test_plan.md` テンプレートにテスト実行コマンドのセクションを追加
- [ ] コマンド抽出パーサーの実装

---

## Decision 2: E2E テストの取り扱い

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: lleizh

### Context
Issue には「E2E tests（オプション：時間がかかる場合はスキップ可能）」という記載がある。E2E テストの実行判断をどのように行うかを決定する必要がある。

### Options Considered

#### Option A: デフォルトで E2E テストを実行、フラグでスキップ可能
**Pros**:
- デフォルトで全テストを実行するのが安全
- 必要に応じてスキップできる柔軟性

**Cons**:
- 実行時間が長くなる
- 開発中の頻繁なテスト実行が遅くなる

**Cost/Effort**: Small

#### Option B: デフォルトで E2E テストをスキップ、フラグで実行可能
**Pros**:
- 通常のテストサイクルが高速
- E2E は PR 前や CI で実行する想定

**Cons**:
- デフォルトで完全なテストカバレッジが得られない
- E2E テストの実行を忘れるリスク

**Cost/Effort**: Small

#### Option C: `50_test_plan.md` の設定に従う
**Pros**:
- Feature ごとに E2E テストの重要度を判断できる
- ドキュメントベースの設定で明示的

**Cons**:
- ドキュメントのパース処理が必要
- 設定の柔軟性がやや低下

**Cost/Effort**: Medium

### Decision
**Chosen Option**: Option C - `50_test_plan.md` の設定に従う

**Rejected Options**:
- Option A: デフォルト実行による開発サイクルの遅延リスク
- Option B: E2E テスト忘れのリスクとデフォルト不完全性

**Rationale**:
Feature ごとに E2E テストの重要度と実行戦略は異なるため、`50_test_plan.md` にその設定を記載することで、各 Feature の特性に応じた最適なテスト実行が可能になる。画一的なデフォルト動作（Option A/B）では、すべてのケースに対応できない。Decision 1 で選択したドキュメント駆動のアプローチとも一貫性がある。

**Accepted Risks**:
- ドキュメントのパース処理が必要
- E2E テストの設定記載を忘れた場合の動作を定義する必要がある

**Non-Negotiables**:
- テスト実行時間が過度に長くならないこと
- 重要なテストがスキップされないこと

### Impact
- **Technical**: `50_test_plan.md` に E2E テストの実行設定（デフォルト実行/スキップ）を記載する仕組みが必要
- **Team**: テスト計画作成時に E2E テストの実行戦略を決定する責任
- **Timeline**: パーサーへの設定読み込み機能追加に1日
- **Cost**: Low

### Follow-up Actions
- [x] Option C を選択
- [ ] `50_test_plan.md` テンプレートに E2E テスト設定のセクションを追加
- [ ] E2E テスト設定のパース処理を実装

---

## Decision 3: テスト結果のレポート形式

**Status**: CONFIRMED  
**Date**: 2025-12-26  
**Decision Maker**: lleizh

### Context
テスト結果をどのような形式でユーザーに表示するか。Issue には基本的なサマリー（Total/Passed/Failed/Skipped）が記載されているが、詳細レベルを決定する必要がある。

### Options Considered

#### Option A: サマリーのみ表示
**Pros**:
- シンプルで見やすい
- 出力が短い

**Cons**:
- 失敗したテストの詳細がわかりにくい
- デバッグに時間がかかる

**Cost/Effort**: Small

#### Option B: 失敗したテストの詳細も表示
**Pros**:
- デバッグが容易
- エラーメッセージがすぐに確認できる

**Cons**:
- 出力が長くなる可能性
- 複数のテスト失敗時に画面が埋まる

**Cost/Effort**: Small

#### Option C: サマリー + 失敗の詳細 + ファイルへの完全なログ出力
**Pros**:
- 画面は見やすく、詳細は後で確認可能
- 監査証跡として完全なログが残る

**Cons**:
- ログファイルの管理が必要
- やや複雑

**Cost/Effort**: Medium

### Decision
**Chosen Option**: Option B - 失敗したテストの詳細も表示

**Rejected Options**:
- Option A: デバッグ情報不足により開発者の生産性が低下
- Option C: ログファイル管理の複雑さと実装コスト増加

**Rationale**:
開発者がテスト失敗時に即座にデバッグできることが最優先。Option A ではエラー詳細を確認するために別のコマンドを実行する必要があり、開発体験が低下する。Option C はログファイル管理という追加の複雑性を導入するが、この Feature の初期実装では過剰。Option B は必要十分な情報を提供し、実装もシンプル。将来的にログファイル出力が必要になれば追加可能。

**Accepted Risks**:
- 多数のテスト失敗時に出力が長くなる（ターミナルスクロールで対応可能）
- 完全なログファイルが残らない（CI では別途ログが保存される）

**Non-Negotiables**:
- 失敗したテストが明確にわかること
- デバッグに必要な情報が提供されること

### Impact
- **Technical**: テスト結果のフォーマット処理（サマリー + 失敗詳細）
- **Team**: テスト失敗時に画面でエラー詳細を確認できる
- **Timeline**: 実装に0.5日
- **Cost**: Minimal

### Follow-up Actions
- [x] Option B を選択
- [ ] テスト結果レポート機能の実装（サマリー + 失敗詳細）

---

## Decision History

### Revisions
（なし）

---

## Quick Reference

### All Confirmed Decisions
1. **テストの実行方法**: Option C - `50_test_plan.md` にテスト実行コマンドを記載 - 2025-12-26
2. **E2E テストの取り扱い**: Option C - `50_test_plan.md` の設定に従う - 2025-12-26
3. **テスト結果のレポート形式**: Option B - 失敗したテストの詳細も表示 - 2025-12-26

### Pending Decisions
（なし）

---

## Notes
全ての Decision が CONFIRMED されました。ドキュメント駆動のアプローチを採用し、`50_test_plan.md` を中心としたテスト実行戦略が確定しました。
