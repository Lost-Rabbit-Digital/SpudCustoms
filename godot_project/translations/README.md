# Translation System for Spud Customs

## Directory Structure

```
translations/
├── README.md                    # This file
├── combined/                    # Combined CSVs for Godot import (auto-generated)
│   ├── menus.csv
│   ├── game.csv
│   └── ...
├── per_language/               # Per-language source files for easier editing
│   ├── menus_en.csv
│   ├── menus_fr.csv
│   ├── game_en.csv
│   ├── game_fr.csv
│   └── ...
└── *.csv                       # Legacy combined format (current)
```

## File Formats

### Per-Language Format (Recommended for editing)
Each file contains only one language:
```csv
keys,{lang_code}
main_menu_new_game,New Game
main_menu_continue,Continue
```

### Combined Format (Used by Godot)
Single file with all languages:
```csv
keys,en,fr,de,es,...
main_menu_new_game,New Game,Nouveau jeu,Neues Spiel,Nuevo juego,...
```

## Supported Languages (All Steam Languages - 31 total)

| Code | Language | Native Name |
|------|----------|-------------|
| ar | Arabic | العربية |
| bg | Bulgarian | Български |
| cs | Czech | Čeština |
| da | Danish | Dansk |
| de | German | Deutsch |
| el | Greek | Ελληνικά |
| en | English | English |
| es | Spanish (Spain) | Español |
| es-419 | Spanish (Latin America) | Español (Latinoamérica) |
| fi | Finnish | Suomi |
| fr | French | Français |
| hu | Hungarian | Magyar |
| id | Indonesian | Bahasa Indonesia |
| it | Italian | Italiano |
| ja | Japanese | 日本語 |
| ko | Korean | 한국어 |
| nl | Dutch | Nederlands |
| no | Norwegian | Norsk |
| pl | Polish | Polski |
| pt | Portuguese | Português |
| pt-BR | Portuguese (Brazil) | Português (Brasil) |
| ro | Romanian | Română |
| ru | Russian | Русский |
| sk | Slovak | Slovenčina |
| sv | Swedish | Svenska |
| th | Thai | ไทย |
| tr | Turkish | Türkçe |
| uk | Ukrainian | Українська |
| vi | Vietnamese | Tiếng Việt |
| zh-CN | Chinese (Simplified) | 简体中文 |
| zh-TW | Chinese (Traditional) | 繁體中文 |

## Translation Workflow

**Keep files split!** Per-language files are:
- Easier to review in PRs (small diffs)
- Less prone to merge conflicts
- Simpler for translators to work with

### For Translators
1. Edit files in `per_language/` directory (e.g., `menus_fr.csv` for French)
2. Each file contains only one language - much easier to work with!
3. Run `--merge` before testing in Godot (Godot needs combined format)

### For Developers
1. Add new keys to `per_language/{category}_en.csv`
2. Run `python translate_with_gemini.py` to auto-translate to all languages
3. Run `--merge` before running/exporting the game

### CLI Commands
```bash
# Check for missing translations
python translate_with_gemini.py --check

# Translate all untranslated content
python translate_with_gemini.py

# Split combined CSVs into per-language files
python translate_with_gemini.py --split

# Merge per-language files back to combined format
python translate_with_gemini.py --merge

# Process only a specific file
python translate_with_gemini.py --file menus.csv
```

## Adding New Content

1. Add English text to the appropriate `per_language/{category}_en.csv`
2. Run the translation tool to generate other languages
3. Review auto-translations for accuracy
4. Merge back to combined format for Godot
