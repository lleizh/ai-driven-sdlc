# Risks

**Feature ID**: FEATURE-1  
**Last Updated**: 2025-12-26  
**Overall Risk Level**: LOW

---

## Risk Assessment Summary

| Risk ID | Risk | Level | Status |
|---------|------|-------|--------|
| R001 | 削除されたオプションを使用しているユーザーへの影響 | Low | Open |
| R002 | README.md と install.sh の不整合が再発 | Low | Open |
| R003 | Git merge コンフリクトの可能性 | Low | Open |

---

## Risk Level Criteria

### Low Risk
**Definition**:
- ドキュメントと既存コードの修正のみ
- 新機能追加なし
- 影響範囲が限定的（2ファイルのみ）
- 後方互換性への影響が最小限
- テストが容易

**Review Requirements**:
- Code review only
- Basic test coverage

---

## Detailed Risk Analysis

### Risk R001: 削除されたオプションを使用しているユーザーへの影響

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description

`--minimal` と `--no-templates` オプションを削除することで、これらのオプションを使用しているユーザーがエラーに遭遇する可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: エラーメッセージが表示され、インストールが失敗する
- **System**: システム自体への影響はなし
- **Business**: ユーザー体験が一時的に低下
- **Data**: データへの影響なし

**Likelihood**: Low (<10%)

理由：
- README.md にこれらのオプションが記載されていたため、使用されている可能性は低い
- そもそもこのプロジェクト自体が新しく、ユーザー数が限定的
- オプション削除は「不要な機能」として判断されたもの

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component（install.sh のみ）
- **Recovery Time**: 即座（オプションを削除するだけ）
- **Data Loss Risk**: No

#### Root Cause

ドキュメントと実装の不整合により、使用されていない機能が実装されていた。

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **削除前にエラーメッセージを明確にする**
   - Description: 不明なオプションに対して、有効なオプション一覧を表示
   - Owner: TBD
   - Due Date: 実装時
   - Status: Planned

2. **README.md を先に更新して周知**
   - Description: README.md を先にコミットし、変更を告知
   - Owner: TBD
   - Due Date: 実装時
   - Status: Planned

**Residual Risk**: Very Low

#### Contingency Plan

もし問題が報告された場合：
1. GitHub Issue で問い合わせを受け付ける
2. 使用状況を確認
3. 必要に応じて暫定的に復活させる（非推奨として）

#### Monitoring

- **Metrics**: GitHub Issues での報告数
- **Alerts**: なし（手動監視）
- **Review Frequency**: 実装後1週間

---

### Risk R002: README.md と install.sh の不整合が再発

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description

今回修正しても、将来的に再び不整合が発生する可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: ユーザーが混乱する
- **System**: 影響なし
- **Business**: ドキュメント品質の低下
- **Data**: 影響なし

**Likelihood**: Medium (10-50%)

理由：
- ドキュメントとコードは別々に更新されるため、同期が難しい
- レビュープロセスで見落とされる可能性

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Component
- **Recovery Time**: 数時間（発見後すぐ修正可能）
- **Data Loss Risk**: No

#### Root Cause

ドキュメントとコードの同期を強制するメカニズムがない。

#### Mitigation Strategy

**Approach**: Reduce

**Actions**:
1. **PR テンプレートにチェックリストを追加**
   - Description: install.sh を変更する際は README.md も更新することをチェックリスト化
   - Owner: TBD
   - Due Date: 将来の改善として
   - Status: Future

2. **定期的な一致性チェック**
   - Description: 月次で README.md と実装の一致性を確認
   - Owner: TBD
   - Due Date: 将来の改善として
   - Status: Future

**Residual Risk**: Low

#### Contingency Plan

再発した場合：
1. 同じプロセスで修正
2. 根本原因を分析
3. プロセス改善を検討

#### Monitoring

- **Metrics**: なし
- **Alerts**: なし
- **Review Frequency**: 月次（手動）

---

### Risk R003: Git merge コンフリクトの可能性

**Level**: LOW  
**Status**: OPEN  
**Owner**: TBD  
**Identified Date**: 2025-12-26

#### Description

README.md と install.sh は頻繁に更新されるファイルのため、他のブランチとマージコンフリクトが発生する可能性がある。

#### Impact
**If this risk materializes**:
- **Users**: 影響なし
- **System**: 影響なし
- **Business**: マージ作業に追加時間が必要
- **Data**: 影響なし

**Likelihood**: Low (<10%)

理由：
- 現在、他に進行中のブランチがない
- 変更箇所が限定的

#### Impact Assessment
- **Severity**: Minor
- **Scope**: Development process
- **Recovery Time**: 数分〜数時間
- **Data Loss Risk**: No

#### Root Cause

複数のブランチで同じファイルを編集する通常のGitワークフロー。

#### Mitigation Strategy

**Approach**: Accept

**Actions**:
通常のGit マージ手順で対応。特別な対策は不要。

**Residual Risk**: Very Low

#### Contingency Plan

コンフリクトが発生した場合：
1. 手動でマージ
2. テストで動作確認
3. レビューで承認

#### Monitoring

- **Metrics**: なし
- **Alerts**: なし
- **Review Frequency**: なし

---

## Risk Categories

### Technical Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| R001: 削除されたオプションを使用しているユーザーへの影響 | Low | Open | エラーメッセージの改善 |
| R003: Git merge コンフリクト | Low | Open | Accept（通常の手順で対応） |

### Operational Risks
| Risk | Level | Status | Mitigation |
|------|-------|--------|------------|
| R002: 不整合の再発 | Low | Open | 定期的な一致性チェック（将来） |

---

## Notes

この Feature は Low Risk であり、すべてのリスクも Low レベル。
特別な対策や承認プロセスは不要。
通常のコードレビューとテストで十分。
