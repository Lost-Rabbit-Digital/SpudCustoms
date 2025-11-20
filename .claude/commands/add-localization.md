---
description: Add localization support for new text content
---

Add localization for new text content across all 20 supported languages.

**Supported Languages:**
See `godot_project/translations/` for complete list

**Implementation Steps:**

1. **Add Translation Keys**:
   - Add keys to base translation CSV files
   - Use descriptive key names: `UI_BUTTON_ACCEPT`, `TUTORIAL_STAMP_HINT`, etc.

2. **Initial Translation**:
   - Add English text first
   - Use placeholder text for other languages initially
   - Mark for professional translation

3. **Use in Code**:
```gdscript
label.text = tr("TRANSLATION_KEY")
# Or with parameters:
label.text = tr("SCORE_MESSAGE").format({"score": current_score})
```

4. **Update LocalizationManager**:
   - Ensure new keys are accessible
   - Test language switching

5. **Testing**:
   - Verify text fits in UI at all font scales
   - Test with longest translations (typically German)
   - Check right-to-left languages if applicable
   - Verify special characters render correctly

**Text Categories:**
- UI labels and buttons
- Tutorial hints
- Dialogue (Dialogic integration)
- Achievement names and descriptions
- Error messages and alerts

**Best Practices:**
- Avoid hardcoded strings in code
- Use parameters for dynamic text
- Consider text length variations
- Test with accessibility font scaling

Ask the user what text needs localization if not specified.
