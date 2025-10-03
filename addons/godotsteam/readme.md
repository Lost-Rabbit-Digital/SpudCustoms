# GodotSteam for Godot Engine 4.x | Community Edition
An ecosystem of tools for [Godot Engine](https://godotengine.org) and [Valve's Steam](https://store.steampowered.com). For the Windows, Linux, and Mac platforms.

Additional Flavors
---
Pre-Compiles | Plug-ins | Server | Examples
--- | --- | --- | ---
[Godot 2.x](https://codeberg.org/godotsteam/godotsteam/src/branch/godot2) | [GDNative](https://codeberg.org/godotsteam/godotsteam/src/branch/gdnative) | [Server 3.x](https://codeberg.org/godotsteam/godotsteam-server/src/branch/godot3) | [Skillet](https://codeberg.org/godotsteam/skillet)
[Godot 3.x](https://codeberg.org/godotsteam/godotsteam/src/branch/godot3) | [GDExtension](https://codeberg.org/godotsteam/godotsteam/src/branch/gdextension) | [Server 4.x](https://codeberg.org/godotsteam/godotsteam-server/src/branch/godot4) | ---
[Godot 4.x](https://codeberg.org/godotsteam/godotsteam/src/branch/godot4) | --- | [GDNative](https://codeberg.org/godotsteam/godotsteam-server/src/branch/gdnative) | ---
[MultiplayerPeer](https://codeberg.org/godotsteam/multiplayerpeer)| --- | [GDExtension](https://codeberg.org/godotsteam/godotsteam-server/src/branch/gdextension) | ---

Documentation
---
[Documentation is available here](https://godotsteam.com). You can also check out the Search Help section inside Godot Engine.

Feel free to chat with us about GodotSteam or ask for assistance on the [Discord server](https://discord.gg/SJRSq6K).

Donate
---
Pull-requests are the best way to help the project out but you can also donate through [Github Sponsors](https://github.com/sponsors/Gramps) or [LiberaPay](https://liberapay.com/godotsteam/donate)! [You can read more about donor perks here.](https://godotsteam.com/contribute/donations/)  [You can also view all our awesome donors here.](https://godotsteam.com/contribute/donors/)

Current Build
---
You can [download pre-compiled versions of this repo here](https://codeberg.org/godotsteam/godotsteam/releases).

**Version 4.16 Changes**
- Added: missing Friends function `activateGameOverlayRemotePlayTogetherInviteDialog()` and `getNumChatsWithUnreadPriorityMessages()`
- Added: missing User function `getMarketEligibility()` and related call result `market_eligibility_response`
- Added: missing UGC functions `setAllowLegacyUpload()`, `removeAllItemKeyValueTags()`
- Added: missing Networking Sockets function `setConnectionUserData()`
- Added: missing Networking Utils functions `setDebugOutputFunction()`, `getIPv4FakeIPType()`, `getRealIdentityForFakeIP()`, `setGlobalCallbackSteamNetConnectionStatusChanged()`, `setGlobalCallbackSteamNetAuthenticationStatusChanged()`, `setGlobalCallbackSteamRelayNetworkStatusChanged()`, `setGlobalCallbackFakeIPResult()`, `setGlobalCallbackMessagesSessionRequest()`, `setGlobalCallbackMessagesSessionFailed()`, `iterateGenericEditableConfigValues()`
- Added: missing Remote Storage call results `published_file_subscribed`, `published_file_unsubscribed`
- Added: missing Remote Play callback `remote_play_guest_invite`
- Added: Steam ID constants for game servers
- Added: some missing constants
- Added: default values to `getQueryUGCContentDdescriptors()` and `getUserContentDescriptorPreferences()` for **max_entries** as there are only five values currently
- Added: missing `releaseCurrentThreadMemory()` function
- Added: patch file for MinGW compatibility
- Changed: included file ID in returned callback `item_updated`
- Changed: included next cursor in returned callback `ugc_query_completed`
- Changed: `MarketNotAllowedReasonFlags` enums corrected to bitwise
- Changed: added missing result response to `steam_server_disconnected` callback
- Changed: minor swaps from integers to enums where needed
- Changed: corrected STEAM_PARTY_BEACON_LOCATION_DATA to STEAM_PARTY_BEACON_LOCATION_DATA_INVALID
- Changed: some argument or variable names for clarity
- Changed: `advertiseGame()` now has defaults to clear game advertisement is nothing is passed
- Changed: `connected_clan_chat_message` and `connected_friend_chat_message` to no longer send dictionaries
- Changed: `getLeaderboardDisplayType()` now returns the direct enum value instead of a dictionary
- Changed: `getLeaderboardSortMethod()` now returns the direct enum value instead of a dictionary
- Changed: `getMostAchievedAchievementInfo()` and `getNextMostAchievedAchievementInfo()` first key to iterator from rank to be more clear
- Changed: `global_achievement_percentages_ready` now returns the enum / int instead of string for result
- Changed: `global_stats_received` now returns the enum / int instead of string for result
- Changed: `leaderboard_ugc_set` now returns the enum /int instead of string for result
- Changed: `getAppInstallDir()` now just returns the string location of the app
- Changed: `getSyncPlatforms()` now returns the direct enum value instead of a dictionary
- Changed: `enumerate_following_list` callback to better fit the actual Steam callback
- Changed: `request_clan_officer_list` callback now returns bool instead of message for success
- Changed: `retrieveConnectionDetails()` now returns a dictionary instead of the connection details string
- Changed: **base_prices** to **base_price** in `getItemsWithPrices()`
- Fixed: added missing "app_ids" hint to `get_app_dependencies_result` callback
- Fixed: published file ID not being uint64_t in some Remote Storage signals
- Fixed: various types
- Fixed: using direct values instead of constants when the names could not be found
- Fixed: missing store_flag argument for `activateGameOverlayToStore()`
- Fixed: `downloadClanActivity()` now takes multiple clans are intended
- Fixed: constant name from LEADERBOARD_DETAIL_MAX to LEADERBOARD_DETAILS_MAX
- Fixed: `setOverlayNotificationPosition()` not using given argument
- Fixed: set limit to `requestGlobalStats()`, values over 60 defaults to 60 now
- Fixed: some incorrect variable names
- Fixed: `getAchievementProgressLimitsInt()` and `getAchievementProgressLimitsFloat()` using wrong variable name and removing unncessary name key from returned dictionary
- Fixed: incorrect spelling in enum name
- Removed: `getClanChatMessage()` as it can only be used in response to `connected_clan_chat_message` which it is called in anyway
- Removed: `getFriendMessage()` as it can only be used in response to `connected_friend_chat_message` which it is called in anyway
- Removed: `getAvailableVoice()` as it did nothing useful; was already incorporated into related functions
- Removed: **branch_size** key from returned dictionary in **getSupportedGameVersionData()** as it was misleading and useless
- Removed: **sender_user_data** key from returned dictionaries in `receiveMessageOnChannel()`
- Removed: temporarily removed `setDualSenseTriggerEffect()` until it can be overhauled
- Removed: **buffer** from returned dictionary in `getConfigValue()` as it was just the size
- Removed: unnecessary keys in certain Networking Socket functions where messages are received or sent
- Removed: `createHostedDedicatedServerListenSocket()` as it should only be in the GodotSteam Server version

[You can read more change-logs here](https://godotsteam.com/changelog/godot4/).

Compatibility
---
While rare, sometimes Steamworks SDK updates will break compatilibity with older GodotSteam versions. Any compatability breaks are noted below. Newer API files (dll, so, dylib) _should_ still work for older versions.

Steamworks SDK Version | GodotSteam Version
---|---
1.62 or newer | 4.14 or newer
1.61 | 4.12 to 4.13
1.60 | 4.6 to 4.11
1.59 | 4.6 to 4.8
1.58a or older | 4.5.4 or older

Versions of GodotSteam that have compatibility breaks introduced.

GodotSteam Version | Broken Compatibility
---|---
4.8 | Networking identity system removed, replaced with Steam IDs
4.9 | sendMessages returns an Array
4.11 | setLeaderboardDetailsMax removed
4.13 | getItemDefinitionProperty return a dictionary, html_needs_paint key 'bgra' changed to 'rbga'
4.14 | Removed first argument for stat request in steamInit and steamInitEx, steamInit returns intended bool value
4.16 | Variety of small break points, refer to [4.16 changelog for details](https://godotsteam.com/changelog/godot4/)

Known Issues
---
- Steam overlay may not work when running your game from the editor if you are using Forward+ as the renderer unless you use auto-initialization from the Project Settings menu.  Your exported project should work perfectly fine in the Steam client, however.
- When self-compiling, **do not** use MinGW without running the extras/mingw_comp.patch first or you will experience crashing.

Quick How-To
---
For complete instructions on how to build the Godot 4.x version of GodotSteam from scratch, [please refer to our documentation's 'How-To Modules' section.](https://godotsteam.com/howto/modules/) It will have the most up-to-date information.

Alternatively, you can just [download the pre-compiled versions in our Releases section](https://codeberg.org/godotsteam/godotsteam/releases) and skip compiling it yourself!

[To start, check out our tutorial on initializing Steam.](https://godotsteam.com/tutorials/initializing/)  There are additional tutorials with more in the works.  You can also [check out additional Godot and Steam related videos, text, additional tools, plug-ins, etc. here.](https://godotsteam.com/tutorials/external/)

License
---
MIT license
