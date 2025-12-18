# Quality Assurance & Testing Strategy

> **Back to:** [GDD Index](README.md) | **Previous:** [Technical Implementation](09_technical.md)

## Overview

Comprehensive testing strategy combining automated unit tests, manual acceptance testing, and continuous integration to ensure code quality and prevent regressions throughout development and post-launch support.

## Testing Framework

**GUT (Godot Unit Test) v9.3.0**
- Lightweight testing framework designed for Godot 4.x
- Installed at: `godot_project/addons/gut/`
- Configuration: `godot_project/.gutconfig.json`
- Test runner: `godot_project/tests/run_tests.gd`

## Test Structure

```
godot_project/tests/
├── unit/                           # Unit tests for individual systems (14 files)
│   ├── test_shift_stats.gd        # ShiftStats bonus calculations
│   ├── test_stats_manager.gd      # Stamp accuracy checking
│   ├── test_law_validator.gd      # Rule validation and date logic
│   ├── test_potato_factory.gd     # Character generation helpers
│   ├── test_event_bus.gd          # EventBus pattern tests
│   ├── test_accessibility_manager.gd
│   ├── test_drag_and_drop_manager.gd
│   ├── test_narrative_manager.gd
│   ├── test_queue_manager.gd
│   ├── test_save_manager.gd
│   ├── test_stamp_system.gd
│   ├── test_tutorial_manager.gd
│   └── test_ui_manager.gd
└── integration/                    # Integration tests (10 files)
    ├── test_achievement_flow.gd
    ├── test_border_runner_flow.gd
    ├── test_document_processing_flow.gd
    ├── test_eventbus_game_flow.gd
    ├── test_eventbus_score_flow.gd
    ├── test_eventbus_strike_flow.gd
    ├── test_narrative_choice_flow.gd
    ├── test_save_load_flow.gd
    └── test_shift_completion_flow.gd
```

## Unit Test Coverage

### Core Systems Tested

#### 1. ShiftStats.gd (`test_shift_stats.gd`)

- **Coverage Areas:**
  - Missile bonus calculation (150 points per perfect hit)
  - Accuracy bonus calculation (200 points per perfect stamp)
  - Speed bonus calculation (100 points per second remaining)
  - Total bonus aggregation
  - Stats reset functionality
- **Test Count:** 15+ test cases
- **Critical for:** Score calculation accuracy, bonus system integrity

#### 2. StatsManager.gd (`test_stats_manager.gd`)

- **Coverage Areas:**
  - Stamp accuracy checking via rectangle intersection
  - Perfect placement detection (10% tolerance)
  - Edge case handling (boundaries, negative coordinates)
  - New stats instance creation
- **Test Count:** 12+ test cases
- **Critical for:** Combo system, player feedback accuracy

#### 3. LawValidator.gd (`test_law_validator.gd`)

- **Coverage Areas:**
  - Age calculation from date of birth
  - Document expiration checking
  - Rule violation detection (condition, gender, country, race)
  - Conflicting rule resolution
  - Rule difficulty classification
- **Test Count:** 25+ test cases
- **Critical for:** Core gameplay mechanics, rule validation accuracy

#### 4. PotatoFactory.gd (`test_potato_factory.gd`)

- **Coverage Areas:**
  - Random attribute generation (name, condition, race, sex, country)
  - Date generation (past and future)
  - Potato info structure validation
  - Asset loading (gibs, explosions)
- **Test Count:** 20+ test cases
- **Critical for:** Character variety, data integrity

## Test Execution

### Local Testing

```bash
# Run all tests via Godot editor
cd godot_project
godot --editor

# Run tests via command line (CI/CD)
godot --headless --script res://tests/run_tests.gd
```

### GitHub Actions Integration

**Workflow:** `.github/workflows/automated_tests.yml`
- **Name:** Automated Tests & Linting
- **Triggers:** Push to `main`, all pull requests
- **Environment:** Ubuntu latest

**Job 1: Static Code Analysis**
- **Tools:** GDScript Toolkit (gdformat, gdlint, gdradon)
- **Steps:**
  1. Checkout code
  2. Setup GDScript Toolkit
  3. Run gdformat --check (code formatting verification)
  4. Run gdlint (linting and style checks)
  5. Run gdradon cc (cyclomatic complexity analysis)
- **Scope:** `godot_project/scripts/` directory

**Job 2: Unit Tests** (runs after static checks pass)
- **Environment:** Godot 4.5.0 headless
- **Steps:**
  1. Checkout code
  2. Setup Godot 4.5.0
  3. Import project (resolve dependencies)
  4. Run GUT test suite
  5. Upload test results as artifacts
- **Failure Handling:** Workflow fails if any check or test fails, blocking merge

**Workflow:** `.github/workflows/static_checks.yml` (Legacy - can be deprecated)
- **Status:** Superseded by integrated workflow above
- **Recommendation:** Remove to avoid duplicate checks

## Manual Testing Requirements

### Pre-Release Test Procedure

**Location:** `project_management/testing/prerelease_test_procedure.md`

**Coverage Areas:**

1. **Core Processing Flow**
   - Megaphone interaction and potato spawning
   - Document dragging and passport inspection
   - Stamp application (approved/rejected)
   - Office shutter and potato movement

2. **Game Systems**
   - Score calculation and display
   - Strike system (difficulty-based limits)
   - Timer functionality
   - Difficulty mode differences

3. **Rule Verification**
   - Rule generation and display
   - Implementation accuracy (5 rule types)
   - Violation detection consistency

4. **Queue Management**
   - Spawn timing and frequency
   - Path following and animations
   - Queue state management

5. **Visual Verification**
   - Texture loading and display
   - Animation playback
   - UI element updates
   - Particle effects

6. **Audio System**
   - Sound effect playback
   - Voiceover integration
   - Audio settings persistence

7. **Performance Testing**
   - Stress tests (maximum potatoes)
   - Memory usage monitoring
   - Frame rate stability

### User Acceptance Testing

**Location:** `project_management/testing/userbob_web_test_guide.txt`
- Web build specific testing procedures
- User-facing bug reporting guidelines

## Test Maintenance Strategy

### When to Write Tests

1. **New Feature Development:** Write unit tests for all new systems before implementation
2. **Bug Fixes:** Add regression tests for fixed bugs to prevent recurrence
3. **Refactoring:** Ensure existing tests pass before and after refactoring
4. **Pre-Release:** Run full manual test suite before Steam deployment

### Test Coverage Goals

- **Target:** 80% coverage for core gameplay systems
- **Priority Systems:**
  - Score calculation and bonuses
  - Rule validation logic
  - State management and persistence
  - Document processing mechanics
  - Character generation and attributes

### Future Test Expansion

**Integration Tests ✓ (Implemented)**
- Full gameplay loop testing
- Save/load functionality
- EventBus score and strike flows
- Narrative choice persistence
- Achievement unlock flows

**Performance Tests (Planned)**
- Frame rate benchmarking across difficulty levels
- Memory leak detection
- Asset loading optimization
- Particle system stress tests

## Continuous Integration Requirements

### Build Requirements

- **Godot Version:** 4.5.0 (locked for consistency)
- **Platform:** Linux (Ubuntu latest for CI/CD)
- **Headless Mode:** Required for automated testing
- **Exit Codes:** Test runner must exit with code 0 (pass) or 1 (fail)

### Merge Requirements

- ✅ **Static Code Analysis:** All checks pass (gdformat, gdlint, gdradon)
- ✅ **Unit Tests:** All automated tests pass (GUT test suite)
- ✅ **No Regressions:** No new orphan nodes warnings
- ✅ **Code Review:** Approval required for team contributions
- ✅ **GitHub Actions:** Both workflow jobs must complete successfully

## Testing Best Practices

### Test Writing Guidelines

1. **Isolation:** Each test should be independent (use `before_each()` and `after_each()`)
2. **Clarity:** Descriptive test names (e.g., `test_get_missile_bonus_with_multiple_perfect_hits`)
3. **Coverage:** Test happy paths, edge cases, and error conditions
4. **Performance:** Keep individual tests fast (<100ms per test)
5. **Determinism:** Avoid flaky tests dependent on timing or randomness

### Test Organization

- **Unit tests:** Test individual functions/methods in isolation
- **Integration tests:** Test interactions between systems
- **Acceptance tests:** Manual testing of user-facing features
- **Regression tests:** Prevent fixed bugs from reoccurring

## Known Testing Limitations

### Systems Not Covered by Automated Tests

1. **Visual/UI Testing:** Requires manual verification
   - Stamp placement visual feedback
   - Animation smoothness
   - Color accuracy
   - Font rendering

2. **Audio Testing:** Requires manual verification
   - Sound effect playback timing
   - Audio mixing levels
   - Voiceover synchronization

3. **Performance Testing:** Requires profiling tools
   - Frame rate under load
   - Memory usage over time
   - Asset loading times

4. **Steam Integration:** Requires manual testing on Steam
   - Leaderboard uploads
   - Achievement unlocks
   - Cloud save synchronization

### Mitigations

- **Manual Test Checklists:** Comprehensive pre-release procedure
- **User Acceptance Testing:** External testers for usability feedback
- **Performance Monitoring:** Periodic profiling sessions
- **Steam Beta Branch:** Test Steam features in `public_test` before release

## Post-Launch Testing Support

### Hotfix Workflow

1. Identify critical bug via user reports
2. Write regression test reproducing the bug
3. Fix bug and verify test passes
4. Run full test suite to prevent new regressions
5. Deploy via Steam patch with patch notes

### Community Feedback Integration

- Monitor Steam forums and GitHub issues for bug reports
- Prioritize bugs affecting core gameplay mechanics
- Add tests for frequently reported issues
- Document fixes in `steam_patch_notes/` directory

---

> **Next:** [Steam Release Requirements](11_steam_release.md)
