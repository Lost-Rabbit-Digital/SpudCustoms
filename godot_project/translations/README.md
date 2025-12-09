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

### File Structure
Each translation category has separate files per language:
```
translations/
├── menus_en.csv      # English menu strings
├── menus_de.csv      # German menu strings
├── menus_fr.csv      # French menu strings
├── game_en.csv       # English game strings
├── game_de.csv       # German game strings
└── ...
```

### For Translators
1. Edit the language-specific CSV files directly (e.g., `menus_fr.csv` for French)
2. Each file has format: `keys,{lang_code}` (e.g., `keys,fr`)
3. Save and test in Godot

### For Developers
1. Add new keys to the English file (e.g., `menus_en.csv`)
2. Run `python translate_with_gemini.py` to auto-translate to all languages

### CLI Commands
```bash
# Check for missing translations
python translate_with_gemini.py --check

# Translate all untranslated content using Gemini API
python translate_with_gemini.py

# Translate specific base name only
python translate_with_gemini.py --base menus

# Dry run - preview what would be translated
python translate_with_gemini.py --dry-run

# List all supported languages
python translate_with_gemini.py --list-languages
```

## Adding New Content

1. Add English text to the appropriate `{category}_en.csv` file
2. Run the translation tool to create/update other language files
3. Review auto-translations for accuracy
