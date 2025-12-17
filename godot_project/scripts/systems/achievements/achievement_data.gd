## Achievement data resource containing all achievement definitions.
##
## Provides a centralized registry of all achievements with metadata
## for display in the achievements UI and Steam integration.
class_name AchievementData
extends RefCounted

## Achievement categories for organization
enum Category {
	GAMEPLAY,
	NARRATIVE_RESISTANCE,
	NARRATIVE_LOYALIST,
	CHARACTER_ARC,
	DISCOVERY
}

## Single achievement definition
class Achievement:
	var id: String
	var steam_id: String
	var name_key: String  # Localization key
	var description_key: String  # Localization key
	var category: Category
	var icon_completed: String
	var icon_locked: String
	var is_hidden: bool  # Hidden until unlocked (spoiler protection)
	var progress_max: int  # For trackable achievements (0 = not trackable)
	var progress_stat: String  # Stat name to track progress

	func _init(
		p_id: String,
		p_steam_id: String,
		p_name_key: String,
		p_description_key: String,
		p_category: Category,
		p_is_hidden: bool = false,
		p_progress_max: int = 0,
		p_progress_stat: String = ""
	) -> void:
		id = p_id
		steam_id = p_steam_id
		name_key = p_name_key
		description_key = p_description_key
		category = p_category
		is_hidden = p_is_hidden
		progress_max = p_progress_max
		progress_stat = p_progress_stat
		icon_completed = "res://assets/achievements/%s_completed.jpg" % steam_id
		icon_locked = "res://assets/achievements/%s_uncompleted.jpg" % steam_id


## All achievement definitions
static var ACHIEVEMENTS: Dictionary = {}

## Category display names (localization keys)
static var CATEGORY_NAMES: Dictionary = {
	Category.GAMEPLAY: "achievement_category_gameplay",
	Category.NARRATIVE_RESISTANCE: "achievement_category_resistance",
	Category.NARRATIVE_LOYALIST: "achievement_category_loyalist",
	Category.CHARACTER_ARC: "achievement_category_character",
	Category.DISCOVERY: "achievement_category_discovery"
}


static func _static_init() -> void:
	_register_all_achievements()


static func _register_all_achievements() -> void:
	# =========================================================================
	# GAMEPLAY ACHIEVEMENTS (9)
	# =========================================================================

	_register(Achievement.new(
		"ROOKIE_OFFICER",
		"rookie_customs_officer",
		"achievement_rookie_officer_name",
		"achievement_rookie_officer_desc",
		Category.GAMEPLAY,
		false,
		1,
		"total_shifts_completed"
	))

	_register(Achievement.new(
		"VETERAN_OFFICER",
		"customs_veteran",
		"achievement_veteran_officer_name",
		"achievement_veteran_officer_desc",
		Category.GAMEPLAY,
		false,
		10,
		"total_shifts_completed"
	))

	_register(Achievement.new(
		"MASTER_OFFICER",
		"master_of_customs",
		"achievement_master_officer_name",
		"achievement_master_officer_desc",
		Category.GAMEPLAY,
		false,
		25,
		"total_shifts_completed"
	))

	_register(Achievement.new(
		"SHARPSHOOTER",
		"sharpshooter",
		"achievement_sharpshooter_name",
		"achievement_sharpshooter_desc",
		Category.GAMEPLAY,
		false,
		10,
		"total_runners_stopped"
	))

	_register(Achievement.new(
		"BORDER_DEFENDER",
		"border_defender",
		"achievement_border_defender_name",
		"achievement_border_defender_desc",
		Category.GAMEPLAY,
		false,
		50,
		"total_runners_stopped"
	))

	_register(Achievement.new(
		"PERFECT_SHOT",
		"perfect_shot",
		"achievement_perfect_shot_name",
		"achievement_perfect_shot_desc",
		Category.GAMEPLAY,
		false,
		5,
		"perfect_hits"
	))

	_register(Achievement.new(
		"HIGH_SCORER",
		"high_scorer",
		"achievement_high_scorer_name",
		"achievement_high_scorer_desc",
		Category.GAMEPLAY,
		false,
		10000,
		"high_score"
	))

	_register(Achievement.new(
		"SCORE_LEGEND",
		"score_legend",
		"achievement_score_legend_name",
		"achievement_score_legend_desc",
		Category.GAMEPLAY,
		false,
		50000,
		"high_score"
	))

	_register(Achievement.new(
		"SAVIOR_OF_SPUD",
		"savior_of_spud",
		"achievement_savior_of_spud_name",
		"achievement_savior_of_spud_desc",
		Category.GAMEPLAY,
		true  # Hidden - story completion
	))

	# =========================================================================
	# NARRATIVE - RESISTANCE PATH (4)
	# =========================================================================

	_register(Achievement.new(
		"BORN_DIPLOMAT",
		"born_diplomat",
		"achievement_born_diplomat_name",
		"achievement_born_diplomat_desc",
		Category.NARRATIVE_RESISTANCE,
		true  # Hidden ending
	))

	_register(Achievement.new(
		"TATER_OF_JUSTICE",
		"tater_of_justice",
		"achievement_tater_of_justice_name",
		"achievement_tater_of_justice_desc",
		Category.NARRATIVE_RESISTANCE,
		true
	))

	_register(Achievement.new(
		"BEST_SERVED_HOT",
		"best_served_hot",
		"achievement_best_served_hot_name",
		"achievement_best_served_hot_desc",
		Category.NARRATIVE_RESISTANCE,
		true
	))

	_register(Achievement.new(
		"DOWN_WITH_THE_TATRIARCHY",
		"down_with_the_tatriarchy",
		"achievement_down_with_tatriarchy_name",
		"achievement_down_with_tatriarchy_desc",
		Category.NARRATIVE_RESISTANCE,
		true
	))

	# =========================================================================
	# NARRATIVE - LOYALIST PATH (3)
	# =========================================================================

	_register(Achievement.new(
		"HEART_OF_STONE",
		"heart_of_stone",
		"achievement_heart_of_stone_name",
		"achievement_heart_of_stone_desc",
		Category.NARRATIVE_LOYALIST,
		true
	))

	_register(Achievement.new(
		"SURVIVOR",
		"survivor",
		"achievement_survivor_name",
		"achievement_survivor_desc",
		Category.NARRATIVE_LOYALIST,
		true
	))

	_register(Achievement.new(
		"LATE_BLOOMER",
		"late_bloomer",
		"achievement_late_bloomer_name",
		"achievement_late_bloomer_desc",
		Category.NARRATIVE_LOYALIST,
		true
	))

	# =========================================================================
	# CHARACTER ARC ACHIEVEMENTS (3)
	# =========================================================================

	_register(Achievement.new(
		"TOMMYS_LEGACY",
		"tommys_legacy",
		"achievement_tommys_legacy_name",
		"achievement_tommys_legacy_desc",
		Category.CHARACTER_ARC,
		true
	))

	_register(Achievement.new(
		"ELENAS_MEMORY",
		"elenas_memory",
		"achievement_elenas_memory_name",
		"achievement_elenas_memory_desc",
		Category.CHARACTER_ARC,
		true
	))

	_register(Achievement.new(
		"THE_NOTE",
		"the_note",
		"achievement_the_note_name",
		"achievement_the_note_desc",
		Category.CHARACTER_ARC,
		true
	))

	# =========================================================================
	# DISCOVERY ACHIEVEMENTS (2)
	# =========================================================================

	_register(Achievement.new(
		"ROOT_OF_EVIL",
		"root_of_evil",
		"achievement_root_of_evil_name",
		"achievement_root_of_evil_desc",
		Category.DISCOVERY,
		true
	))

	_register(Achievement.new(
		"CHAOS_ARCHITECT",
		"chaos_architect",
		"achievement_chaos_architect_name",
		"achievement_chaos_architect_desc",
		Category.DISCOVERY,
		true
	))


static func _register(achievement: Achievement) -> void:
	ACHIEVEMENTS[achievement.id] = achievement


## Get achievement by internal ID
static func get_achievement(id: String) -> Achievement:
	return ACHIEVEMENTS.get(id, null)


## Get achievement by Steam ID
static func get_achievement_by_steam_id(steam_id: String) -> Achievement:
	for achievement in ACHIEVEMENTS.values():
		if achievement.steam_id == steam_id:
			return achievement
	return null


## Get all achievements in a category
static func get_achievements_by_category(category: Category) -> Array[Achievement]:
	var result: Array[Achievement] = []
	for achievement in ACHIEVEMENTS.values():
		if achievement.category == category:
			result.append(achievement)
	return result


## Get all achievement IDs
static func get_all_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in ACHIEVEMENTS.keys():
		ids.append(id)
	return ids


## Get total achievement count
static func get_total_count() -> int:
	return ACHIEVEMENTS.size()
