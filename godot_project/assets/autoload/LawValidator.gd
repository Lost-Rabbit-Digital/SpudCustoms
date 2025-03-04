extends Node

var LAW_CHECKS = {
	# Condition-based rules
	"All potatoes must be Fresh!": {
		"check": func(potato_info): return potato_info.condition != "Fresh",
		"message": func(potato_info): return "Potato was %s but must be Fresh" % potato_info.condition
	},
	"Extra Eyes are suspicious, inspect carefully and reject.": {
		"check": func(potato_info): return potato_info.condition == "Extra Eyes",
		"message": func(potato_info): return "Potato had Extra Eyes which is forbidden"
	},
	"Rotten potatoes are strictly forbidden.": {
		"check": func(potato_info): return potato_info.condition == "Rotten",
		"message": func(potato_info): return "Rotten potatoes are not allowed"
	},
	"Sprouted potatoes must be denied.": {
		"check": func(potato_info): return potato_info.condition == "Sprouted",
		"message": func(potato_info): return "Sprouted potatoes are not allowed"
	},
	"Dehydrated potatoes are not allowed today.": {
		"check": func(potato_info): return potato_info.condition == "Dehydrated",
		"message": func(potato_info): return "Dehydrated potatoes are not allowed"
	},
	"Frozen potatoes require a special permit.": {
		"check": func(potato_info): return potato_info.condition == "Frozen",
		"message": func(potato_info): return "Frozen potatoes are not allowed without permit"
	},

	# Age-based rules
	"No potatoes over 5 years old.": {
		"check": func(potato_info): return calculate_age(potato_info.date_of_birth) >= 5,
		"message": func(potato_info): return "Potato is %d years old (max 5 years)" % calculate_age(potato_info.date_of_birth)
	},
	"Reject potatoes younger than 3 years old.": {
		"check": func(potato_info): return calculate_age(potato_info.date_of_birth) <= 3,
		"message": func(potato_info): return "Potato is %d years old (must be over 3)" % calculate_age(potato_info.date_of_birth)
	},
	"Young potatoes (under 2 years) need guardian.": {
		"check": func(potato_info): return calculate_age(potato_info.date_of_birth) <= 2,
		"message": func(potato_info): return "Potato under 2 years old needs guardian"
	},

	# Gender-based rules
	"Only male potatoes allowed today.": {
		"check": func(potato_info): return potato_info.sex == "Female",
		"message": func(potato_info): return "Only male potatoes allowed today"
	},
	"Female potatoes only, reject all males.": {
		"check": func(potato_info): return potato_info.sex == "Male",
		"message": func(potato_info): return "Only female potatoes allowed today"
	},

	# Country-based rules
	"Potatoes from Spudland must be denied.": {
		"check": func(potato_info): return potato_info.country_of_issue == "Spudland",
		"message": func(potato_info): return "Spudland potatoes are not allowed"
	},
	"Potatopia citizens cannot enter under any circumstances.": {
		"check": func(potato_info): return potato_info.country_of_issue == "Potatopia",
		"message": func(potato_info): return "Potatopia citizens are not allowed"
	},
	"Tuberstan potatoes suspected of concealing arms.": {
		"check": func(potato_info): return potato_info.country_of_issue == "Tuberstan",
		"message": func(potato_info): return "Tuberstan potatoes are currently restricted"
	},
	"North Yamnea is currently restricted due to radioactive taters.": {
		"check": func(potato_info): return potato_info.country_of_issue == "North Yamnea",
		"message": func(potato_info): return "North Yamnea potatoes are restricted (radioactive)"
	},
	"Reject Spuddington potatoes because of visa counterfeiting activity.": {
		"check": func(potato_info): return potato_info.country_of_issue == "Spuddington",
		"message": func(potato_info): return "Spuddington potatoes restricted (counterfeiting)"
	},
	"Tatcross citizens get ABSOLUTELY NO entry processing.": {
		"check": func(potato_info): return potato_info.country_of_issue == "Tatcross",
		"message": func(potato_info): return "Tatcross citizens are not allowed"
	},
	"Mash Meadows potatoes are subject to quarantine, reject!": {
		"check": func(potato_info): return potato_info.country_of_issue == "Mash Meadows",
		"message": func(potato_info): return "Mash Meadows under quarantine"
	},
	"Tuberville potatoes subject to absolute rejection.": {
		"check": func(potato_info): return potato_info.country_of_issue == "Tuberville",
		"message": func(potato_info): return "Tuberville potatoes are not allowed"
	},
	"Chip Hill exports are currently restricted.": {
		"check": func(potato_info): return potato_info.country_of_issue == "Chip Hill",
		"message": func(potato_info): return "Chip Hill exports are restricted"
	},
	"Murphyland potatoes are banned from the economy. Reject!": {
		"check": func(potato_info): return potato_info.country_of_issue == "Murphyland",
		"message": func(potato_info): return "Murphyland potatoes are banned"
	},
	"Colcannon citizens must be rejected due to seasonings.": {
		"check": func(potato_info): return potato_info.country_of_issue == "Colcannon",
		"message": func(potato_info): return "Colcannon citizens are not allowed"
	},
	"Pratie Point potatoes require rejection on agricultural grounds.": {
		"check": func(potato_info): return potato_info.country_of_issue == "Pratie Point",
		"message": func(potato_info): return "Pratie Point potatoes not allowed"
	}
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
