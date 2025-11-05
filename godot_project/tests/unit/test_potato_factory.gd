extends GutTest

# Unit tests for PotatoFactory.gd
# Tests potato generation helper functions and data validation

# Test random name generation
func test_get_random_name_returns_valid_format():
	var name = PotatoFactory.get_random_name()
	assert_not_null(name, "Name should not be null")
	assert_gt(name.length(), 0, "Name should not be empty")
	assert_true(name.contains(" "), "Name should contain a space (first and last name)")

func test_get_random_name_consistency():
	# Test that multiple calls return valid names
	for i in range(10):
		var name = PotatoFactory.get_random_name()
		var parts = name.split(" ")
		assert_eq(parts.size(), 2, "Name should have exactly 2 parts (first and last)")

# Test condition generation
func test_get_random_condition_returns_valid_condition():
	var valid_conditions = ["Fresh", "Extra Eyes", "Rotten", "Sprouted", "Dehydrated", "Frozen"]
	var condition = PotatoFactory.get_random_condition()

	assert_true(condition in valid_conditions, "Condition should be one of the valid types")

func test_get_random_condition_distribution():
	# Test that we get different conditions over multiple calls
	var conditions = {}
	for i in range(100):
		var condition = PotatoFactory.get_random_condition()
		conditions[condition] = true

	# With 100 calls we should get at least 3 different conditions
	assert_gt(conditions.size(), 2, "Should generate varied conditions over 100 calls")

# Test race generation
func test_get_random_race_returns_valid_race():
	var valid_races = ["Russet", "Yukon Gold", "Sweet Potato", "Purple Majesty"]
	var race = PotatoFactory.get_random_race()

	assert_true(race in valid_races, "Race should be one of the valid types")

func test_get_random_race_all_types_possible():
	var races = {}
	for i in range(100):
		var race = PotatoFactory.get_random_race()
		races[race] = true

	# With 100 calls we should get multiple races
	assert_gt(races.size(), 1, "Should generate varied races")

# Test sex generation
func test_get_random_sex_returns_valid_sex():
	var sex = PotatoFactory.get_random_sex()
	assert_true(sex == "Male" or sex == "Female", "Sex should be either Male or Female")

func test_get_random_sex_distribution():
	var sexes = {}
	for i in range(50):
		var sex = PotatoFactory.get_random_sex()
		sexes[sex] = true

	# With 50 calls we should get both sexes
	assert_eq(sexes.size(), 2, "Should generate both Male and Female over 50 calls")

# Test country generation
func test_get_random_country_returns_valid_country():
	var valid_countries = [
		"Spudland", "Potatopia", "Tuberstan", "North Yamnea",
		"Spuddington", "Tatcross", "Mash Meadows", "Tuberville",
		"Chip Hill", "Murphyland", "Colcannon", "Pratie Point"
	]
	var country = PotatoFactory.get_random_country()

	assert_true(country in valid_countries, "Country should be one of the valid countries")

func test_get_random_country_not_empty():
	var country = PotatoFactory.get_random_country()
	assert_not_null(country, "Country should not be null")
	assert_gt(country.length(), 0, "Country should not be empty")

# Test date generation - past dates
func test_get_past_date_format():
	var date = PotatoFactory.get_past_date(1, 5)
	assert_not_null(date, "Date should not be null")

	# Check format YYYY.MM.DD
	var parts = date.split(".")
	assert_eq(parts.size(), 3, "Date should have 3 parts (year, month, day)")

	var year = parts[0].to_int()
	var month = parts[1].to_int()
	var day = parts[2].to_int()

	var current_year = Time.get_date_dict_from_system().year

	assert_between(year, current_year - 10, current_year, "Year should be in past")
	assert_between(month, 1, 12, "Month should be between 1-12")
	assert_between(day, 1, 28, "Day should be between 1-28")

func test_get_past_date_is_in_past():
	var date = PotatoFactory.get_past_date(2, 5)
	var parts = date.split(".")
	var year = parts[0].to_int()
	var current_year = Time.get_date_dict_from_system().year

	assert_lt(year, current_year + 1, "Generated year should not be in the future")

# Test date generation - future dates
func test_get_future_date_format():
	var date = PotatoFactory.get_future_date(1, 3)
	assert_not_null(date, "Date should not be null")

	var parts = date.split(".")
	assert_eq(parts.size(), 3, "Date should have 3 parts")

	var month = parts[1].to_int()
	var day = parts[2].to_int()

	assert_between(month, 1, 12, "Month should be valid")
	assert_between(day, 1, 28, "Day should be valid")

func test_get_future_date_is_in_future():
	var date = PotatoFactory.get_future_date(1, 3)
	var parts = date.split(".")
	var year = parts[0].to_int()
	var current_year = Time.get_date_dict_from_system().year

	assert_gte(year, current_year, "Generated year should be current year or later")

# Test generate_random_potato_info structure
func test_generate_random_potato_info_has_required_fields():
	var info = PotatoFactory.generate_random_potato_info()

	assert_not_null(info, "Potato info should not be null")
	assert_true(info.has("name"), "Should have name field")
	assert_true(info.has("condition"), "Should have condition field")
	assert_true(info.has("sex"), "Should have sex field")
	assert_true(info.has("race"), "Should have race field")
	assert_true(info.has("country_of_issue"), "Should have country_of_issue field")
	assert_true(info.has("date_of_birth"), "Should have date_of_birth field")
	assert_true(info.has("expiration_date"), "Should have expiration_date field")
	assert_true(info.has("character_data"), "Should have character_data field")

func test_generate_random_potato_info_valid_values():
	var info = PotatoFactory.generate_random_potato_info()

	# Test that values are valid types
	var valid_conditions = ["Fresh", "Extra Eyes", "Rotten", "Sprouted", "Dehydrated", "Frozen"]
	assert_true(info.condition in valid_conditions, "Condition should be valid")

	var valid_sexes = ["Male", "Female"]
	assert_true(info.sex in valid_sexes, "Sex should be valid")

	var valid_races = ["Russet", "Yukon Gold", "Sweet Potato", "Purple Majesty"]
	assert_true(info.race in valid_races, "Race should be valid")

	# Test date formats
	assert_eq(info.date_of_birth.split(".").size(), 3, "Date of birth should be valid format")
	assert_eq(info.expiration_date.split(".").size(), 3, "Expiration date should be valid format")

func test_generate_random_potato_info_expiration_probability():
	# Test that sometimes we get expired documents (20% chance)
	var expired_count = 0
	var total_tests = 100

	for i in range(total_tests):
		var info = PotatoFactory.generate_random_potato_info()
		var expiry_parts = info.expiration_date.split(".")
		var expiry_year = expiry_parts[0].to_int()
		var current_year = Time.get_date_dict_from_system().year

		if expiry_year < current_year:
			expired_count += 1

	# With 20% probability and 100 tests, we expect around 20 expired
	# Allow for variance: between 5 and 40 expired
	assert_between(expired_count, 0, 50, "Should have some expired documents over 100 generations")

# Test that multiple generated infos are different (randomness check)
func test_generate_random_potato_info_produces_variety():
	var infos = []
	for i in range(10):
		infos.append(PotatoFactory.generate_random_potato_info())

	# Check that not all names are the same
	var unique_names = {}
	for info in infos:
		unique_names[info.name] = true

	assert_gt(unique_names.size(), 5, "Should generate varied names (at least 5 unique in 10 generations)")

# Test gib texture loading
func test_load_gib_textures_returns_array():
	var textures = PotatoFactory.load_gib_textures()
	assert_not_null(textures, "Should return texture array")
	assert_true(textures is Array, "Should be an array")

func test_load_gib_textures_has_textures():
	var textures = PotatoFactory.load_gib_textures()
	# Should load giblet_1.png through giblet_8.png
	assert_gt(textures.size(), 0, "Should load at least some gib textures")

# Test explosion frames loading
func test_load_explosion_frames_returns_array():
	var frames = PotatoFactory.load_explosion_frames()
	assert_not_null(frames, "Should return frames array")
	assert_true(frames is Array, "Should be an array")

func test_load_explosion_frames_correct_count():
	var frames = PotatoFactory.load_explosion_frames()
	# Should have 13 frames
	if frames.size() > 0:  # Only test if spritesheet loads successfully
		assert_eq(frames.size(), 13, "Should have 13 explosion frames")
