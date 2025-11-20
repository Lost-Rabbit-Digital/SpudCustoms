# Spud Customs - Claude Code Commands

This directory contains Claude Code slash commands for common development tasks. These commands consolidate project management workflows and provide structured guidance for implementing features, tests, and architectural improvements.

## Available Commands

### Testing & Quality

- **/test-system** - Create comprehensive unit tests for a specific game system
- **/test-integration** - Create integration tests for critical user flows
- **/test-eventbus** - Create unit tests for EventBus signal emissions and subscriptions
- **/run-tests** - Run the GUT test suite and report results
- **/code-quality** - Run code quality checks (format, lint, complexity analysis)

### Architecture & Migration

- **/migrate-eventbus** - Migrate a file to use EventBus pattern instead of direct Global mutations
- **/add-di-pattern** - Refactor a system to use dependency injection instead of autoload singletons
- **/fix-hardcoded-paths** - Find and fix hardcoded /root/ node paths throughout the project

### Features & Content

- **/add-game-feature** - Add a new gameplay feature to the game
- **/add-narrative-content** - Add new narrative content (dialogue, choices, timelines)
- **/add-achievement** - Add a new Steam achievement with tracking logic
- **/add-accessibility** - Add accessibility features to a UI component or system
- **/add-localization** - Add localization support for new text content

### Bug Fixes & Optimization

- **/fix-z-index** - Fix z-index layering issues for visual elements
- **/optimize-performance** - Optimize performance using object pooling and efficiency patterns
- **/steam-integration** - Add or debug Steam integration features

### Documentation

- **/update-docs** - Update project documentation to reflect current implementation state

## Usage Examples

### Running Tests
```
/run-tests
```

### Creating Tests for a System
```
/test-system
```
Then specify which system (e.g., "DragAndDropManager")

### Migrating to EventBus
```
/migrate-eventbus analytics.gd
```

### Adding a New Feature
```
/add-game-feature
```
Then describe the feature (e.g., "X-ray scanner system")

## Command Organization

Commands are organized by function:

1. **Testing commands** - Ensure code quality and test coverage
2. **Architecture commands** - Migrate to EventBus and dependency injection patterns
3. **Feature commands** - Add new gameplay systems and content
4. **Maintenance commands** - Fix bugs, optimize, and update documentation

## Best Practices

- Use these commands to maintain consistent code patterns across the project
- Always run `/code-quality` before committing major changes
- Use `/test-system` when creating new systems
- Migrate existing code with `/migrate-eventbus` following the priority list
- Keep documentation updated with `/update-docs`

## Reference Documentation

- **Claude.md** - Development guidelines and Godot 4.5 best practices
- **EVENTBUS_MIGRATION_GUIDE.md** - EventBus architecture migration guide
- **project_tasks.md** - Historical task list (now consolidated into these commands)

## Migration Priorities

High priority files for EventBus migration:
1. `analytics.gd` (15+ Global reads)
2. `level_list_manager.gd` (advance_shift calls)
3. `NarrativeManager.gd` (game_mode checks)
4. `Global.gd` (hardcoded NarrativeManager paths)

Use `/migrate-eventbus <filename>` to migrate these files.

## Contributing

When adding new commands:
1. Create a new `.md` file in this directory
2. Include `---\ndescription: Brief description\n---` frontmatter
3. Provide clear implementation steps
4. Reference existing code patterns
5. Include examples and best practices
6. Update this README with the new command
