# Controller Glyphs

Controller glyph assets are located at:

`res://assets/sprites/controller_glyphs/`

## Folder Structure

- `Xbox Series/` - Xbox Series X controller glyphs (XboxSeriesX_*.png)
- `PS5/` - PlayStation 5 controller glyphs (PS5_*.png)
- `Switch/` - Nintendo Switch controller glyphs (Switch_*.png)
- `Steam Deck/` - Steam Deck controller glyphs (SteamDeck_*.png)
- `Keyboard & Mouse/Dark/` - Keyboard and mouse glyphs (*_Key_Dark.png)

## File Naming Convention

### Xbox Series
- `XboxSeriesX_A.png`, `XboxSeriesX_B.png`, `XboxSeriesX_X.png`, `XboxSeriesX_Y.png`
- `XboxSeriesX_LB.png`, `XboxSeriesX_RB.png`, `XboxSeriesX_LT.png`, `XboxSeriesX_RT.png`
- `XboxSeriesX_Dpad_Up.png`, `XboxSeriesX_Dpad_Down.png`, etc.
- `XboxSeriesX_Left_Stick.png`, `XboxSeriesX_Left_Stick_Click.png`, etc.
- `XboxSeriesX_View.png`, `XboxSeriesX_Menu.png`

### PlayStation 5
- `PS5_Cross.png`, `PS5_Circle.png`, `PS5_Square.png`, `PS5_Triangle.png`
- `PS5_L1.png`, `PS5_R1.png`, `PS5_L2.png`, `PS5_R2.png`
- `PS5_Dpad_Up.png`, `PS5_Dpad_Down.png`, etc.
- `PS5_Left_Stick.png`, `PS5_Left_Stick_Click.png`, etc.
- `PS5_Share.png`, `PS5_Options.png`

### Nintendo Switch
- `Switch_A.png`, `Switch_B.png`, `Switch_X.png`, `Switch_Y.png`
- `Switch_L.png`, `Switch_R.png`, `Switch_ZL.png`, `Switch_ZR.png`
- `Switch_Dpad_Up.png`, `Switch_Dpad_Down.png`, etc.
- `Switch_Left_Stick.png`, `Switch_Left_Stick_Click.png`, etc.
- `Switch_Minus.png`, `Switch_Plus.png`

### Steam Deck
- `SteamDeck_A.png`, `SteamDeck_B.png`, `SteamDeck_X.png`, `SteamDeck_Y.png`
- `SteamDeck_L1.png`, `SteamDeck_R1.png`, `SteamDeck_L2.png`, `SteamDeck_R2.png`
- `SteamDeck_Dpad_Up.png`, etc.
- `SteamDeck_Menu.png`

### Keyboard & Mouse
Located in `Keyboard & Mouse/Dark/`:
- `Enter_Key_Dark.png`, `Esc_Key_Dark.png`, `Space_Key_Dark.png`
- `A_Key_Dark.png`, `W_Key_Dark.png`, `S_Key_Dark.png`, `D_Key_Dark.png`
- `Mouse_Left_Key_Dark.png`, `Mouse_Right_Key_Dark.png`

## Notes

- If glyph files are missing, the system will fall back to text labels (e.g., "[A]", "[RT]")
- See `InputGlyphManager.gd` for the full mapping of button names to file paths
