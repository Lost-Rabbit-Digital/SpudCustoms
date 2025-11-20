---
description: Run the GUT test suite and report results
---

Run the GUT (Godot Unit Test) test suite for the project.

**Test Execution:**
```bash
cd godot_project
godot --headless --script res://tests/run_tests.gd
```

**Analysis Required:**
1. Report total tests run, passed, and failed
2. List any failing tests with error messages
3. Calculate test coverage percentage (if available)
4. Identify untested critical systems
5. Suggest priority areas for additional tests

**Test Categories:**
- Unit tests: `tests/unit/test_*.gd`
- Integration tests: `tests/integration/test_*.gd` (if they exist)

**Current Test Coverage:**
- ShiftStats: 15 tests (bonus calculations)
- StatsManager: 12 tests (stamp accuracy)
- LawValidator: 25 tests (rule validation)
- PotatoFactory: 20 tests (character generation)

After running tests, suggest which systems need more test coverage based on the migration guide priorities.
