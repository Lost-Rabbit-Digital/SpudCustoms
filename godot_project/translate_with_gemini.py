#!/usr/bin/env python3
"""
Comprehensive translation management tool for Spud Customs.
Handles translation checking, fixing, and API translation for multi-language CSV files.

Usage:
    python translate_with_gemini.py                    # Translate ALL untranslated keys
    python translate_with_gemini.py --check            # Check for missing/untranslated keys
    python translate_with_gemini.py --file game.csv    # Translate specific file only
    python translate_with_gemini.py --dry-run          # Show what would be translated without making changes

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

# Language mapping - columns in CSV files (excluding 'keys' and 'en')
LANGUAGE_COLUMNS = {
    'cs': 'Czech',
    'da': 'Danish',
    'de': 'German',
    'es': 'Spanish',
    'fi': 'Finnish',
    'fr': 'French',
    'hu': 'Hungarian',
    'id': 'Indonesian',
    'it': 'Italian',
    'nl': 'Dutch',
    'no': 'Norwegian',
    'pl': 'Polish',
    'pt': 'Portuguese',
    'ro': 'Romanian',
    'sk': 'Slovak',
    'sv': 'Swedish',
    'tr': 'Turkish',
    'vi': 'Vietnamese'
}

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


def get_csv_files(specific_file=None):
    """Get list of CSV files to process."""
    translations_dir = get_translations_dir()

    if specific_file:
        csv_file = translations_dir / specific_file
        if csv_file.exists():
            return [csv_file]
        else:
            print(f"ERROR: File not found: {csv_file}")
            return []

    # Get all translation CSV files (exclude .import files and non-translation CSVs)
    csv_files = []
    for f in sorted(translations_dir.glob('*.csv')):
        # Skip import metadata files
        if f.suffix == '.import':
            continue
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
            if lang_idx == -1 or lang_idx >= len(row):
                continue

            lang_value = row[lang_idx] if lang_idx < len(row) else ''

            # If language value matches English exactly, it's untranslated
            if lang_value == en_value:
                untranslated[row_idx][lang_code] = en_value

    return untranslated


# ═══════════════════════════════════════════════════════════
# MODE 1: CHECK TRANSLATIONS
# ═══════════════════════════════════════════════════════════

def check_translations(specific_file=None):
    """Check all CSV files for untranslated content."""
    csv_files = get_csv_files(specific_file)

    if not csv_files:
        print("No CSV files found to check")
        return

    total_untranslated = 0
    files_with_issues = 0

    print("=" * 80)
    print("TRANSLATION CHECK REPORT")
    print("=" * 80)

    for csv_file in csv_files:
        headers, rows = read_csv_file(csv_file)

        if not headers or not rows:
            continue

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

    if total_untranslated == 0:
        print("\n✅ All translations are complete!")
    else:
        print(f"\n⚠️  Found {total_untranslated} cells that need translation")
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
        if lang_idx != -1 and translations:
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

    csv_files = get_csv_files(specific_file)

    if not csv_files:
        print("No CSV files found to translate")
        return

    print("🚀 Starting Gemini Translation Service for Spud Customs")
    print(f"   Model: {GEMINI_MODEL}")
    print(f"   Rate limit: {MAX_REQUESTS_PER_MINUTE} requests/minute")
    print(f"   Batch size: {BATCH_SIZE} keys per request")
    print(f"   Max concurrent: {MAX_CONCURRENT_REQUESTS} requests")
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
# MAIN CLI INTERFACE
# ═══════════════════════════════════════════════════════════

def main():
    """Main entry point with CLI argument parsing."""
    parser = argparse.ArgumentParser(
        description='Translation management tool for Spud Customs',
        epilog='''
Examples:
  %(prog)s                    # Translate all untranslated content
  %(prog)s --check            # Check for missing/untranslated content
  %(prog)s --file game.csv    # Translate specific file only
  %(prog)s --dry-run          # Preview what would be translated
  %(prog)s --check --file menus.csv  # Check specific file
        ''',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument('--check', action='store_true',
                        help='Check for untranslated content without translating')
    parser.add_argument('--file', type=str, metavar='FILENAME',
                        help='Process only a specific CSV file (e.g., game.csv)')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be translated without making changes')

    args = parser.parse_args()

    # Execute requested mode
    if args.check:
        check_translations(args.file)
    else:
        try:
            import asyncio
            asyncio.run(translate_with_gemini_async(args.file, args.dry_run))
        except ImportError as e:
            if 'aiohttp' in str(e):
                print("❌ aiohttp is required for translation. Install with: pip install aiohttp")
            else:
                raise
        except KeyboardInterrupt:
            print("\n\n⚠️  Translation interrupted by user")


if __name__ == '__main__':
    main()
