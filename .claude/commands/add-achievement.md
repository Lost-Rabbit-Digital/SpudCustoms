---
description: Add a new Steam achievement with tracking logic
---

Add a new Steam achievement to the game.

**Implementation Steps:**

1. **Define Achievement in Steam Partner Portal**:
   - Achievement ID (e.g., "border_defender")
   - Display name
   - Description
   - Icon (upload to Steam)

2. **Add Tracking Logic**:
   - Update `Global.gd` with tracking variables if needed
   - Use EventBus to track achievement-related events
   - Implement check logic in `Global.check_achievements()`

3. **Unlock via SteamManager**:
```gdscript
func check_new_achievement():
    if <condition_met>:
        SteamManager.unlock_achievement("achievement_id")
```

4. **Add to Save System**:
   - Ensure achievement progress persists
   - Update `SaveManager` to save tracking stats

5. **Test**:
   - Test unlock condition triggers correctly
   - Verify Steam API integration works
   - Test offline mode (graceful fallback)
   - Verify achievement appears in Steam overlay

**Achievement Types:**
- **Story-based**: Complete specific shifts or narrative paths
- **Stats-based**: Reach milestones (50 runners stopped, etc.)
- **Skill-based**: Perfect accuracy, speed runs
- **Collection**: Unlock all endings, see all potato types

**Existing Achievements Reference:**
- See `Global.check_achievements()` for implementation patterns
- See `SteamManager.gd` for unlock methods

Ask the user what achievement they want to add if not specified.
