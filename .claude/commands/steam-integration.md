---
description: Add or debug Steam integration features (leaderboards, achievements, cloud saves)
---

Implement or debug Steam integration features using GodotSteam.

**Steam Features:**

1. **Leaderboards**:
   - Create leaderboard in Steam Partner
   - Submit scores via `SteamManager.submit_leaderboard_score()`
   - Fetch scores for display
   - Handle timeout and offline scenarios

2. **Achievements**:
   - Define in Steam Partner portal
   - Track progress in Global.gd
   - Unlock via `SteamManager.unlock_achievement()`
   - Test offline graceful degradation

3. **Cloud Saves**:
   - Upload via `SteamManager.upload_cloud_saves()`
   - Verify file paths in Steam settings
   - Test sync across devices
   - Handle conflicts

4. **Stats Tracking**:
   - Define stats in Steam Partner
   - Update via `SteamManager.update_steam_stats()`
   - Use for achievement triggers

**Known Issues** (from project_tasks.md):
- Leaderboards not loading in public_test build
- Steam Cloud Save path verification needed
- Timeout handling for leaderboard submission

**Testing Requirements:**
- Test with Steam running
- Test offline mode (graceful fallbacks)
- Test Steam overlay integration
- Verify all API calls check `Steam.isSteamRunning()`

**Reference:**
- Implementation: `godot_project/assets/autoload/SteamManager.gd`
- Usage examples: `ShiftSummaryScreen.gd`, `Global.gd`

Ask the user which Steam feature they want to implement/debug if not specified.
