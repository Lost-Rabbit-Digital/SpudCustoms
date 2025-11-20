---
description: Create integration tests for critical user flows
---

Create integration tests for critical user flows that span multiple systems.

**Critical User Flows to Test:**
1. **Document Processing Flow**: Queue → Inspection → Stamp → Approval/Rejection
2. **Border Runner Flow**: Spawn → Detection → Missile Launch → Hit/Miss → Score Update
3. **Shift Completion Flow**: Quota Check → Summary Screen → Leaderboard Submission → Save
4. **Narrative Choice Flow**: Dialogue → Choice → State Update → Save → Load Verification
5. **Achievement Flow**: Action → Stat Tracking → Achievement Check → Steam Unlock

**Requirements:**
- Test cross-system interactions
- Verify EventBus event chains work correctly
- Test state persistence across save/load
- Verify UI updates reflect backend state changes
- Test error recovery and edge cases
- Mock Steam API calls for offline testing

**Location:** `godot_project/tests/integration/test_<flow_name>.gd`

Ask the user which flow they want to test if not specified.
