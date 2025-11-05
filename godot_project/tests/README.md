# Spud Customs - Test Suite

This directory contains automated tests for the Spud Customs game using the GUT (Godot Unit Test) framework.

## Directory Structure

```
tests/
├── README.md              # This file
├── run_tests.gd          # CI/CD test runner script
├── unit/                 # Unit tests for individual systems
│   ├── test_shift_stats.gd
│   ├── test_stats_manager.gd
│   ├── test_law_validator.gd
│   └── test_potato_factory.gd
└── integration/          # Integration tests (future)
```

## Running Tests

### Via Godot Editor (Recommended for Development)

1. Open the project in Godot Editor
2. Look for the **GUT** panel at the bottom of the editor
3. Click **"Run All"** to execute all tests
4. Review results in the GUT panel

### Via Command Line (CI/CD)

```bash
cd godot_project
godot --headless --script res://tests/run_tests.gd
```

This will:
- Run all tests in `tests/unit/` and `tests/integration/`
- Exit with code 0 if all tests pass
- Exit with code 1 if any tests fail

### Run Specific Test File

In the Godot Editor GUT panel:
1. Expand the test directory tree
2. Select a specific test file
3. Click **"Run Selected"**

## Writing New Tests

### Test File Naming Convention

- Unit tests: `test_<system_name>.gd`
- Integration tests: `test_integration_<feature>.gd`
- All test files must be in `tests/unit/` or `tests/integration/`

### Basic Test Structure

```gdscript
extends GutTest

# Test subject
var my_system: MySystem

# Setup before each test
func before_each():
    my_system = MySystem.new()

# Cleanup after each test
func after_each():
    my_system = null

# Test function (must start with 'test_')
func test_my_feature_works_correctly():
    var result = my_system.do_something()
    assert_eq(result, expected_value, "Should return expected value")
```

### Common Assertions

```gdscript
# Equality
assert_eq(actual, expected, "message")
assert_ne(actual, expected, "message")

# Boolean
assert_true(condition, "message")
assert_false(condition, "message")

# Null checks
assert_null(value, "message")
assert_not_null(value, "message")

# Numeric comparisons
assert_gt(actual, expected, "message")  # greater than
assert_lt(actual, expected, "message")  # less than
assert_gte(actual, expected, "message") # greater than or equal
assert_lte(actual, expected, "message") # less than or equal
assert_between(value, min, max, "message")

# String checks
assert_string_contains(string, substring, "message")
assert_string_starts_with(string, prefix, "message")
assert_string_ends_with(string, suffix, "message")
```

### Best Practices

1. **One Test, One Purpose:** Each test should verify a single behavior
2. **Descriptive Names:** Use clear names like `test_missile_bonus_with_zero_hits()`
3. **Independent Tests:** Tests should not depend on each other
4. **Use before_each/after_each:** Clean setup and teardown for isolation
5. **Test Edge Cases:** Don't just test happy paths
6. **Fast Tests:** Keep individual tests under 100ms

### Example: Adding a New Unit Test

1. Create new file: `tests/unit/test_my_system.gd`

```gdscript
extends GutTest

var my_system: MySystem

func before_each():
    my_system = MySystem.new()

func after_each():
    my_system.free()
    my_system = null

func test_basic_functionality():
    var result = my_system.calculate(5, 3)
    assert_eq(result, 8, "Should add numbers correctly")

func test_edge_case_zero():
    var result = my_system.calculate(0, 0)
    assert_eq(result, 0, "Should handle zero values")

func test_edge_case_negative():
    var result = my_system.calculate(-5, 3)
    assert_eq(result, -2, "Should handle negative numbers")
```

2. Save the file
3. Run tests via GUT panel or command line
4. Verify all tests pass

## Current Test Coverage

### Unit Tests (70+ test cases)

- **ShiftStats.gd** (15 tests)
  - Bonus calculations (missile, accuracy, speed)
  - Stats reset functionality
  - Edge cases for large numbers

- **StatsManager.gd** (12 tests)
  - Stamp accuracy checking
  - Rectangle intersection logic
  - Boundary conditions

- **LawValidator.gd** (25 tests)
  - Age calculation
  - Date expiration checking
  - Rule violation detection
  - Conflict resolution

- **PotatoFactory.gd** (20 tests)
  - Random attribute generation
  - Date format validation
  - Asset loading

## CI/CD Integration

Tests run automatically on GitHub Actions for:
- Every push to `main` branch
- All pull requests

**Workflow:** `.github/workflows/automated_tests.yml`

The workflow includes:
1. **Static Code Analysis** (gdformat, gdlint, gdradon)
2. **Unit Tests** (GUT test suite)

Both jobs must pass for the workflow to succeed.

## Troubleshooting

### Tests fail locally but pass in CI

- Ensure you're using Godot 4.5.0 (same as CI)
- Check for hardcoded file paths
- Verify dependencies are loaded correctly

### GUT panel not visible in editor

1. Go to **Project > Project Settings > Plugins**
2. Ensure **GUT** plugin is enabled
3. Restart Godot Editor

### Tests run but show no output

- Check `.gutconfig.json` settings
- Ensure `log_level` is set to 1 or higher
- Verify test files are in correct directories

### "Cannot find class" errors

- Ensure class has `class_name` defined
- Check autoload configuration in `project.godot`
- Verify file paths use `res://` protocol

## Additional Resources

- [GUT Documentation](https://github.com/bitwes/Gut/wiki)
- [GUT Assertion Reference](https://github.com/bitwes/Gut/wiki/Asserts-and-Methods)
- Project GDD: `project_management/spud_customs_design_document.md` (Section 7)

## Contributing

When adding new features:

1. Write unit tests first (TDD approach recommended)
2. Ensure all existing tests still pass
3. Add integration tests for complex features
4. Update this README if adding new test categories
5. Run full test suite before committing

---

**Target Coverage:** 80% for core gameplay systems

**Current Focus:** Unit tests for individual systems and components
