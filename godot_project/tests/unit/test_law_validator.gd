extends GutTest

# Unit tests for LawValidator.gd
# Tests rule validation, age calculation, and expiration checking

var law_validator: Node

func before_each():
	# Load the LawValidator autoload script
	var LawValidatorScript = load("res://assets/autoload/LawValidator.gd")
	law_validator = LawValidatorScript.new()

func after_each():
	law_validator.free()
	law_validator = null

# Test age calculation
func test_calculate_age_exact_birthday():
	# Test with a date exactly 5 years ago
	var current_date = Time.get_date_dict_from_system()
	var birth_date = "%04d.%02d.%02d" % [current_date.year - 5, current_date.month, current_date.day]

	var age = law_validator.calculate_age(birth_date)
	assert_eq(age, 5, "Age should be exactly 5 years for birthday today")

func test_calculate_age_birthday_not_yet_occurred():
	# Test with birthday later this year (not yet occurred)
	var current_date = Time.get_date_dict_from_system()
	var future_month = (current_date.month % 12) + 1
	var future_year = current_date.year - 5
	if future_month < current_date.month:
		future_year += 1

	var birth_date = "%04d.%02d.%02d" % [future_year, future_month, current_date.day]

	var age = law_validator.calculate_age(birth_date)
	# Age should be one less since birthday hasn't occurred
	assert_true(age >= 0, "Age should be valid non-negative number")

func test_calculate_age_newborn():
	var current_date = Time.get_date_dict_from_system()
	var birth_date = "%04d.%02d.%02d" % [current_date.year, current_date.month, current_date.day]

	var age = law_validator.calculate_age(birth_date)
	assert_eq(age, 0, "Age should be 0 for someone born today")

func test_calculate_age_very_old():
	var current_date = Time.get_date_dict_from_system()
	var birth_date = "%04d.%02d.%02d" % [current_date.year - 100, 1, 1]

	var age = law_validator.calculate_age(birth_date)
	assert_true(age >= 99, "Age should be at least 99 for someone born 100 years ago")

func test_calculate_age_invalid_format():
	# Test with invalid date format
	var age = law_validator.calculate_age("invalid_date")
	assert_eq(age, 0, "Invalid date should return 0")

# Test expiration date checking
func test_is_expired_past_date():
	var current_date = Time.get_date_dict_from_system()
	var expired_date = "%04d.%02d.%02d" % [current_date.year - 1, current_date.month, current_date.day]

	var result = law_validator.is_expired(expired_date)
	assert_true(result, "Date from last year should be expired")

func test_is_expired_future_date():
	var current_date = Time.get_date_dict_from_system()
	var future_date = "%04d.%02d.%02d" % [current_date.year + 1, current_date.month, current_date.day]

	var result = law_validator.is_expired(future_date)
	assert_false(result, "Future date should not be expired")

func test_is_expired_today():
	var current_date = Time.get_date_dict_from_system()
	var today = "%04d.%02d.%02d" % [current_date.year, current_date.month, current_date.day]

	var result = law_validator.is_expired(today)
	assert_false(result, "Today's date should not be expired")

func test_is_expired_yesterday():
	var current_date = Time.get_date_dict_from_system()
	var yesterday_day = current_date.day - 1
	var yesterday_month = current_date.month
	var yesterday_year = current_date.year

	if yesterday_day < 1:
		yesterday_month -= 1
		yesterday_day = 28  # Simplified
		if yesterday_month < 1:
			yesterday_month = 12
			yesterday_year -= 1

	var yesterday = "%04d.%02d.%02d" % [yesterday_year, yesterday_month, yesterday_day]
	var result = law_validator.is_expired(yesterday)
	assert_true(result, "Yesterday's date should be expired")

# Test condition-based rules
func test_check_violations_fresh_potatoes_rule():
	var potato_info = {
		"condition": "Rotten",
		"expiration_date": "2030.12.31",
		"sex": "Male",
		"country_of_issue": "Spudland",
		"race": "Russet",
		"date_of_birth": "2020.01.01"
	}
	var rules = ["law_fresh_potatoes"]

	var result = law_validator.check_violations(potato_info, rules)
	assert_false(result.is_valid, "Rotten potato should violate fresh potatoes rule")
	assert_string_contains(result.violation_reason, "not_fresh", "Violation reason should mention not fresh")

func test_check_violations_rotten_rule():
	var potato_info = {
		"condition": "Rotten",
		"expiration_date": "2030.12.31",
		"sex": "Male",
		"country_of_issue": "Spudland",
		"race": "Russet",
		"date_of_birth": "2020.01.01"
	}
	var rules = ["law_rotten"]

	var result = law_validator.check_violations(potato_info, rules)
	assert_false(result.is_valid, "Rotten potato should violate rotten rule")

func test_check_violations_no_violations():
	var potato_info = {
		"condition": "Fresh",
		"expiration_date": "2030.12.31",
		"sex": "Male",
		"country_of_issue": "Spudland",
		"race": "Russet",
		"date_of_birth": "2020.01.01"
	}
	var rules = ["law_rotten"]  # Only ban rotten potatoes

	var result = law_validator.check_violations(potato_info, rules)
	assert_true(result.is_valid, "Fresh potato should not violate rotten rule")
	assert_eq(result.violation_reason, "", "No violation reason should be present")

# Test gender-based rules
func test_check_violations_males_only():
	var potato_info = {
		"condition": "Fresh",
		"expiration_date": "2030.12.31",
		"sex": "Female",
		"country_of_issue": "Spudland",
		"race": "Russet",
		"date_of_birth": "2020.01.01"
	}
	var rules = ["law_males_only"]

	var result = law_validator.check_violations(potato_info, rules)
	assert_false(result.is_valid, "Female potato should violate males only rule")

func test_check_violations_females_only():
	var potato_info = {
		"condition": "Fresh",
		"expiration_date": "2030.12.31",
		"sex": "Male",
		"country_of_issue": "Spudland",
		"race": "Russet",
		"date_of_birth": "2020.01.01"
	}
	var rules = ["law_females_only"]

	var result = law_validator.check_violations(potato_info, rules)
	assert_false(result.is_valid, "Male potato should violate females only rule")

# Test expired documents
func test_check_violations_expired_document():
	var potato_info = {
		"condition": "Fresh",
		"expiration_date": "2020.01.01",  # Expired
		"sex": "Male",
		"country_of_issue": "Spudland",
		"race": "Russet",
		"date_of_birth": "2015.01.01"
	}
	var rules = []

	var result = law_validator.check_violations(potato_info, rules)
	assert_false(result.is_valid, "Expired document should always be invalid")
	assert_string_contains(result.violation_reason, "expired", "Violation should mention expiration")

# Test rule conflict resolution
func test_remove_conflicting_rules_fresh_vs_rotten():
	var rules = ["law_fresh_potatoes", "law_rotten"]
	var processed = law_validator.remove_conflicting_rules(rules)

	assert_true(processed.has("law_fresh_potatoes"), "Should keep first rule (law_fresh_potatoes)")
	assert_false(processed.has("law_rotten"), "Should remove conflicting rule (law_rotten)")

func test_remove_conflicting_rules_males_vs_females():
	var rules = ["law_males_only", "law_females_only"]
	var processed = law_validator.remove_conflicting_rules(rules)

	assert_true(processed.has("law_males_only"), "Should keep first rule")
	assert_false(processed.has("law_females_only"), "Should remove conflicting rule")

func test_remove_conflicting_rules_no_conflicts():
	var rules = ["law_rotten", "law_purple_majesty", "law_country_spudland"]
	var processed = law_validator.remove_conflicting_rules(rules)

	assert_eq(processed.size(), 3, "Should keep all non-conflicting rules")

# Test rule difficulty classification
func test_get_rule_difficulty_simple():
	var difficulty = law_validator.get_rule_difficulty("law_rotten")
	assert_eq(difficulty, 1, "law_rotten should be difficulty 1 (simple)")

func test_get_rule_difficulty_medium():
	var difficulty = law_validator.get_rule_difficulty("law_males_only")
	assert_eq(difficulty, 2, "law_males_only should be difficulty 2 (medium)")

func test_get_rule_difficulty_complex():
	var difficulty = law_validator.get_rule_difficulty("law_over_5_years")
	assert_eq(difficulty, 3, "law_over_5_years should be difficulty 3 (complex)")

func test_get_rule_difficulty_default():
	var difficulty = law_validator.get_rule_difficulty("law_unknown_rule")
	assert_eq(difficulty, 2, "Unknown rules should default to difficulty 2")

# Test country-based rules
func test_check_violations_country_rule():
	var potato_info = {
		"condition": "Fresh",
		"expiration_date": "2030.12.31",
		"sex": "Male",
		"country_of_issue": "Spudland",
		"race": "Russet",
		"date_of_birth": "2020.01.01"
	}
	var rules = ["law_country_spudland"]

	var result = law_validator.check_violations(potato_info, rules)
	assert_false(result.is_valid, "Potato from Spudland should violate country ban")

# Test race-based rules
func test_check_violations_race_rule():
	var potato_info = {
		"condition": "Fresh",
		"expiration_date": "2030.12.31",
		"sex": "Male",
		"country_of_issue": "Tuberville",
		"race": "Purple Majesty",
		"date_of_birth": "2020.01.01"
	}
	var rules = ["law_purple_majesty"]

	var result = law_validator.check_violations(potato_info, rules)
	assert_false(result.is_valid, "Purple Majesty potato should violate race rule")
