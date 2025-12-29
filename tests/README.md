# SDLC Tests

このディレクトリには、SDLCコマンドと共有スクリプトのテストが含まれています。

## 概要

テスト戦略は **単体テスト + 統合テストのバランス型** (Decision 4で確定) で、80%以上のカバレッジを目標としています。

## テストフレームワーク

**BATS (Bash Automated Testing System)** を使用しています。

### インストール

#### macOS
```bash
brew install bats-core
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install bats
```

#### 手動インストール
```bash
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

## ディレクトリ構造

```
tests/
├── README.md                      # このファイル
├── test_helper.sh                 # 共通テストヘルパー関数
├── unit/                          # 単体テスト
│   ├── test_common_functions.bats
│   ├── test_update_metadata.bats
│   └── test_check_branch.bats
├── integration/                   # 統合テスト（Phase 2で実装予定）
│   ├── test_sdlc_init.bats
│   ├── test_sdlc_decision.bats
│   └── test_sdlc_coding.bats
└── e2e/                          # E2Eテスト（Phase 4で実装予定）
    ├── test_workflow_happy_path.bats
    └── test_workflow_error_cases.bats
```

## テストの実行

### 全てのテストを実行

```bash
# プロジェクトルートから
bats tests/unit/*.bats
```

### 特定のテストファイルのみ実行

```bash
bats tests/unit/test_common_functions.bats
bats tests/unit/test_update_metadata.bats
bats tests/unit/test_check_branch.bats
```

### 特定のテストケースのみ実行

```bash
# フィルター指定で実行
bats tests/unit/test_common_functions.bats --filter "get_os_type"
```

### verbose モードで実行

```bash
bats tests/unit/*.bats --verbose
```

---

## 単体テスト (Unit Tests)

**対象**: 共有スクリプト (`scripts/*.sh`)

### test_common_functions.bats

`scripts/common-functions.sh` のテスト。

**テスト内容**:
- ✅ `get_os_type` - OS判定（macOS/Linux）
- ✅ `validate_feature_id` - Feature ID形式検証
- ✅ `check_feature_exists` - Feature存在確認
- ✅ `get_current_branch` - 現在ブランチ取得
- ✅ `get_metadata_value` - Metadata値取得
- ✅ `log_*` 関数 - ログ出力関数

**テストケース数**: 20+

**実行例**:
```bash
bats tests/unit/test_common_functions.bats
```

---

### test_update_metadata.bats

`scripts/update-metadata.sh` のテスト。

**テスト内容**:
- ✅ 既存キーの更新
- ✅ 新規キーの追加
- ✅ 特殊文字を含む値の処理
- ✅ エラーケース（Feature不存在、引数不足など）
- ✅ 複数更新の連続実行
- ✅ 値の上書き確認

**テストケース数**: 12+

**実行例**:
```bash
bats tests/unit/test_update_metadata.bats
```

---

### test_check_branch.bats

`scripts/check-branch.sh` のテスト。

**テスト内容**:
- ✅ 正しいブランチでの成功
- ✅ 誤ったブランチでのエラー
- ✅ 無効なFeature ID形式のエラー
- ✅ Git リポジトリ外でのエラー
- ✅ エラーメッセージの詳細確認

**テストケース数**: 12+

**実行例**:
```bash
bats tests/unit/test_check_branch.bats
```

---

## 統合テスト (Integration Tests)

**Phase 2で実装予定**

**対象**: SDLCコマンド全体

**実装予定のテスト**:
- `test_sdlc_init.bats` - `/sdlc-init` コマンドのテスト
- `test_sdlc_decision.bats` - `/sdlc-decision` コマンドのテスト
- `test_sdlc_coding.bats` - `/sdlc-coding` コマンドのテスト

**テスト内容**:
- 各コマンドが共有スクリプトを正しく呼び出すか
- Metadata更新が正しく行われるか
- エラーケースで適切なメッセージが表示されるか

---

## E2Eテスト (End-to-End Tests)

**Phase 4で実装予定**

**対象**: SDLCワークフロー全体

**実装予定のテスト**:
- `test_workflow_happy_path.bats` - 正常フローのテスト
  - `/sdlc-init` → `/sdlc-decision` → `/sdlc-coding` → ...
- `test_workflow_error_cases.bats` - エラーケースのテスト

---

## テストヘルパー関数

`test_helper.sh` には共通のヘルパー関数が含まれています。

### 主な関数

#### セットアップ・クリーンアップ
- `setup_test()` - テスト前の準備処理
- `teardown_test()` - テスト後のクリーンアップ

#### テストデータ作成
- `create_test_feature(feature_id)` - テスト用Feature作成
- `create_test_git_repo(repo_dir)` - テスト用Gitリポジトリ作成
- `create_test_branch(repo_dir, branch)` - テスト用ブランチ作成

#### アサーション
- `assert_output_contains(output, expected)` - 出力に文字列が含まれるか
- `assert_file_exists(file)` - ファイルが存在するか
- `assert_file_not_exists(file)` - ファイルが存在しないか
- `assert_file_contains(file, expected)` - ファイルに文字列が含まれるか
- `assert_exit_code(actual, expected)` - Exit codeが一致するか

#### ユーティリティ
- `strip_colors(text)` - ANSI色コードを除去

---

## CI/CD統合

**Phase 1で設計、Phase 4で実装予定**

### GitHub Actions設定（予定）

`.github/workflows/test.yml` でマトリックステストを実行：
- macOS latest
- Ubuntu 20.04
- Ubuntu 22.04

**実行タイミング**:
- 全てのPRで自動実行
- `main` / `develop` ブランチへのPush時

---

## テストカバレッジ

### 目標
- **単体テスト**: 90%以上
- **統合テスト**: 80%以上
- **E2Eテスト**: 主要パスをカバー

### 現在のカバレッジ（Phase 1完了時）

| スクリプト | テストケース数 | カバレッジ（推定） |
|-----------|---------------|------------------|
| `common-functions.sh` | 20+ | ~95% |
| `update-metadata.sh` | 12+ | ~90% |
| `check-branch.sh` | 12+ | ~95% |
| `rebase-with-develop.sh` | 未実装 | 0% |

**Phase 1 合計**: 約 44 テストケース

---

## テストの書き方

### 基本構造

```bash
#!/usr/bin/env bats

load ../test_helper

setup() {
    setup_test
}

teardown() {
    teardown_test
}

@test "テストの説明" {
    # テストコード
    run command_to_test
    [ "$status" -eq 0 ]
    [[ "$output" == *"期待される文字列"* ]]
}
```

### ベストプラクティス

1. **テスト名は明確に**: 何をテストしているか一目で分かる名前を使用
2. **1テスト1目的**: 各テストは1つの機能のみをテスト
3. **独立性**: テスト間で依存関係を持たない
4. **クリーンアップ**: `teardown()` で一時ファイルを必ず削除
5. **エラーメッセージ**: 失敗時に原因が分かるメッセージを含める

---

## トラブルシューティング

### BATSが見つからない

```bash
# インストール確認
command -v bats

# インストール
brew install bats-core  # macOS
```

### テストが失敗する

```bash
# verbose モードで詳細を確認
bats tests/unit/test_*.bats --verbose

# 特定のテストのみ実行
bats tests/unit/test_common_functions.bats --filter "get_os_type"
```

### 一時ファイルが残る

```bash
# 手動クリーンアップ
rm -rf tests/.tmp
```

### Permission denied エラー

```bash
# スクリプトに実行権限を付与
chmod +x scripts/*.sh
```

---

## Phase別実装計画

### ✅ Phase 1（完了）
- [x] テストディレクトリ構造作成
- [x] `test_helper.sh` 実装
- [x] `test_common_functions.bats` 実装
- [x] `test_update_metadata.bats` 実装
- [x] `test_check_branch.bats` 実装

### Phase 2（予定）
- [ ] 統合テスト実装
- [ ] `test_sdlc_init.bats` 実装
- [ ] `test_sdlc_decision.bats` 実装

### Phase 3（予定）
- [ ] 簡素化後のコマンドのテスト更新

### Phase 4（予定）
- [ ] E2Eテスト実装
- [ ] CI/CD統合（GitHub Actions）
- [ ] カバレッジレポート生成

---

## 関連リソース

- [BATS Documentation](https://bats-core.readthedocs.io/)
- [FEATURE-29 Implementation Plan](../sdlc/features/FEATURE-29/30_implementation_plan.md)
- [Shared Scripts Documentation](../scripts/README.md)
- [SDLC Commands](../.claude/commands/)

---

## 変更履歴

- **2025-12-29**: Phase 1 - 単体テスト実装（44テストケース）
