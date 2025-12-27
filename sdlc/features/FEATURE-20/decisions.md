# Decision Log

## D-001: Use Default Status Field Only

**Status**: PENDING  
**Date**: 2025-12-27  
**Decided By**: TBD

### Context

GitHub Projects provides a default Status field, and we currently also have a custom "SDLC Status" field. This creates confusion and complexity.

### Decision

Use only the default Status field for all project status tracking, and remove the custom "SDLC Status" field.

### Rationale

- Reduces confusion by having a single source of truth
- Simplifies workflow automation
- Easier for new team members to understand
- Follows GitHub's standard conventions
- Reduces maintenance overhead

### Consequences

#### Positive
- Simpler, more intuitive workflow
- Reduced complexity in automation scripts
- Better alignment with GitHub's native features
- Easier onboarding for new contributors

#### Negative
- Need to migrate existing status values
- May need to update documentation and workflows
- Temporary disruption during migration

### Alternatives Considered

1. **Keep both Status fields**
   - Rejected: Continues the confusion problem
   
2. **Use only custom "SDLC Status" field**
   - Rejected: Goes against GitHub's conventions and native tooling

3. **Use default Status field only (SELECTED)**
   - Chosen: Simplest and most maintainable approach

---

## D-002: Status Field Mapping Strategy

**Status**: PENDING  
**Date**: 2025-12-27  
**Decided By**: TBD

### Context

When migrating from "SDLC Status" to the default Status field, we need to define how existing status values should map.

### Decision

Map SDLC Status values to default Status field values as follows:
- Planning → Todo
- Design → In Progress
- Implementation → In Progress
- Testing → In Progress
- Review → In Review
- Done → Done

### Rationale

- Preserves the essential workflow stages
- Aligns with GitHub's standard status values
- Maintains clarity without over-complicating

### Consequences

#### Positive
- Clear migration path
- Maintains workflow continuity
- Compatible with GitHub's native features

#### Negative
- Some granularity is lost (Design, Implementation, Testing all map to "In Progress")
- May need to rely on labels or other fields for detailed status tracking

### Alternatives Considered

1. **Create custom status values in default field**
   - Rejected: Defeats the purpose of using standard conventions
   
2. **Use simpler mapping (everything to Todo/In Progress/Done)**
   - Considered: Might be too simple for tracking purposes

---

## D-003: Workflow Automation Update Strategy

**Status**: PENDING  
**Date**: 2025-12-27  
**Decided By**: TBD

### Context

The `.github/workflows/sync-metadata-to-project.yml` workflow currently updates both Status fields. This needs to be simplified.

### Decision

Update the workflow to:
1. Remove all references to custom "SDLC Status" field
2. Update only the default Status field
3. Use the status mapping defined in D-002

### Rationale

- Simplifies workflow logic
- Reduces API calls
- Eliminates potential sync conflicts between two fields

### Consequences

#### Positive
- Simpler workflow code
- Faster execution
- Fewer potential error points

#### Negative
- Requires workflow testing
- Need to ensure backward compatibility during transition

### Alternatives Considered

1. **Keep dual-field update temporarily**
   - Rejected: Prolongs the complexity problem
   
2. **Immediate switch (SELECTED)**
   - Chosen: Clean break is better for long-term maintenance
