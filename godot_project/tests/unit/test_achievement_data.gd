extends GutTest

## Unit tests for AchievementData system
## Tests achievement definitions, lookups, and category organization


# ==================== ACHIEVEMENT REGISTRATION TESTS ====================


func test_achievements_registered() -> void:
	var all_ids: Array[String] = AchievementData.get_all_ids()
	assert_gt(all_ids.size(), 0, "Should have achievements registered")


func test_total_achievement_count() -> void:
	var count: int = AchievementData.get_total_count()
	assert_eq(count, 22, "Should have 22 total achievements (9 gameplay + 13 narrative)")


func test_gameplay_achievements_exist() -> void:
	var gameplay_achievements: Array = [
		"ROOKIE_OFFICER",
		"VETERAN_OFFICER",
		"MASTER_OFFICER",
		"SHARPSHOOTER",
		"BORDER_DEFENDER",
		"PERFECT_SHOT",
		"HIGH_SCORER",
		"SCORE_LEGEND",
		"SAVIOR_OF_SPUD"
	]

	for id in gameplay_achievements:
		var achievement: AchievementData.Achievement = AchievementData.get_achievement(id)
		assert_not_null(achievement, "Achievement %s should exist" % id)


func test_narrative_achievements_exist() -> void:
	var narrative_achievements: Array = [
		"BORN_DIPLOMAT",
		"TATER_OF_JUSTICE",
		"BEST_SERVED_HOT",
		"DOWN_WITH_THE_TATRIARCHY",
		"HEART_OF_STONE",
		"SURVIVOR",
		"LATE_BLOOMER",
		"TOMMYS_LEGACY",
		"ELENAS_MEMORY",
		"THE_NOTE",
		"ROOT_OF_EVIL",
		"CHAOS_ARCHITECT"
	]

	for id in narrative_achievements:
		var achievement: AchievementData.Achievement = AchievementData.get_achievement(id)
		assert_not_null(achievement, "Narrative achievement %s should exist" % id)


# ==================== ACHIEVEMENT LOOKUP TESTS ====================


func test_get_achievement_by_id() -> void:
	var achievement: AchievementData.Achievement = AchievementData.get_achievement("ROOKIE_OFFICER")
	assert_not_null(achievement)
	assert_eq(achievement.id, "ROOKIE_OFFICER")
	assert_eq(achievement.steam_id, "rookie_customs_officer")


func test_get_achievement_by_steam_id() -> void:
	var achievement: AchievementData.Achievement = AchievementData.get_achievement_by_steam_id("sharpshooter")
	assert_not_null(achievement)
	assert_eq(achievement.id, "SHARPSHOOTER")


func test_get_nonexistent_achievement_returns_null() -> void:
	var achievement: AchievementData.Achievement = AchievementData.get_achievement("FAKE_ACHIEVEMENT")
	assert_null(achievement, "Getting nonexistent achievement should return null")


func test_get_nonexistent_steam_id_returns_null() -> void:
	var achievement: AchievementData.Achievement = AchievementData.get_achievement_by_steam_id("fake_steam_id")
	assert_null(achievement, "Getting nonexistent steam ID should return null")


# ==================== CATEGORY TESTS ====================


func test_gameplay_category_count() -> void:
	var gameplay: Array[AchievementData.Achievement] = AchievementData.get_achievements_by_category(AchievementData.Category.GAMEPLAY)
	assert_eq(gameplay.size(), 9, "Gameplay category should have 9 achievements")


func test_resistance_category_count() -> void:
	var resistance: Array[AchievementData.Achievement] = AchievementData.get_achievements_by_category(AchievementData.Category.NARRATIVE_RESISTANCE)
	assert_eq(resistance.size(), 4, "Resistance path should have 4 achievements")


func test_loyalist_category_count() -> void:
	var loyalist: Array[AchievementData.Achievement] = AchievementData.get_achievements_by_category(AchievementData.Category.NARRATIVE_LOYALIST)
	assert_eq(loyalist.size(), 3, "Loyalist path should have 3 achievements")


func test_character_arc_category_count() -> void:
	var character: Array[AchievementData.Achievement] = AchievementData.get_achievements_by_category(AchievementData.Category.CHARACTER_ARC)
	assert_eq(character.size(), 3, "Character arc category should have 3 achievements")


func test_discovery_category_count() -> void:
	var discovery: Array[AchievementData.Achievement] = AchievementData.get_achievements_by_category(AchievementData.Category.DISCOVERY)
	assert_eq(discovery.size(), 2, "Discovery category should have 2 achievements")


# ==================== ACHIEVEMENT PROPERTY TESTS ====================


func test_achievement_has_name_key() -> void:
	var achievement: AchievementData.Achievement = AchievementData.get_achievement("HIGH_SCORER")
	assert_true(achievement.name_key.length() > 0, "Achievement should have name key")
	assert_eq(achievement.name_key, "achievement_high_scorer_name")


func test_achievement_has_description_key() -> void:
	var achievement: AchievementData.Achievement = AchievementData.get_achievement("HIGH_SCORER")
	assert_true(achievement.description_key.length() > 0, "Achievement should have description key")
	assert_eq(achievement.description_key, "achievement_high_scorer_desc")


func test_achievement_icon_paths() -> void:
	var achievement: AchievementData.Achievement = AchievementData.get_achievement("SHARPSHOOTER")
	assert_true(achievement.icon_completed.ends_with("_completed.jpg"))
	assert_true(achievement.icon_locked.ends_with("_uncompleted.jpg"))


func test_trackable_achievement_has_progress_max() -> void:
	var achievement: AchievementData.Achievement = AchievementData.get_achievement("BORDER_DEFENDER")
	assert_eq(achievement.progress_max, 50, "Border Defender should require 50 runners")
	assert_eq(achievement.progress_stat, "total_runners_stopped")


func test_narrative_achievement_not_trackable() -> void:
	var achievement: AchievementData.Achievement = AchievementData.get_achievement("BORN_DIPLOMAT")
	assert_eq(achievement.progress_max, 0, "Narrative achievement should not be trackable")


func test_hidden_achievements() -> void:
	# Narrative achievements should be hidden
	var hidden: AchievementData.Achievement = AchievementData.get_achievement("BORN_DIPLOMAT")
	assert_true(hidden.is_hidden, "Narrative achievement should be hidden")

	# Gameplay trackable achievements should not be hidden
	var visible: AchievementData.Achievement = AchievementData.get_achievement("ROOKIE_OFFICER")
	assert_false(visible.is_hidden, "Trackable gameplay achievement should not be hidden")


# ==================== CATEGORY NAME TESTS ====================


func test_category_names_defined() -> void:
	assert_true(AchievementData.CATEGORY_NAMES.has(AchievementData.Category.GAMEPLAY))
	assert_true(AchievementData.CATEGORY_NAMES.has(AchievementData.Category.NARRATIVE_RESISTANCE))
	assert_true(AchievementData.CATEGORY_NAMES.has(AchievementData.Category.NARRATIVE_LOYALIST))
	assert_true(AchievementData.CATEGORY_NAMES.has(AchievementData.Category.CHARACTER_ARC))
	assert_true(AchievementData.CATEGORY_NAMES.has(AchievementData.Category.DISCOVERY))
