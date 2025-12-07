#!/usr/bin/env python3
"""
Translate Steam patch notes to all supported languages while preserving BBCode formatting.
Creates individual .txt files for each language that can be copy-pasted into Steam announcements.

Usage:
    python translate_patch_notes.py                    # Translate to all languages
    python translate_patch_notes.py --lang fr de ja   # Translate to specific languages only
    python translate_patch_notes.py --check           # List which translations exist
"""

import os
import sys
import time
import argparse
from pathlib import Path

# API configuration
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "")
GEMINI_MODEL = "gemini-2.5-flash"
GEMINI_API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent?key={GEMINI_API_KEY}"

# All Steam supported languages
STEAM_LANGUAGES = {
    'ar': 'Arabic',
    'bg': 'Bulgarian',
    'cs': 'Czech',
    'da': 'Danish',
    'de': 'German',
    'el': 'Greek',
    'en': 'English',
    'es': 'Spanish',
    'es-419': 'Spanish (Latin America)',
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
    'pt-BR': 'Portuguese (Brazil)',
    'ro': 'Romanian',
    'ru': 'Russian',
    'sk': 'Slovak',
    'sv': 'Swedish',
    'th': 'Thai',
    'tr': 'Turkish',
    'uk': 'Ukrainian',
    'vi': 'Vietnamese',
    'zh-CN': 'Chinese (Simplified)',
    'zh-TW': 'Chinese (Traditional)',
}

GAME_CONTEXT = """Spud Customs - A border checkpoint simulation game where you play as a potato inspector.
You check potato passports, verify documents, and decide whether to approve or reject potato travelers.
The game has dark humor elements and is inspired by "Papers, Please".
NICU = Neonatal Intensive Care Unit (hospital unit for newborn babies)."""


def translate_text(text: str, target_language: str, max_retries: int = 3) -> str:
    """Translate text to target language using Gemini API."""
    import urllib.request
    import json

    prompt = f"""Translate this Steam game patch notes announcement from English to {target_language}.

CRITICAL RULES:
1. Keep ALL Steam BBCode tags exactly as they are: [h1], [h2], [h3], [b], [/b], [i], [/i], [list], [/list], [*], [url], [/url]
2. Do NOT translate game-specific terms: "Spud Customs", "StagNation", "Nation of Spud", "Great Wall of Spud", "Sweet Potato Sasha"
3. Keep version numbers exactly as they are: "1.2.0", "0.1", "0.8"
4. Preserve all formatting and line breaks
5. This is for a game about potato border inspection with dark humor

Game context: {GAME_CONTEXT}

Text to translate:
{text}

Return ONLY the translated text with BBCode formatting preserved. No explanations."""

    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 0.3,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 8192,
        }
    }

    for attempt in range(max_retries):
        try:
            data = json.dumps(payload).encode('utf-8')
            req = urllib.request.Request(
                GEMINI_API_URL,
                data=data,
                headers={'Content-Type': 'application/json'},
                method='POST'
            )

            with urllib.request.urlopen(req, timeout=60) as response:
                result = json.loads(response.read().decode('utf-8'))

                if 'candidates' in result and len(result['candidates']) > 0:
                    candidate = result['candidates'][0]
                    if 'content' in candidate and 'parts' in candidate['content']:
                        return candidate['content']['parts'][0].get('text', '')

        except Exception as e:
            if attempt < max_retries - 1:
                print(f"  Retry {attempt + 1}/{max_retries} for {target_language}: {e}")
                time.sleep(2 ** attempt)
            else:
                print(f"  Failed to translate to {target_language}: {e}")
                return ""

    return ""


def main():
    parser = argparse.ArgumentParser(description='Translate Steam patch notes to all languages')
    parser.add_argument('--lang', nargs='+', help='Specific language codes to translate')
    parser.add_argument('--check', action='store_true', help='Check which translations exist')
    parser.add_argument('--source', type=str, default='patch_notes_1_2_0_en.txt',
                        help='Source file name (default: patch_notes_1_2_0_en.txt)')
    args = parser.parse_args()

    # Get paths
    script_dir = Path(__file__).parent
    translations_dir = script_dir / 'translations'
    source_file = translations_dir / args.source

    if not source_file.exists():
        print(f"Error: Source file not found: {source_file}")
        return 1

    # Read source text
    with open(source_file, 'r', encoding='utf-8') as f:
        source_text = f.read()

    # Get base name for output files
    base_name = args.source.replace('_en.txt', '')

    # Determine which languages to process
    if args.lang:
        languages = {code: STEAM_LANGUAGES[code] for code in args.lang if code in STEAM_LANGUAGES}
    else:
        languages = {k: v for k, v in STEAM_LANGUAGES.items() if k != 'en'}

    # Check mode - just show status
    if args.check:
        print("Translation Status:")
        print("=" * 50)
        for code, name in STEAM_LANGUAGES.items():
            output_file = translations_dir / f"{base_name}_{code}.txt"
            status = "✓" if output_file.exists() else "✗"
            print(f"  {status} {code:8} {name}")
        return 0

    # Check API key
    if not GEMINI_API_KEY:
        print("Error: GEMINI_API_KEY environment variable not set")
        print("Get your API key from: https://aistudio.google.com/apikey")
        return 1

    print(f"Translating patch notes to {len(languages)} languages...")
    print(f"Source: {source_file}")
    print()

    # Translate each language
    success_count = 0
    for code, name in languages.items():
        output_file = translations_dir / f"{base_name}_{code}.txt"

        # Skip if already exists
        if output_file.exists():
            print(f"  Skipping {code} ({name}) - already exists")
            success_count += 1
            continue

        print(f"  Translating to {code} ({name})...", end='', flush=True)

        translated = translate_text(source_text, name)

        if translated:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(translated)
            print(" Done!")
            success_count += 1
        else:
            print(" Failed!")

        # Rate limiting
        time.sleep(0.5)

    print()
    print(f"Completed: {success_count}/{len(languages)} translations")
    print(f"Output directory: {translations_dir}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
