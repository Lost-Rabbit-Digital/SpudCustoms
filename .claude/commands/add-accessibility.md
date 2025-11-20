---
description: Add accessibility features to a UI component or system
---

Implement accessibility features for the specified UI component following the patterns in `AccessibilityManager.gd`.

**Required Accessibility Features:**
1. **Colorblind Support**: Shape + color differentiation for important UI elements
2. **Font Scaling**: Support Small/Medium/Large/Extra Large text
3. **UI Scaling**: Support 80%/100%/120%/150% interface scaling
4. **High Contrast Mode**: Enhanced borders and backgrounds
5. **Keyboard Navigation**: Full keyboard support with visible focus indicators
6. **Screen Reader**: Descriptive labels and ARIA-equivalent metadata

**Implementation Checklist:**
- [ ] Subscribe to `AccessibilityManager` settings change signals
- [ ] Apply colorblind filters to color-dependent UI
- [ ] Ensure text respects font scaling settings
- [ ] Test with all accessibility modes enabled
- [ ] Add keyboard shortcuts and focus handling
- [ ] Provide alternative visual cues (not just color)
- [ ] Test with minimum font size and maximum UI scaling

**Systems Needing Accessibility:**
- Stamp system (color + shape for approve/reject)
- Alert messages (visual + audio feedback)
- Tutorial hints (resizable, high contrast)
- Leaderboards (scalable text)
- Document text (font scaling)

Ask the user which component needs accessibility if not specified.
