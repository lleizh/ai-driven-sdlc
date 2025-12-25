# Design

**Feature ID**: {FEATURE_ID}  
**Last Updated**: {DATE}  
**Status**: DRAFT | UNDER_REVIEW | APPROVED

## Overview
<!-- 設計の全体像を 2-3 段落で説明 -->

## Architecture

### System Architecture
<!-- システムアーキテクチャ図（必要に応じて） -->
```
[Component A] --> [Component B] --> [Database]
      |
      v
[External Service]
```

### Component Design
<!-- 各コンポーネントの責務と関係 -->

#### Component: {Name}
**Responsibility**: 
**Interfaces**: 
**Dependencies**: 

#### Component: {Name}
**Responsibility**: 
**Interfaces**: 
**Dependencies**: 

## Data Design

### Database Schema Changes
<!-- スキーマ変更がある場合 -->
```sql
CREATE TABLE example (
    id BIGINT PRIMARY KEY,
    field VARCHAR(255),
    created_at TIMESTAMP
);
```

### Migration Strategy
<!-- マイグレーション戦略 -->
1. 
2. 

### Data Flow
<!-- データの流れ -->
```
User Input --> Validation --> Business Logic --> Database --> Response
```

## API Design

### Endpoint 1: {METHOD} {PATH}
**Purpose**: 

**Request**:
```json
{
  "example": "request"
}
```

**Response**:
```json
{
  "example": "response"
}
```

**Business Logic**:
1. 
2. 

## Security Considerations
<!-- セキュリティ上の考慮事項 -->
- [ ] Input validation
- [ ] Authentication/Authorization
- [ ] Data encryption
- [ ] Rate limiting
- [ ] Audit logging

## Error Handling
<!-- エラー処理の方針 -->
| Error Type | Handling Strategy | User Message |
|------------|-------------------|--------------|
| Validation | | |
| Business Logic | | |
| System | | |

## Performance Considerations
<!-- パフォーマンスの考慮事項 -->
- Caching strategy: 
- Database indexes: 
- Query optimization: 
- Async processing: 

## Scalability Considerations
<!-- スケーラビリティの考慮事項 -->
- Horizontal scaling: 
- Load balancing: 
- Resource limits: 

## Monitoring & Observability
<!-- 監視・可観測性の設計 -->

### Metrics
- 
- 

### Logs
- 
- 

### Alerts
- 
- 

## Alternative Designs Considered
<!-- 検討した他の設計案とその理由 -->

### Alternative 1: {Name}
**Pros**: 
**Cons**: 
**Why Rejected**: 

### Alternative 2: {Name}
**Pros**: 
**Cons**: 
**Why Rejected**: 

## Open Questions
<!-- 未解決の問題や要確認事項 -->
- [ ] 
- [ ] 

## References
<!-- 参考資料 -->
- 
- 
