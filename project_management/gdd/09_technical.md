# Technical Implementation

> **Back to:** [GDD Index](README.md) | **Previous:** [Audio Design](08_audio_design.md)

## Core Requirements

- Godot 4 engine
- Steam integration
- **Steam Cloud Save**: Verification needed for correct path configuration
- Leaderboard system (per shift, per difficulty, score attack mode)

## EventBus Architecture ✓ (Implemented)

The game uses a centralized **publish-subscribe event system** for decoupled communication between game systems.

**Location:** `scripts/autoload/EventBus.gd`

### Signal Categories (50+ signals across 14 categories)

| Category | Example Signals |
|----------|-----------------|
| Score & Game State | `score_add_requested`, `score_changed`, `high_score_achieved` |
| Strike & Penalty | `strike_add_requested`, `strike_changed`, `max_strikes_reached` |
| Game Flow | `shift_advance_requested`, `quota_updated`, `game_over_triggered` |
| Gameplay Actions | `runner_escaped`, `runner_stopped`, `missile_launched` |
| Document Processing | `potato_approved`, `potato_rejected`, `stamp_applied` |
| Narrative & Dialogue | `narrative_choice_made`, `dialogue_started`, `story_state_changed` |
| UI & Feedback | `alert_red_requested`, `screen_shake_requested` |
| Minigames | `minigame_started`, `minigame_completed`, `minigame_bonus_requested` |
| Save/Load | `save_game_requested`, `game_saved`, `game_loaded` |
| Analytics | `analytics_event`, `session_started` |
| Achievements | `achievement_unlocked`, `achievement_check_requested` |
| Accessibility | `accessibility_settings_changed`, `tts_speak_requested` |
| Tutorial | `tutorial_step_advanced`, `tutorial_completed` |
| Tension & Game Feel | `tension_level_changed`, `critical_state_entered`, `perfect_celebration_requested` |

### Pattern Usage

```gdscript
# Emitting events (request-style)
EventBus.request_score_add(100, "runner_stopped", {"runner_type": "potato"})

# Subscribing to events (listener-style)
func _ready():
    EventBus.score_changed.connect(_on_score_changed)
```

### Benefits

- **Decoupling**: Systems don't directly reference each other
- **Testable**: Mock EventBus signals for unit testing
- **Extensible**: New systems subscribe to existing events
- **Auditable**: All state changes flow through events with metadata

## Key Classes and Systems

```gdscript
# Core game management
class_name GameManager
var difficulty_level: String
var game_mode: String
var current_chapter: int

# Story system
class_name StoryManager
var current_arc: Dictionary
var player_choices: Array
var reputation: Dictionary

# Narrative tracking
class_name NarrativeManager
# CRITICAL: Ensure choice tracking properly saves/loads
var tracked_choices: Dictionary
var ending_criteria: Dictionary

# Potato processing
class_name ProcessingManager
var processing_time: float
var current_rules: Array
var validation_system: ValidationSystem

# Save system
class_name SaveManager
# Must include: narrative choices, customization, high scores
var player_progress: Dictionary
var narrative_state: Dictionary
var customization_data: Dictionary
```

## Performance Optimization Needs

- **Footprint System**: Implement sprite pooling (currently creates/destroys)
- **Particle Systems**: Add cleanup plan for dynamically created particles
- **Z-Index Management**: Multiple rendering order issues documented

## Critical Debug Controls

### Development Efficiency Tools

Debug controls enable rapid testing and iteration during development. All debug features must be disabled in production builds.

### Core Debug Keybinds

- **F1** - Toggle debug overlay (FPS, memory usage, active nodes)
- **F2** - Skip current shift (instant win for testing progression)
- **F3** - Force shift failure (test fail states and retry flow)
- **F4** - Spawn test potato (bypasses queue timing)
- **F5** - Toggle god mode (unlimited strikes, infinite time)
- **F6** - Unlock all potato types (test visual variety)
- **F7** - Toggle free camera (inspect scene details)
- **F8** - Reload current scene (quick iteration on changes)
- **F9** - Toggle hitbox visualization (collision debugging)
- **F10** - Force runner spawn (test missile defense)
- **F11** - Fullscreen toggle (player-accessible)
- **F12** - Screenshot (player-accessible)

### Console Commands (Debug Build Only)

```gdscript
# Shift progression
/skip_to_shift <number>     # Jump to specific shift
/reset_narrative            # Clear all story choices
/unlock_endings             # Enable all ending branches

# Scoring and stats
/set_score <amount>         # Override current score
/add_perfect_stamps <count> # Test combo bonuses
/reset_leaderboards         # Clear local leaderboard cache

# Potato spawning
/spawn_runner               # Force border runner
/spawn_sapper               # Force sapper variant
/spawn_vip                  # Force VIP potato
/spawn_invalid              # Force invalid documents

# Rule testing
/list_active_rules          # Print current shift rules
/add_rule <rule_id>         # Add specific rule to shift
/clear_rules                # Remove all rules (auto-approve mode)

# Performance testing
/stress_test <potato_count> # Spawn many potatoes
/profile_start              # Begin performance profiling
/profile_stop               # End profiling and dump results
/clear_pooled_objects       # Force cleanup of object pools

# Audio/visual debugging
/mute_sfx                   # Toggle sound effects
/mute_music                 # Toggle music
/show_z_indices             # Render z-index labels on nodes
/highlight_clickable        # Show all interactive areas

# Save/load testing
/force_save                 # Immediate save
/corrupt_save               # Test save corruption handling
/delete_save                # Clear all save data
/export_save                # Dump save JSON to file
```

### Debug Overlay Information

- Frame rate (current, average, minimum)
- Memory usage (current, peak)
- Active potato count
- Active particle emitters
- Current shift timer
- Active rules count
- Narrative variables state
- Steam connection status

### Build Configuration

```gdscript
# project.godot settings
[debug]
enabled = true              # Debug mode active
show_fps = true             # Display FPS counter
verbose_logging = true      # Extended console output
allow_remote_debug = true   # Godot editor debugging

[release]
enabled = false             # All debug features disabled
strip_debug_symbols = true  # Reduce build size
optimize_for_size = true    # Minimize executable size
```

### Testing Workflows

#### Rapid Narrative Testing

1. Use `/skip_to_shift 9` to jump near endings
2. Use `/reset_narrative` to test different choice branches
3. Use `/unlock_endings` to verify all ending art/dialogue

#### Performance Testing

1. Use `/stress_test 50` to spawn maximum potatoes
2. Enable F1 overlay to monitor frame rate
3. Use `/profile_start` and `/profile_stop` for detailed metrics
4. Use `/clear_pooled_objects` to test cleanup systems

#### Rule Validation Testing

1. Use `/list_active_rules` to see current rules
2. Use `/spawn_invalid` to force rule violations
3. Test strike system with intentional failures
4. Use `/clear_rules` to test UI without rule complexity

### Prohibited in Release Builds

- All F-key debug shortcuts (except F11/F12 player features)
- Console command system entirely removed
- Debug overlay system disabled
- Verbose logging disabled
- God mode functionality removed
- Skip/cheat functions removed

### Debug Build Distribution

- Internal testing only
- Never distribute to press or players
- Clearly labeled "DEBUG BUILD" in main menu
- Auto-expiration after 30 days (build date check)
- Watermark on screenshots/recordings

---

> **Next:** [Quality Assurance & Testing](10_testing_qa.md)
