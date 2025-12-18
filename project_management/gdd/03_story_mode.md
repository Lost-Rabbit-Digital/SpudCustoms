# Story Mode

> **Back to:** [GDD Index](README.md) | **Previous:** [Core Gameplay](02_core_gameplay.md)

## Chapter Structure

Each chapter represents one work shift (10 total shifts)

### Shift 1: "Peeling Back the Layers"

- **Dynamic tutorial system** ✓ (implemented - replaces hard-coded screenshot tutorial)
  - Text readability shader for tutorial emphasis
  - Click-to-continue functionality
  - Tutorial progress indicator in UI
  - Softer highlight intensity for better readability
  - Triggers on document pickup with contextual guidance
- Introduction to border checkpoint operations
- Tutorial for gate raising mechanic
- Tutorial for runners with emote warnings
- Introduction of Supervisor Russet and key characters
- **Narrative Note**: Ending with "And remember, Glory to Spud!"

### Shift 2-3: "The Underground Root Cellar"

- Discovery of resistance movement
- Introduction of coded messages via X-ray scanning
- Deeper conspiracy elements
- Moral choice integration
- Environmental storytelling begins (propaganda posters visible)

### Shift 4: "The Mashing Fields"

- Major plot revelations
- Increased difficulty
- Character relationships deepen
- **Needs Work**: Ending is abrupt and jarring, requires smoother transition

### Shift 10: "Mash or Be Mashed"

- Story climax with **4 distinct endings** (2 art pieces + 4 dialogue lines each)
- **Needs Revision**: Confusing narrative change in "stay" path regarding resistance members
- **Requires Implementation**: Multiple ending branches based on player choices
- Final confrontations
- Resolution of major plot threads

## Narrative Elements

- Dialogue system with choice consequences (tracked via NarrativeManager)
- Environmental storytelling through:
  - Propaganda posters (progressive display as shifts advance)
  - Radio broadcasts (audio integration needed)
  - Newspaper headlines (visible in background)
- Character relationships and reputation system
- **New**: Interactive potato conversations during document inspection (Terry Pratchett-inspired)
- **Technical Note**: Use OGV video files or Animated GIFs for StagNation artwork integration

## Choice Tracking System

- NarrativeManager must properly retain, track, save, and load player choices
- SaveManager integration required for narrative persistence
- All major story decisions must affect ending determination

---

> **Next:** [Game Modes](04_game_modes.md)
