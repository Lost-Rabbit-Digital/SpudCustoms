# Feedback System Setup

## Overview
The feedback system allows players to submit feedback, bug reports, and suggestions directly from the main menu, which are sent to a Discord channel via webhook.

## Discord Webhook Setup

### 1. Create a Discord Webhook

1. Open your Discord server
2. Go to Server Settings → Integrations → Webhooks
3. Click "New Webhook"
4. Name it "Spud Customs Feedback" (or similar)
5. Select the channel where feedback should be posted
6. Copy the Webhook URL

### 2. Configure the Webhook in the Game

Open `/godot_project/scripts/ui/FeedbackMenu.gd` and find this line:

```gdscript
const DISCORD_WEBHOOK_URL = ""  # TODO: Add your Discord webhook URL here
```

Replace it with your webhook URL:

```gdscript
const DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
```

**⚠️ IMPORTANT SECURITY NOTE:**
- Never commit the webhook URL to public repositories
- Consider using environment variables or a separate config file for production
- Add `FeedbackMenu.gd` to `.gitignore` after adding the webhook URL, or use a local override

### 3. Test the Feedback System

1. Run the game
2. Go to Main Menu
3. Click "Feedback"
4. Enter at least 10 characters of feedback
5. Click "Submit"
6. Check your Discord channel for the message

## Features

### Feedback Form
- **Title**: "Send Feedback"
- **Tip**: Instructions for users
- **Text Input**: Multi-line text editor with character count
- **Character Limits**:
  - Minimum: 10 characters
  - Maximum: 2000 characters
- **Buttons**: Back and Submit

### System Information Included
Each feedback submission automatically includes:
- **Version**: Game version from `project.godot`
- **Playtime**: Total time played (formatted as "Xh Ym")
- **Steam**: Steam user ID (or "Steam Disabled" if not running Steam)

### Validation
- Submit button is disabled until minimum character count is reached
- Character counter changes color:
  - Red/Orange: Below minimum
  - Green: Valid range
  - Yellow: Approaching maximum
- Prevents double submission
- Shows success/error status messages

## Discord Message Format

Feedback appears as an embedded message in Discord with:

**Title**: "New Feedback from Spud Customs"
**Description**: The user's feedback text
**Fields**:
- Version: 1.1.0
- Playtime: 2h 30m
- Steam: 76561198012345678 (or "Steam Disabled")
**Timestamp**: When the feedback was submitted

## Troubleshooting

### "Feedback system not configured" Error
- Make sure you've added the Discord webhook URL to `FeedbackMenu.gd`
- Verify the URL is correct and not empty

### "Failed to send feedback" Error
- Check your internet connection
- Verify the webhook URL is valid and the webhook hasn't been deleted
- Check if Discord's API is experiencing issues

### Feedback button not showing
- Ensure `feedback_menu.tscn` is in the correct location
- Check the console for any error messages during scene loading
- Verify the main menu script is calling `_setup_feedback_menu()`

## Future Improvements

Consider adding:
- Rate limiting to prevent spam
- Screenshot attachment capability
- Category selection (Bug / Suggestion / Other)
- Email notification option
- GitHub issue creation integration
