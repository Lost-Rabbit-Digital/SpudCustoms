---
description: Create comprehensive unit tests for a specific game system
---

Create comprehensive unit tests using GUT (Godot Unit Test) framework for the specified system.

**Requirements:**
- Follow the testing patterns in `godot_project/tests/unit/`
- Extend `GutTest` base class
- Use `before_each()` for test setup
- Include edge cases, boundary conditions, and error handling
- Test all public methods and critical logic paths
- Use descriptive test names: `test_<method>_<scenario>_<expected_result>()`
- Add assertions with clear failure messages
- Target minimum 80% code coverage for the system

**Test File Location:** `godot_project/tests/unit/test_<system_name>.gd`

**Examples of systems to test:**
- DragAndDropManager
- AccessibilityManager
- TutorialManager
- DocumentFactory
- NarrativeManager choice tracking
- SaveManager persistence

Ask the user which system they want to test if not specified.
