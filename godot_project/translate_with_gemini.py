#!/usr/bin/env python3
"""
Comprehensive translation management tool for Starbrew Station.
Handles translation checking, fixing, API translation, and manual overrides.

Usage:
    python translate_with_gemini.py                    # Translate ALL untranslated keys
    python translate_with_gemini.py --check            # Check for missing/untranslated keys
    python translate_with_gemini.py --fix              # Add missing keys with English placeholders
    python translate_with_gemini.py --fix --translate  # Fix then translate (recommended workflow)
    python translate_with_gemini.py --apply-manual     # Apply hardcoded manual translations

Note: The translate function now automatically detects ALL keys that match English values
and translates them, rather than using a hardcoded list.
"""

import asyncio
import aiohttp
import argparse
import csv
import json
import sys
import time
from pathlib import Path
from collections import defaultdict

# ═══════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════

# Gemini API configuration
# NOTE: API key has a hard budget set and is used in a private repo only
GEMINI_API_KEY = "AIzaSyAi3h86O6Uac8YdoYizn5dyQ0Gb6UrwFs0"
GEMINI_API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key={GEMINI_API_KEY}"

# Rate limiting: 120 requests per minute (staying under 150 limit)
MAX_REQUESTS_PER_MINUTE = 120
REQUEST_INTERVAL = 60.0 / MAX_REQUESTS_PER_MINUTE  # ~0.5 seconds between requests

# Language mapping
LANGUAGE_NAMES = {
    'ar': 'Arabic',
    'bg': 'Bulgarian',
    'cs': 'Czech',
    'da': 'Danish',
    'de': 'German',
    'el': 'Greek',
    'es': 'Spanish',
    'fi': 'Finnish',
    'fr': 'French',
    'hu': 'Hungarian',
    'id': 'Indonesian',
    'it': 'Italian',
    'ja': 'Japanese',
    'ko': 'Korean',
    'nl': 'Dutch',
    'no': 'Norwegian',
    'pl': 'Polish',
    'pt': 'Portuguese',
    'pt_br': 'Brazilian Portuguese',
    'ro': 'Romanian',
    'ru': 'Russian',
    'sv': 'Swedish',
    'th': 'Thai',
    'tr': 'Turkish',
    'uk': 'Ukrainian',
    'vi': 'Vietnamese',
    'zh_cn': 'Simplified Chinese',
    'zh_tw': 'Traditional Chinese'
}

# DEPRECATED: This list is kept for historical reference only
# The translate function now dynamically detects ALL untranslated keys
# instead of using this hardcoded list
KEYS_TO_TRANSLATE = [
    # Original keys
    'UI_PAUSE_BUTTON',
    'UI_PAUSE_TOOLTIP',
    'DAILY_REWARD_STREAK_BONUS',
    'DAILY_REWARD_TIMER_TEXT',
    'DAILY_REWARD_TIMER_TITLE',
    'PRESTIGE_TOOLTIP_NEXT_MILESTONE',
    'PRESTIGE_TOOLTIP_READY',
    'UNIT_DECK1_PATRON1_NAME',
    'UNIT_DECK1_PATRON1_DESC',
    'UNIT_DECK3_BARISTA1_NAME',
    'UNIT_DECK3_BARISTA1_DESC',
    'UNIT_DECK4_BARISTA1_NAME',
    'UNIT_DECK4_BARISTA1_DESC',
    'UNIT_DECK5_SUPPORT1_NAME',
    'UNIT_DECK5_SUPPORT1_DESC',
    'TUTORIAL_STEP1_TEXT',
    # Community Vote keys (added Nov 2025)
    'COMMUNITY_VOTE_BUTTON',
    'COMMUNITY_VOTE_COUNT',
    'COMMUNITY_VOTE_SUBTITLE',
    'COMMUNITY_VOTE_THANKS',
    'COMMUNITY_VOTE_TITLE',
    'COMMUNITY_VOTE_YOUR_VOTE',
    'ACHIEVEMENT_UNLOCKED',
    'NOTIFICATION_CONTINUE',
    # Next Goals keys
    'NEXT_GOALS_TITLE',
    'NEXT_GOALS_ACHIEVEMENT',
    'NEXT_GOALS_ALL_COMPLETE',
    'NEXT_GOALS_BUILDING_DECK',
    'NEXT_GOALS_DECK_PROGRESS',
    'NEXT_GOALS_DECK_READY',
    'NEXT_GOALS_KEEP_BUILDING',
    'NEXT_GOALS_PRESTIGE_AVAILABLE',
    'NEXT_GOALS_PRESTIGE_PROGRESS',
    'NEXT_GOALS_UNLOCK_DECK_5',
    # Filter keys
    'FILTER_ALL',
    'FILTER_BARISTA',
    'FILTER_FIGHTER',
    'FILTER_PATRON',
    'FILTER_SUPPORT',
    'FILTER_TECHNICIAN',
    # Stats/Production keys
    'STATS_PRODUCTION_BREAKDOWN',
    'STATS_TOP_PRODUCERS',
    'STATS_TOTAL_PRODUCTION',
    'STATS_GRAPH_1MIN',
    'UI_PRODUCTION_NO_BREAKDOWN',
    'BUY_AMOUNT_LABEL',
    # Prestige keys
    'PRESTIGE_HISTORY_TITLE',
    'PRESTIGE_NO_HISTORY',
    'PRESTIGE_VIEW_HISTORY',
    'PRESTIGE_TOKENS_ON_PRESTIGE',
    'PRESTIGE_UPGRADE_AUTO_CLICK_SPEED_NAME',
    'PRESTIGE_UPGRADE_AUTO_CLICK_SPEED_DESC',
    'PRESTIGE_UPGRADE_HOLD_BREW_SPEED_NAME',
    'PRESTIGE_UPGRADE_HOLD_BREW_SPEED_DESC',
    'PRESTIGE_UPGRADE_MANUAL_CLICK_RADIUS_NAME',
    'PRESTIGE_UPGRADE_MANUAL_CLICK_RADIUS_DESC',
    # Deck locking keys
    'DECK_LOCKED_COMPLETE_PREVIOUS',
    'DECK_LOCKED_USE_BUOY',
    # Tutorial keys
    'TUTORIAL_CLICKABLE_REWARDS',
    'TUTORIAL_TOKEN_SHOP',
    # Other keys
    'RUN_MODIFIERS',
    'VERSION_TAG',
    # Twitch Integration keys (untranslated)
    'TWITCH_CONFIG_TITLE',
    'TWITCH_CONFIG_ENABLE',
    'TWITCH_CONFIG_CHANNEL',
    'TWITCH_CONFIG_CONNECT',
    'TWITCH_CONFIG_DISCONNECT',
    'TWITCH_CONFIG_SAVE',
    'TWITCH_CONFIG_VIEWER_NAMES',
    'TWITCH_CONFIG_CHAT_BONUS',
    'TWITCH_TOOLTIP',
    'TWITCH_STATUS_CONNECTED',
    'TWITCH_STATUS_DISCONNECTED',
    'TWITCH_CHAT_BONUS_NOTIFICATION',
    'TWITCH_CHAT_BONUS_AMOUNT',
    # Auto-prestige keys
    'AUTO_PRESTIGE_MINIMUM_LABEL',
    'AUTO_PRESTIGE_MINIMUM_DESC',
    'AUTO_PRESTIGE_MINIMUM_TOOLTIP',
    'AUTO_PRESTIGE_TRIGGERED',
    # Stats graph keys
    'STATS_GRAPH_5MIN',
    'STATS_GRAPH_10MIN',
    'STATS_GRAPH_15MIN',
    'STATS_PRODUCTION_GRAPH',
    'STATS_GRAPH_WAITING',
]

# ═══════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════

def read_csv_lines(filepath):
    """Read CSV file preserving all lines."""
    with open(filepath, 'r', encoding='utf-8-sig') as f:
        return f.readlines()


def parse_csv_to_dict(lines):
    """Parse CSV lines into a dictionary."""
    data = {}
    for line in lines:
        line_stripped = line.strip()
        if line_stripped and not line_stripped.startswith('#') and ',' in line_stripped:
            parts = line_stripped.split(',', 1)
            if len(parts) == 2:
                key = parts[0].strip()
                value = parts[1].strip()
                if key and key != 'keys':
                    data[key] = value
    return data


def parse_csv_keys_with_positions(lines):
    """Extract keys and their line positions from CSV lines."""
    keys_with_values = {}
    for i, line in enumerate(lines):
        line_stripped = line.strip()
        if line_stripped and not line_stripped.startswith('#') and ',' in line_stripped:
            parts = line_stripped.split(',', 1)
            if len(parts) >= 2:
                key = parts[0].strip()
                value = parts[1].strip() if len(parts) > 1 else ''
                if key and key != 'keys':
                    keys_with_values[key] = (value, i)
    return keys_with_values


def get_english_values(keys_filter=None):
    """Get English values for keys that need translation."""
    script_dir = Path(__file__).parent.resolve()
    en_file = script_dir / 'translations' / 'starbrew_en.csv'
    lines = read_csv_lines(en_file)
    en_data = parse_csv_to_dict(lines)

    if keys_filter:
        return {key: en_data.get(key, '') for key in keys_filter if key in en_data}
    return en_data


# ═══════════════════════════════════════════════════════════
# MODE 1: CHECK TRANSLATIONS
# ═══════════════════════════════════════════════════════════

def check_translations():
    """Comprehensive check of all translations."""
    script_dir = Path(__file__).parent.resolve()
    translations_dir = script_dir / 'translations'

    # Read English reference
    en_file = translations_dir / 'starbrew_en.csv'
    if not en_file.exists():
        print(f"ERROR: English reference file not found: {en_file}")
        return

    en_translations = parse_csv_to_dict(read_csv_lines(en_file))
    en_keys = set(en_translations.keys())

    print(f"English reference has {len(en_keys)} keys")
    print("=" * 80)

    csv_files = sorted(translations_dir.glob('starbrew_*.csv'))
    all_missing_keys = set()
    untranslated_report = defaultdict(list)

    for csv_file in csv_files:
        if csv_file.name == 'starbrew_en.csv':
            continue

        lang_code = csv_file.stem.replace('starbrew_', '')
        file_translations = parse_csv_to_dict(read_csv_lines(csv_file))
        file_keys = set(file_translations.keys())

        # Track missing keys
        missing_keys = en_keys - file_keys
        all_missing_keys.update(missing_keys)

        # Check for untranslated values (still in English)
        untranslated_keys = []
        for key in file_keys:
            if key in en_translations:
                en_value = en_translations[key]
                file_value = file_translations[key]
                # Check if value is same as English (untranslated)
                # Exclude single characters/symbols that might legitimately be the same
                if file_value == en_value and len(en_value) > 3:
                    untranslated_keys.append(key)

        if untranslated_keys:
            untranslated_report[lang_code] = untranslated_keys

    # Report missing keys
    print("\n📋 MISSING KEYS:")
    print("-" * 80)
    if all_missing_keys:
        for i, key in enumerate(sorted(all_missing_keys), 1):
            en_value = en_translations.get(key, "")
            if len(en_value) > 60:
                en_value = en_value[:57] + "..."
            print(f"{i:2}. {key}")
            print(f"    EN: {en_value}")
    else:
        print("✅ No missing keys found!")

    # Report untranslated values
    print("\n\n📋 UNTRANSLATED VALUES (values identical to English):")
    print("=" * 80)

    if not untranslated_report:
        print("✅ No untranslated values found!")
    else:
        # Group by key to see which keys are untranslated across languages
        keys_by_language_count = defaultdict(list)
        for lang, keys in untranslated_report.items():
            for key in keys:
                keys_by_language_count[key].append(lang)

        # Sort by number of languages affected
        sorted_keys = sorted(keys_by_language_count.items(), key=lambda x: -len(x[1]))

        print(f"\nKeys with untranslated values (total unique keys: {len(sorted_keys)}):")
        print("-" * 80)

        for key, langs in sorted_keys[:50]:  # Show top 50
            en_value = en_translations.get(key, "")
            if len(en_value) > 50:
                en_value = en_value[:47] + "..."
            print(f"\n{key}")
            print(f"  EN: {en_value}")
            print(f"  Untranslated in {len(langs)} languages: {', '.join(sorted(langs)[:10])}", end="")
            if len(langs) > 10:
                print(f"... and {len(langs) - 10} more")
            else:
                print()

        if len(sorted_keys) > 50:
            print(f"\n... and {len(sorted_keys) - 50} more keys with untranslated values")

        # Summary by language
        print("\n\n📊 SUMMARY BY LANGUAGE:")
        print("-" * 80)
        for lang in sorted(untranslated_report.keys()):
            count = len(untranslated_report[lang])
            print(f"  {lang.upper():8} : {count} untranslated values")


# ═══════════════════════════════════════════════════════════
# MODE 2: FIX TRANSLATIONS (Add Missing Keys)
# ═══════════════════════════════════════════════════════════

def find_insertion_position(lines, key_to_insert, en_keys_order, file_keys):
    """Find the best position to insert a missing key based on English file order."""
    en_keys_list = list(en_keys_order.keys())

    try:
        target_index = en_keys_list.index(key_to_insert)
    except ValueError:
        return len(lines)

    # Find the nearest existing key before the target
    for i in range(target_index - 1, -1, -1):
        prev_key = en_keys_list[i]
        if prev_key in file_keys:
            _, line_num = file_keys[prev_key]
            return line_num + 1

    # If no previous key found, find the nearest key after
    for i in range(target_index + 1, len(en_keys_list)):
        next_key = en_keys_list[i]
        if next_key in file_keys:
            _, line_num = file_keys[next_key]
            return line_num

    return len(lines)


def fix_translation_file(filepath, missing_keys, en_translations):
    """Add missing keys to a translation file."""
    lines = read_csv_lines(filepath)
    file_keys = parse_csv_keys_with_positions(lines)

    lang_code = Path(filepath).stem.replace('starbrew_', '')
    insertions = []

    for missing_key in sorted(missing_keys):
        if missing_key in en_translations:
            en_value, _ = en_translations[missing_key]
            insert_pos = find_insertion_position(lines, missing_key, en_translations, file_keys)
            insertions.append((insert_pos, missing_key, en_value))

    # Sort insertions by position (reverse to maintain correct positions)
    insertions.sort(reverse=True, key=lambda x: x[0])

    # Insert missing keys
    for insert_pos, key, value in insertions:
        new_line = f"{key},{value}\n"
        lines.insert(insert_pos, new_line)
        print(f"  Added {key} at line {insert_pos + 1}")

    # Write back to file
    try:
        with open(filepath, 'w', encoding='utf-8-sig', newline='') as f:
            f.writelines(lines)
        return True
    except Exception as e:
        print(f"  ERROR writing file: {e}")
        return False


def fix_translations():
    """Add missing keys to all translation files with English placeholders."""
    script_dir = Path(__file__).parent.resolve()
    translations_dir = script_dir / 'translations'

    print("Loading English translations...")
    en_lines = read_csv_lines(translations_dir / 'starbrew_en.csv')
    en_translations = parse_csv_keys_with_positions(en_lines)
    en_keys_set = set(en_translations.keys())

    csv_files = sorted(translations_dir.glob('starbrew_*.csv'))
    fixed_count = 0

    for csv_file in csv_files:
        if csv_file.name == 'starbrew_en.csv':
            continue

        lang_code = csv_file.stem.replace('starbrew_', '').upper()

        # Read file keys
        lines = read_csv_lines(csv_file)
        file_keys = parse_csv_keys_with_positions(lines)
        file_keys_set = set(file_keys.keys())

        # Find missing keys
        missing_keys = en_keys_set - file_keys_set

        if missing_keys:
            print(f"\nFixing {lang_code} ({csv_file.name})...")
            print(f"  Missing {len(missing_keys)} keys")

            if fix_translation_file(csv_file, missing_keys, en_translations):
                print(f"  ✅ Fixed!")
                fixed_count += 1
            else:
                print(f"  ❌ Failed to fix")
        else:
            print(f"✅ {lang_code} is already up to date")

    print(f"\n{'=' * 80}")
    print(f"Fixed {fixed_count} translation files")


# ═══════════════════════════════════════════════════════════
# MODE 3: APPLY MANUAL TRANSLATIONS
# ═══════════════════════════════════════════════════════════

# Comprehensive manual translations for all languages (from apply_translations.py)
MANUAL_TRANSLATIONS = {
    'ar': {  # Arabic
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'إيقاف مؤقت / القائمة (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 سلسلة {streak} يوم! (مكافأة {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} ساعات {minutes} دقائق',
        'DAILY_REWARD_TIMER_TITLE': '⏰ المكافأة اليومية متاحة في:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'التالي +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] أكواب إضافية',
        'PRESTIGE_TOOLTIP_READY': 'جاهز للمستوى التالي!',
    },
    'bg': {  # Bulgarian
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Пауза / Меню (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 Серия от {streak} дни! (Бонус {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} часа {minutes} минути',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Дневна награда достъпна след:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Следващ +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] още чаши',
        'PRESTIGE_TOOLTIP_READY': 'Готов за следващ етап!',
    },
    'cs': {  # Czech
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Pauza / Menu (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 Série {streak} dní! (Bonus {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} hodin {minutes} minut',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Denní odměna dostupná za:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Další +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] dalších šálků',
        'PRESTIGE_TOOLTIP_READY': 'Připraven na další milník!',
        'UNIT_DECK1_PATRON1_NAME': 'Modrý Kosmonaut',
        'UNIT_DECK1_PATRON1_DESC': 'Mimozemšťan s modrou kůží, který se stal věrným zákazníkem. Vždy má čas na dobrý šálek.',
    },
    'da': {  # Danish
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Pause / Menu (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 {streak} Dages Streak! ({bonus}% Bonus)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} timer {minutes} minutter',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Daglig Belønning Tilgængelig Om:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Næste +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] flere kopper',
        'PRESTIGE_TOOLTIP_READY': 'Klar til næste milepæl!',
    },
    'de': {  # German
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Pause / Menü (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 {streak} Tage Streak! ({bonus}% Bonus)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} Stunden {minutes} Minuten',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Tägliche Belohnung verfügbar in:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Nächster +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] weitere Tassen',
        'PRESTIGE_TOOLTIP_READY': 'Bereit für den nächsten Meilenstein!',
    },
    'el': {  # Greek
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Παύση / Μενού (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 Σειρά {streak} Ημερών! (Μπόνους {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} ώρες {minutes} λεπτά',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Ημερήσια Ανταμοιβή Διαθέσιμη Σε:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Επόμενο +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] ακόμα φλιτζάνια',
        'PRESTIGE_TOOLTIP_READY': 'Έτοιμος για το επόμενο ορόσημο!',
    },
    'es': {  # Spanish
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Pausa / Menú (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 ¡Racha de {streak} días! (Bonificación {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} horas {minutes} minutos',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Recompensa Diaria Disponible En:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Siguiente +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] tazas más',
        'PRESTIGE_TOOLTIP_READY': '¡Listo para el siguiente hito!',
    },
    'fi': {  # Finnish
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Tauko / Valikko (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 {streak} Päivän Putki! ({bonus}% Bonus)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} tuntia {minutes} minuuttia',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Päivittäinen Palkinto Saatavilla:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Seuraava +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] lisää kuppia',
        'PRESTIGE_TOOLTIP_READY': 'Valmis seuraavaan virstanpylvääseen!',
    },
    'fr': {  # French
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Pause / Menu (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 Série de {streak} jours ! (Bonus {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} heures {minutes} minutes',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Récompense Quotidienne Disponible Dans :',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Prochain +{token_gain} : [color=#66DDFF]{coffee_needed}[/color] tasses supplémentaires',
        'PRESTIGE_TOOLTIP_READY': 'Prêt pour le prochain jalon !',
    },
    'hu': {  # Hungarian
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Szünet / Menü (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 {streak} Napos Sorozat! ({bonus}% Bónusz)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} óra {minutes} perc',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Napi Jutalom Elérhető:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Következő +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] további csésze',
        'PRESTIGE_TOOLTIP_READY': 'Készen áll a következő mérföldkőre!',
    },
    'id': {  # Indonesian
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Jeda / Menu (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 Streak {streak} Hari! (Bonus {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} jam {minutes} menit',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Hadiah Harian Tersedia Dalam:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Berikutnya +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] cangkir lagi',
        'PRESTIGE_TOOLTIP_READY': 'Siap untuk pencapaian berikutnya!',
        'UNIT_DECK3_BARISTA1_NAME': 'Brewmaster Flora',
        'UNIT_DECK3_BARISTA1_DESC': 'Makhluk hibrida tanaman yang mencampur kopi dengan senyawa organik untuk rasa yang luar biasa.',
    },
    'it': {  # Italian
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Pausa / Menu (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 Serie di {streak} Giorni! (Bonus {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} ore {minutes} minuti',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Ricompensa Giornaliera Disponibile Tra:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Prossimo +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] tazze in più',
        'PRESTIGE_TOOLTIP_READY': 'Pronto per il prossimo traguardo!',
    },
    'ja': {  # Japanese
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': '一時停止 / メニュー (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 {streak}日連続!({bonus}%ボーナス)',
        'DAILY_REWARD_TIMER_TEXT': '{hours}時間{minutes}分',
        'DAILY_REWARD_TIMER_TITLE': '⏰ デイリー報酬まで:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': '次の +{token_gain}:[color=#66DDFF]{coffee_needed}[/color] カップ追加',
        'PRESTIGE_TOOLTIP_READY': '次のマイルストーンの準備完了!',
    },
    'ko': {  # Korean
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': '일시정지 / 메뉴 (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 {streak}일 연속! ({bonus}% 보너스)',
        'DAILY_REWARD_TIMER_TEXT': '{hours}시간 {minutes}분',
        'DAILY_REWARD_TIMER_TITLE': '⏰ 일일 보상 가능 시간:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': '다음 +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] 컵 더 필요',
        'PRESTIGE_TOOLTIP_READY': '다음 이정표 준비 완료!',
        'UNIT_DECK5_SUPPORT1_NAME': '기술 지원 드론',
        'UNIT_DECK5_SUPPORT1_DESC': '기술자 속도를 30% 최적화하는 최첨단 유지보수 드론.',
    },
    'nl': {  # Dutch
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Pauze / Menu (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 {streak} Dagen Streak! ({bonus}% Bonus)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} uur {minutes} minuten',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Dagelijkse Beloning Beschikbaar Over:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Volgende +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] meer kopjes',
        'PRESTIGE_TOOLTIP_READY': 'Klaar voor de volgende mijlpaal!',
    },
    'no': {  # Norwegian
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Pause / Meny (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 {streak} Dagers Streak! ({bonus}% Bonus)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} timer {minutes} minutter',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Daglig Belønning Tilgjengelig Om:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Neste +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] flere kopper',
        'PRESTIGE_TOOLTIP_READY': 'Klar for neste milepæl!',
    },
    'pl': {  # Polish
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Pauza / Menu (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 Seria {streak} Dni! (Bonus {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} godzin {minutes} minut',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Codzienna Nagroda Dostępna Za:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Następny +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] więcej filiżanek',
        'PRESTIGE_TOOLTIP_READY': 'Gotowy na kolejny kamień milowy!',
    },
    'pt': {  # Portuguese
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Pausar / Menu (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 Sequência de {streak} Dias! (Bónus {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} horas {minutes} minutos',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Recompensa Diária Disponível Em:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Próximo +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] mais chávenas',
        'PRESTIGE_TOOLTIP_READY': 'Pronto para o próximo marco!',
    },
    'pt_br': {  # Brazilian Portuguese
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Pausar / Menu (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 Sequência de {streak} Dias! (Bônus {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} horas {minutes} minutos',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Recompensa Diária Disponível Em:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Próximo +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] mais xícaras',
        'PRESTIGE_TOOLTIP_READY': 'Pronto para o próximo marco!',
    },
    'ro': {  # Romanian
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Pauză / Meniu (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 Serie de {streak} Zile! (Bonus {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} ore {minutes} minute',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Recompensă Zilnică Disponibilă În:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Următorul +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] mai multe căni',
        'PRESTIGE_TOOLTIP_READY': 'Pregătit pentru următorul obiectiv!',
    },
    'ru': {  # Russian
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Пауза / Меню (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 Серия {streak} дней! (Бонус {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} часов {minutes} минут',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Ежедневная награда доступна через:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Следующий +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] ещё чашек',
        'PRESTIGE_TOOLTIP_READY': 'Готов к следующему этапу!',
    },
    'sv': {  # Swedish
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Pausa / Meny (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 {streak} Dagars Streak! ({bonus}% Bonus)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} timmar {minutes} minuter',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Daglig Belöning Tillgänglig Om:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Nästa +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] fler koppar',
        'PRESTIGE_TOOLTIP_READY': 'Redo för nästa milstolpe!',
    },
    'th': {  # Thai
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'หยุดชั่วคราว / เมนู (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 ต่อเนื่อง {streak} วัน! (โบนัส {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} ชั่วโมง {minutes} นาที',
        'DAILY_REWARD_TIMER_TITLE': '⏰ รางวัลประจำวันพร้อมใช้งานใน:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'ถัดไป +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] ถ้วยเพิ่มเติม',
        'PRESTIGE_TOOLTIP_READY': 'พร้อมสำหรับเป้าหมายถัดไป!',
    },
    'tr': {  # Turkish
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Duraklat / Menü (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 {streak} Günlük Seri! (%{bonus} Bonus)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} saat {minutes} dakika',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Günlük Ödül Kullanılabilir:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Sonraki +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] fincan daha',
        'PRESTIGE_TOOLTIP_READY': 'Bir sonraki dönüm noktası için hazır!',
        'TUTORIAL_STEP1_TEXT': 'İlk kahve fincanlarınızı kazanmak için herhangi bir kahve makinesine tıklayın.',
    },
    'uk': {  # Ukrainian
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Пауза / Меню (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 Серія {streak} днів! (Бонус {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} годин {minutes} хвилин',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Щоденна нагорода доступна через:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Наступний +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] ще чашок',
        'PRESTIGE_TOOLTIP_READY': 'Готовий до наступного етапу!',
    },
    'vi': {  # Vietnamese
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': 'Tạm dừng / Menu (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 Chuỗi {streak} Ngày! (Thưởng {bonus}%)',
        'DAILY_REWARD_TIMER_TEXT': '{hours} giờ {minutes} phút',
        'DAILY_REWARD_TIMER_TITLE': '⏰ Phần Thưởng Hàng Ngày Có Sẵn Sau:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': 'Tiếp theo +{token_gain}: [color=#66DDFF]{coffee_needed}[/color] cốc nữa',
        'PRESTIGE_TOOLTIP_READY': 'Sẵn sàng cho cột mốc tiếp theo!',
    },
    'zh_cn': {  # Simplified Chinese
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': '暂停 / 菜单 (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 连续{streak}天!({bonus}%奖励)',
        'DAILY_REWARD_TIMER_TEXT': '{hours}小时{minutes}分钟',
        'DAILY_REWARD_TIMER_TITLE': '⏰ 每日奖励可用时间:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': '下一个 +{token_gain}:[color=#66DDFF]{coffee_needed}[/color] 更多杯',
        'PRESTIGE_TOOLTIP_READY': '准备好迎接下一个里程碑!',
        'TUTORIAL_STEP1_TEXT': '点击任意咖啡机手动冲泡咖啡,赚取你的第一批咖啡杯。',
        'UNIT_DECK4_BARISTA1_NAME': '等离子专家',
        'UNIT_DECK4_BARISTA1_DESC': '利用等离子能量进行超快速冲泡的机械咖啡师。',
    },
    'zh_tw': {  # Traditional Chinese
        'UI_PAUSE_BUTTON': '⏸',
        'UI_PAUSE_TOOLTIP': '暫停 / 選單 (ESC)',
        'DAILY_REWARD_STREAK_BONUS': '🔥 連續{streak}天!({bonus}%獎勵)',
        'DAILY_REWARD_TIMER_TEXT': '{hours}小時{minutes}分鐘',
        'DAILY_REWARD_TIMER_TITLE': '⏰ 每日獎勵可用時間:',
        'PRESTIGE_TOOLTIP_NEXT_MILESTONE': '下一個 +{token_gain}:[color=#66DDFF]{coffee_needed}[/color] 更多杯',
        'PRESTIGE_TOOLTIP_READY': '準備好迎接下一個里程碑!',
        'TUTORIAL_STEP1_TEXT': '點擊任意咖啡機手動沖泡咖啡,賺取你的第一批咖啡杯。',
    },
}


def update_csv_file_with_translations(filepath, translations):
    """Update CSV file with translations."""
    lines = read_csv_lines(filepath)

    updated = False
    for i, line in enumerate(lines):
        line_stripped = line.strip()
        if line_stripped and not line_stripped.startswith('#') and ',' in line_stripped:
            parts = line_stripped.split(',', 1)
            if len(parts) == 2:
                key = parts[0].strip()
                if key in translations:
                    lines[i] = f"{key},{translations[key]}\n"
                    updated = True
                    print(f"  ✓ {key}")

    if updated:
        with open(filepath, 'w', encoding='utf-8-sig', newline='') as f:
            f.writelines(lines)
        return True
    return False


def apply_manual_translations():
    """Apply hardcoded manual translations to all files."""
    script_dir = Path(__file__).parent.resolve()
    translations_dir = script_dir / 'translations'

    translated_count = 0

    for lang_code, translations in MANUAL_TRANSLATIONS.items():
        csv_file = translations_dir / f'starbrew_{lang_code}.csv'

        if not csv_file.exists():
            print(f"⚠️  File not found: {csv_file.name}")
            continue

        print(f"\nUpdating {lang_code.upper()} ({csv_file.name})...")

        if update_csv_file_with_translations(csv_file, translations):
            translated_count += 1
            print(f"  ✅ Updated!")
        else:
            print(f"  ⚠️  No changes made")

    print("\n" + "=" * 80)
    print(f"Manual translations complete! Updated {translated_count} files")


# ═══════════════════════════════════════════════════════════
# MODE 4: TRANSLATE WITH GEMINI API
# ═══════════════════════════════════════════════════════════

class ProgressTracker:
    """Track and display real-time progress."""

    def __init__(self, total_languages, total_batches):
        self.total_languages = total_languages
        self.total_batches = total_batches
        self.completed_languages = 0
        self.completed_batches = 0
        self.successful_keys = 0
        self.failed_keys = 0
        self.api_requests = 0
        self.input_tokens = 0
        self.output_tokens = 0
        self.start_time = time.time()
        self.lock = asyncio.Lock()

    async def update_batch(self, keys_translated, input_tokens=0, output_tokens=0):
        async with self.lock:
            self.completed_batches += 1
            self.successful_keys += keys_translated
            self.api_requests += 1
            self.input_tokens += input_tokens
            self.output_tokens += output_tokens
            self._print_status()

    async def complete_language(self, success=True):
        async with self.lock:
            self.completed_languages += 1
            if not success:
                self.failed_keys += 1
            self._print_status()

    def _print_status(self):
        elapsed = time.time() - self.start_time
        rate = self.successful_keys / elapsed * 60 if elapsed > 0 else 0
        req_rate = self.api_requests / elapsed * 60 if elapsed > 0 else 0

        # Clear line and print status
        status = (
            f"\r🌍 Lang: {self.completed_languages}/{self.total_languages} | "
            f"📦 Batches: {self.completed_batches}/{self.total_batches} | "
            f"📝 Keys: {self.successful_keys} | "
            f"⚡ {rate:.0f} keys/min | "
            f"🔄 {req_rate:.0f} req/min | "
            f"🎯 Tokens: {self.input_tokens + self.output_tokens:,}"
        )

        # Pad to clear previous text
        sys.stdout.write(status.ljust(140))
        sys.stdout.flush()

    def print_final(self):
        elapsed = time.time() - self.start_time
        print(f"\n\n{'=' * 80}")
        print(f"✅ Translation complete!")
        print(f"   Languages processed: {self.completed_languages}/{self.total_languages}")
        print(f"   Keys translated: {self.successful_keys}")
        print(f"   API requests made: {self.api_requests}")
        print(f"   Total tokens used: {self.input_tokens + self.output_tokens:,}")
        print(f"      Input tokens: {self.input_tokens:,}")
        print(f"      Output tokens: {self.output_tokens:,}")
        print(f"   Time elapsed: {elapsed:.1f} seconds")
        print(f"   Average rate: {self.successful_keys / elapsed * 60:.1f} keys/minute")
        print(f"   Request rate: {self.api_requests / elapsed * 60:.1f} requests/minute")


async def translate_batch_async(session, texts, target_language, semaphore, rate_limiter):
    """Translate a batch of texts using Gemini API asynchronously.

    Returns: (translations_dict, input_tokens, output_tokens)
    """
    async with semaphore:
        # Rate limiting
        await rate_limiter.acquire()

        texts_to_translate = [f"{key}: {value}" for key, value in texts.items()]

        prompt = f"""Translate these game UI texts from English to {target_language} for "Starbrew Station" (space coffee shop game).

Rules:
- Keep formatting codes: {{variable}}, [color=#code], %d, %s, %.0f
- Keep symbols like ⏸ ✅ 🎯 but translate surrounding text
- Return ONLY key: translation format, one per line
- No explanations

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
                "maxOutputTokens": 4096,
            }
        }

        try:
            async with session.post(
                GEMINI_API_URL,
                json=payload,
                timeout=aiohttp.ClientTimeout(total=90)
            ) as response:
                response.raise_for_status()
                result = await response.json()

                # Extract token usage
                usage = result.get('usageMetadata', {})
                input_tokens = usage.get('promptTokenCount', 0)
                output_tokens = usage.get('candidatesTokenCount', 0)

                if 'candidates' not in result or len(result['candidates']) == 0:
                    return {}, input_tokens, output_tokens

                candidate = result['candidates'][0]

                if candidate.get('finishReason') == 'SAFETY':
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
                        if key in texts:
                            translations[key] = value

                return translations, input_tokens, output_tokens

        except Exception as e:
            return {}, 0, 0


class RateLimiter:
    """Token bucket rate limiter that allows concurrent requests."""

    def __init__(self, requests_per_minute):
        self.max_tokens = requests_per_minute
        self.tokens = requests_per_minute  # Start with full bucket
        self.refill_rate = requests_per_minute / 60.0  # Tokens per second
        self.last_refill = time.time()
        self.lock = asyncio.Lock()

    async def acquire(self):
        while True:
            async with self.lock:
                # Refill tokens based on elapsed time
                now = time.time()
                elapsed = now - self.last_refill
                self.tokens = min(self.max_tokens, self.tokens + elapsed * self.refill_rate)
                self.last_refill = now

                # If we have a token, take it and proceed
                if self.tokens >= 1:
                    self.tokens -= 1
                    return

            # No tokens available, wait a bit and try again
            await asyncio.sleep(0.1)


async def translate_language_async(session, lang_code, lang_name, keys_to_translate, semaphore, rate_limiter, progress):
    """Translate all keys for a single language asynchronously."""
    items = list(keys_to_translate.items())
    BATCH_SIZE = 15
    all_translations = {}

    # Create batches
    batches = []
    for i in range(0, len(items), BATCH_SIZE):
        batch = dict(items[i:i + BATCH_SIZE])
        batches.append(batch)

    # Process batches concurrently (but rate-limited)
    tasks = []
    for batch in batches:
        task = translate_batch_async(session, batch, lang_name, semaphore, rate_limiter)
        tasks.append(task)

    # Gather results with progress updates
    for task in asyncio.as_completed(tasks):
        translations, input_tokens, output_tokens = await task
        all_translations.update(translations)
        await progress.update_batch(len(translations), input_tokens, output_tokens)

    return all_translations


def update_csv_file(filepath, translations):
    """Update CSV file with translations."""
    lines = read_csv_lines(filepath)

    updated = False
    for i, line in enumerate(lines):
        line_stripped = line.strip()
        if line_stripped and not line_stripped.startswith('#') and ',' in line_stripped:
            parts = line_stripped.split(',', 1)
            if len(parts) == 2:
                key = parts[0].strip()
                if key in translations:
                    lines[i] = f"{key},{translations[key]}\n"
                    updated = True

    if updated:
        with open(filepath, 'w', encoding='utf-8-sig', newline='') as f:
            f.writelines(lines)
        return True
    return False


async def translate_with_gemini_async():
    """Main async translation function."""
    script_dir = Path(__file__).parent.resolve()
    translations_dir = script_dir / 'translations'

    print("🚀 Starting Gemini Translation Service")
    print(f"   Rate limit: {MAX_REQUESTS_PER_MINUTE} requests/minute")
    print(f"   Batch size: 15 keys per request")
    print()

    print("📚 Loading English reference values...")
    en_values = get_english_values()  # Get ALL keys, not just KEYS_TO_TRANSLATE
    print(f"   Found {len(en_values)} keys to translate\n")

    # Get all translation files and prepare work
    csv_files = sorted(translations_dir.glob('starbrew_*.csv'))

    languages_to_process = []
    for csv_file in csv_files:
        if csv_file.name == 'starbrew_en.csv':
            continue

        lang_code = csv_file.stem.replace('starbrew_', '')
        lang_name = LANGUAGE_NAMES.get(lang_code, lang_code.upper())

        # Check which keys need translation
        lines = read_csv_lines(csv_file)
        current_data = parse_csv_to_dict(lines)

        keys_needing_translation = {}
        for key in en_values:  # Check ALL keys, not just KEYS_TO_TRANSLATE
            if key in current_data:
                # Check if value is same as English (untranslated)
                # Exclude single characters/symbols that might legitimately be the same
                if current_data[key] == en_values[key] and len(en_values[key]) > 3:
                    keys_needing_translation[key] = en_values[key]

        if keys_needing_translation:
            languages_to_process.append((csv_file, lang_code, lang_name, keys_needing_translation))

    if not languages_to_process:
        print("✅ All translations are already complete!")
        return

    # Calculate total batches for progress tracking
    total_batches = sum(
        (len(keys) + 14) // 15  # Ceiling division for batch size of 15
        for _, _, _, keys in languages_to_process
    )

    print(f"🌍 Processing {len(languages_to_process)} languages with pending translations")
    print(f"   Total API requests needed: {total_batches}\n")

    # Initialize progress tracker
    progress = ProgressTracker(len(languages_to_process), total_batches)

    # Set up rate limiting and concurrency
    # Allow up to 50 concurrent requests - rate limiter will handle the pacing
    semaphore = asyncio.Semaphore(50)
    rate_limiter = RateLimiter(MAX_REQUESTS_PER_MINUTE)

    # Create aiohttp session
    connector = aiohttp.TCPConnector(limit=50)
    async with aiohttp.ClientSession(connector=connector) as session:
        # Helper to process a single language and save results
        async def process_language(csv_file, lang_code, lang_name, keys):
            translations = await translate_language_async(
                session, lang_code, lang_name, keys, semaphore, rate_limiter, progress
            )
            if translations:
                update_csv_file(csv_file, translations)
            await progress.complete_language(success=bool(translations))
            return translations

        # Schedule ALL languages to run concurrently
        tasks = [
            process_language(csv_file, lang_code, lang_name, keys)
            for csv_file, lang_code, lang_name, keys in languages_to_process
        ]

        # Run all languages in parallel
        await asyncio.gather(*tasks)

    progress.print_final()


# ═══════════════════════════════════════════════════════════
# MAIN CLI INTERFACE
# ═══════════════════════════════════════════════════════════

def main():
    """Main entry point with CLI argument parsing."""
    parser = argparse.ArgumentParser(
        description='Comprehensive translation management tool for Starbrew Station',
        epilog='''
Examples:
  %(prog)s                    # Translate missing keys with Gemini API
  %(prog)s --check            # Check for missing/untranslated keys
  %(prog)s --fix              # Add missing keys with English placeholders
  %(prog)s --fix --translate  # Fix then translate (recommended workflow)
  %(prog)s --apply-manual     # Apply hardcoded manual translations
        ''',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument('--check', action='store_true',
                        help='Check for missing and untranslated keys')
    parser.add_argument('--fix', action='store_true',
                        help='Add missing keys with English placeholders')
    parser.add_argument('--translate', action='store_true',
                        help='Translate missing keys with Gemini API')
    parser.add_argument('--apply-manual', action='store_true',
                        help='Apply hardcoded manual translations')

    args = parser.parse_args()

    # Execute requested modes
    if args.check:
        check_translations()
    elif args.fix:
        fix_translations()
        if args.translate:
            print("\n" + "=" * 80)
            print("Proceeding to translation...\n")
            try:
                import aiohttp
                asyncio.run(translate_with_gemini_async())
            except ImportError:
                print("❌ aiohttp is required for translation. Install with: pip install aiohttp")
    elif args.apply_manual:
        apply_manual_translations()
    elif args.translate:
        # Default: translate mode
        try:
            import aiohttp
            asyncio.run(translate_with_gemini_async())
        except ImportError:
            print("❌ aiohttp is required for translation. Install with: pip install aiohttp")
    else:
        # No arguments: default to translate mode
        try:
            import aiohttp
            asyncio.run(translate_with_gemini_async())
        except ImportError:
            print("❌ aiohttp is required for translation. Install with: pip install aiohttp")


if __name__ == '__main__':
    main()
