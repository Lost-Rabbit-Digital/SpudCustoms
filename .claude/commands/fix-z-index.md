---
description: Fix z-index layering issues for visual elements
---

Fix z-index rendering issues to ensure proper visual layering.

**Current Z-Index System:**
Reference: `godot_project/scripts/constant_z_indexes.gd`

**Common Issues:**
- Documents appearing behind UI
- Particles obscuring gameplay elements
- Stamps extending beyond document bounds
- Corpses rendering above explosions
- Footprints appearing above structures

**Resolution Steps:**
1. Identify the visual element with incorrect layering
2. Check current z-index value
3. Reference `ConstantZIndexes` for correct layer
4. Update z-index assignment
5. Test in-game to verify fix
6. Update `ConstantZIndexes` if new layer needed

**Recent Fixes** (reference for patterns):
- Explosions: 12 → 1 (below inspection table)
- Explosion smoke: 13 → 1 (matches explosions)
- Footprints: 9 → 0 (ground level)
- Gibs: 11 → 21 (above screen borders)
- Missile smoke: 11 → 7 (proper layering)

**Known Issues** (from project_tasks.md):
- Documents show above suspect panel background (needs viewport masking)
- Stamps can be placed outside passport (needs viewport masking)
- Corpses need lower z-index than explosions

Ask the user which z-index issue they want to fix if not specified.
