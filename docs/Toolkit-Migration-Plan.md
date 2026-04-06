# ME ACS Support Toolkit Migration Plan

## Goal

Create one support-facing toolkit for the MAG support team without destabilizing the already-working `ME_ACS SQL Patcher`.

The intended end state is:

1. One main repository for support tooling.
2. One main app entry point for the support team.
3. SQL patching kept as a dedicated module rather than rushed into a large rewrite.

## Recommended Structure

Use:

- `1 repository`
- `1 shared solution`
- `2 application projects` at first

That means:

1. `ME ACS Support Tool` stays the hub app.
2. `ME_ACS SQL Patcher` is migrated into this repository as its own project.
3. Shared code is extracted only after both apps are stable in the same repo.

## Why This Approach

This approach protects the current SQL patcher because:

1. The patcher already works well and should not be rewritten just to satisfy repository cleanup.
2. The support tool is already designed around action-first operations and is the natural launcher/hub.
3. A repo-level combine is lower risk than an immediate code-level merge.

## Migration Phases

### Phase 1: Repository Consolidation

Goal:

- Make this repository the new home for the full support toolkit.

Actions:

1. Create a migration branch in this repository.
2. Import the `ME_ACS SQL Patcher` repository into a subfolder such as `external/ME_ACS_SQL_Patcher/`.
3. Keep the original patcher repository untouched during the first migration pass.
4. Add both application projects into one root solution.

Expected result:

- One repo contains both products.
- The working patcher remains buildable with minimal code change.

### Phase 2: Support Tool As The Main Entry Point

Goal:

- Give the support team one place to start.

Actions:

1. Add a `SQL Patcher` action/card in the support tool UI.
2. Let the support tool launch the patcher executable first.
3. Optionally display patcher version, release notes, or patch-library status in the support dashboard.

Expected result:

- Support staff use one toolkit entry point.
- The patcher remains operational as a specialized module.

### Phase 3: Shared Foundations

Goal:

- Reduce duplication after the repo combine is stable.

Candidate shared areas:

1. Logging and run history
2. Common app-data path handling
3. Environment detection
4. Packaging and release helpers
5. Shared design/theme assets where useful

Expected result:

- Cleaner maintenance without forcing an early rewrite.

### Phase 4: Decide On Deeper Integration

Goal:

- Decide whether a single-window experience is actually worth the extra complexity.

Options:

1. Keep the patcher as a launched companion module.
2. Move patcher workflows into shared libraries and host them directly in the support tool UI.

Recommendation:

- Do not choose option 2 until the combined repo and release flow have proven stable.

## Release Strategy During Migration

Until the toolkit migration settles:

1. Keep the SQL patcher release process working as-is.
2. Keep the support tool release process working as-is.
3. Introduce a combined release bundle only after the support tool can reliably launch the migrated patcher.

This keeps rollback simple if the first combined release has issues.

## Documentation Changes

During migration:

1. The SQL patcher repository should clearly say it is planned to move into the support toolkit.
2. This repository should clearly state that it is the destination home for the combined toolkit.
3. Operator instructions should continue pointing to the current stable workflow until the combined release is actually live.

## Practical First Implementation

The safest first implementation is:

1. Import `ME_ACS SQL Patcher` into this repository.
2. Add a root solution containing both projects.
3. Add a `Launch SQL Patcher` action to the support tool.
4. Validate build, smoke test, and release flow.

This gives the team one support-facing toolkit without betting everything on an immediate full merge.
