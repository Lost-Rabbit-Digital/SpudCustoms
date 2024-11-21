extends Control
var build_type: String
var initialize_response: Dictionary
var easy_leaderboard = "endless_easy"
var normal_leaderboard = "endless_normal"
var expert_leaderboard = "endless_expert"
var score = 100
var keep_best = true
var leaderboard_handle = 0  # Store the handle globally in your script

func find_leaderboard():
	Steam.findLeaderboard(easy_leaderboard)
	# Handle will be received in _on_leaderboard_find_result

func _ready():


	build_type = Global.build_type
	print("Build type is: " + str(build_type))
	
	if build_type == "Demo Release":
		# Initialize Steam with the Demo AppID
		initialize_response= Steam.steamInit( false, 3356370 )
	
	if build_type == "Full Release":
		# Initialize Steam with the Full Release AppID
		print("Running full release logic")
		initialize_response = Steam.steamInit( true, 3291880 )
		print(initialize_response)
		
	var steamRunning = Steam.isSteamRunning()
	
	# Close out 
	if !steamRunning:
		print("Shit Bro... Steam is not running, I'ma crash out.")
		return
		
	# Fetch example steam player data
	if steamRunning:
		var game_id = Steam.getAppID()
		var is_on_steam_deck: bool = Steam.isSteamRunningOnSteamDeck()
		var is_online: bool = Steam.loggedOn()
		var is_owned: bool = Steam.isSubscribed()
		var steam_id: int = Steam.getSteamID()
		var steam_username: String = Steam.getPersonaName()
		Steam.findLeaderboard("endless_easy")
		print("Game ID is: "  + str(game_id))
		print("Online state is:" + str(is_online))
		print("Owned state is: " + str(is_owned))
		print("Steam username is: " + str(steam_username))
		print("Steam ID is: " + str(steam_id))
		print("Steam is running Bro! That's all you had to say.")
		# Fetch player avatar image in small format for leaderboard display
		Steam.getPlayerAvatar(Steam.AVATAR_SMALL)
		Steam.avatar_loaded.connect(_on_loaded_avatar)
		Steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
		Steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
		Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)
		Steam.uploadLeaderboardScore(score, keep_best, leaderboard_handle)
		Steam.downloadLeaderboardEntries( 1, 10, Steam.LEADERBOARD_DATA_REQUEST_GLOBAL, leaderboard_handle )
		var user_array = [steam_id]
		Steam.downloadLeaderboardEntriesForUsers(user_array, leaderboard_handle)

# Leaderboard testing for each difficulty level
func _on_leaderboard_find_result(handle, found):
	if found:
		leaderboard_handle = handle
		# Now you can use the handle for uploads/downloads
		Steam.uploadLeaderboardScore(score, keep_best, leaderboard_handle)
		Steam.downloadLeaderboardEntries(1, 10, Steam.LEADERBOARD_DATA_REQUEST_GLOBAL, leaderboard_handle)
		
		var user_array = [Steam.getSteamID()]
		Steam.downloadLeaderboardEntriesForUsers(user_array, leaderboard_handle)
	else:
		print("Failed to find leaderboard")

func _on_leaderboard_score_uploaded(success: int, this_handle: int, this_score: Dictionary) -> void:
	if success == 1:
		print("Successfully uploaded scores!")
		# Add additional logic to use other variables passed back
	else:
		print("Failed to upload scores!")
	
func _on_leaderboard_scores_downloaded(message: String, this_leaderboard_handle: int, result: Array) -> void:
	print("Scores downloaded message: %s" % message)

	# Save this for later leaderboard interactions, if you want
	var leaderboard_handle: int = this_leaderboard_handle

	# Add logic to display results
	for this_result in result:
		# Use each entry that is returned
		print(result)	

# Avatar loading logic
func _on_loaded_avatar(user_id: int, avatar_size: int, avatar_buffer: PackedByteArray) -> void:
	print("Avatar for user: %s" % user_id)
	print("Size: %s" % avatar_size)

	# Create the image and texture for loading
	var avatar_image: Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)

	# Optionally resize the image if it is too large
	if avatar_size > 128:
		avatar_image.resize(128, 128, Image.INTERPOLATE_LANCZOS)

	# Apply the image to a texture
	var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)

	# Set the texture to a Sprite, TextureRect, etc.
	$Sprite.set_texture(avatar_texture)
	
	
# Data syncing with Steam Cloud 
	
func _process(delta):
		pass
