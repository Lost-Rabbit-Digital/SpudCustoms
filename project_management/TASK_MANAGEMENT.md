# Task Management

## Current System

As of November 20, 2025, Spud Customs uses **Claude Code slash commands** for task management instead of flat task lists.

### Slash Commands

All development tasks have been consolidated into actionable Claude Code slash commands located in `.claude/commands/`.

**To use:** Type `/` followed by the command name in Claude Code:

```
/test-system DragAndDropManager
/migrate-eventbus analytics.gd
/add-game-feature
/run-tests
```

See `.claude/commands/README.md` for the complete list of available commands.

### Command Categories

1. **Testing** - Create and run unit/integration tests
2. **Architecture** - Migrate to EventBus and dependency injection
3. **Features** - Add gameplay features, narrative content, achievements
4. **Maintenance** - Fix bugs, optimize performance, update documentation

### Why Slash Commands?

Slash commands provide:
- **Structured guidance** for implementing features
- **Consistent patterns** across the codebase
- **Actionable workflows** instead of flat task lists
- **Context-aware help** that references existing code patterns
- **Easy discoverability** of available development tasks

### Legacy Task List

The previous flat task list (`project_tasks.md`) has been archived to:
- `project_management/archive/project_tasks_archived_2025-11-20.md`

High-priority items from that list have been converted into:
- Slash commands for implementation
- Issues in the EventBus migration guide (`docs/EVENTBUS_MIGRATION_GUIDE.md`)
- Known issues in the Game Design Document

### Getting Started

1. Review available commands: `cat .claude/commands/README.md`
2. Check migration priorities: `cat docs/EVENTBUS_MIGRATION_GUIDE.md`
3. Run tests: `/run-tests`
4. Review code quality: `/code-quality`

### Adding New Tasks

Instead of adding to a flat list:
1. Create a new slash command in `.claude/commands/`
2. Follow the existing command structure
3. Include implementation steps and code examples
4. Update `.claude/commands/README.md`

### Active Priorities

**Architecture Migration:**
- `/migrate-eventbus analytics.gd`
- `/migrate-eventbus level_list_manager.gd`
- `/migrate-eventbus NarrativeManager.gd`
- `/fix-hardcoded-paths` (Global.gd)

**Testing:**
- `/test-eventbus` - Create EventBus unit tests
- `/test-integration` - Test critical user flows

**Documentation:**
- All docs now reference the EventBus architecture
- Claude.md updated with EventBus patterns and slash commands

See `Claude.md` for complete development guidelines.
