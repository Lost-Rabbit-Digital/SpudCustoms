extends Node

var LAW_CHECKS = {
	"law_fresh_potatoes":
	{
		"check": func(potato_info): return potato_info.condition != "Fresh",
		"message": func(potato_info): return tr("violation_condition_not_fresh").format({"condition": potato_info.condition})
	},
	"law_extra_eyes":
	{
		"check": func(potato_info): return potato_info.condition == "Extra Eyes",
		"message": func(potato_info): return tr("violation_extra_eyes")
	},
	"law_rotten":
	{
		"check": func(potato_info): return potato_info.condition == "Rotten",
		"message": func(potato_info): return tr("violation_rotten")
	},
	"law_sprouted":
	{
		"check": func(potato_info): return potato_info.condition == "Sprouted",
		"message": func(potato_info): return tr("violation_sprouted")
	},
	"law_dehydrated":
	{
		"check": func(potato_info): return potato_info.condition == "Dehydrated",
		"message": func(potato_info): return tr("violation_dehydrated")
	},
	"law_frozen":
	{
		"check": func(potato_info): return potato_info.condition == "Frozen",
		"message": func(potato_info): return tr("violation_frozen")
	},
	"law_over_5_years":
	{
		"check": func(potato_info): return calculate_age(potato_info.date_of_birth) >= 5,
		"message": func(potato_info): return tr("violation_too_old").format({"age": calculate_age(potato_info.date_of_birth)})
	},
	"law_under_3_years":
	{
		"check": func(potato_info): return calculate_age(potato_info.date_of_birth) <= 3,
		"message": func(potato_info): return tr("violation_too_young_3").format({"age": calculate_age(potato_info.date_of_birth)})
	},
	"law_under_2_years":
	{
		"check": func(potato_info): return calculate_age(potato_info.date_of_birth) <= 2,
		"message": func(potato_info): return tr("violation_too_young_2").format({"age": calculate_age(potato_info.date_of_birth)})
	},
	# Gender-based rules
	"law_males_only":
	{
		"check": func(potato_info): return potato_info.sex == "Female",
		"message": func(potato_info): return tr("violation_males_only")
	},
	"law_females_only":
	{
		"check": func(potato_info): return potato_info.sex == "Male",
		"message": func(potato_info): return tr("violation_females_only")
	},
	# Country-based rules
	"law_country_spudland":
	{
		"check": func(potato_info): return potato_info.country_of_issue == "Spudland",
		"message": func(potato_info): return tr("violation_country_spudland")
	},
	"law_country_potatopia":
	{
		"check": func(potato_info): return potato_info.country_of_issue == "Potatopia",
		"message": func(potato_info): return tr("violation_country_potatopia")
	},
	"law_country_tuberstan":
	{
		"check": func(potato_info): return potato_info.country_of_issue == "Tuberstan",
		"message": func(potato_info): return tr("violation_country_tuberstan")
	},
	"law_country_north_yamnea":
	{
		"check": func(potato_info): return potato_info.country_of_issue == "North Yamnea",
		"message": func(potato_info): return tr("violation_country_north_yamnea")
	},
	"law_country_spuddington":
	{
		"check": func(potato_info): return potato_info.country_of_issue == "Spuddington",
		"message": func(potato_info): return tr("violation_country_spuddington")
	},
	"law_country_tatcross":
	{
		"check": func(potato_info): return potato_info.country_of_issue == "Tatcross",
		"message": func(potato_info): return tr("violation_country_tatcross")
	},
	"law_country_mash_meadows":
	{
		"check": func(potato_info): return potato_info.country_of_issue == "Mash Meadows",
		"message": func(potato_info): return tr("violation_country_mash_meadows")
	},
	"law_country_tuberville":
	{
		"check": func(potato_info): return potato_info.country_of_issue == "Tuberville",
		"message": func(potato_info): return tr("violation_country_tuberville")
	},
	"law_country_chip_hill":
	{
		"check": func(potato_info): return potato_info.country_of_issue == "Chip Hill",
		"message": func(potato_info): return tr("violation_country_chip_hill")
	},
	"law_country_murphyland":
	{
		"check": func(potato_info): return potato_info.country_of_issue == "Murphyland",
		"message": func(potato_info): return tr("violation_country_murphyland")
	},
	"law_country_colcannon":
	{
		"check": func(potato_info): return potato_info.country_of_issue == "Colcannon",
		"message": func(potato_info): return tr("violation_country_colcannon")
	},
	"law_country_pratie_point":
	{
		"check": func(potato_info): return potato_info.country_of_issue == "Pratie Point",
		"message": func(potato_info): return tr("violation_country_pratie_point")
	},
	# Race/Type-based rules
	"law_purple_majesty":
	{
		"check": func(potato_info): return potato_info.race == "Purple Majesty",
		"message": func(potato_info): return tr("violation_race_purple_majesty")
	},
	"law_sweet_potatoes":
	{
		"check": func(potato_info): return potato_info.race == "Sweet Potato",
		"message": func(potato_info): return tr("violation_race_sweet_potato")
	},
	"law_yukon_gold":
	{
		"check": func(potato_info): return potato_info.race == "Yukon Gold",
		"message": func(potato_info): return tr("violation_race_yukon_gold")
	},
}


# Get translated rule text
func get_translated_rule_text(rule_key: String) -> String:
	return tr(rule_key)


# Helper function to check all violations
func check_violations(potato_info: Dictionary, current_rules: Array) -> Dictionary:
	var result = {"is_valid": true, "violation_reason": ""}

	# Check expiration first
	if is_expired(potato_info.expiration_date):
		result.is_valid = false
		result.violation_reason = tr("violation_expired_document").format(
			{"date": potato_info.expiration_date}
		)
		return result

	# Check for rule conflicts and remove them
	var processed_rules = remove_conflicting_rules(current_rules)

	# Check each active rule
	for rule in processed_rules:
		if rule in LAW_CHECKS:
			var check_func = LAW_CHECKS[rule]["check"]
			if check_func.call(potato_info):
				result.is_valid = false
				result.violation_reason = LAW_CHECKS[rule]["message"].call(potato_info)
				break

	return result


# Enhanced conflict resolution
func remove_conflicting_rules(rules: Array) -> Array:
	var processed_rules = rules.duplicate()

	# Define conflicting rule pairs (keep first, remove second)
	var conflict_pairs = [
		["law_fresh_potatoes", "law_rotten"],
		["law_males_only", "law_females_only"],
		["law_under_2_years", "law_under_3_years"],
		["law_under_3_years", "law_over_5_years"]
	]

	for pair in conflict_pairs:
		if processed_rules.has(pair[0]) and processed_rules.has(pair[1]):
			processed_rules.erase(pair[1])

	return processed_rules


# Get rule difficulty for progressive complexity
func get_rule_difficulty(rule_key: String) -> int:
	var simple_rules = ["law_rotten", "law_sprouted", "law_fresh_potatoes", "law_extra_eyes"]
	var medium_rules = [
		"law_country_chip_hill", "law_sweet_potatoes", "law_males_only", "law_females_only"
	]
	var complex_rules = ["law_over_5_years", "law_under_3_years", "law_under_2_years"]

	if rule_key in simple_rules:
		return 1
	elif rule_key in medium_rules:
		return 2
	elif rule_key in complex_rules:
		return 3
	else:
		return 2


# Helper function to calculate age
func calculate_age(date_of_birth: String) -> int:
	var current_date = Time.get_date_dict_from_system()
	var birth_parts = date_of_birth.split(".")

	if birth_parts.size() != 3:
		push_error("Invalid date format: " + date_of_birth)
		return 0

	var birth_year = birth_parts[0].to_int()
	var birth_month = birth_parts[1].to_int()
	var birth_day = birth_parts[2].to_int()

	var age = current_date.year - birth_year

	# Adjust age if birthday hasn't occurred this year
	if (
		current_date.month < birth_month
		or (current_date.month == birth_month and current_date.day < birth_day)
	):
		age -= 1

	return age


# Helper function to check expiration
func is_expired(expiration_date: String) -> bool:
	var current_date = Time.get_date_dict_from_system()
	var expiry_parts = expiration_date.split(".")

	if expiry_parts.size() != 3:
		push_error("Invalid date format: " + expiration_date)
		return false

	var expiry = {
		"year": expiry_parts[0].to_int(),
		"month": expiry_parts[1].to_int(),
		"day": expiry_parts[2].to_int()
	}

	# Compare years first
	if expiry.year < current_date.year:
		return true
	elif expiry.year > current_date.year:
		return false

	# Same year, check months
	if expiry.month < current_date.month:
		return true
	elif expiry.month > current_date.month:
		return false

	# Same year and month, check days
	return expiry.day < current_date.day
