# SDLC 共有スクリプト

このディレクトリには、SDLCコマンド間で共有される汎用スクリプトが含まれています。

## 概要

SDLCコマンドの実装において重複していたロジックを共通スクリプトとして抽出し、DRY原則を適用しています。全てのスクリプトは macOS と Linux の両方で動作します。

## スクリプト一覧

### common-functions.sh

共通のユーティリティ関数を提供します。他のスクリプトから `source` して使用します。

**主な関数**:
- `log_info` - 情報ログを出力
- `log_error` - エラーログを出力
- `log_success` - 成功ログを出力
- `log_warning` - 警告ログを出力
- `get_os_type` - OS種別を判定（macos/linux/unknown）
- `validate_feature_id` - Feature ID形式を検証
- `check_feature_exists` - Featureディレクトリの存在確認
- `check_gh_auth` - GitHub CLI認証確認
- `check_git_config` - Git設定確認
- `get_current_branch` - 現在のブランチ名取得
- `get_metadata_value` - .metadataから値を取得
- `display_error` - 標準化されたエラーメッセージ表示

**使用例**:
```bash
source scripts/common-functions.sh

log_info "処理を開始します"
if check_feature_exists "FEATURE-29"; then
    log_success "Feature が見つかりました"
else
    log_error "Feature が見つかりません"
fi
```

---

### update-metadata.sh

Feature の `.metadata` ファイルを更新します。

**使用方法**:
```bash
./scripts/update-metadata.sh <FEATURE_ID> <KEY> <VALUE>
```

**例**:
```bash
./scripts/update-metadata.sh FEATURE-29 STATUS implementing
./scripts/update-metadata.sh FEATURE-29 DECISION_STATUS confirmed
./scripts/update-metadata.sh FEATURE-29 LAST_UPDATED 2025-12-29
```

**Exit codes**:
- `0` - 成功
- `1` - Feature ディレクトリが存在しない
- `2` - Metadata ファイルが存在しない
- `3` - 書き込み失敗
- `4` - 引数エラー

**特徴**:
- macOS/Linux 両対応（互換コマンド使用）
- キーが存在する場合は更新、存在しない場合は追加
- Atomic 操作（一時ファイル使用）

---

### check-branch.sh

現在の git ブランチが正しいかを検証します。

**使用方法**:
```bash
./scripts/check-branch.sh <FEATURE_ID>
```

**例**:
```bash
./scripts/check-branch.sh FEATURE-29
# 期待されるブランチ: feature/FEATURE-29
```

**Exit codes**:
- `0` - 正しいブランチ
- `1` - 誤ったブランチ
- `2` - ブランチ情報取得失敗

**出力例**:
```
✅ Correct branch: feature/FEATURE-29
```

または、誤ったブランチの場合:
```
❌ Error: Wrong branch
   Context: Expected branch: feature/FEATURE-29
   Context: Current branch:  main
   Action: git checkout feature/FEATURE-29
```

---

### rebase-with-develop.sh

現在の feature ブランチを develop ブランチと rebase します。

**使用方法**:
```bash
./scripts/rebase-with-develop.sh <FEATURE_ID>
```

**例**:
```bash
./scripts/rebase-with-develop.sh FEATURE-29
```

**Exit codes**:
- `0` - Rebase 成功
- `1` - コンフリクト発生
- `2` - その他のエラー

**処理内容**:
1. 現在のブランチが `feature/<FEATURE_ID>` であることを確認
2. `origin/develop` から最新を fetch
3. `origin/develop` で rebase を実行
4. コンフリクトが発生した場合は詳細を表示

**コンフリクト発生時の出力例**:
```
❌ Error: Rebase conflicts detected
   Context: 以下のファイルでコンフリクトが発生しました:
      - file1.txt
      - file2.txt
   Action: コンフリクトを解決してから以下を実行:
      1. コンフリクトを手動で解決
      2. git add <解決したファイル>
      3. git rebase --continue
   または、rebaseを中止する場合:
      git rebase --abort
```

---

## プラットフォーム互換性

全てのスクリプトは macOS と Linux の両方で動作するように設計されています。

**互換性のための工夫**:
- `sed` コマンドは一時ファイルを使用（`sed -i` の違いを回避）
- 標準的な Bash 機能のみを使用
- プラットフォーム固有の機能を使用しない

**テスト環境**:
- macOS 14+
- Ubuntu 20.04+
- Ubuntu 22.04+

---

## エラーメッセージの標準化

全てのスクリプトは統一されたエラーメッセージ形式を使用しています：

```
❌ Error: <問題の概要>
   Context: <追加の文脈情報>
   Action: <ユーザーが取るべきアクション>
```

**例**:
```
❌ Error: Feature not found: FEATURE-99
   Context: ディレクトリ 'sdlc/features/FEATURE-99' が存在しません
   Action: /sdlc-init FEATURE-99 を先に実行してください
```

---

## 開発ガイドライン

### 新しいスクリプトを追加する場合

1. **Shebang** を追加:
   ```bash
   #!/usr/bin/env bash
   ```

2. **Set オプション** を設定:
   ```bash
   set -euo pipefail
   ```

3. **共通関数を読み込み**:
   ```bash
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   source "${SCRIPT_DIR}/common-functions.sh"
   ```

4. **実行権限を付与**:
   ```bash
   chmod +x scripts/your-script.sh
   ```

5. **ドキュメントを更新**: このREADMEに追加

---

## テスト

スクリプトのテストは `tests/unit/` ディレクトリに配置されています。

**テストの実行**:
```bash
# 全ての単体テストを実行
bats tests/unit/*.bats

# 特定のスクリプトのテストのみ実行
bats tests/unit/test_update_metadata.bats
```

---

## トラブルシューティング

### Permission denied エラー

スクリプトに実行権限がない場合:
```bash
chmod +x scripts/<script-name>.sh
```

### macOS で sed エラー

macOS の BSD sed と Linux の GNU sed の違いによるエラーは発生しないはずですが、もし発生した場合は Issue を報告してください。

### Git 認証エラー

GitHub CLI の認証が必要な場合:
```bash
gh auth login
```

---

## 関連リソース

- [FEATURE-29: SDLCコマンドリファクタリング](../sdlc/features/FEATURE-29/)
- [テストドキュメント](../tests/README.md)
- [SDLCコマンド一覧](../.claude/commands/)

---

## 変更履歴

- **2025-12-29**: Phase 1 - 初期実装（4つの共有スクリプト）
