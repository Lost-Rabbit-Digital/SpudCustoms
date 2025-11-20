---
description: Add new narrative content (dialogue, choices, timelines) to the game
---

Add new narrative content to the game using Dialogic 2.

**Content Types:**
1. **New Dialogue Timeline**: Create a new `.dtl` file in `assets/narrative/dialogic/timelines/`
2. **Character Addition**: Define new character in Dialogic characters
3. **Choice Tracking**: Add choice to NarrativeManager tracking system
4. **Branching Logic**: Implement conditional dialogue based on player choices

**Implementation Steps:**
1. Create the Dialogic timeline file
2. Add narrative variables to track choices
3. Update NarrativeManager to persist choices
4. Add localization keys for all dialogue
5. Test choice persistence across save/load
6. Verify EventBus integration for narrative events

**Existing Systems:**
- Timeline directory: `godot_project/assets/narrative/dialogic/timelines/`
- Characters: Defined in Dialogic character system
- Choice tracking: `NarrativeManager.record_choice(key, value)`
- Events: `EventBus.emit_narrative_choice_made(choice_data)`

**Critical Requirements:**
- All dialogue must be localized (20 languages supported)
- Choices must be saved via SaveManager
- Use EventBus for narrative state changes
- Follow existing timeline naming: `shift<N>_intro`, `shift<N>_end`

Ask the user what narrative content they want to add if not specified.
