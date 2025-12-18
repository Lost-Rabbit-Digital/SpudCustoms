# Spud Customs - Game Design Document

> **Version:** 1.2.0 Feature Complete | **Last Updated:** December 2025 | **Status:** Pre-Release

## Overview

This directory contains the comprehensive Game Design Document for **Spud Customs**, split into focused sections for easier navigation and maintenance.

## Document Index

| # | Section | Description |
|---|---------|-------------|
| 01 | [Game Overview](01_game_overview.md) | High concept, target audience, genre, pricing |
| 02 | [Core Gameplay](02_core_gameplay.md) | Mechanics, difficulty, scoring, X-ray system, citations/strikes |
| 03 | [Story Mode](03_story_mode.md) | Chapter structure, narrative elements, choice tracking |
| 04 | [Game Modes](04_game_modes.md) | Story, Endless, Daily Challenge modes |
| 05 | [Progression Timing](05_progression_timing.md) | Time targets, player segments, pacing |
| 06 | [Features & Systems](06_features_systems.md) | Mini-games, emotes, visual feedback, tension system |
| 07 | [UI Layout](07_ui_layout.md) | Screen design, menus, accessibility, animations |
| 08 | [Audio Design](08_audio_design.md) | Music system, SFX catalog, audio buses |
| 09 | [Technical Implementation](09_technical.md) | EventBus, debug controls, known bugs |
| 10 | [Quality Assurance](10_testing_qa.md) | Testing framework, CI/CD, manual testing |
| 11 | [Steam Release](11_steam_release.md) | Requirements, system specs, store materials |
| 12 | [Development Timeline](12_timeline.md) | Phases, current status, remaining work |
| 13 | [Post-Launch Support](13_post_launch.md) | Update roadmap, content plans |
| 14 | [Steam Achievements](14_achievements.md) | 21 achievements with triggers and requirements |
| 15 | [Credits](15_credits.md) | Team, third-party assets, legal notices |

## Quick Links

### For Developers
- [Technical Implementation](09_technical.md) - EventBus architecture, debug commands
- [Quality Assurance](10_testing_qa.md) - Testing requirements, CI/CD pipeline

### For Designers
- [Core Gameplay](02_core_gameplay.md) - Game mechanics and systems
- [Features & Systems](06_features_systems.md) - Detailed system documentation

### For Writers
- [Story Mode](03_story_mode.md) - Narrative structure and choices
- [Steam Achievements](14_achievements.md) - Story-driven achievement design

### For Artists/Audio
- [UI Layout](07_ui_layout.md) - Visual design specifications
- [Audio Design](08_audio_design.md) - Sound requirements and mixing

## Key Features Summary

- **2-3 hour story campaign** with 4 distinct endings
- **5 integrated mini-games** unlocking through story progression
- **40+ immigration rules** with progressive complexity
- **3 difficulty levels** (Easy, Normal, Hard)
- **21 Steam achievements** across narrative and skill categories
- **29 supported languages** (all Steam-supported languages)
- **EventBus architecture** for decoupled, testable systems
- **TensionManager** for dynamic near-failure feedback

## Related Documentation

- [CLAUDE.md](../../CLAUDE.md) - Development guidelines and conventions
- [EventBus Migration Guide](../../docs/EVENTBUS_MIGRATION_GUIDE.md) - Architecture patterns
- [Test Documentation](../../godot_project/tests/README.md) - Unit testing guide
- [Pre-release Testing](../testing/prerelease_test_procedure.md) - Manual test checklist

## Changelog

### Version 1.2.0 (December 2025)
- Split monolithic GDD into 15 focused documents
- Added TensionManager and celebration system documentation
- Added contextual bubble dialogue system
- Removed Known Issues section (tracked separately)
- Updated EventBus signal documentation

### Version 1.1.0
- Added EventBus architecture documentation
- Dynamic tutorial system
- 5 mini-games integration
- 7 custom music tracks

### Version 1.0.0
- Initial GDD creation
