# Risks

**Feature ID**: FEATURE-3  
**Last Updated**: 2025-12-26  
**Overall Risk Level**: LOW

---

## Risk Assessment Summary

| Risk ID | Risk | Level | Status |
|---------|------|-------|--------|
| R001 | `gh` コマンド不在時の処理失敗 | Low | Open |
| R002 | GitHub 認証エラー時のユーザー混乱 | Low | Open |
| R003 | 既存 Label との名前衝突 | Low | Open |

---

## Risk Level Criteria

### Low Risk
**Definition**:
- 既存機能に影響なし
- 追加機能のみ
- ロールバックが容易
- 標準的なコードレビューで十分

**Review Requirements**:
- コードレビューのみ
- 基本的なテストカバレッジ

---

## Detailed Risk Analysis

### Risk R001: `gh` コマンド不在時の処理失敗

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description
ユーザーの環境に `gh` コマンドがインストールされていない場合、Label 初期化処理が実行できない。Issue には警告メッセージと手動コマンドを表示する対応が提案されているが、ユーザーが `gh` コマンドのインストール方法を知らない可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: Label が自動作成されず、後で SDLC コマンド実行時にエラーが発生する
- **System**: システム全体には影響なし（Label 作成処理のみスキップ）
- **Business**: ユーザー体験の悪化、サポート負荷の増加
- **Data**: 影響なし

**Likelihood**: Medium (10-50%) - `gh` コマンドを事前にインストールしていないユーザーは一定数存在する

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component（Label 初期化機能のみ）
- **Recovery Time**: 5-10分（ユーザーが手動で `gh` をインストール）
- **Data Loss Risk**: No

#### Root Cause
`gh` コマンドは外部依存であり、すべてのユーザーが事前にインストールしているとは限らない。

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **明確な警告メッセージを表示**
   - Description: `gh` コマンドが見つからない場合、インストール方法を含む警告メッセージを表示
   - Owner: 実装担当者
   - Due Date: 実装時
   - Status: Planned

2. **README に前提条件を明記**
   - Description: `gh` コマンドが必要であることを README の「前提条件」セクションに明記
   - Owner: 実装担当者
   - Due Date: 実装時
   - Status: Planned

**Residual Risk**: Low - 警告メッセージにより、ユーザーは問題を認識して対応できる

#### Contingency Plan
1. ユーザーが警告メッセージを見逃した場合、後で SDLC コマンド実行時に "label not found" エラーが発生
2. その時点で Label を手動作成するか、`gh` をインストールして `install.sh` を再実行

#### Monitoring
- **Metrics**: エラーログ、サポートチケット数
- **Alerts**: なし
- **Review Frequency**: 月次

---

### Risk R002: GitHub 認証エラー時のユーザー混乱

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description
`gh` コマンドはインストールされているが、`gh auth login` が完了していない場合、Label 作成処理が認証エラーで失敗する。Issue にはエラーをスキップする対応が提案されているが、ユーザーがエラーメッセージを正しく理解できない可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: Label が自動作成されず、認証エラーの意味を理解できない場合、混乱する
- **System**: システム全体には影響なし（Label 作成処理のみスキップ）
- **Business**: ユーザー体験の悪化、サポート負荷の増加
- **Data**: 影響なし

**Likelihood**: Medium (10-50%) - 初めて `gh` を使うユーザーは認証を忘れることがある

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component（Label 初期化機能のみ）
- **Recovery Time**: 5-10分（ユーザーが `gh auth login` を実行）
- **Data Loss Risk**: No

#### Root Cause
GitHub 認証は `gh` コマンドの初回使用時に必要だが、ユーザーがこれを知らない可能性がある。

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **認証エラー時に明確な手順を表示**
   - Description: 認証エラー時に `gh auth login` を実行するよう促すメッセージを表示
   - Owner: 実装担当者
   - Due Date: 実装時
   - Status: Planned

2. **README に認証手順を明記**
   - Description: `gh auth login` が必要であることを README に明記
   - Owner: 実装担当者
   - Due Date: 実装時
   - Status: Planned

**Residual Risk**: Low - 明確なメッセージにより、ユーザーは問題を認識して対応できる

#### Contingency Plan
1. ユーザーが認証エラーを無視した場合、後で SDLC コマンド実行時に "label not found" エラーが発生
2. その時点で認証を完了して `install.sh` を再実行

#### Monitoring
- **Metrics**: エラーログ、サポートチケット数
- **Alerts**: なし
- **Review Frequency**: 月次

---

### Risk R003: 既存 Label との名前衝突

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description
ユーザーのリポジトリに既に同名の Label（例: `feature`, `bug`）が存在する場合、色や説明が異なる可能性がある。Issue では既存 Label をスキップする対応が提案されているが、既存 Label の色や説明が SDLC フレームワークの期待と異なる場合、問題が発生する可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: 既存 Label がスキップされるため、色や説明が期待と異なる
- **System**: SDLC コマンドは Label 名のみを参照するため、機能的には問題なし
- **Business**: 軽微な混乱（色や説明の不一致）
- **Data**: 影響なし

**Likelihood**: Low (<10%) - 同名の Label が存在する可能性は低い

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component（Label の見た目のみ）
- **Recovery Time**: 即座（既存 Label を削除して再実行、または手動で色を変更）
- **Data Loss Risk**: No

#### Root Cause
Label 名は標準的だが、ユーザーが既に同じ名前の Label を使用している可能性がある。

#### Mitigation Strategy

**Approach**: Accept

**Actions**:
（特になし - 既存 Label をスキップする動作は妥当）

**Residual Risk**: Low - 機能的には問題なし、見た目のみの不一致

#### Contingency Plan
1. ユーザーが色や説明の不一致に気づいた場合、既存 Label を削除して `install.sh` を再実行
2. または GitHub UI で手動で色や説明を変更

#### Monitoring
- **Metrics**: なし
- **Alerts**: なし
- **Review Frequency**: なし

---

## Risk Categories

### Technical Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| `gh` コマンド不在 | Low | Open | 警告メッセージ表示 |
| GitHub 認証エラー | Low | Open | 認証手順を表示 |

### Operational Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| 既存 Label との衝突 | Low | Open | 既存 Label をスキップ |

### Security Risks
なし

### Performance Risks
なし

### Data Risks
なし

### Dependency Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| `gh` コマンド依存 | Low | Open | README に明記 |

---

## Risk Matrix

|           | Low Impact | Medium Impact | High Impact |
|-----------|------------|---------------|-------------|
| **High Likelihood** | Medium | High | Critical |
| **Medium Likelihood** | **R001, R002** | Medium | High |
| **Low Likelihood** | **R003** | Low | Medium |

### Current Risks Plotted
- **Critical**: 0
- **High**: 0
- **Medium**: 0
- **Low**: 3 - R001, R002, R003

---

## Notes
- このフェーチャーは既存機能に影響を与えないため、全体的なリスクレベルは Low です
- すべてのリスクは適切な警告メッセージとドキュメントで軽減可能です
- ロールバックは容易（`install.sh` の変更を元に戻すだけ）
