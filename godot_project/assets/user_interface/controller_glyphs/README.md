# Controller Glyphs

This directory contains button prompt images for different controller types.

## Required Assets

The InputGlyphManager expects the following image files for each controller type:

### Xbox Controller (`xbox_*.png`)
- `xbox_a.png` - A button
- `xbox_b.png` - B button
- `xbox_x.png` - X button
- `xbox_y.png` - Y button
- `xbox_lb.png` - Left bumper
- `xbox_rb.png` - Right bumper
- `xbox_lt.png` - Left trigger
- `xbox_rt.png` - Right trigger
- `xbox_view.png` - View button (back)
- `xbox_menu.png` - Menu button (start)
- `xbox_l3.png` - Left stick click
- `xbox_r3.png` - Right stick click
- `xbox_dpad_up.png` - D-pad up
- `xbox_dpad_down.png` - D-pad down
- `xbox_dpad_left.png` - D-pad left
- `xbox_dpad_right.png` - D-pad right
- `xbox_stick_l.png` - Left stick
- `xbox_stick_r.png` - Right stick

### PlayStation Controller (`ps_*.png`)
- `ps_cross.png` - Cross button (X)
- `ps_circle.png` - Circle button (O)
- `ps_square.png` - Square button
- `ps_triangle.png` - Triangle button
- `ps_l1.png` - L1 button
- `ps_r1.png` - R1 button
- `ps_l2.png` - L2 trigger
- `ps_r2.png` - R2 trigger
- `ps_share.png` - Share button
- `ps_options.png` - Options button
- `ps_l3.png` - L3 (left stick click)
- `ps_r3.png` - R3 (right stick click)
- `ps_dpad_up.png` - D-pad up
- `ps_dpad_down.png` - D-pad down
- `ps_dpad_left.png` - D-pad left
- `ps_dpad_right.png` - D-pad right
- `ps_stick_l.png` - Left stick
- `ps_stick_r.png` - Right stick

### Nintendo Switch Controller (`switch_*.png`)
- `switch_a.png` - A button (position of B on Xbox)
- `switch_b.png` - B button (position of A on Xbox)
- `switch_x.png` - X button (position of Y on Xbox)
- `switch_y.png` - Y button (position of X on Xbox)
- `switch_l.png` - L button
- `switch_r.png` - R button
- `switch_zl.png` - ZL trigger
- `switch_zr.png` - ZR trigger
- `switch_minus.png` - Minus button
- `switch_plus.png` - Plus button
- `switch_l3.png` - Left stick click
- `switch_r3.png` - Right stick click
- `switch_dpad_up.png` - D-pad up
- `switch_dpad_down.png` - D-pad down
- `switch_dpad_left.png` - D-pad left
- `switch_dpad_right.png` - D-pad right
- `switch_stick_l.png` - Left stick
- `switch_stick_r.png` - Right stick

### Steam Deck (`deck_*.png`)
Same naming as Xbox but with `deck_` prefix.

### Keyboard/Mouse (fallback)
- `key_enter.png` - Enter key
- `key_esc.png` - Escape key
- `key_space.png` - Space key
- `key_e.png` - E key
- `key_q.png` - Q key
- `key_ctrl.png` - Control key
- `key_tab.png` - Tab key
- `key_w.png`, `key_a.png`, `key_s.png`, `key_d.png` - WASD keys
- `mouse_left.png` - Left mouse button
- `mouse_right.png` - Right mouse button

## Recommended Specifications

- **Size**: 64x64 pixels (will be scaled as needed)
- **Format**: PNG with transparency
- **Style**: Match the game's visual style (pixel art recommended)

## Notes

- If glyph files are missing, the system will fall back to text labels
- Steam Input can also provide glyphs dynamically, which will override these files
- Consider using the Xelu's FREE Controller Prompts pack or similar free resources
