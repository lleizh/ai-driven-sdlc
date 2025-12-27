# Decision Log

## D-001: Use Default Status Field Only

**Status**: CONFIRMED  
**Date**: 2025-12-27  
**Decided By**: lleizh

### Context

GitHub Projects provides a default Status field, and we currently also have a custom "SDLC Status" field. This creates confusion and complexity.

### Decision

Use only the default Status field for all project status tracking, and remove the custom "SDLC Status" field.

### Chosen Option

Use default Status field only - remove the custom "SDLC Status" field completely and rely on GitHub's native Status field for all status tracking.

### Rejected Options

1. **Keep both Status fields**
   - Rejected: Continues the confusion problem and maintains unnecessary complexity
   
2. **Use only custom "SDLC Status" field**
   - Rejected: Goes against GitHub's conventions and native tooling, makes integration harder

### Rationale

- Reduces confusion by having a single source of truth
- Simplifies workflow automation
- Easier for new team members to understand
- Follows GitHub's standard conventions
- Reduces maintenance overhead
- Better integration with GitHub's native features

### Accepted Risks

- R-001: Status Data Loss During Migration (Low risk, mitigated by backup strategy)
- R-003: User Confusion During Transition (Low risk, mitigated by documentation and communication)

### Non-Negotiables

- Existing Issue/PR status information must be preserved during migration
- Workflow automation must continue to function correctly

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

---

## D-002: Status Field Mapping Strategy

**Status**: CONFIRMED  
**Date**: 2025-12-27  
**Decided By**: lleizh

### Context

When migrating from "SDLC Status" to the default Status field, we need to define how existing status values should map.

### Decision

Configure the default Status field with SDLC status values directly (no mapping needed):
- Planning → Planning
- Design → Design
- Implementation → Implementation
- Testing → Testing
- Review → Review
- Done → Done
- Blocked → Blocked

### Chosen Option

Create a custom "Status" field during install.sh with SDLC status values. This eliminates the need for mapping logic in workflows.

Note: We create a custom field named "Status" rather than modifying GitHub's default Status field, as the default field cannot be customized via API.

### Rejected Options

1. **Create custom status values in default field**
   - Rejected: Defeats the purpose of using standard conventions, adds complexity back
   
2. **Use simpler mapping (everything to Todo/In Progress/Done)**
   - Rejected: Too simple, loses important distinction between work in progress vs review stage

### Rationale

- Preserves all SDLC workflow stages with full granularity
- Creates a custom "Status" field with our SDLC values
- No mapping logic needed in workflows (direct 1:1 correspondence)
- Maintains clarity and simplicity
- All status transitions are explicit and traceable
- Avoids limitations of GitHub's default Status field (cannot be customized)

### Accepted Risks

- Creates a custom field rather than using GitHub's built-in Status field
- New Projects will need to run install.sh to create the Status field
- Team members need to use the custom "Status" field, not the default one

### Non-Negotiables

- Must maintain all SDLC stages (Planning, Design, Implementation, Testing, Review, Done, Blocked)
- Status field must be created during install.sh
- Field name must be "Status" (same as default, for consistency)

### Consequences

#### Positive
- Full granularity maintained (all SDLC stages visible)
- Simple, direct mapping (no translation logic)
- Works seamlessly with GitHub's native Status field
- Easy to understand for all team members

#### Negative
- Requires running install.sh to configure Status field
- Status field options differ from GitHub's defaults

---

## D-003: Workflow Automation Update Strategy

**Status**: CONFIRMED  
**Date**: 2025-12-27  
**Decided By**: lleizh

### Context

The `.github/workflows/sync-metadata-to-project.yml` workflow currently updates both Status fields. This needs to be simplified.

### Decision

Update the workflow to:
1. Remove all references to custom "SDLC Status" field
2. Update only the default Status field
3. Use the status mapping defined in D-002

### Chosen Option

Immediate switch - make a clean break by removing all SDLC Status references in one update and switching to the default Status field only.

### Rejected Options

1. **Keep dual-field update temporarily**
   - Rejected: Prolongs the complexity problem, creates confusion about which field is authoritative, requires maintaining complex logic longer than necessary

### Rationale

- Simplifies workflow logic significantly
- Reduces API calls
- Eliminates potential sync conflicts between two fields
- Clean break is better for long-term maintenance
- Easier to test and validate one approach vs maintaining dual-field logic

### Accepted Risks

- R-002: Workflow Automation Failure (Low risk, mitigated by testing in feature branch and rollback plan)
- Requires thorough testing before merging

### Non-Negotiables

- Must have rollback plan ready before deployment
- Must test workflow changes in feature branch before merging to main
- Workflow must continue to sync .metadata to GitHub Projects correctly

### Consequences

#### Positive
- Simpler workflow code
- Faster execution
- Fewer potential error points
- Easier to maintain going forward

#### Negative
- Requires workflow testing
- Need to ensure backward compatibility during transition
- Brief period of adjustment for team
