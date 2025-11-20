---
description: Add a new gameplay feature to the game
---

Add a new gameplay feature to Spud Customs.

**Feature Implementation Process:**

1. **Design Phase**:
   - Define feature requirements
   - Identify affected systems
   - Plan integration points
   - Consider EventBus events needed

2. **Implementation Phase**:
   - Create new scripts in appropriate `scripts/systems/` directory
   - Use dependency injection patterns
   - Emit EventBus events for state changes
   - Follow naming conventions from Claude.md

3. **Integration Phase**:
   - Hook into existing game loop
   - Add UI elements if needed
   - Integrate with save/load system
   - Add Steam achievements if applicable

4. **Polish Phase**:
   - Add sound effects
   - Add visual feedback
   - Add accessibility support
   - Add localization

5. **Testing Phase**:
   - Create unit tests
   - Create integration tests
   - Playtest thoroughly
   - Performance test

**High-Priority Features** (from project_tasks.md):
- X-ray scanner system for hidden contraband
- Entry ticket document and validation
- Additional document types (work permits, baggage, visas)
- Baggage inspection mini-game
- Citation system (more forgiving than strikes)
- Environmental storytelling (propaganda, newspapers)

**Required Considerations:**
- EventBus integration from the start
- Save/load persistence
- Localization support (20 languages)
- Accessibility features
- Unit test coverage

Ask the user which feature they want to implement if not specified.
