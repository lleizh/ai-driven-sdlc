# Design（設計）

**Feature ID**: FEATURE-29  
**Last Updated**: 2025-12-29  
**Status**: FROZEN

## Overview（概要）

FEATURE-29は、11個のSDLCコマンドを体系的にリファクタリングするための設計です。主な目標は、コードの重複削減、複雑性の簡素化、標準化、プラットフォーム互換性の確保です。

設計は4つのフェーズに分割され、各フェーズは独立したPRとして実装可能です：
1. **共有スクリプトの抽出**: 重複するロジックを共通化
2. **コマンド標準化**: 構造とメッセージの統一
3. **複雑性の簡素化**: 複雑なコマンドの分解
4. **バリデーション強化**: エラー処理の改善

## Architecture（アーキテクチャ）

### System Architecture（システムアーキテクチャ）

```
┌─────────────────────────────────────────┐
│        SDLC Commands (11個)             │
│  /sdlc-init, /sdlc-decision, etc.      │
└────────────────┬────────────────────────┘
                 │
                 │ 呼び出し
                 ↓
┌─────────────────────────────────────────┐
│      Shared Scripts (scripts/)          │
│  - update-metadata.sh                   │
│  - check-branch.sh                      │
│  - rebase-with-develop.sh               │
│  - common-functions.sh (ユーティリティ) │
└────────────────┬────────────────────────┘
                 │
                 │ 操作
                 ↓
┌─────────────────────────────────────────┐
│         SDLC Data Structure             │
│  - sdlc/features/{FEATURE_ID}/          │
│    - .metadata                          │
│    - *.md (documents)                   │
└─────────────────────────────────────────┘
```

### Component Design（コンポーネント設計）

#### Component: update-metadata.sh
**Responsibility**（責務）: Featureのmetadataファイルを更新する  
**Interfaces**（インターフェース）:
```bash
update-metadata.sh <FEATURE_ID> <KEY> <VALUE>
```
**Dependencies**（依存関係）: なし（純粋なファイル操作）

**Implementation Details**:
- プラットフォーム判定（macOS/Linux）
- 適切な`sed`コマンドの使用
- Atomic操作（一時ファイル使用）
- エラーハンドリング

#### Component: check-branch.sh
**Responsibility**（責務）: 現在のgitブランチが正しいかチェック  
**Interfaces**（インターフェース）:
```bash
check-branch.sh <FEATURE_ID>
# Exit code 0: 正しいブランチ
# Exit code 1: 誤ったブランチ
```
**Dependencies**（依存関係）: git

**Implementation Details**:
- `git branch --show-current`で現在ブランチ取得
- `feature/{FEATURE_ID}`と比較
- 標準化されたエラーメッセージ

#### Component: rebase-with-develop.sh
**Responsibility**（責務）: developブランチとのrebaseを実行  
**Interfaces**（インターフェース）:
```bash
rebase-with-develop.sh <FEATURE_ID>
# Exit code 0: Rebase成功
# Exit code 1: コンフリクト発生
```
**Dependencies**（依存関係）: git

**Implementation Details**:
- `git fetch origin develop`で最新取得
- `git rebase origin/develop`を実行
- コンフリクト検出とメッセージ
- Abort時の適切なクリーンアップ

#### Component: common-functions.sh
**Responsibility**（責務）: 共通のユーティリティ関数を提供  
**Interfaces**（インターフェース）:
```bash
source scripts/common-functions.sh
log_info "message"
log_error "message"
check_feature_exists <FEATURE_ID>
check_gh_auth
```
**Dependencies**（依存関係）: gh (GitHub CLI)

## Data Design（データ設計）

### Metadata File Structure
`.metadata`ファイルの構造は維持されます：
```
FEATURE_ID=FEATURE-29
RISK_LEVEL=medium
STATUS=planning|implementation|review|completed
CREATED_DATE=2025-12-29
DECISION_STATUS=pending|confirmed|rejected
ISSUE_URL=https://github.com/...
BRANCH=feature/FEATURE-29
LAST_UPDATED=2025-12-29
```

### Data Flow（データフロー）

```
Command Execution
    ↓
Validate Input (check-branch.sh, common-functions.sh)
    ↓
Execute Business Logic
    ↓
Update Metadata (update-metadata.sh)
    ↓
Git Operations (commit, push)
    ↓
Response to User
```

## API Design（API設計）

### Shared Script APIs

#### API 1: update-metadata.sh
**Purpose**（目的）: Metadataの更新を統一的に処理

**Usage**:
```bash
./scripts/update-metadata.sh FEATURE-29 STATUS implementation
```

**Return Codes**:
- `0`: 成功
- `1`: Featureディレクトリが存在しない
- `2`: Metadataファイルが存在しない
- `3`: 書き込み失敗

**Error Messages**:
```
❌ Error: Feature directory not found: sdlc/features/FEATURE-29
   Action: Check FEATURE_ID or run /sdlc-init first
```

#### API 2: check-branch.sh
**Purpose**（目的）: ブランチの妥当性を検証

**Usage**:
```bash
./scripts/check-branch.sh FEATURE-29
```

**Return Codes**:
- `0`: 正しいブランチ
- `1`: 誤ったブランチ

**Error Messages**:
```
❌ Error: Wrong branch. Expected: feature/FEATURE-29, Current: main
   Action: git checkout feature/FEATURE-29
```

#### API 3: common-functions.sh
**Purpose**（目的）: 共通関数を提供

**Functions**:
```bash
# ログ出力
log_info "message"    # 情報ログ
log_error "message"   # エラーログ
log_success "message" # 成功ログ

# バリデーション
check_feature_exists <FEATURE_ID>  # Featureの存在確認
check_gh_auth                       # GitHub認証確認

# プラットフォーム判定
get_os_type  # "macos" または "linux" を返す
```

## Platform Compatibility Design（プラットフォーム互換性設計）

### Strategy: 互換性のあるコマンドを優先

**Approach**:
1. プラットフォーム判定関数を実装
2. OS固有の処理は条件分岐
3. 可能な限り互換性のあるコマンドを使用

**Example**:
```bash
# common-functions.sh
get_os_type() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

# update-metadata.sh
OS_TYPE=$(get_os_type)
if [ "$OS_TYPE" = "macos" ]; then
    sed -i '' "s/^${KEY}=.*/${KEY}=${VALUE}/" "$METADATA_FILE"
else
    sed -i "s/^${KEY}=.*/${KEY}=${VALUE}/" "$METADATA_FILE"
fi
```

## Command Standardization Design（コマンド標準化設計）

### Unified Command Structure

全てのSDLCコマンドは以下の構造に統一：

```markdown
# Command: /sdlc-command-name

Brief description（簡潔な説明）

## Usage（使用方法）
/sdlc-command-name <args>

## Prerequisites（前提条件）
- Requirement 1
- Requirement 2

## Execution（実行内容）
1. Step 1
2. Step 2

## Constraints（制約）
- Constraint 1

## Error Handling（エラー処理）
- Error case 1 → Action
- Error case 2 → Action
```

### Unified Commit Message Format

```
<type>(<FEATURE_ID>): <description>

[optional body]

Related: #<issue-number>
```

**Types**:
- `docs`: ドキュメント生成・更新
- `feat`: 実装
- `fix`: バグ修正
- `refactor`: リファクタリング

## Complexity Reduction Design（複雑性削減設計）

### /sdlc-init の簡素化

**現状**: 44ステップ（単一の長いスクリプト）

**改善後**: 30ステップ以下（責務の分離）

**Strategy**:
1. Issue取得を関数化
2. テンプレート処理を関数化
3. Git操作を共有スクリプト化

```bash
# Before: 全て inline
gh issue view ...
mkdir -p ...
cat > file << EOF
...
EOF
git add ...
git commit ...

# After: 関数とスクリプトの活用
source scripts/common-functions.sh
ISSUE_DATA=$(fetch_issue "$ISSUE_URL")
generate_documents "$FEATURE_ID" "$ISSUE_DATA"
scripts/update-metadata.sh "$FEATURE_ID" STATUS planning
git_commit_and_push "$FEATURE_ID" "docs: Generate SDLC documents"
```

### /sdlc-decision の簡素化

**現状**: Blockerチェックが20+サブステップ

**改善後**: 明確な関数分離

```bash
# Before: 複雑なネストと条件分岐
if [ ... ]; then
    if [ ... ]; then
        # 多層のネスト
    fi
fi

# After: 関数による明確化
check_decision_blockers() {
    local FEATURE_ID=$1
    check_pending_decisions "$FEATURE_ID" || return 1
    check_unresolved_risks "$FEATURE_ID" || return 2
    return 0
}
```

## Error Handling Design（エラー処理設計）

### Standardized Error Messages

全てのエラーメッセージは以下の形式：

```
❌ Error: <簡潔な問題の説明>
   Context: <追加の文脈情報>
   Action: <ユーザーが取るべきアクション>
```

**Example**:
```bash
❌ Error: GitHub authentication failed
   Context: Command 'gh' requires authentication
   Action: Run 'gh auth login' to authenticate
```

### Error Handling Hierarchy

```
1. 入力バリデーション
   - Feature ID の形式チェック
   - 必須引数の存在チェック

2. 環境チェック
   - GitHub認証
   - Git設定

3. 前提条件チェック
   - Feature存在確認
   - ブランチチェック
   - Decision status チェック

4. 実行時エラー
   - Git操作の失敗
   - ファイル操作の失敗
   - 外部コマンドの失敗
```

## Testing Strategy（テスト戦略）

### Unit Tests（ユニットテスト）
- 各共有スクリプトの独立したテスト
- Mock/Stubを使用した環境分離
- 両プラットフォームでのテスト

### Integration Tests（統合テスト）
- コマンドから共有スクリプトの呼び出し
- Metadataの更新を含む一連の流れ
- エラーケースのテスト

### E2E Tests（E2Eテスト）
- 実際のSDLCワークフロー
  - `/sdlc-init` → `/sdlc-decision` → `/sdlc-coding`
- 各フェーズの完全な実行

### Platform Compatibility Tests
- GitHub Actionsでのマトリックステスト
  - macOS latest
  - Ubuntu 20.04
  - Ubuntu 22.04

## Security Considerations（セキュリティの考慮事項）

- [x] Input validation（入力検証）: Feature ID の形式チェック
- [x] Authentication/Authorization（認証・認可）: GitHub認証の事前チェック
- [ ] Data encryption（データ暗号化）: 不要（公開リポジトリ想定）
- [ ] Rate limiting（レート制限）: GitHub API制限の考慮
- [x] Audit logging（監査ログ）: Git履歴が監査ログとして機能

## Performance Considerations（パフォーマンスの考慮事項）

- **Caching strategy**（キャッシュ戦略）: なし（コマンドは一時的な実行）
- **Script optimization**（スクリプト最適化）: 
  - 不必要なサブシェル生成を避ける
  - パイプラインの効率化
- **Parallel execution**（並列実行）: 現時点では非対応（将来的な検討事項）

## Migration Strategy（移行戦略）

### Phase-by-Phase Rollout

**Phase 1**: 共有スクリプト導入
- 共有スクリプトを作成
- 1-2個のコマンドで試験的に使用
- 問題なければ全コマンドに展開

**Phase 2**: 標準化適用
- Commit形式を統一
- コマンド構造を統一
- エラーメッセージを統一

**Phase 3**: 複雑性削減
- `/sdlc-init`をリファクタリング
- `/sdlc-decision`をリファクタリング
- `/sdlc-check`を外部化

**Phase 4**: バリデーション追加
- 全コマンドにバリデーションを追加
- テストカバレッジ確認

### Backward Compatibility

- コマンドのインターフェース（引数、動作）は変更しない
- Metadata形式は維持
- Git構造（ブランチ名など）は維持

## Monitoring & Observability（監視と可観測性）

### Metrics（メトリクス）
- コマンド実行時間（各フェーズ前後で比較）
- コマンド成功率（エラー削減の効果測定）
- 共有スクリプト呼び出し回数

### Logs（ログ）
- 各共有スクリプトで標準化されたログ出力
- `log_info`, `log_error`, `log_success`関数の使用
- デバッグモード（`SDLC_DEBUG=1`）でより詳細なログ

### CI/CD Metrics
- テスト実行時間
- テストカバレッジ
- プラットフォーム別の成功率

## Open Questions（未解決の問題）

- [ ] Decision 1: 共有スクリプトの実装言語（Bash/Go/Python）
- [ ] Decision 2: リファクタリングの実装順序
- [ ] Decision 3: プラットフォーム互換性の実装方法
- [ ] Decision 4: テスト戦略の詳細
- [ ] CI/CDパイプラインの具体的な構成
- [ ] パフォーマンスベンチマークの目標値

## References（参考資料）

- FEATURE-27: リファクタリングの契機となったIssue
- Agent タスク a2a4e6e: 品質レビューレポート
- 既存SDLCコマンド: `.claude/commands/sdlc-*.md`
