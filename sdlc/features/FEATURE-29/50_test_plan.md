# Test Plan（テスト計画）

**Feature ID**: FEATURE-29  
**Last Updated**: 2025-12-29  
**Test Owner**（テスト責任者）: TBD

## Test Strategy（テスト戦略）

FEATURE-29のリファクタリングでは、既存機能を破壊しないことが最優先です。包括的なテストスイートを構築し、各フェーズでリグレッションを防ぎます。

**Testing Levels**（テストレベル）:
- Unit Testing（ユニットテスト）: 80%以上のカバレッジ目標
- Integration Testing（統合テスト）: 主要なワークフローをカバー
- E2E Testing（E2Eテスト）: 全SDLCワークフローをカバー
- Platform Compatibility Testing（プラットフォーム互換性テスト）: 必須
- Performance Testing（パフォーマンステスト）: 推奨

## Test Scope（テスト範囲）

### In Scope（範囲内）
- 全11個のSDLCコマンドの動作
- 新規作成する3つの共有スクリプト
- プラットフォーム互換性（macOS/Linux）
- エラーハンドリング
- Metadata操作の整合性
- Git操作（commit, push, rebase）

### Out of Scope（範囲外）
- GitHub APIの動作（モックを使用）
- Git内部の動作（Git自体のテスト）
- ユーザーの環境設定（標準環境を想定）

## Unit Tests（ユニットテスト）

### Component: update-metadata.sh

#### Test Case 1: 正常なMetadata更新
- **Description**（説明）: 既存のキーの値を正常に更新
- **Input**（入力）:
  - FEATURE_ID: FEATURE-TEST
  - KEY: STATUS
  - VALUE: implementation
- **Expected Output**（期待出力）: Exit code 0, STATUS行が更新される
- **Edge Cases**（エッジケース）:
  - 値にスペースが含まれる
  - 値に特殊文字が含まれる

#### Test Case 2: Feature不存在エラー
- **Description**（説明）: 存在しないFeature IDを指定
- **Input**（入力）: FEATURE_ID: NONEXISTENT
- **Expected Output**（期待出力）: Exit code 1, エラーメッセージ表示
- **Edge Cases**（エッジケース）: なし

#### Test Case 3: Metadataファイル不存在
- **Description**（説明）: Featureディレクトリは存在するがmetadataファイルがない
- **Input**（入力）: 有効なFEATURE_IDだがmetadataファイルなし
- **Expected Output**（期待出力）: Exit code 2, エラーメッセージ表示
- **Edge Cases**（エッジケース）: なし

#### Test Case 4: プラットフォーム互換性（macOS）
- **Description**（説明）: macOSで`sed -i ''`が正しく動作
- **Input**（入力）: 標準的な更新操作
- **Expected Output**（期待出力）: 正常に更新、バックアップファイルが作成されない
- **Edge Cases**（エッジケース）: なし

#### Test Case 5: プラットフォーム互換性（Linux）
- **Description**（説明）: Linuxで`sed -i`が正しく動作
- **Input**（入力）: 標準的な更新操作
- **Expected Output**（期待出力）: 正常に更新、バックアップファイルが作成されない
- **Edge Cases**（エッジケース）: なし

### Component: check-branch.sh

#### Test Case 1: 正しいブランチにいる
- **Description**（説明）: feature/FEATURE-TESTブランチで実行
- **Input**（入力）: FEATURE_ID: FEATURE-TEST
- **Expected Output**（期待出力）: Exit code 0
- **Edge Cases**（エッジケース）: なし

#### Test Case 2: 誤ったブランチにいる
- **Description**（説明）: mainブランチで実行
- **Input**（入力）: FEATURE_ID: FEATURE-TEST
- **Expected Output**（期待出力）: Exit code 1, エラーメッセージ
- **Edge Cases**（エッジケース）:
  - developブランチ
  - 別のfeatureブランチ

#### Test Case 3: ブランチが存在しない
- **Description**（説明）: 存在しないFeature IDを指定
- **Input**（入力）: FEATURE_ID: NONEXISTENT
- **Expected Output**（期待出力）: Exit code 2, エラーメッセージ
- **Edge Cases**（エッジケース）: なし

### Component: rebase-with-develop.sh

#### Test Case 1: クリーンなRebase
- **Description**（説明）: コンフリクトなしでrebase成功
- **Input**（入力）: FEATURE_ID: FEATURE-TEST
- **Expected Output**（期待出力）: Exit code 0, rebase完了
- **Edge Cases**（エッジケース）: なし

#### Test Case 2: コンフリクト発生
- **Description**（説明）: rebase中にコンフリクトが発生
- **Input**（入力）: コンフリクトするFeature
- **Expected Output**（期待出力）: Exit code 1, コンフリクトメッセージ、rebase abort
- **Edge Cases**（エッジケース）: なし

#### Test Case 3: developブランチ取得失敗
- **Description**（説明）: ネットワークエラーなどでfetch失敗
- **Input**（入力）: ネットワーク切断状態
- **Expected Output**（期待出力）: Exit code 2, エラーメッセージ
- **Edge Cases**（エッジケース）: なし

### Component: common-functions.sh

#### Test Case 1: log_info関数
- **Description**（説明）: 情報ログが正しく出力される
- **Input**（入力）: "Test message"
- **Expected Output**（期待出力）: "[INFO] Test message" が標準出力に表示
- **Edge Cases**（エッジケース）: 長いメッセージ、特殊文字

#### Test Case 2: check_feature_exists（存在する）
- **Description**（説明）: 存在するFeatureで成功
- **Input**（入力）: FEATURE-TEST（存在）
- **Expected Output**（期待出力）: Exit code 0
- **Edge Cases**（エッジケース）: なし

#### Test Case 3: check_feature_exists（存在しない）
- **Description**（説明）: 存在しないFeatureでエラー
- **Input**（入力）: NONEXISTENT
- **Expected Output**（期待出力）: Exit code 1, エラーメッセージ
- **Edge Cases**（エッジケース）: なし

#### Test Case 4: check_gh_auth（認証済み）
- **Description**（説明）: GitHub認証済みで成功
- **Input**（入力）: `gh auth status`が成功
- **Expected Output**（期待出力）: Exit code 0
- **Edge Cases**（エッジケース）: なし

#### Test Case 5: check_gh_auth（未認証）
- **Description**（説明）: GitHub未認証でエラー
- **Input**（入力）: `gh auth status`が失敗
- **Expected Output**（期待出力）: Exit code 1, エラーメッセージ
- **Edge Cases**（エッジケース）: なし

## Integration Tests（統合テスト）

### Integration 1: /sdlc-init と共有スクリプト
**Scope**（範囲）: /sdlc-init + update-metadata.sh + common-functions.sh

#### Test Case 1: 新規Feature作成の完全フロー
- **Description**（説明）: Issue URLから新規Feature作成まで
- **Setup**（セットアップ）: 
  - テスト用GitHubリポジトリ
  - モックIssue作成
- **Steps**（手順）:
  1. `/sdlc-init <issue-url>`を実行
  2. ブランチ作成を確認
  3. ディレクトリ作成を確認
  4. Metadataファイルを確認
  5. 各ドキュメントファイルを確認
- **Expected Result**（期待結果）:
  - 正しいブランチが作成される
  - Metadataが正しく設定される
  - 全ドキュメントが生成される
  - Git commitが作成される
- **Cleanup**（クリーンアップ）: テストブランチとディレクトリ削除

#### Test Case 2: 既存Feature再初期化のエラー
- **Description**（説明）: 既に存在するFeatureで/sdlc-initを実行
- **Setup**（セットアップ）: 既存のFeature作成
- **Steps**（手順）:
  1. 同じIssue URLで`/sdlc-init`を再実行
- **Expected Result**（期待結果）:
  - エラーメッセージが表示される
  - 既存データが上書きされない
- **Cleanup**（クリーンアップ）: テストFeature削除

### Integration 2: /sdlc-decision と共有スクリプト
**Scope**（範囲）: /sdlc-decision + update-metadata.sh + check-branch.sh

#### Test Case 1: Decision確定の完全フロー
- **Description**（説明）: PENDINGのDecisionをCONFIRMED/REJECTEDに変更
- **Setup**（セットアップ）:
  - テストFeature作成
  - decisions.mdにPENDING Decision追加
- **Steps**（手順）:
  1. 正しいブランチにチェックアウト
  2. `/sdlc-decision`を実行
  3. Metadataの更新を確認
- **Expected Result**（期待結果）:
  - DECISION_STATUSがconfirmedに更新
  - Commitが作成される
- **Cleanup**（クリーンアップ）: テストFeature削除

#### Test Case 2: 誤ったブランチでのエラー
- **Description**（説明）: mainブランチで/sdlc-decisionを実行
- **Setup**（セットアップ）: テストFeature作成、mainブランチに移動
- **Steps**（手順）:
  1. `/sdlc-decision`を実行
- **Expected Result**（期待結果）:
  - check-branch.shがエラーを返す
  - 処理が中断される
  - エラーメッセージが表示される
- **Cleanup**（クリーンアップ）: テストFeature削除

### Integration 3: /sdlc-coding と共有スクリプト
**Scope**（範囲）: /sdlc-coding + update-metadata.sh + rebase-with-develop.sh

#### Test Case 1: 実装開始の完全フロー
- **Description**（説明）: Decision確定後に実装を開始
- **Setup**（セットアップ）:
  - テストFeature作成
  - DECISION_STATUSをconfirmedに設定
- **Steps**（手順）:
  1. `/sdlc-coding`を実行
  2. Rebase実行を確認
  3. Metadata更新を確認
- **Expected Result**（期待結果）:
  - developとrebaseされる
  - STATUSがimplementationに更新
  - Commitが作成される
- **Cleanup**（クリーンアップ）: テストFeature削除

## E2E Tests（E2Eテスト）

### User Flow 1: 完全なSDLCワークフロー
**Scenario**（シナリオ）: Issue作成から実装完了まで

#### Test Case 1: Happy Path（正常系）
- **User Actions**（ユーザー操作）:
  1. GitHub Issueを作成
  2. `/sdlc-init <issue-url>`を実行
  3. 生成された文書をレビュー
  4. `/sdlc-decision`でDecisionを確定
  5. `/sdlc-coding`で実装開始
  6. コード実装
  7. `/sdlc-test`でテスト実行
  8. `/sdlc-pr`でPR作成
- **Expected Behavior**（期待動作）:
  - 各ステップがエラーなく完了
  - Metadataが各段階で正しく更新される
  - Gitの状態が一貫している
- **Verification Points**（検証ポイント）:
  - 各フェーズでMetadataのSTATUSが正しい
  - 全てのCommitメッセージが統一形式
  - 共有スクリプトが正しく呼び出される

#### Test Case 2: Error Path - Decision未確定で実装開始
- **User Actions**（ユーザー操作）:
  1. `/sdlc-init`を実行
  2. Decisionを確定せずに`/sdlc-coding`を実行
- **Expected Behavior**（期待動作）:
  - エラーメッセージが表示される
  - 実装フェーズに進めない
  - Metadataが変更されない
- **Verification Points**（検証ポイント）:
  - DECISION_STATUSがpendingのまま
  - STATUSがplanningのまま

### User Flow 2: リファクタリング前後の比較
**Scenario**（シナリオ）: 既存コマンドとリファクタリング後の動作一致

#### Test Case 1: 全コマンドの動作一致
- **User Actions**（ユーザー操作）:
  1. リファクタリング前のコマンドでFeature作成
  2. 同じ操作をリファクタリング後のコマンドで実行
- **Expected Behavior**（期待動作）:
  - 生成される結果が同一
  - Metadataの内容が同一
  - Git履歴の構造が同一
- **Verification Points**（検証ポイント）:
  - ファイル内容の差分がない（タイムスタンプ除く）
  - Commit数とメッセージが一致

## Platform Compatibility Tests（プラットフォーム互換性テスト）

### Test 1: macOS環境
- **Environment**: macOS Monterey以降
- **Test Cases**:
  - [ ] 全11コマンドが正常実行
  - [ ] 共有スクリプトが正常実行
  - [ ] `sed -i ''`が正しく動作
  - [ ] Metadata更新が正常
  - [ ] Git操作が正常

### Test 2: Linux環境（Ubuntu 20.04）
- **Environment**: Ubuntu 20.04
- **Test Cases**:
  - [ ] 全11コマンドが正常実行
  - [ ] 共有スクリプトが正常実行
  - [ ] `sed -i`が正しく動作
  - [ ] Metadata更新が正常
  - [ ] Git操作が正常

### Test 3: Linux環境（Ubuntu 22.04）
- **Environment**: Ubuntu 22.04
- **Test Cases**:
  - [ ] 全11コマンドが正常実行
  - [ ] 共有スクリプトが正常実行
  - [ ] `sed -i`が正しく動作
  - [ ] Metadata更新が正常
  - [ ] Git操作が正常

### Test 4: クロスプラットフォーム互換性
- **Scenario**: macOSで作成したFeatureをLinuxで操作
- **Test Cases**:
  - [ ] macOSで`/sdlc-init`、Linuxで`/sdlc-decision`
  - [ ] Metadataファイルの互換性
  - [ ] 改行コードの問題がない

## Performance Tests（パフォーマンステスト）

### Test 1: 共有スクリプトのオーバーヘッド測定
- **Objective**（目的）: 共有スクリプト導入による実行時間の影響測定
- **Test Data**: 10個のテストFeature
- **Measurement**:
  - リファクタリング前: 各コマンドの実行時間
  - リファクタリング後: 各コマンドの実行時間
- **Success Criteria**（成功基準）:
  - 実行時間の増加が20%以内
  - 共有スクリプト呼び出しが100ms以内

### Test 2: 複雑性削減の効果測定
- **Objective**（目的）: /sdlc-initの実行時間削減
- **Measurement**:
  - リファクタリング前: 実行時間
  - リファクタリング後: 実行時間
- **Success Criteria**（成功基準）:
  - ステップ数が30以下
  - 実行時間が現状と同等以下

## Regression Tests（リグレッションテスト）

各フェーズ完了後に実行：
- [ ] 既存の全SDLCワークフローが動作する
- [ ] 既存Featureのメタデータが正しく読み込める
- [ ] 既存Featureで新しいコマンドが動作する
- [ ] Git操作（commit, push, rebase）が正常
- [ ] GitHub API連携が正常

## Test Environment（テスト環境）

### Setup Requirements（セットアップ要件）
- **OS**: macOS Monterey以降、Ubuntu 20.04/22.04
- **Git**: 2.0以降
- **GitHub CLI**: 最新版
- **Bash**: 4.0以降
- **Test Repository**: プライベートまたはテスト用リポジトリ

### Test Data（テストデータ）
- テスト用GitHub Issue（複数のリスクレベル）
- テスト用Feature（各フェーズの状態）
- モックデータ（GitHub API応答）

## Test Execution（テスト実行）

### Automated Tests（自動テスト）
- **Framework**: Bats (Bash Automated Testing System)
- **Command**（コマンド）: `make test`
- **CI/CD Integration**: GitHub Actions
  ```yaml
  strategy:
    matrix:
      os: [macos-latest, ubuntu-20.04, ubuntu-22.04]
  ```
- **Coverage Tool**: kcov
- **Coverage Threshold**（カバレッジ閾値）: 80%

### Manual Tests（手動テスト）
- **When**: 各フェーズ完了後、リリース前
- **What**: E2Eワークフロー、エラーケース、ユーザー体験
- **Tester**（テスター）: TBD

## Test Coverage（テストカバレッジ）

### Coverage Targets（カバレッジ目標）
- Unit Test Coverage（ユニットテストカバレッジ）: ≥ 80%
- Integration Test Coverage（統合テストカバレッジ）: ≥ 70%
- Critical Paths（クリティカルパス）: 100%
  - Metadata更新
  - ブランチチェック
  - Decision確定フロー

### Coverage Reports（カバレッジレポート）
- **Tool**（ツール）: kcov
- **Report Location**（レポート場所）: `coverage/` ディレクトリ
- **CI Integration**: GitHub Actions artifacts

## Risk-Based Testing（リスクベーステスト）

| リスク領域 | 優先度 | テスト種別 | カバレッジ |
|-----------|--------|-----------|----------|
| 既存機能の破壊 | High | E2E, Regression | 100% |
| プラットフォーム互換性 | High | Platform Tests | 100% |
| Metadata破損 | Medium | Unit, Integration | 90% |
| Git操作失敗 | Medium | Integration | 80% |
| パフォーマンス劣化 | Low | Performance Tests | ベンチマークのみ |

## Test Schedule（テストスケジュール）

### Phase 1: 共有スクリプト抽出
- Week 1: ユニットテスト作成と実行
- Week 2: 統合テスト作成と実行
- Week 3: プラットフォーム互換性テスト

### Phase 2: コマンド標準化
- Week 4: リグレッションテスト
- Week 5: E2Eテスト

### Phase 3: 複雑性簡素化
- Week 6: パフォーマンステスト
- Week 7: リグレッションテスト

### Phase 4: バリデーション強化
- Week 8: 全テストスイート実行
- Week 9: 手動テストとユーザー受け入れテスト

## Exit Criteria（終了基準）

各フェーズの完了基準：
- [ ] All planned tests executed（全計画テストが実行された）
- [ ] Coverage targets met（カバレッジ目標を達成: 80%以上）
- [ ] No critical bugs open（クリティカルバグなし）
- [ ] Platform tests passed（両プラットフォームでテスト通過）
- [ ] Performance benchmarks passed（パフォーマンス基準を通過: 20%以内の増加）
- [ ] Regression tests passed（リグレッションテスト通過）
- [ ] Code review approved（コードレビュー承認）

## Test Results（テスト結果）

各フェーズ完了後に記録：

### Phase 1 Results
- **Date**（日付）: TBD
- **Total Tests**（総テスト数）: TBD
- **Passed**（成功）: TBD
- **Failed**（失敗）: TBD
- **Coverage**（カバレッジ）: TBD%

### Phase 2 Results
- **Date**（日付）: TBD
- **Total Tests**（総テスト数）: TBD
- **Passed**（成功）: TBD
- **Failed**（失敗）: TBD
- **Coverage**（カバレッジ）: TBD%

### Phase 3 Results
- **Date**（日付）: TBD
- **Total Tests**（総テスト数）: TBD
- **Passed**（成功）: TBD
- **Failed**（失敗）: TBD
- **Coverage**（カバレッジ）: TBD%

### Phase 4 Results
- **Date**（日付）: TBD
- **Total Tests**（総テスト数）: TBD
- **Passed**（成功）: TBD
- **Failed**（失敗）: TBD
- **Coverage**（カバレッジ）: TBD%

## Notes（備考）

- テストは各フェーズの実装前に作成（TDD推奨）
- CI/CDパイプラインで全テストを自動実行
- プラットフォーム互換性テストは必須
- パフォーマンステストは各フェーズ完了後に実施
