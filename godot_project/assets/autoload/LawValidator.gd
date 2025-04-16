extends Node

var LAW_CHECKS = {
	# Condition-based rules
	"[color=dark_goldenrod]All[/color] potatoes must be [color=dark_green]fresh[/color]!\n": {
		"check": func(potato_info): return potato_info.condition != "Fresh",
		"message": func(potato_info): return "Potato was %s but must be Fresh" % potato_info.condition
	},
	"[color=dark_goldenrod]Extra Eyes[/color] are suspicious, inspect carefully and [color=dark_red]reject[/color].\n": {
		"check": func(potato_info): return potato_info.condition == "Extra Eyes",
		"message": func(potato_info): return "Potato had Extra Eyes which is forbidden"
	},
	"[color=dark_goldenrod]Rotten[/color] potatoes are strictly [color=dark_red]forbidden[/color].\n": {
		"check": func(potato_info): return potato_info.condition == "Rotten",
		"message": func(potato_info): return "Rotten potatoes are not allowed"
	},
	"[color=dark_goldenrod]Sprouted[/color] potatoes must be [color=dark_red]denied[/color].\n": {
		"check": func(potato_info): return potato_info.condition == "Sprouted",
		"message": func(potato_info): return "Sprouted potatoes are not allowed"
	},
	"[color=dark_goldenrod]Dehydrated[/color] potatoes are [color=dark_red]not allowed[/color] today.\n": {
		"check": func(potato_info): return potato_info.condition == "Dehydrated",
		"message": func(potato_info): return "Dehydrated potatoes are not allowed"
	},
	"[color=dark_goldenrod]Frozen[/color] potatoes are [color=dark_red]banned[/color] due to low temperatures.\n": {
		"check": func(potato_info): return potato_info.condition == "Frozen",
		"message": func(potato_info): return "Frozen potatoes are not allowed without thawing"
	},

	# Age-based rules
	"[color=dark_red]No[/color] potatoes over [color=dark_goldenrod]5 years old[/color].\n": {
		"check": func(potato_info): return calculate_age(potato_info.date_of_birth) >= 5,
		"message": func(potato_info): return "Potato is %d years old (max 5 years)" % calculate_age(potato_info.date_of_birth)
	},
	"[color=dark_red]Reject[/color] potatoes younger than [color=dark_goldenrod]3 years old[/color].\n": {
		"check": func(potato_info): return calculate_age(potato_info.date_of_birth) <= 3,
		"message": func(potato_info): return "Potato is %d years old (must be over 3)" % calculate_age(potato_info.date_of_birth)
	},
	"Potatoes under [color=dark_goldenrod]2 years old[/color] are [color=dark_red]not[/color] allowed.\n": {
		"check": func(potato_info): return calculate_age(potato_info.date_of_birth) <= 2,
		"message": func(potato_info): return "Potatoes under 2 years old are banned"
	},

	# Gender-based rules
	"Only [color=dark_goldenrod]male[/color] potatoes [color=dark_green]allowed[/color] today.\n": {
		"check": func(potato_info): return potato_info.sex == "Female",
		"message": func(potato_info): return "Only male potatoes allowed today"
	},
	"[color=dark_goldenrod]Female[/color] potatoes only, [color=dark_red]reject[/color] all males.\n": {
		"check": func(potato_info): return potato_info.sex == "Male",
		"message": func(potato_info): return "Only female potatoes allowed today"
	},

	# Country-based rules
	"Potatoes from [color=dark_goldenrod]Spudland[/color] must be [color=dark_red]denied[/color].\n": {
		"check": func(potato_info): return potato_info.country_of_issue == "Spudland",
		"message": func(potato_info): return "Spudland potatoes are not allowed"
	},
	"[color=dark_goldenrod]Potatopia[/color] citizens [color=dark_red]cannot[/color] enter for any reason.\n": {
		"check": func(potato_info): return potato_info.country_of_issue == "Potatopia",
		"message": func(potato_info): return "Potatopia citizens are not allowed"
	},
	"[color=dark_goldenrod]Tuberstan[/color] potatoes suspected of [color=dark_red]concealing arms[/color].\n": {
		"check": func(potato_info): return potato_info.country_of_issue == "Tuberstan",
		"message": func(potato_info): return "Tuberstan potatoes are currently restricted"
	},
	"[color=dark_goldenrod]North Yamnea[/color] is currently restricted due to [color=dark_red]radioactive taters[/color].\n": {
		"check": func(potato_info): return potato_info.country_of_issue == "North Yamnea",
		"message": func(potato_info): return "North Yamnea potatoes are restricted (radioactive)"
	},
	"[color=dark_goldenrod]Spuddington[/color] potatoes are [color=dark_red]counterfeiting[/color] documents.\n": {
		"check": func(potato_info): return potato_info.country_of_issue == "Spuddington",
		"message": func(potato_info): return "Spuddington potatoes restricted (counterfeiting)"
	},
	"[color=dark_goldenrod]Tatcross[/color] citizens get [color=dark_red]ABSOLUTELY NO[/color] entry processing.\n": {
		"check": func(potato_info): return potato_info.country_of_issue == "Tatcross",
		"message": func(potato_info): return "Tatcross citizens are not allowed"
	},
	"[color=dark_goldenrod]Mash Meadows[/color] potatoes are [color=dark_red]banned[/color] due to quarantine!\n": {
		"check": func(potato_info): return potato_info.country_of_issue == "Mash Meadows",
		"message": func(potato_info): return "Mash Meadows under quarantine"
	},
	"[color=dark_goldenrod]Tuberville[/color] potatoes subject to [color=dark_red]absolute rejection[/color].\n": {
		"check": func(potato_info): return potato_info.country_of_issue == "Tuberville",
		"message": func(potato_info): return "Tuberville potatoes are not allowed"
	},
	"[color=dark_goldenrod]Chip Hill[/color] exports are currently [color=dark_red]restricted[/color].\n": {
		"check": func(potato_info): return potato_info.country_of_issue == "Chip Hill",
		"message": func(potato_info): return "Chip Hill exports are restricted"
	},
	"[color=dark_goldenrod]Murphyland[/color] potatoes are [color=dark_red]banned[/color] from the economy!\n": {
		"check": func(potato_info): return potato_info.country_of_issue == "Murphyland",
		"message": func(potato_info): return "Murphyland potatoes are banned"
	},
	"[color=dark_goldenrod]Colcannon[/color] citizens must be [color=dark_red]rejected[/color] due to plague.\n": {
		"check": func(potato_info): return potato_info.country_of_issue == "Colcannon",
		"message": func(potato_info): return "Colcannon citizens are not allowed"
	},
	"[color=dark_goldenrod]Pratie Point[/color] potatoes require [color=dark_red]rejection[/color] due to agricultural differences.\n": {
		"check": func(potato_info): return potato_info.country_of_issue == "Pratie Point",
		"message": func(potato_info): return "Pratie Point potatoes not allowed"
	},
	"[color=dark_goldenrod]Purple Majesty[/color] potatoes [color=dark_red]forbidden[/color].\n": {
		"check": func(potato_info): return potato_info.race == "Purple Majesty",
		"message": func(potato_info): return "Purple Majesty potatoes are not allowed."
	},
	"[color=dark_goldenrod]Sweet Potatoes[/color] need [color=dark_goldenrod]special paperwork[/color].\n": {
		"check": func(potato_info): return potato_info.race == "Sweet Potato",
		"message": func(potato_info): return "Sweet Potatoes require Form T-43."
	},
	"[color=dark_goldenrod]Yukon Gold[/color] potatoes must be [color=dark_green]fresh[/color].\n": {
		"check": func(potato_info): return potato_info.race != "Yukon Gold" or potato_info.condition == "Fresh",
		"message": func(potato_info): return "Yukon Gold potatoes must be fresh."
	},
}

# Helper function to check all violations
func check_violations(potato_info: Dictionary, current_rules: Array) -> Dictionary:
	var result = {
		"is_valid": true,
		"violation_reason": ""
	}
	
	# Check expiration first
	if is_expired(potato_info.expiration_date):
		result.is_valid = false
		result.violation_reason = "Document expired on " + potato_info.expiration_date
		return result
	
	# Check each active rule
	for rule in current_rules:
		if rule in LAW_CHECKS:
			var check_func = LAW_CHECKS[rule]["check"]
			if check_func.call(potato_info):
				result.is_valid = false
				result.violation_reason = LAW_CHECKS[rule]["message"].call(potato_info)
				break
	
	return result

# Helper function to calculate age
func calculate_age(date_of_birth: String) -> int:
	var current_date = Time.get_date_dict_from_system()
	var birth_parts = date_of_birth.split('.')
	
	if birth_parts.size() != 3:
		push_error("Invalid date format: " + date_of_birth)
		return 0
	
	var birth_year = birth_parts[0].to_int()
	var birth_month = birth_parts[1].to_int()
	var birth_day = birth_parts[2].to_int()
	
	var age = current_date.year - birth_year
	
	# Adjust age if birthday hasn't occurred this year
	if current_date.month < birth_month or (current_date.month == birth_month and current_date.day < birth_day):
		age -= 1
	
	return age

# Helper function to check expiration
func is_expired(expiration_date: String) -> bool:
	var current_date = Time.get_date_dict_from_system()
	var expiry_parts = expiration_date.split('.')
	
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
