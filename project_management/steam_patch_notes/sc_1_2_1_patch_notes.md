[h1]SPUD CUSTOMS 1.2.1 - HOTFIX UPDATE[/h1]

Thank you to everyone who has provided feedback since the 1.2.0 release! This hotfix addresses critical performance issues that were causing freezes on some systems, along with several bug fixes reported by the community.

[h2]PERFORMANCE IMPROVEMENTS[/h2]

[b]Major Optimizations[/b]
[list]
[*][b]Save System Caching[/b]: Added game state caching to prevent repeated disk reads. This eliminates 60-300ms freezes that were occurring on slower storage devices during high score checks.
[*][b]Object Pooling[/b]: Implemented pooling for explosion sprites (15 pre-allocated) and footprint sprites (50 pre-allocated). Previously, the game was creating 600-1200+ objects per shift - now these are recycled efficiently.
[*][b]Reduced Particle Count[/b]: Explosion VFX particles reduced from 400 to 100, significantly reducing draw calls during border runner sequences.
[*][b]Resource Preloading[/b]: CharacterGenerator, gib textures, and explosion spritesheets are now preloaded at startup instead of blocking during gameplay.
[*][b]Frame-level Optimizations[/b]: Vehicle spawner no longer calls get_children() every frame. Viewport calculations cached per frame instead of per missile.
[/list]

[h2]BUG FIXES[/h2]

[b]Save Compatibility[/b]
[list]
[*]Fixed save file errors for players upgrading from v1.1.x. The game now properly handles save files that referenced the old game_state.gd location, with automatic backup and recovery for corrupted saves.
[/list]

[b]Tutorial Fixes[/b]
[list]
[*]Fixed stamp tutorial marker being visible when it shouldn't be (now hidden by default, only shown via debug command)
[*]Fixed "Skip All Tutorials" option not properly marking all tutorials as completed, which was causing tutorials to replay when transitioning from tutorial to Shift 1
[*]Fixed stamp position update affecting the wrong node
[/list]

[b]Visual Fixes[/b]
[list]
[*]Fixed type mismatch errors that could occur during perfect stamp celebrations
[*]Fixed potential nil access during celebration particle animations
[/list]

[b]Stats and Achievements[/b]
[list]
[*]Fixed duplicate achievement/stats calls at shift completion (was incrementing total_shifts_completed twice)
[*]Reduced redundant Steam API calls from 4 to 2 per shift completion
[/list]

[h2]OTHER CHANGES[/h2]
[list]
[*]Updated game icon
[*]Added new screenshot
[*]Updated cutscene visuals
[/list]

[h2]TECHNICAL NOTES[/h2]

This update includes a comprehensive performance audit that identified and addressed critical issues causing app hangs, particularly on laptop hardware. If you were experiencing freezes or stuttering in v1.2.0, this update should significantly improve your experience.

As always, thank you for your feedback and support!

[i]- Lost Rabbit Digital Development Team[/i]
