# Steam Release Requirements

> **Back to:** [GDD Index](README.md) | **Previous:** [Quality Assurance & Testing](10_testing_qa.md)

## Essential Features

- **Steam Cloud Saves** ✓
- 21 Achievements (displayed in-game from menus)
- Global Leaderboards:
  - Per shift per difficulty
  - Score attack mode
  - Daily challenges
  - Top 3 + player position ±3

## Launch Content

- 40+ unique immigration rules
- **4 potato types** (progressive unlock)
- 3 difficulty levels
- 2-3 hour story campaign with **8 endings**
- Endless / Score Attack mode with progressive difficulty
- Daily challenges with leaderboards

## Price Point: $4.99

**Justification:**
- Unique gameplay mechanics
- Rich narrative content with multiple endings
- Multiple game modes
- Regular content updates
- Environmental storytelling elements

## Release Checklist ✓

- Steam Cloud Save path verification ✓
- Leaderboard functionality testing (all modes) ✓
- Achievement unlock testing (narrative + stats-based) ✓
- All 8 story endings playable ✓
- Demo build tested ✓
- Deployment process documented (Steam Depots via Web Builds) ✓

## System Requirements

### Minimum Requirements

- **OS**: Windows 10 (64-bit), macOS 10.15+, Ubuntu 20.04+
- **Processor**: Intel Core i3 or equivalent
- **Memory**: 2 GB RAM
- **Graphics**: OpenGL 3.3 compatible GPU
- **Storage**: 500 MB available space
- **Sound Card**: DirectX compatible
- **Additional Notes**: Mouse required for gameplay

### Recommended Requirements

- **OS**: Windows 11 (64-bit), macOS 12+, Ubuntu 22.04+
- **Processor**: Intel Core i5 or equivalent
- **Memory**: 4 GB RAM
- **Graphics**: Dedicated GPU with 1GB VRAM
- **Storage**: 1 GB available space
- **Sound Card**: DirectX compatible
- **Additional Notes**: 1920x1080 resolution or higher recommended

### Supported Platforms

- Windows (primary)
- macOS (planned)
- Linux (planned)
- Web (HTML5 export for demos)

### Technical Requirements

- Internet connection required for:
  - Steam achievements
  - Global leaderboards
  - Daily challenges
  - Cloud saves
- Offline play available for Story Mode and Endless Mode (local scores only)

## Steam Store Materials Checklist

### Required Assets (Pre-Release)

- [ ] **Capsule Images**
  - Main capsule: 616x353px
  - Small capsule: 231x87px
  - Header capsule: 460x215px
  - Vertical capsule: 374x448px
  - Hero capsule: 1920x620px

- [ ] **Screenshots**
  - Minimum 5 screenshots at 1920x1080
  - Showcase: Document inspection, missile defense, story moments, UI elements, different potato types
  - All must be actual in-game screenshots (no mockups)

- [ ] **Trailer**
  - 30-90 seconds recommended
  - Show core gameplay loop
  - Highlight unique mechanics (stamp combos, X-ray, missile defense)
  - Include narrative hook
  - Trailer script at: `project_management/spud_customs_trailer_1.md`

- [ ] **Store Description**
  - Short description (300 characters max)
  - Long description with feature bullets
  - About This Game section
  - Key features list
  - System requirements (see above)

- [ ] **Store Tags**
  - Primary: Simulation, Indie, Casual, Strategy
  - Secondary: Immigration, Time Management, Choices Matter, Multiple Endings
  - Thematic: Dark Humor, Dystopian, Story Rich, Singleplayer

- [ ] **Legal & Compliance**
  - Age rating justification (Teen - dark humor, mild violence)
  - Privacy policy (if collecting data)
  - EULA/Terms of Service
  - Attribution credits (see Credits section below)

- [ ] **Community Setup**
  - Discussion boards enabled
  - Workshop integration (optional - for user-created content)
  - Achievement showcase enabled
  - Trading cards (optional - future consideration)

- [ ] **Launch Checklist**
  - Steam Depot configured for Windows build
  - Demo build uploaded and tested
  - Wishlisting enabled 2+ weeks before launch
  - Press kit prepared
  - Social media accounts ready
  - Launch discount strategy (10% recommended)

---

> **Next:** [Development Timeline](12_timeline.md)
