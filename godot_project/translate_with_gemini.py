#!/usr/bin/env python3
"""
Comprehensive translation management tool for Spud Customs.
Handles translation checking, fixing, and API translation for multi-language CSV files.
Supports both combined CSVs and per-language file formats.

Usage:
    python translate_with_gemini.py                    # Translate ALL untranslated keys
    python translate_with_gemini.py --check            # Check for missing/untranslated keys
    python translate_with_gemini.py --file game.csv    # Translate specific file only
    python translate_with_gemini.py --dry-run          # Show what would be translated without making changes
    python translate_with_gemini.py --split            # Split combined CSVs into per-language files
    python translate_with_gemini.py --merge            # Merge per-language files into combined CSVs

Note: The translate function automatically detects ALL keys that match English values
and translates them across all language columns.
"""

import argparse
import csv
import os
import sys
import time
from pathlib import Path
from collections import defaultdict
from io import StringIO

# ═══════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════

# Gemini API configuration
# API key is read from environment variable for security
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "")

# Model options (use the latest available):
# - gemini-2.5-pro: Latest stable Pro model (best quality)
# - gemini-2.5-flash: Fast and efficient (good for bulk translation)
# - gemini-2.0-flash: Previous generation flash model
GEMINI_MODEL = "gemini-2.5-flash"  # Using Flash for faster translations
GEMINI_API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent?key={GEMINI_API_KEY}"

# Rate limiting: Gemini 2.5 Flash allows up to 2000 RPM for paid tier
# Using 500 RPM to be safe and avoid hitting rate limits
MAX_REQUESTS_PER_MINUTE = 500
REQUEST_INTERVAL = 60.0 / MAX_REQUESTS_PER_MINUTE

# Concurrency settings for async operations
MAX_CONCURRENT_REQUESTS = 100  # Higher concurrency for Flash model
BATCH_SIZE = 25  # Items per API request (increased from 15)

# ═══════════════════════════════════════════════════════════
# ALL STEAM SUPPORTED LANGUAGES (31 total)
# ═══════════════════════════════════════════════════════════

# Complete mapping of all Steam-supported languages
# Format: 'code': ('Full Name', 'Native Name')
ALL_STEAM_LANGUAGES = {
    'ar': ('Arabic', 'العربية'),
    'bg': ('Bulgarian', 'Български'),
    'cs': ('Czech', 'Čeština'),
    'da': ('Danish', 'Dansk'),
    'de': ('German', 'Deutsch'),
    'el': ('Greek', 'Ελληνικά'),
    'en': ('English', 'English'),
    'es': ('Spanish', 'Español'),
    'es-419': ('Spanish (Latin America)', 'Español (Latinoamérica)'),
    'fi': ('Finnish', 'Suomi'),
    'fr': ('French', 'Français'),
    'hu': ('Hungarian', 'Magyar'),
    'id': ('Indonesian', 'Bahasa Indonesia'),
    'it': ('Italian', 'Italiano'),
    'ja': ('Japanese', '日本語'),
    'ko': ('Korean', '한국어'),
    'nl': ('Dutch', 'Nederlands'),
    'no': ('Norwegian', 'Norsk'),
    'pl': ('Polish', 'Polski'),
    'pt': ('Portuguese', 'Português'),
    'pt-BR': ('Portuguese (Brazil)', 'Português (Brasil)'),
    'ro': ('Romanian', 'Română'),
    'ru': ('Russian', 'Русский'),
    'sk': ('Slovak', 'Slovenčina'),
    'sv': ('Swedish', 'Svenska'),
    'th': ('Thai', 'ไทย'),
    'tr': ('Turkish', 'Türkçe'),
    'uk': ('Ukrainian', 'Українська'),
    'vi': ('Vietnamese', 'Tiếng Việt'),
    'zh-CN': ('Chinese (Simplified)', '简体中文'),
    'zh-TW': ('Chinese (Traditional)', '繁體中文'),
}

# Language mapping for translation (excluding 'en')
LANGUAGE_COLUMNS = {code: name for code, (name, _) in ALL_STEAM_LANGUAGES.items() if code != 'en'}

# Ordered list of language codes for CSV columns (consistent ordering)
LANGUAGE_ORDER = ['en', 'ar', 'bg', 'cs', 'da', 'de', 'el', 'es', 'es-419', 'fi', 'fr',
                  'hu', 'id', 'it', 'ja', 'ko', 'nl', 'no', 'pl', 'pt', 'pt-BR',
                  'ro', 'ru', 'sk', 'sv', 'th', 'tr', 'uk', 'vi', 'zh-CN', 'zh-TW']

# Game context for translation prompt
GAME_CONTEXT = """Spud Customs - A border checkpoint simulation game where you play as a potato inspector.
You check potato passports, verify documents, and decide whether to approve or reject potato travelers.
The game has dark humor elements and is inspired by "Papers, Please".
Key terms: potato (the travelers), passport, stamps (approve/reject), strikes (penalties), shift (work period),
border runner (escapees), quota (processing target), violations (document issues)."""

# ═══════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════

def get_translations_dir():
    """Get the translations directory path."""
    script_dir = Path(__file__).parent.resolve()
    return script_dir / 'translations'


def get_per_language_dir():
    """Get the per-language translations directory path.

    Now looks directly in translations/ root folder instead of per_language/ subdirectory.
    """
    return get_translations_dir()


def get_combined_dir():
    """Get the combined translations directory path."""
    return get_translations_dir() / 'combined'


def ensure_dirs():
    """Ensure all translation directories exist."""
    get_per_language_dir().mkdir(parents=True, exist_ok=True)
    get_combined_dir().mkdir(parents=True, exist_ok=True)


def is_per_language_file(filepath):
    """Check if a file is in per-language format (e.g., menus_en.csv, menus_de.csv)."""
    stem = filepath.stem
    for lang_code in LANGUAGE_ORDER:
        if stem.endswith(f'_{lang_code}'):
            return True
    return False


def get_per_language_base_name(filepath):
    """Get the base name from a per-language file (e.g., menus_en.csv -> menus)."""
    stem = filepath.stem
    for lang_code in LANGUAGE_ORDER:
        suffix = f'_{lang_code}'
        if stem.endswith(suffix):
            return stem[:-len(suffix)]
    return stem


def get_per_language_lang_code(filepath):
    """Get the language code from a per-language file (e.g., menus_en.csv -> en)."""
    stem = filepath.stem
    for lang_code in LANGUAGE_ORDER:
        if stem.endswith(f'_{lang_code}'):
            return lang_code
    return None


def group_per_language_files():
    """Group per-language files by their base name.

    Returns: {base_name: {lang_code: filepath}}
    """
    per_lang_dir = get_per_language_dir()
    if not per_lang_dir.exists():
        return {}

    groups = defaultdict(dict)
    for csv_file in per_lang_dir.glob('*.csv'):
        if not is_per_language_file(csv_file):
            continue
        base_name = get_per_language_base_name(csv_file)
        lang_code = get_per_language_lang_code(csv_file)
        if base_name and lang_code:
            groups[base_name][lang_code] = csv_file

    return dict(groups)


def get_english_translations(base_name, file_groups):
    """Load English translations from a per-language file group.

    Returns: {key: english_value}
    """
    if base_name not in file_groups:
        return {}

    if 'en' not in file_groups[base_name]:
        return {}

    en_file = file_groups[base_name]['en']
    headers, rows = read_csv_file(en_file)

    if not headers or not rows:
        return {}

    # Get key and value column indices
    key_idx = 0  # First column is always keys
    val_idx = get_language_index(headers, 'en')
    if val_idx == -1:
        val_idx = 1  # Fallback to second column

    translations = {}
    for row in rows:
        if len(row) >= 2 and row[0] and not row[0].startswith('_'):
            translations[row[0]] = row[val_idx] if val_idx < len(row) else ''

    return translations


def find_untranslated_per_language(base_name, file_groups, lang_code):
    """Find untranslated keys for a specific language in per-language format.

    Returns: {key: english_value} for keys that need translation
    """
    english_translations = get_english_translations(base_name, file_groups)
    if not english_translations:
        return {}

    # If language file doesn't exist, all English keys need translation
    if lang_code not in file_groups[base_name]:
        # Filter out very short values that are likely symbols
        return {k: v for k, v in english_translations.items() if v and len(v) > 3}

    # Load existing translations for this language
    lang_file = file_groups[base_name][lang_code]
    headers, rows = read_csv_file(lang_file)

    # Get value column index for this language
    val_idx = get_language_index(headers, lang_code)
    if val_idx == -1:
        val_idx = 1  # Fallback to second column

    existing_translations = {}
    for row in rows:
        if len(row) >= 2 and row[0]:
            existing_translations[row[0]] = row[val_idx] if val_idx < len(row) else ''

    # Find keys that need translation
    untranslated = {}
    for key, en_value in english_translations.items():
        if not en_value or len(en_value) <= 3:
            continue  # Skip very short values

        lang_value = existing_translations.get(key, '')

        # Consider untranslated if: empty, same as English, or missing
        if not lang_value or lang_value == en_value:
            untranslated[key] = en_value

    return untranslated


def get_csv_files(specific_file=None, use_combined=True):
    """Get list of CSV files to process.

    Args:
        specific_file: Process only this file if specified
        use_combined: If True, use combined dir; if False, use root translations dir
    """
    if use_combined:
        translations_dir = get_combined_dir()
        if not translations_dir.exists():
            # Fall back to root translations directory
            translations_dir = get_translations_dir()
    else:
        translations_dir = get_translations_dir()

    if specific_file:
        csv_file = translations_dir / specific_file
        if csv_file.exists():
            return [csv_file]
        # Try root dir if not in combined
        csv_file = get_translations_dir() / specific_file
        if csv_file.exists():
            return [csv_file]
        print(f"ERROR: File not found: {specific_file}")
        return []

    # Get all translation CSV files (exclude .import files and non-translation CSVs)
    csv_files = []
    for f in sorted(translations_dir.glob('*.csv')):
        # Skip import metadata files
        if f.suffix == '.import':
            continue
        csv_files.append(f)

    # Also check root translations dir for legacy files
    if use_combined:
        for f in sorted(get_translations_dir().glob('*.csv')):
            if f.suffix == '.import':
                continue
            if f not in csv_files:
                csv_files.append(f)

    return csv_files


def read_csv_file(filepath):
    """Read CSV file and return headers and rows."""
    with open(filepath, 'r', encoding='utf-8-sig') as f:
        content = f.read()

    # Parse CSV properly handling quoted fields
    reader = csv.reader(StringIO(content))
    rows = list(reader)

    if not rows:
        return [], []

    headers = rows[0]
    data_rows = rows[1:]

    return headers, data_rows


def write_csv_file(filepath, headers, rows):
    """Write CSV file with proper quoting."""
    output = StringIO()
    writer = csv.writer(output, quoting=csv.QUOTE_MINIMAL, lineterminator='\n')
    writer.writerow(headers)
    writer.writerows(rows)

    with open(filepath, 'w', encoding='utf-8-sig', newline='') as f:
        f.write(output.getvalue())


def get_language_index(headers, lang_code):
    """Get the column index for a language code."""
    # Try exact match first
    if lang_code in headers:
        return headers.index(lang_code)
    # Try with trailing comma (some CSVs have this)
    for i, h in enumerate(headers):
        if h.strip().rstrip(',') == lang_code:
            return i
    return -1


def find_untranslated_cells(headers, rows):
    """Find cells that still contain English text (untranslated).

    Returns a dict: {row_index: {lang_code: english_value}}
    """
    en_idx = get_language_index(headers, 'en')
    if en_idx == -1:
        print("WARNING: No 'en' column found in CSV")
        return {}

    untranslated = defaultdict(dict)

    for row_idx, row in enumerate(rows):
        # Skip empty rows or comment rows
        if not row or not row[0] or row[0].startswith('_'):
            continue

        # Get English value
        en_value = row[en_idx] if en_idx < len(row) else ''

        # Skip empty English values or very short ones (likely symbols)
        if not en_value or len(en_value) <= 3:
            continue

        # Check each language column
        for lang_code in LANGUAGE_COLUMNS.keys():
            lang_idx = get_language_index(headers, lang_code)
            if lang_idx == -1:
                # Language column doesn't exist - treat as untranslated
                untranslated[row_idx][lang_code] = en_value
                continue

            if lang_idx >= len(row):
                # Row doesn't have this column - treat as untranslated
                untranslated[row_idx][lang_code] = en_value
                continue

            lang_value = row[lang_idx]

            # If language value matches English exactly or is empty, it's untranslated
            if lang_value == en_value or not lang_value:
                untranslated[row_idx][lang_code] = en_value

    return untranslated


# ═══════════════════════════════════════════════════════════
# MODE: SPLIT COMBINED CSVs INTO PER-LANGUAGE FILES
# ═══════════════════════════════════════════════════════════

def split_csv_to_per_language(csv_file):
    """Split a combined CSV file into per-language files.

    Input: menus.csv with columns (keys, en, fr, de, ...)
    Output: per_language/menus_en.csv, per_language/menus_fr.csv, ...
    """
    headers, rows = read_csv_file(csv_file)
    if not headers or not rows:
        return 0

    base_name = csv_file.stem  # e.g., "menus"
    per_lang_dir = get_per_language_dir()
    per_lang_dir.mkdir(parents=True, exist_ok=True)

    files_created = 0
    key_idx = get_language_index(headers, 'keys')
    if key_idx == -1:
        key_idx = 0  # Assume first column is keys

    # Process each language
    for lang_code in LANGUAGE_ORDER:
        lang_idx = get_language_index(headers, lang_code)
        if lang_idx == -1:
            continue

        # Create per-language file
        lang_file = per_lang_dir / f"{base_name}_{lang_code}.csv"
        lang_headers = ['keys', lang_code]
        lang_rows = []

        for row in rows:
            key = row[key_idx] if key_idx < len(row) else ''
            value = row[lang_idx] if lang_idx < len(row) else ''
            lang_rows.append([key, value])

        write_csv_file(lang_file, lang_headers, lang_rows)
        files_created += 1

    return files_created


def split_all_csvs():
    """Split all combined CSV files into per-language files."""
    ensure_dirs()
    csv_files = get_csv_files(use_combined=False)

    if not csv_files:
        print("No CSV files found to split")
        return

    print("=" * 80)
    print("SPLITTING COMBINED CSVs TO PER-LANGUAGE FILES")
    print("=" * 80)

    total_files = 0
    for csv_file in csv_files:
        files_created = split_csv_to_per_language(csv_file)
        if files_created > 0:
            print(f"  {csv_file.name}: Created {files_created} language files")
            total_files += files_created

    print(f"\nTotal per-language files created: {total_files}")
    print(f"Output directory: {get_per_language_dir()}")


# ═══════════════════════════════════════════════════════════
# MODE: MERGE PER-LANGUAGE FILES INTO COMBINED CSVs
# ═══════════════════════════════════════════════════════════

def install_to_godot():
    """Copy combined CSV files to root translations folder for Godot import.

    This copies files from translations/combined/ to translations/
    so Godot can import them and generate .translation files.
    """
    import shutil

    combined_dir = get_combined_dir()
    root_dir = get_translations_dir()

    if not combined_dir.exists():
        print("Combined directory not found. Run --merge first.")
        return

    csv_files = list(combined_dir.glob('*.csv'))
    if not csv_files:
        print("No combined CSV files found. Run --merge first.")
        return

    print("=" * 80)
    print("INSTALLING COMBINED CSVs TO GODOT")
    print("=" * 80)

    installed = 0
    for csv_file in csv_files:
        dest = root_dir / csv_file.name
        shutil.copy2(csv_file, dest)
        print(f"  Copied: {csv_file.name}")
        installed += 1

    print(f"\nInstalled {installed} files to {root_dir}")
    print("\nNext steps:")
    print("  1. Open Godot project")
    print("  2. Wait for reimport (or use Project > Tools > Reimport All)")
    print("  3. Check Project Settings > Localization > Translations")


def merge_per_language_to_combined():
    """Merge per-language CSV files back into combined format.

    Input: per_language/menus_en.csv, per_language/menus_fr.csv, ...
    Output: combined/menus.csv
    """
    ensure_dirs()
    per_lang_dir = get_per_language_dir()
    combined_dir = get_combined_dir()

    if not per_lang_dir.exists():
        print(f"Per-language directory not found: {per_lang_dir}")
        return

    # Group files by base name
    file_groups = defaultdict(dict)  # {base_name: {lang_code: file_path}}

    for lang_file in per_lang_dir.glob('*.csv'):
        # Parse filename: menus_en.csv -> base=menus, lang=en
        parts = lang_file.stem.rsplit('_', 1)
        if len(parts) != 2:
            continue
        base_name, lang_code = parts

        # Handle special case for es-419, pt-BR, zh-CN, zh-TW
        # These might be stored as menus_es-419.csv
        if lang_code in ['419', 'BR', 'CN', 'TW']:
            # Check for hyphenated codes
            parts2 = lang_file.stem.rsplit('_', 2)
            if len(parts2) >= 2:
                potential_lang = f"{parts2[-2]}-{parts2[-1]}"
                if potential_lang in ALL_STEAM_LANGUAGES:
                    base_name = '_'.join(parts2[:-2]) if len(parts2) > 2 else parts2[0].rsplit('-', 1)[0]
                    lang_code = potential_lang

        if lang_code in ALL_STEAM_LANGUAGES:
            file_groups[base_name][lang_code] = lang_file

    print("=" * 80)
    print("MERGING PER-LANGUAGE FILES TO COMBINED CSVs")
    print("=" * 80)

    for base_name, lang_files in sorted(file_groups.items()):
        # Start with English as the base
        if 'en' not in lang_files:
            print(f"  WARNING: {base_name} has no English file, skipping")
            continue

        # Read English file to get all keys
        en_headers, en_rows = read_csv_file(lang_files['en'])
        if not en_rows:
            continue

        # Build combined data structure
        keys = [row[0] if row else '' for row in en_rows]
        translations = {lang: {} for lang in LANGUAGE_ORDER}

        # Read each language file
        for lang_code, lang_file in lang_files.items():
            headers, rows = read_csv_file(lang_file)
            for row in rows:
                if len(row) >= 2:
                    key, value = row[0], row[1]
                    translations[lang_code][key] = value

        # Build combined headers and rows
        combined_headers = ['keys'] + [lang for lang in LANGUAGE_ORDER if lang in lang_files]
        combined_rows = []

        for key in keys:
            row = [key]
            for lang in LANGUAGE_ORDER:
                if lang in lang_files:
                    row.append(translations[lang].get(key, ''))
            combined_rows.append(row)

        # Write combined file
        combined_file = combined_dir / f"{base_name}.csv"
        write_csv_file(combined_file, combined_headers, combined_rows)
        print(f"  {base_name}.csv: Merged {len(lang_files)} languages, {len(keys)} keys")

    print(f"\nOutput directory: {combined_dir}")


# ═══════════════════════════════════════════════════════════
# MODE: ADD MISSING LANGUAGE COLUMNS
# ═══════════════════════════════════════════════════════════

def add_missing_language_columns(csv_file):
    """Add missing language columns to a combined CSV file."""
    headers, rows = read_csv_file(csv_file)
    if not headers or not rows:
        return False

    # Check which languages are missing
    missing_langs = []
    for lang_code in LANGUAGE_ORDER:
        if get_language_index(headers, lang_code) == -1:
            missing_langs.append(lang_code)

    if not missing_langs:
        return False

    # Add missing language columns
    en_idx = get_language_index(headers, 'en')

    for lang_code in missing_langs:
        headers.append(lang_code)
        for row in rows:
            # Initialize with English value (will be translated later)
            en_value = row[en_idx] if en_idx != -1 and en_idx < len(row) else ''
            row.append(en_value)

    write_csv_file(csv_file, headers, rows)
    return True


def add_all_missing_columns():
    """Add missing language columns to all CSV files."""
    csv_files = get_csv_files(use_combined=False)

    print("=" * 80)
    print("ADDING MISSING LANGUAGE COLUMNS")
    print("=" * 80)

    for csv_file in csv_files:
        headers, _ = read_csv_file(csv_file)
        missing = [lang for lang in LANGUAGE_ORDER if get_language_index(headers, lang) == -1]

        if missing:
            add_missing_language_columns(csv_file)
            print(f"  {csv_file.name}: Added {len(missing)} languages: {', '.join(missing)}")
        else:
            print(f"  {csv_file.name}: All languages present")


# ═══════════════════════════════════════════════════════════
# MODE: CHECK PER-LANGUAGE TRANSLATIONS
# ═══════════════════════════════════════════════════════════

def check_per_language_translations(specific_base=None):
    """Check per-language CSV files for untranslated content."""
    file_groups = group_per_language_files()

    if not file_groups:
        print("No per-language files found in translations/per_language/")
        return

    if specific_base:
        if specific_base not in file_groups:
            print(f"ERROR: No files found for base name: {specific_base}")
            return
        file_groups = {specific_base: file_groups[specific_base]}

    total_untranslated = 0
    bases_with_issues = 0
    missing_english = []

    print("=" * 80)
    print("PER-LANGUAGE TRANSLATION CHECK REPORT")
    print("=" * 80)

    for base_name, lang_files in sorted(file_groups.items()):
        # Check if English file exists
        if 'en' not in lang_files:
            missing_english.append(base_name)
            continue

        english_translations = get_english_translations(base_name, file_groups)
        if not english_translations:
            continue

        base_untranslated = 0
        missing_langs = []

        # Check each target language
        for lang_code in LANGUAGE_COLUMNS.keys():
            untranslated = find_untranslated_per_language(base_name, file_groups, lang_code)
            if untranslated:
                base_untranslated += len(untranslated)
                if lang_code not in lang_files:
                    missing_langs.append(lang_code)

        if base_untranslated > 0:
            bases_with_issues += 1
            total_untranslated += base_untranslated

            print(f"\n📄 {base_name}")
            print("-" * 60)
            print(f"   English keys: {len(english_translations)}")
            print(f"   Existing translations: {len(lang_files) - 1} languages")
            if missing_langs:
                print(f"   Missing language files: {', '.join(sorted(missing_langs)[:10])}{'...' if len(missing_langs) > 10 else ''}")
            print(f"   Total untranslated cells: {base_untranslated}")

    print("\n" + "=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print(f"Translation groups checked: {len(file_groups)}")
    print(f"Groups with untranslated content: {bases_with_issues}")
    print(f"Total untranslated cells: {total_untranslated}")

    if missing_english:
        print(f"\n⚠️  Missing English files ({len(missing_english)}):")
        for name in sorted(missing_english)[:10]:
            print(f"   - {name}_en.csv")
        if len(missing_english) > 10:
            print(f"   ... and {len(missing_english) - 10} more")

    if total_untranslated == 0 and not missing_english:
        print("\n✅ All per-language translations are complete!")
    else:
        print(f"\n⚠️  Found {total_untranslated} cells that need translation")
        print("   Run without --check to translate them")


def write_per_language_file(base_name, lang_code, translations, file_groups):
    """Write translations to a per-language file.

    Args:
        translations: {key: translated_value}
    """
    per_lang_dir = get_per_language_dir()
    lang_file = per_lang_dir / f"{base_name}_{lang_code}.csv"

    # If file exists, update it; otherwise create new
    if lang_code in file_groups.get(base_name, {}):
        existing_file = file_groups[base_name][lang_code]
        headers, rows = read_csv_file(existing_file)

        # Update existing rows
        key_to_row = {row[0]: idx for idx, row in enumerate(rows) if row}
        for key, value in translations.items():
            if key in key_to_row:
                row_idx = key_to_row[key]
                if len(rows[row_idx]) > 1:
                    rows[row_idx][1] = value
            else:
                # Add new row
                rows.append([key, value])

        write_csv_file(lang_file, headers, rows)
    else:
        # Create new file from English source
        english_translations = get_english_translations(base_name, file_groups)
        headers = ['keys', lang_code]
        rows = []
        for key, en_value in english_translations.items():
            value = translations.get(key, en_value)  # Use translation if available, else English
            rows.append([key, value])

        write_csv_file(lang_file, headers, rows)


# ═══════════════════════════════════════════════════════════
# MODE 1: CHECK TRANSLATIONS
# ═══════════════════════════════════════════════════════════

def check_translations(specific_file=None):
    """Check all CSV files for untranslated content."""
    csv_files = get_csv_files(specific_file, use_combined=False)

    if not csv_files:
        print("No CSV files found to check")
        return

    total_untranslated = 0
    files_with_issues = 0
    missing_languages = defaultdict(set)

    print("=" * 80)
    print("TRANSLATION CHECK REPORT")
    print("=" * 80)

    for csv_file in csv_files:
        headers, rows = read_csv_file(csv_file)

        if not headers or not rows:
            continue

        # Check for missing language columns
        for lang_code in LANGUAGE_ORDER:
            if get_language_index(headers, lang_code) == -1:
                missing_languages[csv_file.name].add(lang_code)

        untranslated = find_untranslated_cells(headers, rows)

        if untranslated:
            files_with_issues += 1
            key_idx = get_language_index(headers, 'keys')

            print(f"\n📄 {csv_file.name}")
            print("-" * 60)

            # Group by key for clearer output
            for row_idx, langs in sorted(untranslated.items()):
                key = rows[row_idx][key_idx] if key_idx != -1 and key_idx < len(rows[row_idx]) else f"row_{row_idx}"
                en_value = list(langs.values())[0]

                # Truncate long values
                display_value = en_value[:50] + "..." if len(en_value) > 50 else en_value
                display_value = display_value.replace('\n', '\\n')

                print(f"  {key}")
                print(f"    EN: {display_value}")
                print(f"    Missing: {', '.join(sorted(langs.keys()))} ({len(langs)} languages)")

                total_untranslated += len(langs)

    print("\n" + "=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print(f"Files checked: {len(csv_files)}")
    print(f"Files with untranslated content: {files_with_issues}")
    print(f"Total untranslated cells: {total_untranslated}")

    if missing_languages:
        print(f"\nFiles missing language columns:")
        for filename, langs in sorted(missing_languages.items()):
            print(f"  {filename}: {', '.join(sorted(langs))}")

    if total_untranslated == 0 and not missing_languages:
        print("\n✅ All translations are complete!")
    else:
        print(f"\n⚠️  Found {total_untranslated} cells that need translation")
        if missing_languages:
            print(f"   Run with --add-columns to add missing language columns")
        print("   Run without --check to translate them")


# ═══════════════════════════════════════════════════════════
# MODE 2: TRANSLATE WITH GEMINI API
# ═══════════════════════════════════════════════════════════

class ProgressTracker:
    """Track and display real-time progress."""

    def __init__(self, total_cells, total_files):
        import asyncio
        self.total_cells = total_cells
        self.total_files = total_files
        self.completed_cells = 0
        self.completed_files = 0
        self.api_requests = 0
        self.input_tokens = 0
        self.output_tokens = 0
        self.start_time = time.time()
        self.lock = asyncio.Lock()

    async def update(self, cells_translated, input_tokens=0, output_tokens=0):
        async with self.lock:
            self.completed_cells += cells_translated
            self.api_requests += 1
            self.input_tokens += input_tokens
            self.output_tokens += output_tokens
            self._print_status()

    async def complete_file(self):
        async with self.lock:
            self.completed_files += 1

    def _print_status(self):
        elapsed = time.time() - self.start_time
        rate = self.completed_cells / elapsed * 60 if elapsed > 0 else 0
        req_rate = self.api_requests / elapsed * 60 if elapsed > 0 else 0

        status = (
            f"\r📄 Files: {self.completed_files}/{self.total_files} | "
            f"📝 Cells: {self.completed_cells}/{self.total_cells} | "
            f"⚡ {rate:.0f} cells/min | "
            f"🔄 {req_rate:.0f} req/min | "
            f"🎯 Tokens: {self.input_tokens + self.output_tokens:,}"
        )

        sys.stdout.write(status.ljust(140))
        sys.stdout.flush()

    def print_final(self):
        elapsed = time.time() - self.start_time
        print(f"\n\n{'=' * 80}")
        print(f"✅ Translation complete!")
        print(f"   Files processed: {self.completed_files}/{self.total_files}")
        print(f"   Cells translated: {self.completed_cells}")
        print(f"   API requests made: {self.api_requests}")
        print(f"   Total tokens used: {self.input_tokens + self.output_tokens:,}")
        print(f"      Input tokens: {self.input_tokens:,}")
        print(f"      Output tokens: {self.output_tokens:,}")
        print(f"   Time elapsed: {elapsed:.1f} seconds")
        if elapsed > 0:
            print(f"   Average rate: {self.completed_cells / elapsed * 60:.1f} cells/minute")


class RateLimiter:
    """Token bucket rate limiter for API requests."""

    def __init__(self, requests_per_minute):
        import asyncio
        self.max_tokens = requests_per_minute
        self.tokens = requests_per_minute
        self.refill_rate = requests_per_minute / 60.0
        self.last_refill = time.time()
        self.lock = asyncio.Lock()

    async def acquire(self):
        import asyncio
        while True:
            async with self.lock:
                now = time.time()
                elapsed = now - self.last_refill
                self.tokens = min(self.max_tokens, self.tokens + elapsed * self.refill_rate)
                self.last_refill = now

                if self.tokens >= 1:
                    self.tokens -= 1
                    return

            await asyncio.sleep(0.1)


async def translate_batch_async(session, texts_dict, target_language, semaphore, rate_limiter, max_retries=3):
    """Translate a batch of texts using Gemini API with retry logic.

    Args:
        texts_dict: {key: english_text}
        target_language: Full language name (e.g., "German")
        max_retries: Number of retry attempts for failed requests

    Returns: (translations_dict, input_tokens, output_tokens)
    """
    import aiohttp
    import asyncio as aio

    async with semaphore:
        for attempt in range(max_retries):
            await rate_limiter.acquire()

            texts_to_translate = [f"{key}: {value}" for key, value in texts_dict.items()]

            prompt = f"""Translate these game UI texts from English to {target_language} for a game called "Spud Customs".

Game context: {GAME_CONTEXT}

Rules:
- Keep formatting codes: {{variable}}, [color=#code], [b], [/b], %d, %s, %.0f, \\n
- Keep symbols like ⏸ ✅ 🎯 but translate surrounding text
- Maintain the tone (professional for UI, dramatic for alerts)
- Return ONLY key: translation format, one per line
- No explanations or extra text

{chr(10).join(texts_to_translate)}"""

            payload = {
                "contents": [{
                    "parts": [{
                        "text": prompt
                    }]
                }],
                "generationConfig": {
                    "temperature": 0.3,
                    "topK": 40,
                    "topP": 0.95,
                    "maxOutputTokens": 8192,
                }
            }

            try:
                async with session.post(
                    GEMINI_API_URL,
                    json=payload,
                    timeout=aiohttp.ClientTimeout(total=60)
                ) as response:
                    # Handle rate limiting with retry
                    if response.status == 429:
                        wait_time = 2 ** attempt
                        await aio.sleep(wait_time)
                        continue

                    response.raise_for_status()
                    result = await response.json()

                    usage = result.get('usageMetadata', {})
                    input_tokens = usage.get('promptTokenCount', 0)
                    output_tokens = usage.get('candidatesTokenCount', 0)

                    if 'candidates' not in result or len(result['candidates']) == 0:
                        return {}, input_tokens, output_tokens

                    candidate = result['candidates'][0]

                    if candidate.get('finishReason') == 'SAFETY':
                        print(f"\n⚠️  Safety filter triggered for {target_language}")
                        return {}, input_tokens, output_tokens

                    if 'content' not in candidate:
                        return {}, input_tokens, output_tokens

                    content = candidate['content']

                    if 'parts' not in content or len(content['parts']) == 0:
                        return {}, input_tokens, output_tokens

                    translated_text = content['parts'][0].get('text', '')

                    if not translated_text:
                        return {}, input_tokens, output_tokens

                    # Parse the response
                    translations = {}
                    for line in translated_text.strip().split('\n'):
                        if ':' in line:
                            key, value = line.split(':', 1)
                            key = key.strip()
                            value = value.strip()
                            if key in texts_dict:
                                translations[key] = value

                    return translations, input_tokens, output_tokens

            except aiohttp.ClientError as e:
                if attempt < max_retries - 1:
                    wait_time = 2 ** attempt
                    await aio.sleep(wait_time)
                    continue
                print(f"\n❌ API error for {target_language} after {max_retries} attempts: {e}")
                return {}, 0, 0
            except Exception as e:
                print(f"\n❌ Unexpected error for {target_language}: {e}")
                return {}, 0, 0

        return {}, 0, 0


async def translate_file_async(session, csv_file, semaphore, rate_limiter, progress, dry_run=False):
    """Translate a single CSV file with parallel language processing."""
    import asyncio as aio

    headers, rows = read_csv_file(csv_file)

    if not headers or not rows:
        return

    untranslated = find_untranslated_cells(headers, rows)

    if not untranslated:
        await progress.complete_file()
        return

    # Group by language for efficient batching
    by_language = defaultdict(dict)
    key_idx = get_language_index(headers, 'keys')

    for row_idx, langs in untranslated.items():
        key = rows[row_idx][key_idx] if key_idx != -1 and key_idx < len(rows[row_idx]) else f"row_{row_idx}"
        for lang_code, en_value in langs.items():
            by_language[lang_code][(row_idx, key)] = en_value

    if dry_run:
        print(f"\n📄 {csv_file.name} - Would translate:")
        for lang_code, items in by_language.items():
            print(f"   {LANGUAGE_COLUMNS.get(lang_code, lang_code)}: {len(items)} items")
        await progress.complete_file()
        return

    # Create all translation tasks for parallel execution
    translation_tasks = []
    task_metadata = []  # Store (lang_code, batch_items) for each task

    for lang_code, items in by_language.items():
        lang_name = LANGUAGE_COLUMNS.get(lang_code, lang_code)
        items_list = list(items.items())

        for i in range(0, len(items_list), BATCH_SIZE):
            batch = dict(items_list[i:i + BATCH_SIZE])
            batch_for_api = {key: value for (row_idx, key), value in batch.items()}

            task = translate_batch_async(
                session, batch_for_api, lang_name, semaphore, rate_limiter
            )
            translation_tasks.append(task)
            task_metadata.append((lang_code, batch))

    # Execute all translation tasks in parallel
    results = await aio.gather(*translation_tasks)

    # Apply all translations to rows
    modified = False
    for (lang_code, batch), (translations, input_tokens, output_tokens) in zip(task_metadata, results):
        lang_idx = get_language_index(headers, lang_code)

        # Add column if missing
        if lang_idx == -1:
            headers.append(lang_code)
            lang_idx = len(headers) - 1
            for row in rows:
                row.append('')

        if translations:
            for (row_idx, key), en_value in batch.items():
                if key in translations:
                    # Extend row if needed
                    while len(rows[row_idx]) <= lang_idx:
                        rows[row_idx].append('')
                    rows[row_idx][lang_idx] = translations[key]
                    modified = True

        await progress.update(len(translations), input_tokens, output_tokens)

    # Write back to file if modified
    if modified:
        write_csv_file(csv_file, headers, rows)

    await progress.complete_file()


async def translate_with_gemini_async(specific_file=None, dry_run=False):
    """Main async translation function."""
    import asyncio
    import aiohttp

    # Check for API key
    if not GEMINI_API_KEY:
        print("❌ ERROR: GEMINI_API_KEY environment variable is not set!")
        print("")
        print("To set it on Windows (Command Prompt):")
        print('    set GEMINI_API_KEY=your_api_key_here')
        print("")
        print("To set it on Windows (PowerShell):")
        print('    $env:GEMINI_API_KEY="your_api_key_here"')
        print("")
        print("To set it permanently on Windows:")
        print("    1. Press Win+R, type 'sysdm.cpl', press Enter")
        print("    2. Go to Advanced tab → Environment Variables")
        print("    3. Under User variables, click New")
        print("    4. Variable name: GEMINI_API_KEY")
        print("    5. Variable value: your_api_key_here")
        print("")
        print("Get your API key from: https://aistudio.google.com/apikey")
        return

    csv_files = get_csv_files(specific_file, use_combined=False)

    if not csv_files:
        print("No CSV files found to translate")
        return

    print("🚀 Starting Gemini Translation Service for Spud Customs")
    print(f"   Model: {GEMINI_MODEL}")
    print(f"   Rate limit: {MAX_REQUESTS_PER_MINUTE} requests/minute")
    print(f"   Batch size: {BATCH_SIZE} keys per request")
    print(f"   Max concurrent: {MAX_CONCURRENT_REQUESTS} requests")
    print(f"   Languages: {len(LANGUAGE_COLUMNS)} target languages")
    print()

    # Count total untranslated cells
    total_cells = 0
    files_to_process = []

    for csv_file in csv_files:
        headers, rows = read_csv_file(csv_file)
        if headers and rows:
            untranslated = find_untranslated_cells(headers, rows)
            cell_count = sum(len(langs) for langs in untranslated.values())
            if cell_count > 0:
                total_cells += cell_count
                files_to_process.append((csv_file, cell_count))

    if total_cells == 0:
        print("✅ All translations are already complete!")
        return

    print(f"📊 Found {total_cells} untranslated cells across {len(files_to_process)} files:")
    for csv_file, count in files_to_process:
        print(f"   {csv_file.name}: {count} cells")
    print()

    if dry_run:
        print("🔍 DRY RUN - No changes will be made\n")

    # Initialize progress tracker
    progress = ProgressTracker(total_cells, len(files_to_process))

    # Set up rate limiting and concurrency
    semaphore = asyncio.Semaphore(MAX_CONCURRENT_REQUESTS)
    rate_limiter = RateLimiter(MAX_REQUESTS_PER_MINUTE)

    # Create aiohttp session with higher connection limit
    connector = aiohttp.TCPConnector(limit=MAX_CONCURRENT_REQUESTS)
    async with aiohttp.ClientSession(connector=connector) as session:
        tasks = [
            translate_file_async(session, csv_file, semaphore, rate_limiter, progress, dry_run)
            for csv_file, _ in files_to_process
        ]

        await asyncio.gather(*tasks)

    if not dry_run:
        progress.print_final()


# ═══════════════════════════════════════════════════════════
# MODE: TRANSLATE PER-LANGUAGE FILES WITH GEMINI
# ═══════════════════════════════════════════════════════════

async def translate_per_language_base_async(session, base_name, file_groups, semaphore, rate_limiter, progress, dry_run=False):
    """Translate a single translation group (base name) in per-language format."""
    import asyncio as aio

    english_translations = get_english_translations(base_name, file_groups)
    if not english_translations:
        await progress.complete_file()
        return

    # Collect all translations needed for each language
    by_language = {}
    for lang_code in LANGUAGE_COLUMNS.keys():
        untranslated = find_untranslated_per_language(base_name, file_groups, lang_code)
        if untranslated:
            by_language[lang_code] = untranslated

    if not by_language:
        await progress.complete_file()
        return

    if dry_run:
        print(f"\n📄 {base_name} - Would translate:")
        for lang_code, items in by_language.items():
            lang_name = LANGUAGE_COLUMNS.get(lang_code, lang_code)
            print(f"   {lang_name}: {len(items)} items")
        await progress.complete_file()
        return

    # Create all translation tasks for parallel execution
    translation_tasks = []
    task_metadata = []  # Store (lang_code, batch_keys) for each task

    for lang_code, untranslated_dict in by_language.items():
        lang_name = LANGUAGE_COLUMNS.get(lang_code, lang_code)
        items_list = list(untranslated_dict.items())

        for i in range(0, len(items_list), BATCH_SIZE):
            batch = dict(items_list[i:i + BATCH_SIZE])

            task = translate_batch_async(
                session, batch, lang_name, semaphore, rate_limiter
            )
            translation_tasks.append(task)
            task_metadata.append((lang_code, batch))

    # Execute all translation tasks in parallel
    results = await aio.gather(*translation_tasks)

    # Collect all translations by language
    lang_translations = defaultdict(dict)
    for (lang_code, batch), (translations, input_tokens, output_tokens) in zip(task_metadata, results):
        if translations:
            lang_translations[lang_code].update(translations)
        await progress.update(len(translations), input_tokens, output_tokens)

    # Write translations to per-language files
    for lang_code, translations in lang_translations.items():
        if translations:
            write_per_language_file(base_name, lang_code, translations, file_groups)

    await progress.complete_file()


async def translate_per_language_async(specific_base=None, dry_run=False):
    """Main async translation function for per-language files."""
    import asyncio
    import aiohttp

    # Check for API key
    if not GEMINI_API_KEY:
        print("❌ ERROR: GEMINI_API_KEY environment variable is not set!")
        print("")
        print("To set it on Linux/Mac:")
        print('    export GEMINI_API_KEY="your_api_key_here"')
        print("")
        print("Get your API key from: https://aistudio.google.com/apikey")
        return

    file_groups = group_per_language_files()

    if not file_groups:
        print("No per-language files found in translations/per_language/")
        return

    if specific_base:
        if specific_base not in file_groups:
            print(f"ERROR: No files found for base name: {specific_base}")
            return
        file_groups = {specific_base: file_groups[specific_base]}

    print("🚀 Starting Gemini Translation Service for Spud Customs (Per-Language Mode)")
    print(f"   Model: {GEMINI_MODEL}")
    print(f"   Rate limit: {MAX_REQUESTS_PER_MINUTE} requests/minute")
    print(f"   Batch size: {BATCH_SIZE} keys per request")
    print(f"   Max concurrent: {MAX_CONCURRENT_REQUESTS} requests")
    print(f"   Languages: {len(LANGUAGE_COLUMNS)} target languages")
    print()

    # Count total untranslated cells
    total_cells = 0
    bases_to_process = []

    for base_name, lang_files in file_groups.items():
        if 'en' not in lang_files:
            continue  # Skip bases without English source

        base_cells = 0
        for lang_code in LANGUAGE_COLUMNS.keys():
            untranslated = find_untranslated_per_language(base_name, file_groups, lang_code)
            base_cells += len(untranslated)

        if base_cells > 0:
            total_cells += base_cells
            bases_to_process.append((base_name, base_cells))

    if total_cells == 0:
        print("✅ All per-language translations are already complete!")
        return

    print(f"📊 Found {total_cells} untranslated cells across {len(bases_to_process)} translation groups:")
    for base_name, count in sorted(bases_to_process, key=lambda x: -x[1])[:10]:
        print(f"   {base_name}: {count} cells")
    if len(bases_to_process) > 10:
        print(f"   ... and {len(bases_to_process) - 10} more groups")
    print()

    if dry_run:
        print("🔍 DRY RUN - No changes will be made\n")

    # Initialize progress tracker
    progress = ProgressTracker(total_cells, len(bases_to_process))

    # Set up rate limiting and concurrency
    semaphore = asyncio.Semaphore(MAX_CONCURRENT_REQUESTS)
    rate_limiter = RateLimiter(MAX_REQUESTS_PER_MINUTE)

    # Create aiohttp session with higher connection limit
    connector = aiohttp.TCPConnector(limit=MAX_CONCURRENT_REQUESTS)
    async with aiohttp.ClientSession(connector=connector) as session:
        tasks = [
            translate_per_language_base_async(
                session, base_name, file_groups, semaphore, rate_limiter, progress, dry_run
            )
            for base_name, _ in bases_to_process
        ]

        await asyncio.gather(*tasks)

    if not dry_run:
        progress.print_final()


# ═══════════════════════════════════════════════════════════
# MAIN CLI INTERFACE
# ═══════════════════════════════════════════════════════════

def main():
    """Main entry point with CLI argument parsing."""
    parser = argparse.ArgumentParser(
        description='Translation management tool for Spud Customs',
        epilog='''
Examples:
  %(prog)s                      # Translate per-language files (default)
  %(prog)s --check              # Check for missing/untranslated content
  %(prog)s --base menus         # Translate specific base name only
  %(prog)s --dry-run            # Preview what would be translated
  %(prog)s --list-languages     # List all supported Steam languages
        ''',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument('--check', action='store_true',
                        help='Check for untranslated content without translating')
    parser.add_argument('--file', type=str, metavar='FILENAME',
                        help='Process only a specific CSV file (combined mode)')
    parser.add_argument('--base', type=str, metavar='BASENAME',
                        help='Process only a specific base name (e.g., menus, game, passport)')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be translated without making changes')
    parser.add_argument('--split', action='store_true',
                        help='Split combined CSVs into per-language files')
    parser.add_argument('--merge', action='store_true',
                        help='Merge per-language files into combined CSVs')
    parser.add_argument('--install', action='store_true',
                        help='Copy combined CSVs to translations/ root for Godot import')
    parser.add_argument('--combined', action='store_true',
                        help='Use combined CSV mode instead of per-language mode')
    parser.add_argument('--add-columns', action='store_true',
                        help='Add missing language columns to existing CSVs')
    parser.add_argument('--list-languages', action='store_true',
                        help='List all supported Steam languages')

    args = parser.parse_args()

    # Handle different modes
    if args.list_languages:
        print("=" * 80)
        print("ALL STEAM SUPPORTED LANGUAGES (31 total)")
        print("=" * 80)
        print(f"{'Code':<10} {'Language Name':<30} {'Native Name':<20}")
        print("-" * 60)
        for code in LANGUAGE_ORDER:
            name, native = ALL_STEAM_LANGUAGES[code]
            print(f"{code:<10} {name:<30} {native:<20}")
        return

    if args.split:
        split_all_csvs()
        return

    if args.merge:
        merge_per_language_to_combined()
        return

    if args.install:
        install_to_godot()
        return

    if args.add_columns:
        add_all_missing_columns()
        return

    # Determine mode: per-language (default) or combined
    # Per-language mode works with files like menus_en.csv, menus_de.csv (one file per language)
    # Combined mode works with files like menus.csv (all languages in one file)
    use_combined = args.combined or args.file is not None

    if args.check:
        if use_combined:
            check_translations(args.file)
        else:
            check_per_language_translations(args.base)
    else:
        try:
            import asyncio
            if use_combined:
                asyncio.run(translate_with_gemini_async(args.file, args.dry_run))
            else:
                asyncio.run(translate_per_language_async(args.base, args.dry_run))
        except ImportError as e:
            if 'aiohttp' in str(e):
                print("❌ aiohttp is required for translation. Install with: pip install aiohttp")
            else:
                raise
        except KeyboardInterrupt:
            print("\n\n⚠️  Translation interrupted by user")


if __name__ == '__main__':
    main()
