---
description: Update project documentation to reflect current implementation state
---

Update project documentation to accurately reflect the current state of the codebase.

**Documents to Update:**

1. **Claude.md** - Development guidelines
   - Add EventBus migration information
   - Update autoload count (currently says 18, actually 21)
   - Add testing guidelines for EventBus
   - Document dependency injection patterns
   - Update known issues list

2. **README.md** - Project overview
   - Update feature status
   - Update build/test instructions
   - Add contribution guidelines reference

3. **EVENTBUS_MIGRATION_GUIDE.md** - Architecture migration
   - Update checklist with completed items
   - Add newly identified files needing migration
   - Document completed migrations

4. **tests/README.md** - Testing guide
   - Add EventBus testing patterns
   - Update test count
   - Document integration test structure

5. **Game Design Document** - Feature specifications
   - Mark completed features
   - Update known issues
   - Revise implementation status

**Update Checklist:**
- [ ] Review document for outdated information
- [ ] Update code examples to current patterns
- [ ] Fix broken file path references
- [ ] Update metrics (test count, file count, etc.)
- [ ] Add newly introduced patterns
- [ ] Remove references to deprecated systems
- [ ] Verify all links work

Ask the user which document needs updating if not specified.
