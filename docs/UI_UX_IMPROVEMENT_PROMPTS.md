# Spud Customs UI/UX Improvement Prompts

> Generated from UI/UX analysis session - December 2025
>
> These are self-contained prompts that can be used to implement each fix independently.

---

## Table of Contents

1. [Fix Reset Button Staying Disabled](#prompt-1-fix-reset-button-staying-disabled)
2. [Fix Green Flash on Strike Decrease](#prompt-2-fix-green-flash-on-strike-decrease)
3. [Add Continue/Back Buttons to Tutorial](#prompt-3-add-continueback-buttons-to-tutorial)
4. [Improve Tutorial Wording](#prompt-4-improve-tutorial-wording)
5. [Highlight Specific Stamps in Tutorial](#prompt-5-highlight-specific-stamps-in-tutorial)
6. [Investigate Passport Z-Index at Missile Area](#prompt-6-investigate-passport-z-index-at-missile-area)
7. [Prepare Minigame Accessibility Sprites](#prompt-7-prepare-minigame-accessibility-sprites)

---

## Prompt 1: Fix Reset Button Staying Disabled

**Priority:** High | **Effort:** Small

```
Fix the "Reset Game Data" button in the options menu that stays disabled after confirming a reset.

**Problem Location:** `godot_project/scenes/menus/options_menu/game/reset_game_control/reset_game_control.gd`

**Current Bug:** In `_on_ConfirmResetDialog_confirmed()`, the button is never re-enabled after the reset completes. The button gets disabled in `_on_ResetButton_pressed()` but only `_on_confirm_reset_dialog_canceled()` re-enables it.

**Required Fix:**
1. Re-enable the button after reset confirmation
2. Add visual feedback to confirm the reset succeeded (e.g., temporarily change button text to "Reset Complete!" for 2 seconds)

**Files to modify:**
- `godot_project/scenes/menus/options_menu/game/reset_game_control/reset_game_control.gd`

**Translation keys to add (if showing success message):**
- Add `reset_game_success` key to `translations/menus_en.csv` and other locale files

**Testing:**
1. Open Options > Game
2. Click Reset Game Data
3. Confirm the reset
4. Verify button is clickable again
5. Verify success feedback appears briefly
```

---

## Prompt 2: Fix Green Flash on Strike Decrease

**Priority:** High | **Effort:** Small

```
Fix the confusing green flash on the Strikes label when strikes decrease (e.g., after a perfect missile hit on a runner).

**Problem Location:** `godot_project/scenes/game_scene/mainGame.gd` in the `update_strikes_display()` function around line 2163-2179.

**Current Behavior:** When strikes decrease (which is a reward), the strike label briefly flashes green. This is confusing because:
- Players associate strikes with bad things
- Green text on a "Strikes" counter looks like a bug

**Required Changes:**

**Part A - Remove green flash, keep bounce animation only:**
In `update_strikes_display()`, modify the "strikes decreased" branch to NOT change the color:

```gdscript
else:
    # Strikes decreased - positive bounce animation only
    tween.tween_property(strikes_label, "scale", Vector2(1.2, 1.2), 0.1)
    tween.tween_property(strikes_label, "scale", Vector2(1.0, 1.0), 0.2) \
        .set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
    # Remove the green color tween - keep strike color neutral/red
```

**Part B - Add separate "Strike Forgiven" popup:**
When a strike is removed via runner stop, show a brief floating "+1 Strike Forgiven!" message near the Strikes label but NOT changing the label itself.

1. In `mainGame.gd`, add a new function `show_strike_forgiven_popup()`
2. Call it when receiving `EventBus.strike_removed` signal
3. Create a temporary Label that floats up and fades out
4. Use a positive color (gold/yellow) for the popup, distinct from the red Strikes label

**Files to modify:**
- `godot_project/scenes/game_scene/mainGame.gd`

**Translation keys to add:**
- `alert_strike_forgiven` = "+1 Strike Forgiven!"

**Testing:**
1. Start a shift with at least 1 strike
2. Successfully stop a runner with a missile
3. Verify the Strikes label does NOT flash green
4. Verify a separate "+1 Strike Forgiven!" popup appears briefly
```

---

## Prompt 3: Add Continue/Back Buttons to Tutorial

**Priority:** Medium | **Effort:** Medium

```
Replace the auto-advancing tutorial system with player-controlled Continue and Back buttons.

**Problem Location:** `godot_project/scripts/autoload/TutorialManager.gd`

**Current Behavior:**
- Tutorial steps auto-advance after a set duration (5-10 seconds)
- No way to go back and re-read previous steps
- Players may miss important information if they read slowly

**Required Changes:**

1. **Modify tutorial panel UI** (`_create_tutorial_ui()` around line 496):
   - Add "Continue" button (always visible for non-action steps)
   - Add "Back" button (visible when step > 0)
   - Keep "Skip" and "Skip All" buttons

2. **Modify step progression logic:**
   - Remove timer-based auto-advance for text steps
   - Keep action-based waiting (e.g., "wait for lever_pulled")
   - Add step history tracking for back navigation:
     ```gdscript
     var step_history: Array[int] = []  # Track visited steps for back navigation
     ```

3. **Add navigation functions:**
   ```gdscript
   func _go_to_previous_step():
       if current_step > 0:
           current_step -= 1
           _show_current_step()

   func _on_continue_pressed():
       if waiting_for_click or not waiting_for_action:
           _advance_step()
   ```

4. **Update button visibility logic:**
   - Back button: visible when `current_step > 0`
   - Continue button: visible when NOT `waiting_for_action`
   - Continue hint text: show "Complete the action above" when waiting for action

5. **Keep existing behavior for action-based steps:**
   - Steps with `wait_for_action` still require the action
   - But add a fallback timer (30+ seconds) with "Having trouble? Click to skip" option

**Files to modify:**
- `godot_project/scripts/autoload/TutorialManager.gd`

**Translation keys to add:**
- `tutorial_continue` = "Continue"
- `tutorial_back` = "Back"
- `tutorial_action_required` = "Complete the action above to continue"
- `tutorial_skip_action` = "Having trouble? Click here to skip"

**Testing:**
1. Start a new game with tutorial
2. Verify Continue button appears on text steps
3. Verify Back button works to revisit previous steps
4. Verify action-required steps still wait for the action
5. Verify Skip/Skip All still work
```

---

## Prompt 4: Improve Tutorial Wording

**Priority:** Medium | **Effort:** Small

```
Improve tutorial text to be clearer, shorter, and more action-focused.

**Location:** `godot_project/translations/menus_en.csv` (and corresponding locale files)

**Current Issues:**
- Text is too long for comfortable reading
- Technical language may confuse new players
- Missing context on WHY actions matter

**Required Changes:**

Update these translation keys in `menus_en.csv`:

1. `tutorial_welcome_step1`:
   - Current: Long welcome message
   - New: "[center][b]Welcome to Spud Customs![/b][/center]\n\nYou're a border officer. Your job: check documents and decide who gets in.\n\n[color=yellow]Let's learn the basics![/color]"

2. `tutorial_gate_control_step1`:
   - Current: Long explanation about lever
   - New: "[center][b]Open Your Booth[/b][/center]\n\nPull the lever to raise the shutter and start your shift!\n\n[color=yellow]{interact} the lever now.[/color]"

3. `tutorial_gate_control_step2`:
   - Current: 5-second explanation
   - New: "[center][b]Booth Open![/b][/center]\n\nGreat! Your booth is now open for business."

4. `tutorial_megaphone_call_step1`:
   - Current: "Use the megaphone to call the next potato..."
   - New: "[center][b]Call the Next Potato[/b][/center]\n\nUse the megaphone to summon a potato from the queue.\n\n[color=yellow]{interact} the megaphone![/color]"

5. `tutorial_document_inspection_step1`:
   - Current: Long paragraph about passport handling
   - New: "[center][b]Inspect Documents[/b][/center]\n\nThe potato handed you their passport. Drag it to your desk to look closer.\n\n[color=yellow]{drag} the passport to your desk.[/color]"

6. `tutorial_document_inspection_step2`:
   - Current: Waiting for passport open
   - New: "[center][b]Open the Passport[/b][/center]\n\n{interact} the passport to open it and see their details.\n\n[color=yellow]{interact} to open.[/color]"

7. `tutorial_rules_checking_step1`:
   - Current: Very long rules explanation
   - New: "[center][b]Check the Rules[/b][/center]\n\nLook at the rules pamphlet on the right. It tells you who to [color=green]APPROVE[/color] or [color=red]REJECT[/color].\n\n[color=red]Expired documents = REJECT![/color]"

8. `tutorial_stamp_usage_step1`:
   - Current: "See the stamp bar at the top..."
   - New: "[center][b]Open the Stamp Bar[/b][/center]\n\n{interact} the handle at the top to reveal your stamps.\n\n[color=yellow]{interact} to open stamps.[/color]"

9. `tutorial_stamp_usage_step2`:
   - Current: Long positioning explanation
   - New: "[center][b]Position the Passport[/b][/center]\n\n{drag} the passport under the stamps. A guide will show you where.\n\n[color=green]Green stamp = APPROVE[/color] | [color=red]Red stamp = REJECT[/color]"

10. `tutorial_stamp_usage_step3`:
    - Current: "Apply the Stamp!"
    - New: "[center][b]Stamp It![/b][/center]\n\n{interact} the correct stamp to mark your decision.\n\n[color=yellow]Choose wisely![/color]"

11. `tutorial_stamp_usage_step4`:
    - Current: "Return the Documents"
    - New: "[center][b]Return the Passport[/b][/center]\n\n{drag} the stamped passport back to the potato.\n\n[color=yellow]Give it back to complete processing.[/color]"

12. `tutorial_strikes_and_quota_step1`:
    - Keep similar but shorten
    - New: "[center][b]Meet Your Quota[/b][/center]\n\nThe [color=yellow]Quota[/color] shows how many potatoes you must process correctly.\n\nMeet your quota to complete the shift!"

13. `tutorial_strikes_and_quota_step2`:
    - Current: Long strike explanation
    - New: "[center][b]Avoid Strikes![/b][/center]\n\n[color=red]Strikes[/color] = mistakes. Too many strikes = game over!\n\nBe careful with your decisions."

14. `tutorial_strikes_and_quota_step3`:
    - Current: Training complete message
    - New: "[center][b]Training Complete![/b][/center]\n\nYou know the basics! Process the remaining potatoes to finish your training.\n\n[color=green]Good luck, Officer![/color]"

**Files to modify:**
- `godot_project/translations/menus_en.csv`
- All other locale files in `godot_project/translations/menus_*.csv` (translate accordingly)

**Testing:**
1. Start new game with tutorial enabled
2. Read through all tutorial steps
3. Verify text is readable within reasonable time
4. Verify instructions are clear and actionable
```

---

## Prompt 5: Highlight Specific Stamps in Tutorial

**Priority:** Medium | **Effort:** Small

```
Modify the stamp tutorial to highlight the individual Approve/Reject stamp buttons instead of the entire StampBarController.

**Problem Location:** `godot_project/scripts/autoload/TutorialManager.gd` and `godot_project/scenes/game_scene/mainGame.tscn`

**Current Behavior:**
- Tutorial step `tutorial_stamp_usage_step3` targets "StampBarController"
- This highlights the entire stamp bar, not the specific stamp buttons

**Required Changes:**

1. **Ensure stamp buttons have unique names** in `mainGame.tscn`:
   - The approval button should be accessible as "ApprovalButton" (already has unique name `%ApprovalButton`)
   - The rejection button should be accessible as "RejectionButton" (already has unique name `%RejectionButton`)

2. **Update TutorialManager.gd** - modify the TUTORIALS constant:
   ```gdscript
   "stamp_usage": {
       "name_key": "tutorial_stamp_usage_name",
       "steps": [
           # ... steps 1-2 unchanged ...
           {
               "text_key": "tutorial_stamp_usage_step3",
               "target": ["ApprovalButton", "RejectionButton"],  # Highlight BOTH stamps
               "highlight": true,
               "wait_for_action": "stamp_applied",
               "pause_game": false
           },
           # ... steps 4-5 unchanged ...
       ],
       # ...
   }
   ```

3. **Modify `_highlight_target()` to support multiple targets**:
   ```gdscript
   func _highlight_target(target_name):
       # Support both single target and array of targets
       var targets = target_name if target_name is Array else [target_name]

       for name in targets:
           var target_node = _find_target_node(name)
           if target_node:
               _apply_highlight_shader(target_node)
           else:
               push_warning("[TutorialManager] Could not find target: " + name)
   ```

4. **Update `_find_target_node()` to search inside StampBarController**:
   Add to the common_paths array:
   ```gdscript
   "Gameplay/InteractiveElements/StampBarController/StampBar/Background/%s" % target_name,
   ```

**Files to modify:**
- `godot_project/scripts/autoload/TutorialManager.gd`

**Testing:**
1. Start new game with tutorial
2. Progress to the "Apply the Stamp!" step
3. Verify BOTH stamp buttons are highlighted with the sweep shader
4. Verify other tutorial highlights still work
```

---

## Prompt 6: Investigate Passport Z-Index at Missile Area

**Priority:** Low | **Effort:** Medium

```
Investigate and fix the passport getting clipped/cut off when it overlaps with the missile/runner area above the desk.

**Problem Description:**
When dragging the passport near the top of the screen (where the runner/missile action happens), part of the passport gets visually cut off.

**Investigation Steps:**

1. **Check z-index constants** in `godot_project/scripts/autoload/ConstantZIndexes.gd`:
   - Document current z-index values for all layers
   - Identify the z-index of the missile/runner area

2. **Check mainGame.tscn scene hierarchy:**
   - Find the node that contains the runner area (likely `BorderRunnerSystem` or similar)
   - Check if it has a clip children property or uses a SubViewport

3. **Check passport dragging z-index:**
   - In `godot_project/scripts/systems/drag_and_drop/` find where dragged items get their z-index
   - Verify the passport z-index is elevated when being dragged

4. **Check for any clipping nodes:**
   - Look for `SubViewport`, `SubViewportContainer`, or `clip_children` properties in the scene hierarchy
   - The runner area may have a container that clips its contents

**Likely Culprits:**
- The runner/missile area may use a SubViewport or Control with `clip_children = true`
- The passport's z-index when dragged may not be high enough
- A visual layer boundary at a fixed Y position

**Files to investigate:**
- `godot_project/scripts/autoload/ConstantZIndexes.gd`
- `godot_project/scenes/game_scene/mainGame.tscn`
- `godot_project/scripts/systems/drag_and_drop/DragAndDropManager.gd`
- `godot_project/scripts/systems/BorderRunnerSystem.gd`

**Potential Fixes:**
1. Increase dragged item z-index to be above all gameplay layers
2. Remove clip_children from problematic containers
3. Render passport on a higher CanvasLayer when dragged
4. Add a mask/shader to properly blend at the boundary

**Testing:**
1. Drag passport around the entire screen
2. Verify it renders correctly when overlapping runner area
3. Verify missile animations still render correctly
4. Verify no visual glitches at layer boundaries
```

---

## Prompt 7: Prepare Minigame Accessibility Sprites

**Priority:** Medium | **Effort:** Medium

```
Prepare the Border Chase minigame to use distinct sprites instead of color-coded boxes, and integrate with AccessibilityManager colorblind palettes.

**Problem Location:** `godot_project/scenes/minigames/games/border_chase/border_chase.gd`

**Current Behavior:**
- Contraband items: Red box with symbols (!,X,?,*)
- Safe items: Green box with "OK" text
- Color is the primary differentiator (accessibility issue)

**Required Changes:**

1. **Create/prepare sprite assets** (to be done separately):
   - `res://assets/minigames/textures/contraband_item.png` - Use distinct SHAPE (triangle, diamond, warning sign)
   - `res://assets/minigames/textures/safe_item.png` - Use distinct SHAPE (circle, checkmark, thumbs up)
   - Both should be clearly different even in grayscale

2. **Modify `_create_item_visual()` in border_chase.gd:**
   ```gdscript
   func _create_item_visual(is_contraband: bool) -> Node2D:
       var container = Node2D.new()
       var sprite = Sprite2D.new()

       if is_contraband:
           sprite.texture = preload("res://assets/minigames/textures/contraband_item.png")
       else:
           sprite.texture = preload("res://assets/minigames/textures/safe_item.png")

       # Apply colorblind-friendly colors if accessibility mode is active
       if AccessibilityManager:
           var mode = AccessibilityManager.current_colorblind_mode
           if mode != AccessibilityManager.ColorblindMode.NONE:
               if is_contraband:
                   sprite.modulate = AccessibilityManager.get_rejection_color()
               else:
                   sprite.modulate = AccessibilityManager.get_approval_color()
           else:
               # Default colors (can still use red/green but shape is primary differentiator)
               sprite.modulate = Color(0.8, 0.2, 0.2) if is_contraband else Color(0.2, 0.6, 0.2)

       container.add_child(sprite)
       return container
   ```

3. **Update timer color warning** (also in border_chase.gd, line 234-237):
   ```gdscript
   func _update_timer_display() -> void:
       # ... existing code ...

       # Use shape/animation instead of just color for low time warning
       if _time_remaining <= 3.0:
           timer_label.add_theme_color_override("font_color", Color.ORANGE)
           # Add pulsing animation for visibility
           if not timer_label.has_meta("pulsing"):
               timer_label.set_meta("pulsing", true)
               _start_timer_pulse()
       elif _time_remaining <= 1.0:
           timer_label.add_theme_color_override("font_color", Color.RED)
   ```

4. **Add similar changes to other minigames** that use color-coded indicators.

**Files to modify:**
- `godot_project/scenes/minigames/games/border_chase/border_chase.gd`
- Create sprite assets (separate task)

**Sprite Design Guidelines:**
- Contraband: Angular/sharp shapes (triangle, X, warning symbol), warm colors
- Safe items: Rounded shapes (circle, checkmark), cool colors
- Both should be distinguishable by SHAPE alone (test in grayscale)
- Keep symbols (!,?,OK) as secondary indicators

**Testing:**
1. Enable each colorblind mode in AccessibilityManager
2. Play Border Chase minigame
3. Verify items are distinguishable by shape
4. Verify correct colors are applied for each colorblind mode
5. Test in grayscale filter to ensure shape differentiation works
```

---

## Summary Table

| # | Issue | Priority | Effort | Files |
|---|-------|----------|--------|-------|
| 1 | Reset button stays disabled | High | Small | `reset_game_control.gd` |
| 2 | Green flash on strike decrease | High | Small | `mainGame.gd` |
| 3 | Tutorial continue/back buttons | Medium | Medium | `TutorialManager.gd` |
| 4 | Tutorial wording improvements | Medium | Small | `menus_en.csv` + locales |
| 5 | Stamp tutorial highlighting | Medium | Small | `TutorialManager.gd` |
| 6 | Passport z-index investigation | Low | Medium | Multiple files |
| 7 | Minigame accessibility sprites | Medium | Medium | `border_chase.gd` + assets |

---

## Additional Notes

### Help Menu Gaps Identified
The help menu (`scenes/menus/help_menu/`) is fairly comprehensive but could add:
- Keyboard/controller shortcuts reference
- Accessibility settings explanation
- Missile/runner shooting mechanic details

### Level Select Debug Prints
Remove debug prints from `scenes/menus/level_select_menu/level_select_menu.gd` at lines 47, 275-276, 292-303.

### Perfect Stamp Detection Consistency
There are two different perfect stamp check methods:
- `StampableComponent.is_perfect_stamp_position()` - uses top-center 1/3 area
- `StatsManager.check_stamp_accuracy()` - uses visa_rect based calculation

Consider consolidating to one method for consistency.
