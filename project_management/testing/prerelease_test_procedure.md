# Spud Customs - Internal Testing Checklist
Version: Based on mainGame.gd current implementation
Time Required: ~30 minutes per test pass

## 1. Core Processing Flow
### Megaphone System
- [ ] Click megaphone when empty - verify dialogue box appears
- [ ] Click megaphone with potato in office - verify warning appears
- [ ] Verify customs officer sound plays on click
- [ ] Check megaphone alert flash visibility:
  - Should flash when no potato in office
  - Should hide when potato enters office

### Document Processing
- [ ] Verify passport appears after potato enters office
- [ ] Check all information fields in passport:
  - Name
  - Type
  - Condition
  - Sex
  - Country of issue
  - Date of birth
  - Expiration date
- [ ] Test document dragging:
  - Passport stays in lower half of screen
  - Guide stays in lower half of screen
  - Proper z-index layering

### Stamp System
- [ ] Test approval stamp pickup and placement
- [ ] Test rejection stamp pickup and placement
- [ ] Verify stamps remain visible after use
- [ ] Check stamp animation and sound effects
- [ ] Confirm right-click drops held stamp
- [ ] Verify multiple stamps can't appear on one passport
- [ ] Check stamp visibility on passport matches z-index rules

## 2. Game Systems
### Score System
- [ ] Verify correct point addition for proper decisions
- [ ] Check score display updates
- [ ] Test score progression to next shift
- [ ] Verify Global.final_score updates correctly

### Strike System
- [ ] Confirm strikes increment for wrong decisions
- [ ] Test strike limit:
  - Easy mode: 5 strikes
  - Normal mode: 3 strikes
  - Hard mode: 2 strikes
- [ ] Verify game over triggers at max strikes

### Timer System
- [ ] Check timer starts when potato enters office
- [ ] Verify countdown display
- [ ] Test time limits:
  - Easy mode: 60 seconds
  - Normal mode: 45 seconds
  - Hard mode: 15 seconds
- [ ] Confirm timer reset between potatoes

## 3. Rule Verification
### Rule Generation
- [ ] Verify 2-3 rules are generated per shift
- [ ] Check rule display in guide
- [ ] Test rule updates between shifts

### Rule Implementation
Test each rule type:
- [ ] Type-based rules (e.g., "Purple Majesty are not welcome")
- [ ] Condition-based rules (e.g., "All potatoes must be Fresh!")
- [ ] Age-based rules (e.g., "No potatoes over 5 years old")
- [ ] Gender-based rules (e.g., "Only male potatoes allowed today")
- [ ] Country-based rules (e.g., "Potatoes from Spudland must be denied")

## 4. Queue Management
### Spawn System
- [ ] Check potato spawn timing (3-second intervals)
- [ ] Verify maximum queue size
- [ ] Test potato type variety
- [ ] Confirm proper queue movement

### Path Following
Test all paths:
- [ ] Enter office path
- [ ] Approve path
- [ ] Reject path
- [ ] Runner path (20% chance on rejection)
- [ ] Timeout path

## 5. Visual Verification
### Potato Visuals
- [ ] Check all potato type textures:
  - Purple Majesty
  - Red Bliss
  - Russet Burbank
  - Sweet Potato
  - Yukon Gold
- [ ] Verify passport photos match potato type
- [ ] Test mugshot animations

### UI Elements
- [ ] Verify all label updates:
  - Score
  - Strikes
  - Time
  - Date
- [ ] Check guide visibility and positioning
- [ ] Test passport positioning and animations

## 6. Audio System
- [ ] Test all customs officer phrases
- [ ] Verify stamp sound effects
- [ ] Check passport open/close sounds
- [ ] Confirm proper audio pool usage

## 7. Performance Testing
### Animation Stress Test
- [ ] Rapid stamp application
- [ ] Quick potato processing
- [ ] Multiple simultaneous path movements
- [ ] Rapid megaphone clicking

### Memory Check
- [ ] Extended play session (10+ minutes)
- [ ] Multiple shift transitions
- [ ] Rapid scene changes

## Bug Reporting Template
```
Bug ID: SPUD-[NUMBER]
Location: [SCENE/SYSTEM]
Severity: [HIGH/MEDIUM/LOW]
Steps to Reproduce:
1.
2.
3.
Expected Result:
Actual Result:
Screenshots/Video:
Additional Notes:
```

## Testing Notes
- Run tests at each difficulty level
- Test edge cases (e.g., extremely fast/slow processing)
- Document any inconsistent behavior
- Note performance on different hardware if possible
