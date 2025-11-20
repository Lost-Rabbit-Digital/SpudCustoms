---
description: Run code quality checks (format, lint, complexity analysis)
---

Run comprehensive code quality checks on the project.

**Tools to Run:**

1. **GDFormat** (code formatting):
```bash
gdformat --check godot_project/scripts/
```

2. **GDLint** (linting):
```bash
gdlint godot_project/scripts/
```

3. **GDRadon** (cyclomatic complexity):
```bash
gdradon cc godot_project/scripts/
```

**Analysis:**
- Report formatting violations
- List linting errors and warnings
- Identify functions with high cyclomatic complexity (>10)
- Suggest refactoring opportunities
- Check for common anti-patterns mentioned in Claude.md

**Auto-fix (if requested):**
```bash
gdformat godot_project/scripts/  # Without --check flag
```

**Priority Focus:**
- Files in the EventBus migration priority list
- New code being added
- High-complexity functions that need refactoring
