# Spud Customs - Two Week Development Roadmap

## Week 1: Critical Fixes & Core Improvements

### High Priority Bugs
1. Collision & Boundary Issues
   - Implement boundary constraints for draggables in lower half of screen
   - Fix stamp dragging outside interaction table
   - Fix passport dragging outside interaction table
   - Implement proper collision masking for interactive elements

2. Stamp System Fixes
   - Fix stamp animation and positioning
   - Prevent multiple stamps from appearing when spamming
   - Ensure stamps stay within passport boundaries
   - Fix mouse-over requirements for stamping

3. Core Gameplay Issues
   - Fix date rule evaluation system
   - Fix months_until_expiry() calculations
   - Prevent passport movement during animations
   - Fix upside-down potato person sprites
   - Implement proper clipping for elements leaving interaction table

### Critical Features
1. Tutorial Improvements
   - Add page-flipping instructions
   - Implement flash arrow indicators for megaphone
   - Add corner indicators for first page
   - Make laws section more prominent and immovable

2. Visual Feedback
   - Implement custom cursors for different states:
     - Hover
     - Click
     - Grab
     - Drag
   - Create new stamp shadow/highlight system
   - Fix pixel resolution consistency for text
   - Update stamp visuals to match pixel art style

## Week 2: Feature Implementation & Polish

### New Features
1. Save System
   - Implement save game functionality
   - Add load game system
   - Add save state persistence between shifts

2. UV Lamp Mini-game
   - Design core mechanics
   - Implement basic functionality
   - Add visual feedback
   - Balance difficulty

3. Difficulty System
   - Implement difficulty selection in menu
   - Add explanations for difficulty levels
   - Balance time pressure based on difficulty:
     - Easy: 60 seconds
     - Normal: 45 seconds
     - Hard: 30 seconds

### Polish & Quality of Life
1. Text & UI Updates
   - Review and update all in-game text
   - Change verbiage for "2 and under" rules
   - Make instructions into closeable overlay
   - Improve visual feedback of controls

2. Gameplay Flow
   - Add persistence for tutorial completion
   - Make border running more visually clear
   - Add flash indicators for important elements
   - Improve feedback for rejected potatoes

3. Audio Polish
   - Add sound effects for:
     - Denying entry
     - Granting entry
   - Balance existing audio levels

### Stretch Goals (If Time Permits)
- Add patrolling officers
- Implement physics for suspect panel items
- Add baggage inspection system
- Enhance potato conversations
- Add lighting effects

## Daily Testing Focus
- Allocate 30 minutes each day for testing recent changes
- Focus on edge cases:
  - Rapid button clicking
  - Multiple object interactions
  - Boundary conditions
  - Process flow interruptions

## Progress Tracking
- [ ] Create daily checklists from this roadmap
- [ ] Set up progress monitoring system
- [ ] Schedule brief daily reviews
- [ ] Plan end-of-week evaluation sessions

## Notes
- Prioritize fixes that impact core gameplay
- Test each fix in isolation before integration
- Document any new bugs discovered during fixes
- Keep performance profiling active during development
