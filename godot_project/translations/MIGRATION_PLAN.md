# Translation Migration Plan: Per-Language Files

## Overview
Migrate from comprehensive multi-language CSV files to per-language single-language CSV files.

## Current State
- **23 Dialogic timeline files** (.dtl) contain the source of truth for dialogue
- **19 English per-language files** exist but some are out of sync
- **4 English files are MISSING** (shift2_end, shift4_end, shift6_end, shift8_end, loyalist_ending)
- **Old comprehensive CSVs** contain all languages in one file (hard to maintain)

## Migration Steps

---

### Step 1: Create Missing English Translation Files

**Prompt to use:**
```
Create the missing English per-language translation files for Dialogic timelines. The following files need to be created:

1. dialogic_shift2_end_translation_en.csv - from shift2_end.dtl
2. dialogic_shift4_end_translation_en.csv - from shift4_end.dtl
3. dialogic_shift6_end_translation_en.csv - from shift6_end.dtl
4. dialogic_shift8_end_translation_en.csv - from shift8_end.dtl
5. dialogic_loyalist_ending_translation_en.csv - from loyalist_ending.dtl

Read each .dtl file from godot_project/assets/narrative/ and extract all lines with #id: tags.

The CSV format should be:
- First line: keys,en
- Text lines: Text/{id}/text,{dialogue text}
- Choice lines: Choice/{id}/text,{choice text}

Put the new files in godot_project/translations/per_language/
```

---

### Step 2: Update Existing English Translation Files (Part 1 - Shifts 1-3)

**Prompt to use:**
```
Update the English per-language translation files to match the current Dialogic timeline content for shifts 1-3:

Files to update:
1. dialogic_shift1_intro_translation_en.csv - sync with shift1_intro.dtl
2. dialogic_shift1_end_translation_en.csv - sync with shift1_end.dtl
3. dialogic_shift2_intro_translation_en.csv - sync with shift2_intro.dtl
4. dialogic_shift3_intro_translation_en.csv - sync with shift3_intro.dtl
5. dialogic_shift3_end_translation_en.csv - sync with shift3_end.dtl

Read each .dtl file, extract all #id: tagged lines, and update the corresponding _en.csv file.
The CSV must include ALL dialogue IDs from the timeline - add any missing, update any changed text.

Format:
- Text lines: Text/{id}/text,{dialogue text}
- Choice lines: Choice/{id}/text,{choice text}
```

---

### Step 3: Update Existing English Translation Files (Part 2 - Shifts 4-6)

**Prompt to use:**
```
Update the English per-language translation files to match the current Dialogic timeline content for shifts 4-6:

Files to update:
1. dialogic_shift4_intro_translation_en.csv - sync with shift4_intro.dtl
2. dialogic_shift5_intro_translation_en.csv - sync with shift5_intro.dtl
3. dialogic_shift5_end_translation_en.csv - sync with shift5_end.dtl
4. dialogic_shift6_intro_translation_en.csv - sync with shift6_intro.dtl

Read each .dtl file, extract all #id: tagged lines, and update the corresponding _en.csv file.
```

---

### Step 4: Update Existing English Translation Files (Part 3 - Shifts 7-10)

**Prompt to use:**
```
Update the English per-language translation files to match the current Dialogic timeline content for shifts 7-10:

Files to update:
1. dialogic_shift7_intro_translation_en.csv - sync with shift7_intro.dtl
2. dialogic_shift7_end_translation_en.csv - sync with shift7_end.dtl
3. dialogic_shift8_intro_translation_en.csv - sync with shift8_intro.dtl
4. dialogic_shift9_intro_translation_en.csv - sync with shift9_intro.dtl
5. dialogic_shift9_end_translation_en.csv - sync with shift9_end.dtl
6. dialogic_shift10_intro_translation_en.csv - sync with shift10_intro.dtl

Read each .dtl file, extract all #id: tagged lines, and update the corresponding _en.csv file.
```

---

### Step 5: Update Special Timeline Files

**Prompt to use:**
```
Update the English per-language translation files for special timelines:

Files to update:
1. dialogic_tutorial_translation_en.csv - sync with tutorial.dtl
2. dialogic_final_confrontation_translation_en.csv - sync with final_confrontation.dtl
3. dialogic_generic_shift_start_translation_en.csv - sync with generic_shift_start.dtl

Read each .dtl file, extract all #id: tagged lines, and update the corresponding _en.csv file.
```

---

### Step 6: Remove Old Comprehensive CSV Files

**Prompt to use:**
```
Remove the old comprehensive (multi-language) CSV files from godot_project/translations/ (root folder, not per_language/).

Delete these files:
- dialogic_shift1_intro_translation.csv
- dialogic_shift1_end_translation.csv
- dialogic_shift2_intro_translation.csv
- dialogic_shift3_intro_translation.csv
- dialogic_shift3_end_translation.csv
- dialogic_shift4_intro_translation.csv
- dialogic_shift5_intro_translation.csv
- dialogic_shift5_end_translation.csv
- dialogic_shift6_intro_translation.csv
- dialogic_shift7_intro_translation.csv
- dialogic_shift7_end_translation.csv
- dialogic_shift8_intro_translation.csv
- dialogic_shift9_intro_translation.csv
- dialogic_shift9_end_translation.csv
- dialogic_shift10_intro_translation.csv
- dialogic_tutorial_translation.csv
- dialogic_final_confrontation_translation.csv
- dialogic_generic_shift_start_translation.csv

Also delete the corresponding .csv.import files and .translation files for these.

Keep the non-dialogic files (menus.csv, game.csv, etc.) for now.
```

---

### Step 7: Use Gemini Tool to Translate

After all English files are correct, use the translation tool:
```bash
cd godot_project/translations
python translate_with_gemini.py
```

This will read all `*_en.csv` files and create translated versions for all other languages.

---

## File Mapping Reference

| Timeline File | English Translation File |
|--------------|-------------------------|
| shift1_intro.dtl | dialogic_shift1_intro_translation_en.csv |
| shift1_end.dtl | dialogic_shift1_end_translation_en.csv |
| shift2_intro.dtl | dialogic_shift2_intro_translation_en.csv |
| shift2_end.dtl | dialogic_shift2_end_translation_en.csv (NEW) |
| shift3_intro.dtl | dialogic_shift3_intro_translation_en.csv |
| shift3_end.dtl | dialogic_shift3_end_translation_en.csv |
| shift4_intro.dtl | dialogic_shift4_intro_translation_en.csv |
| shift4_end.dtl | dialogic_shift4_end_translation_en.csv (NEW) |
| shift5_intro.dtl | dialogic_shift5_intro_translation_en.csv |
| shift5_end.dtl | dialogic_shift5_end_translation_en.csv |
| shift6_intro.dtl | dialogic_shift6_intro_translation_en.csv |
| shift6_end.dtl | dialogic_shift6_end_translation_en.csv (NEW) |
| shift7_intro.dtl | dialogic_shift7_intro_translation_en.csv |
| shift7_end.dtl | dialogic_shift7_end_translation_en.csv |
| shift8_intro.dtl | dialogic_shift8_intro_translation_en.csv |
| shift8_end.dtl | dialogic_shift8_end_translation_en.csv (NEW) |
| shift9_intro.dtl | dialogic_shift9_intro_translation_en.csv |
| shift9_end.dtl | dialogic_shift9_end_translation_en.csv |
| shift10_intro.dtl | dialogic_shift10_intro_translation_en.csv |
| tutorial.dtl | dialogic_tutorial_translation_en.csv |
| final_confrontation.dtl | dialogic_final_confrontation_translation_en.csv |
| generic_shift_start.dtl | dialogic_generic_shift_start_translation_en.csv |
| loyalist_ending.dtl | dialogic_loyalist_ending_translation_en.csv (NEW) |
