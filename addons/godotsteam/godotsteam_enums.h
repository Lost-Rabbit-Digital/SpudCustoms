//===========================================================================//
// GodotSteam - godotsteam_enums.h
//===========================================================================//
//
// Copyright (c) 2015-Current | GP Garcia and Contributors
//
// View all contributors at https://godotsteam.com/contribute/contributors/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//===========================================================================//

#ifndef GODOTSTEAM_ENUMS_H
#define GODOTSTEAM_ENUMS_H


enum AccountType {
	// Found in steamclientpublic.h
	ACCOUNT_TYPE_INVALID = k_EAccountTypeInvalid,
	ACCOUNT_TYPE_INDIVIDUAL = k_EAccountTypeIndividual,
	ACCOUNT_TYPE_MULTISEAT = k_EAccountTypeMultiseat,
	ACCOUNT_TYPE_GAME_SERVER = k_EAccountTypeGameServer,
	ACCOUNT_TYPE_ANON_GAME_SERVER = k_EAccountTypeAnonGameServer,
	ACCOUNT_TYPE_PENDING = k_EAccountTypePending,
	ACCOUNT_TYPE_CONTENT_SERVER = k_EAccountTypeContentServer,
	ACCOUNT_TYPE_CLAN = k_EAccountTypeClan,
	ACCOUNT_TYPE_CHAT = k_EAccountTypeChat,
	ACCOUNT_TYPE_CONSOLE_USER = k_EAccountTypeConsoleUser,
	ACCOUNT_TYPE_ANON_USER = k_EAccountTypeAnonUser,
	ACCOUNT_TYPE_MAX = k_EAccountTypeMax
};

enum AuthSessionResponse {
	// Found in steamclientpublic.hg
	AUTH_SESSION_RESPONSE_OK = k_EAuthSessionResponseOK,
	AUTH_SESSION_RESPONSE_USER_NOT_CONNECTED_TO_STEAM = k_EAuthSessionResponseUserNotConnectedToSteam,
	AUTH_SESSION_RESPONSE_NO_LICENSE_OR_EXPIRED = k_EAuthSessionResponseNoLicenseOrExpired,
	AUTH_SESSION_RESPONSE_VAC_BANNED = k_EAuthSessionResponseVACBanned,
	AUTH_SESSION_RESPONSE_LOGGED_IN_ELSEWHERE = k_EAuthSessionResponseLoggedInElseWhere,
	AUTH_SESSION_RESPONSE_VAC_CHECK_TIMED_OUT = k_EAuthSessionResponseVACCheckTimedOut,
	AUTH_SESSION_RESPONSE_AUTH_TICKET_CANCELED = k_EAuthSessionResponseAuthTicketCanceled,
	AUTH_SESSION_RESPONSE_AUTH_TICKET_INVALID_ALREADY_USED = k_EAuthSessionResponseAuthTicketInvalidAlreadyUsed,
	AUTH_SESSION_RESPONSE_AUTH_TICKET_INVALID = k_EAuthSessionResponseAuthTicketInvalid,
	AUTH_SESSION_RESPONSE_PUBLISHER_ISSUED_BAN = k_EAuthSessionResponsePublisherIssuedBan,
	AUTH_SESSION_RESPONSE_AUTH_TICKET_NETWORK_IDENTITY_FAILURE = k_EAuthSessionResponseAuthTicketNetworkIdentityFailure
};

enum BeginAuthSessionResult {
	// Found in steamclientpublic.h
	BEGIN_AUTH_SESSION_RESULT_OK = k_EBeginAuthSessionResultOK,
	BEGIN_AUTH_SESSION_RESULT_INVALID_TICKET = k_EBeginAuthSessionResultInvalidTicket,
	BEGIN_AUTH_SESSION_RESULT_DUPLICATE_REQUEST = k_EBeginAuthSessionResultDuplicateRequest,
	BEGIN_AUTH_SESSION_RESULT_INVALID_VERSION = k_EBeginAuthSessionResultInvalidVersion,
	BEGIN_AUTH_SESSION_RESULT_GAME_MISMATCH = k_EBeginAuthSessionResultGameMismatch,
	BEGIN_AUTH_SESSION_RESULT_EXPIRED_TICKET = k_EBeginAuthSessionResultExpiredTicket
};

enum BetaBranchFlags {
	// Found in steamclientpublic.h
	BETA_BRANCH_NONE = k_EBetaBranch_None,
	BETA_BRANCH_DEFAULT = k_EBetaBranch_Default,
	BETA_BRANCH_AVAILABLE = k_EBetaBranch_Available,
	BETA_BRANCH_PRIVATE = k_EBetaBranch_Private,
	BETA_BRANCH_SELECTED = k_EBetaBranch_Selected,
	BETA_BRANCH_INSTALLED = k_EBetaBranch_Installed
};

enum BroadcastUploadResult {
	// Found in steamclientpublic.h
	BROADCAST_UPLOAD_RESULT_NONE = k_EBroadcastUploadResultNone,
	BROADCAST_UPLOAD_RESULT_OK = k_EBroadcastUploadResultOK,
	BROADCAST_UPLOAD_RESULT_INIT_FAILED = k_EBroadcastUploadResultInitFailed,
	BROADCAST_UPLOAD_RESULT_FRAME_FAILED = k_EBroadcastUploadResultFrameFailed,
	BROADCAST_UPLOAD_RESULT_TIME_OUT = k_EBroadcastUploadResultTimeout,
	BROADCAST_UPLOAD_RESULT_BANDWIDTH_EXCEEDED = k_EBroadcastUploadResultBandwidthExceeded,
	BROADCAST_UPLOAD_RESULT_LOW_FPS = k_EBroadcastUploadResultLowFPS,
	BROADCAST_UPLOAD_RESULT_MISSING_KEYFRAMES = k_EBroadcastUploadResultMissingKeyFrames,
	BROADCAST_UPLOAD_RESULT_NO_CONNECTION = k_EBroadcastUploadResultNoConnection,
	BROADCAST_UPLOAD_RESULT_RELAY_FAILED = k_EBroadcastUploadResultRelayFailed,
	BROADCAST_UPLOAD_RESULT_SETTINGS_CHANGED = k_EBroadcastUploadResultSettingsChanged,
	BROADCAST_UPLOAD_RESULT_MISSING_AUDIO = k_EBroadcastUploadResultMissingAudio,
	BROADCAST_UPLOAD_RESULT_TOO_FAR_BEHIND = k_EBroadcastUploadResultTooFarBehind,
	BROADCAST_UPLOAD_RESULT_TRANSCODE_BEHIND = k_EBroadcastUploadResultTranscodeBehind,
	BROADCAST_UPLOAD_RESULT_NOT_ALLOWED_TO_PLAY = k_EBroadcastUploadResultNotAllowedToPlay,
	BROADCAST_UPLOAD_RESULT_BUSY = k_EBroadcastUploadResultBusy,
	BROADCAST_UPLOAD_RESULT_BANNED = k_EBroadcastUploadResultBanned,
	BROADCAST_UPLOAD_RESULT_ALREADY_ACTIVE = k_EBroadcastUploadResultAlreadyActive,
	BROADCAST_UPLOAD_RESULT_FORCED_OFF = k_EBroadcastUploadResultForcedOff,
	BROADCAST_UPLOAD_RESULT_AUDIO_BEHIND = k_EBroadcastUploadResultAudioBehind,
	BROADCAST_UPLOAD_RESULT_SHUTDOWN = k_EBroadcastUploadResultShutdown,
	BROADCAST_UPLOAD_RESULT_DISCONNECT = k_EBroadcastUploadResultDisconnect,
	BROADCAST_UPLOAD_RESULT_VIDEO_INIT_FAILED = k_EBroadcastUploadResultVideoInitFailed,
	BROADCAST_UPLOAD_RESULT_AUDIO_INIT_FAILED = k_EBroadcastUploadResultAudioInitFailed
};

enum ChatEntryType {
	// Found in steamclientpublic.h
	CHAT_ENTRY_TYPE_INVALID = k_EChatEntryTypeInvalid,
	CHAT_ENTRY_TYPE_CHAT_MSG = k_EChatEntryTypeChatMsg,
	CHAT_ENTRY_TYPE_TYPING = k_EChatEntryTypeTyping,
	CHAT_ENTRY_TYPE_INVITE_GAME = k_EChatEntryTypeInviteGame,
	CHAT_ENTRY_TYPE_EMOTE = k_EChatEntryTypeEmote,
	CHAT_ENTRY_TYPE_LEFT_CONVERSATION = k_EChatEntryTypeLeftConversation,
	CHAT_ENTRY_TYPE_ENTERED = k_EChatEntryTypeEntered,
	CHAT_ENTRY_TYPE_WAS_KICKED = k_EChatEntryTypeWasKicked,
	CHAT_ENTRY_TYPE_WAS_BANNED = k_EChatEntryTypeWasBanned,
	CHAT_ENTRY_TYPE_DISCONNECTED = k_EChatEntryTypeDisconnected,
	CHAT_ENTRY_TYPE_HISTORICAL_CHAT = k_EChatEntryTypeHistoricalChat,
	CHAT_ENTRY_TYPE_LINK_BLOCKED = k_EChatEntryTypeLinkBlocked
};

enum ChatRoomEnterResponse {
	// Found in steamclientpublic.h
	CHAT_ROOM_ENTER_RESPONSE_SUCCESS = k_EChatRoomEnterResponseSuccess,
	CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST = k_EChatRoomEnterResponseDoesntExist,
	CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED = k_EChatRoomEnterResponseNotAllowed,
	CHAT_ROOM_ENTER_RESPONSE_FULL = k_EChatRoomEnterResponseFull,
	CHAT_ROOM_ENTER_RESPONSE_ERROR = k_EChatRoomEnterResponseError,
	CHAT_ROOM_ENTER_RESPONSE_BANNED = k_EChatRoomEnterResponseBanned,
	CHAT_ROOM_ENTER_RESPONSE_LIMITED = k_EChatRoomEnterResponseLimited,
	CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED = k_EChatRoomEnterResponseClanDisabled,
	CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN = k_EChatRoomEnterResponseCommunityBan,
	CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU = k_EChatRoomEnterResponseMemberBlockedYou,
	CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER = k_EChatRoomEnterResponseYouBlockedMember,
	CHAT_ROOM_ENTER_RESPONSE_RATE_LIMIT_EXCEEDED = k_EChatRoomEnterResponseRatelimitExceeded
};

enum ChatSteamIDInstanceFlags {
	// Found in steamclientpublic.h
	CHAT_ACCOUNT_INSTANCE_MASK = k_EChatAccountInstanceMask,
	CHAT_INSTANCE_FLAG_CLAN = k_EChatInstanceFlagClan,
	CHAT_INSTANCE_FLAG_LOBBY = k_EChatInstanceFlagLobby,
	CHAT_INSTANCE_FLAG_MMS_LOBBY = k_EChatInstanceFlagMMSLobby
};

enum DenyReason {
	// Found in steamclientpublic.h
	DENY_INVALID = k_EDenyInvalid,
	DENY_INVALID_VERSION = k_EDenyInvalidVersion,
	DENY_GENERIC = k_EDenyGeneric,
	DENY_NOT_LOGGED_ON = k_EDenyNotLoggedOn,
	DENY_NO_LICENSE = k_EDenyNoLicense,
	DENY_CHEATER = k_EDenyCheater,
	DENY_LOGGED_IN_ELSEWHERE = k_EDenyLoggedInElseWhere,
	DENY_UNKNOWN_TEXT = k_EDenyUnknownText,
	DENY_INCOMPATIBLE_ANTI_CHEAT = k_EDenyIncompatibleAnticheat,
	DENY_MEMORY_CORRUPTION = k_EDenyMemoryCorruption,
	DENY_INCOMPATIBLE_SOFTWARE = k_EDenyIncompatibleSoftware,
	DENY_STEAM_CONNECTION_LOST = k_EDenySteamConnectionLost,
	DENY_STEAM_CONNECTION_ERROR = k_EDenySteamConnectionError,
	DENY_STEAM_RESPONSE_TIMED_OUT = k_EDenySteamResponseTimedOut,
	DENY_STEAM_VALIDATION_STALLED = k_EDenySteamValidationStalled,
	DENY_STEAM_OWNER_LEFT_GUEST_USER = k_EDenySteamOwnerLeftGuestUser
};

enum GameIDType {
	GAME_TYPE_APP = CGameID::k_EGameIDTypeApp,
	GAME_TYPE_GAME_MOD = CGameID::k_EGameIDTypeGameMod,
	GAME_TYPE_SHORTCUT = CGameID::k_EGameIDTypeShortcut,
	GAME_TYPE_P2P = CGameID::k_EGameIDTypeP2P
};

enum IPType {
	IP_TYPE_IPV4 = k_ESteamIPTypeIPv4,
	IP_TYPE_IPV6 = k_ESteamIPTypeIPv6
};

enum IPv6ConnectivityProtocol {
	// Found in steamclientpublic.h
	IPV6_CONNECTIVITY_PROTOCOL_INVALID = k_ESteamIPv6ConnectivityProtocol_Invalid,
	IPV6_CONNECTIVITY_PROTOCOL_HTTP = k_ESteamIPv6ConnectivityProtocol_HTTP,
	IPV6_CONNECTIVITY_PROTOCOL_UDP = k_ESteamIPv6ConnectivityProtocol_UDP
};

enum IPv6ConnectivityState {
	// Found in steamclientpublic.h
	IPV6_CONNECTIVITY_STATE_UNKNOWN = k_ESteamIPv6ConnectivityState_Unknown,
	IPV6_CONNECTIVITY_STATE_GOOD = k_ESteamIPv6ConnectivityState_Good,
	IPV6_CONNECTIVITY_STATE_BAD = k_ESteamIPv6ConnectivityState_Bad
};

enum MarketNotAllowedReasonFlags {
	// Found in steamclientpublic.h
	MARKET_NOT_ALLOWED_REASON_NONE = k_EMarketNotAllowedReason_None,
	MARKET_NOT_ALLOWED_REASON_TEMPORARY_FAILURE = k_EMarketNotAllowedReason_TemporaryFailure,
	MARKET_NOT_ALLOWED_REASON_ACCOUNT_DISABLED = k_EMarketNotAllowedReason_AccountDisabled,
	MARKET_NOT_ALLOWED_REASON_ACCOUNT_LOCKED_DOWN = k_EMarketNotAllowedReason_AccountLockedDown,
	MARKET_NOT_ALLOWED_REASON_ACCOUNT_LIMITED = k_EMarketNotAllowedReason_AccountLimited,
	MARKET_NOT_ALLOWED_REASON_TRADE_BANNED = k_EMarketNotAllowedReason_TradeBanned,
	MARKET_NOT_ALLOWED_REASON_ACCOUNT_NOT_TRUSTED = k_EMarketNotAllowedReason_AccountNotTrusted,
	MARKET_NOT_ALLOWED_REASON_STEAM_GUARD_NOT_ENABLED = k_EMarketNotAllowedReason_SteamGuardNotEnabled,
	MARKET_NOT_ALLOWED_REASON_STEAM_GUARD_ONLY_RECENTLY_ENABLED = k_EMarketNotAllowedReason_SteamGuardOnlyRecentlyEnabled,
	MARKET_NOT_ALLOWED_REASON_RECENT_PASSWORD_RESET = k_EMarketNotAllowedReason_RecentPasswordReset,
	MARKET_NOT_ALLOWED_REASON_NEW_PAYMENT_METHOD = k_EMarketNotAllowedReason_NewPaymentMethod,
	MARKET_NOT_ALLOWED_REASON_INVALID_COOKIE = k_EMarketNotAllowedReason_InvalidCookie,
	MARKET_NOT_ALLOWED_REASON_USING_NEW_DEVICE = k_EMarketNotAllowedReason_UsingNewDevice,
	MARKET_NOT_ALLOWED_REASON_RECENT_SELF_REFUND = k_EMarketNotAllowedReason_RecentSelfRefund,
	MARKET_NOT_ALLOWED_REASON_NEW_PAYMENT_METHOD_CANNOT_BE_VERIFIED = k_EMarketNotAllowedReason_NewPaymentMethodCannotBeVerified,
	MARKET_NOT_ALLOWED_REASON_NO_RECENT_PURCHASES = k_EMarketNotAllowedReason_NoRecentPurchases,
	MARKET_NOT_ALLOWED_REASON_ACCEPTED_WALLET_GIFT = k_EMarketNotAllowedReason_AcceptedWalletGift
};

enum NotificationPosition {
	// Found in steamclientpublic.h
	POSITION_INVALID = k_EPositionInvalid,
	POSITION_TOP_LEFT = k_EPositionTopLeft,
	POSITION_TOP_RIGHT = k_EPositionTopRight,
	POSITION_BOTTOM_LEFT = k_EPositionBottomLeft,
	POSITION_BOTTOM_RIGHT = k_EPositionBottomRight
};

enum Result {
	// Found in steamclientpublic.h
	RESULT_NONE = k_EResultNone,
	RESULT_OK = k_EResultOK,
	RESULT_FAIL = k_EResultFail,
	RESULT_NO_CONNECTION = k_EResultNoConnection,
	RESULT_INVALID_PASSWORD = k_EResultInvalidPassword,
	RESULT_LOGGED_IN_ELSEWHERE = k_EResultLoggedInElsewhere,
	RESULT_INVALID_PROTOCOL_VER = k_EResultInvalidProtocolVer,
	RESULT_INVALID_PARAM = k_EResultInvalidParam,
	RESULT_FILE_NOT_FOUND = k_EResultFileNotFound,
	RESULT_BUSY = k_EResultBusy,
	RESULT_INVALID_STATE = k_EResultInvalidState,
	RESULT_INVALID_NAME = k_EResultInvalidName,
	RESULT_INVALID_EMAIL = k_EResultInvalidEmail,
	RESULT_DUPLICATE_NAME = k_EResultDuplicateName,
	RESULT_ACCESS_DENIED = k_EResultAccessDenied,
	RESULT_TIMEOUT = k_EResultTimeout,
	RESULT_BANNED = k_EResultBanned,
	RESULT_ACCOUNT_NOT_FOUND = k_EResultAccountNotFound,
	RESULT_INVALID_STEAMID = k_EResultInvalidSteamID,
	RESULT_SERVICE_UNAVAILABLE = k_EResultServiceUnavailable,
	RESULT_NOT_LOGGED_ON = k_EResultNotLoggedOn,
	RESULT_PENDING = k_EResultPending,
	RESULT_ENCRYPTION_FAILURE = k_EResultEncryptionFailure,
	RESULT_INSUFFICIENT_PRIVILEGE = k_EResultInsufficientPrivilege,
	RESULT_LIMIT_EXCEEDED = k_EResultLimitExceeded,
	RESULT_REVOKED = k_EResultRevoked,
	RESULT_EXPIRED = k_EResultExpired,
	RESULT_ALREADY_REDEEMED = k_EResultAlreadyRedeemed,
	RESULT_DUPLICATE_REQUEST = k_EResultDuplicateRequest,
	RESULT_ALREADY_OWNED = k_EResultAlreadyOwned,
	RESULT_IP_NOT_FOUND = k_EResultIPNotFound,
	RESULT_PERSIST_FAILED = k_EResultPersistFailed,
	RESULT_LOCKING_FAILED = k_EResultLockingFailed,
	RESULT_LOG_ON_SESSION_REPLACED = k_EResultLogonSessionReplaced,
	RESULT_CONNECT_FAILED = k_EResultConnectFailed,
	RESULT_HANDSHAKE_FAILED = k_EResultHandshakeFailed,
	RESULT_IO_FAILURE = k_EResultIOFailure,
	RESULT_REMOTE_DISCONNECT = k_EResultRemoteDisconnect,
	RESULT_SHOPPING_CART_NOT_FOUND = k_EResultShoppingCartNotFound,
	RESULT_BLOCKED = k_EResultBlocked,
	RESULT_IGNORED = k_EResultIgnored,
	RESULT_NO_MATCH = k_EResultNoMatch,
	RESULT_ACCOUNT_DISABLED = k_EResultAccountDisabled,
	RESULT_SERVICE_READ_ONLY = k_EResultServiceReadOnly,
	RESULT_ACCOUNT_NOT_FEATURED = k_EResultAccountNotFeatured,
	RESULT_ADMINISTRATOR_OK = k_EResultAdministratorOK,
	RESULT_CONTENT_VERSION = k_EResultContentVersion,
	RESULT_TRY_ANOTHER_CM = k_EResultTryAnotherCM,
	RESULT_PASSWORD_REQUIRED_TO_KICK_SESSION = k_EResultPasswordRequiredToKickSession,
	RESULT_ALREADY_LOGGED_IN_ELSEWHERE = k_EResultAlreadyLoggedInElsewhere,
	RESULT_SUSPENDED = k_EResultSuspended,
	RESULT_CANCELLED = k_EResultCancelled,
	RESULT_DATA_CORRUPTION = k_EResultDataCorruption,
	RESULT_DISK_FULL = k_EResultDiskFull,
	RESULT_REMOTE_CALL_FAILED = k_EResultRemoteCallFailed,
	RESULT_PASSWORD_UNSET = k_EResultPasswordUnset,
	RESULT_EXTERNAL_ACCOUNT_UNLINKED = k_EResultExternalAccountUnlinked,
	RESULT_PSN_TICKET_INVALID = k_EResultPSNTicketInvalid,
	RESULT_EXTERNAL_ACCOUNT_ALREADY_LINKED = k_EResultExternalAccountAlreadyLinked,
	RESULT_REMOTE_FILE_CONFLICT = k_EResultRemoteFileConflict,
	RESULT_ILLEGAL_PASSWORD = k_EResultIllegalPassword,
	RESULT_SAME_AS_PREVIOUS_VALUE = k_EResultSameAsPreviousValue,
	RESULT_ACCOUNT_LOG_ON_DENIED = k_EResultAccountLogonDenied,
	RESULT_CANNOT_USE_OLD_PASSWORD = k_EResultCannotUseOldPassword,
	RESULT_INVALID_LOG_IN_AUTH_CODE = k_EResultInvalidLoginAuthCode,
	RESULT_ACCOUNT_LOG_ON_DENIED_NO_MAIL = k_EResultAccountLogonDeniedNoMail,
	RESULT_HARDWARE_NOT_CAPABLE_OF_IPT = k_EResultHardwareNotCapableOfIPT,
	RESULT_IPT_INIT_ERROR = k_EResultIPTInitError,
	RESULT_PARENTAL_CONTROL_RESTRICTED = k_EResultParentalControlRestricted,
	RESULT_FACEBOOK_QUERY_ERROR = k_EResultFacebookQueryError,
	RESULT_EXPIRED_LOGIN_AUTH_CODE = k_EResultExpiredLoginAuthCode,
	RESULT_IP_LOGIN_RESTRICTION_FAILED = k_EResultIPLoginRestrictionFailed,
	RESULT_ACCOUNT_LOCKED_DOWN = k_EResultAccountLockedDown,
	RESULT_ACCOUNT_LOG_ON_DENIED_VERIFIED_EMAIL_REQUIRED = k_EResultAccountLogonDeniedVerifiedEmailRequired,
	RESULT_NO_MATCHING_URL = k_EResultNoMatchingURL,
	RESULT_BAD_RESPONSE = k_EResultBadResponse,
	RESULT_REQUIRE_PASSWORD_REENTRY = k_EResultRequirePasswordReEntry,
	RESULT_VALUE_OUT_OF_RANGE = k_EResultValueOutOfRange,
	RESULT_UNEXPECTED_ERROR = k_EResultUnexpectedError,
	RESULT_DISABLED = k_EResultDisabled,
	RESULT_INVALID_CEG_SUBMISSION = k_EResultInvalidCEGSubmission,
	RESULT_RESTRICTED_DEVICE = k_EResultRestrictedDevice,
	RESULT_REGION_LOCKED = k_EResultRegionLocked,
	RESULT_RATE_LIMIT_EXCEEDED = k_EResultRateLimitExceeded,
	RESULT_ACCOUNT_LOGIN_DENIED_NEED_TWO_FACTOR = k_EResultAccountLoginDeniedNeedTwoFactor,
	RESULT_ITEM_DELETED = k_EResultItemDeleted,
	RESULT_ACCOUNT_LOGIN_DENIED_THROTTLE = k_EResultAccountLoginDeniedThrottle,
	RESULT_TWO_FACTOR_CODE_MISMATCH = k_EResultTwoFactorCodeMismatch,
	RESULT_TWO_FACTOR_ACTIVATION_CODE_MISMATCH = k_EResultTwoFactorActivationCodeMismatch,
	RESULT_ACCOUNT_ASSOCIATED_TO_MULTIPLE_PARTNERS = k_EResultAccountAssociatedToMultiplePartners,
	RESULT_NOT_MODIFIED = k_EResultNotModified,
	RESULT_NO_MOBILE_DEVICE = k_EResultNoMobileDevice,
	RESULT_TIME_NOT_SYNCED = k_EResultTimeNotSynced,
	RESULT_SMS_CODE_FAILED = k_EResultSmsCodeFailed,
	RESULT_ACCOUNT_LIMIT_EXCEEDED = k_EResultAccountLimitExceeded,
	RESULT_ACCOUNT_ACTIVITY_LIMIT_EXCEEDED = k_EResultAccountActivityLimitExceeded,
	RESULT_PHONE_ACTIVITY_LIMIT_EXCEEDED = k_EResultPhoneActivityLimitExceeded,
	RESULT_REFUND_TO_WALLET = k_EResultRefundToWallet,
	RESULT_EMAIL_SEND_FAILURE = k_EResultEmailSendFailure,
	RESULT_NOT_SETTLED = k_EResultNotSettled,
	RESULT_NEED_CAPTCHA = k_EResultNeedCaptcha,
	RESULT_GSLT_DENIED = k_EResultGSLTDenied,
	RESULT_GS_OWNER_DENIED = k_EResultGSOwnerDenied,
	RESULT_INVALID_ITEM_TYPE = k_EResultInvalidItemType,
	RESULT_IP_BANNED = k_EResultIPBanned,
	RESULT_GSLT_EXPIRED = k_EResultGSLTExpired,
	RESULT_INSUFFICIENT_FUNDS = k_EResultInsufficientFunds,
	RESULT_TOO_MANY_PENDING = k_EResultTooManyPending,
	RESULT_NO_SITE_LICENSES_FOUND = k_EResultNoSiteLicensesFound,
	RESULT_WG_NETWORK_SEND_EXCEEDED = k_EResultWGNetworkSendExceeded,
	RESULT_ACCOUNT_NOT_FRIENDS = k_EResultAccountNotFriends,
	RESULT_LIMITED_USER_ACCOUNT = k_EResultLimitedUserAccount,
	RESULT_CANT_REMOVE_ITEM = k_EResultCantRemoveItem,
	RESULT_ACCOUNT_DELETED = k_EResultAccountDeleted,
	RESULT_EXISTING_USER_CANCELLED_LICENSE = k_EResultExistingUserCancelledLicense,
	RESULT_COMMUNITY_COOLDOWN = k_EResultCommunityCooldown,
	RESULT_NO_LAUNCHER_SPECIFIED = k_EResultNoLauncherSpecified,
	RESULT_MUST_AGREE_TO_SSA = k_EResultMustAgreeToSSA,
	RESULT_LAUNCHER_MIGRATED = k_EResultLauncherMigrated,
	RESULT_STEAM_REALM_MISMATCH = k_EResultSteamRealmMismatch,
	RESULT_INVALID_SIGNATURE = k_EResultInvalidSignature,
	RESULT_PARSE_FAILURE = k_EResultParseFailure,
	RESULT_NO_VERIFIED_PHONE = k_EResultNoVerifiedPhone,
	RESULT_INSUFFICIENT_BATTERY = k_EResultInsufficientBattery,
	RESULT_CHARGER_REQUIRED = k_EResultChargerRequired,
	RESULT_CACHED_CREDENTIAL_INVALID = k_EResultCachedCredentialInvalid,
	RESULT_PHONE_NUMBER_IS_VOIP = K_EResultPhoneNumberIsVOIP,
	RESULT_NOT_SUPPORTED = k_EResultNotSupported,
	RESULT_FAMILY_SIZE_LIMIT_EXCEEDED = k_EResultFamilySizeLimitExceeded,
	RESULT_OFFLINE_APP_CACHE_INVALID = k_EResultOfflineAppCacheInvalid

};

enum SteamAPIInitResult {
	// Found in steam_api.h
	STEAM_API_INIT_RESULT_OK = k_ESteamAPIInitResult_OK,
	STEAM_API_INIT_RESULT_FAILED_GENERIC = k_ESteamAPIInitResult_FailedGeneric,
	STEAM_API_INIT_RESULT_NO_STEAM_CLIENT = k_ESteamAPIInitResult_NoSteamClient,
	STEAM_API_INIT_RESULT_VERSION_MISMATCH = k_ESteamAPIInitResult_VersionMismatch
};

enum Universe {
	// Found in steamuniverse.h
	UNIVERSE_INVALID = k_EUniverseInvalid,
	UNIVERSE_PUBLIC = k_EUniversePublic,
	UNIVERSE_BETA = k_EUniverseBeta,
	UNIVERSE_INTERNAL = k_EUniverseInternal,
	UNIVERSE_DEV = k_EUniverseDev,
	UNIVERSE_MAX = k_EUniverseMax
};

enum UserHasLicenseForAppResult {
	// Found in steamclientpublic.h
	USER_HAS_LICENSE_RESULT_HAS_LICENSE = k_EUserHasLicenseResultHasLicense,
	USER_HAS_LICENSE_RESULT_DOES_NOT_HAVE_LICENSE = k_EUserHasLicenseResultDoesNotHaveLicense,
	USER_HAS_LICENSE_RESULT_NO_AUTH = k_EUserHasLicenseResultNoAuth
};

enum VoiceResult {
	// Found in steamclientpublic.h
	VOICE_RESULT_OK = k_EVoiceResultOK,
	VOICE_RESULT_NOT_INITIALIZED = k_EVoiceResultNotInitialized,
	VOICE_RESULT_NOT_RECORDING = k_EVoiceResultNotRecording,
	VOICE_RESULT_NO_DATE = k_EVoiceResultNoData,
	VOICE_RESULT_BUFFER_TOO_SMALL = k_EVoiceResultBufferTooSmall,
	VOICE_RESULT_DATA_CORRUPTED = k_EVoiceResultDataCorrupted,
	VOICE_RESULT_RESTRICTED = k_EVoiceResultRestricted,
	VOICE_RESULT_UNSUPPORTED_CODEC = k_EVoiceResultUnsupportedCodec,
	VOICE_RESULT_RECEIVER_OUT_OF_DATE = k_EVoiceResultReceiverOutOfDate,
	VOICE_RESULT_RECEIVER_DID_NOT_ANSWER = k_EVoiceResultReceiverDidNotAnswer
};

// Friends enums
enum AvatarSizes {
	AVATAR_SMALL = 1,
	AVATAR_MEDIUM = 2,
	AVATAR_LARGE = 3
};

enum CommunityProfileItemProperty {
	PROFILE_ITEM_PROPERTY_IMAGE_SMALL = k_ECommunityProfileItemProperty_ImageSmall,
	PROFILE_ITEM_PROPERTY_IMAGE_LARGE = k_ECommunityProfileItemProperty_ImageLarge,
	PROFILE_ITEM_PROPERTY_INTERNAL_NAME = k_ECommunityProfileItemProperty_InternalName,
	PROFILE_ITEM_PROPERTY_TITLE = k_ECommunityProfileItemProperty_Title,
	PROFILE_ITEM_PROPERTY_DESCRIPTION = k_ECommunityProfileItemProperty_Description,
	PROFILE_ITEM_PROPERTY_APP_ID = k_ECommunityProfileItemProperty_AppID,
	PROFILE_ITEM_PROPERTY_TYPE_ID = k_ECommunityProfileItemProperty_TypeID,
	PROFILE_ITEM_PROPERTY_CLASS = k_ECommunityProfileItemProperty_Class,
	PROFILE_ITEM_PROPERTY_MOVIE_WEBM = k_ECommunityProfileItemProperty_MovieWebM,
	PROFILE_ITEM_PROPERTY_MOVIE_MP4 = k_ECommunityProfileItemProperty_MovieMP4,
	PROFILE_ITEM_PROPERTY_MOVIE_WEBM_SMALL = k_ECommunityProfileItemProperty_MovieWebMSmall,
	PROFILE_ITEM_PROPERTY_MOVIE_MP4_SMALL = k_ECommunityProfileItemProperty_MovieMP4Small
};

enum CommunityProfileItemType {
	PROFILE_ITEM_TYPE_ANIMATED_AVATAR = k_ECommunityProfileItemType_AnimatedAvatar,
	PROFILE_ITEM_TYPE_AVATAR_FRAME = k_ECommunityProfileItemType_AvatarFrame,
	PROFILE_ITEM_TYPE_PROFILE_MODIFIER = k_ECommunityProfileItemType_ProfileModifier,
	PROFILE_ITEM_TYPE_PROFILE_BACKGROUND = k_ECommunityProfileItemType_ProfileBackground,
	PROFILE_ITEM_TYPE_MINI_PROFILE_BACKGROUND = k_ECommunityProfileItemType_MiniProfileBackground
};

enum FriendFlags {
	FRIEND_FLAG_NONE = k_EFriendFlagNone,
	FRIEND_FLAG_BLOCKED = k_EFriendFlagBlocked,
	FRIEND_FLAG_FRIENDSHIP_REQUESTED = k_EFriendFlagFriendshipRequested,
	FRIEND_FLAG_IMMEDIATE = k_EFriendFlagImmediate,
	FRIEND_FLAG_CLAN_MEMBER = k_EFriendFlagClanMember,
	FRIEND_FLAG_ON_GAME_SERVER = k_EFriendFlagOnGameServer,
	//			FRIEND_FLAG_HAS_PLAYED_WITH = k_EFriendFlagHasPlayedWith,
	//			FRIEND_FLAG_FRIEND_OF_FRIEND = k_EFriendFlagFriendOfFriend,
	FRIEND_FLAG_REQUESTING_FRIENDSHIP = k_EFriendFlagRequestingFriendship,
	FRIEND_FLAG_REQUESTING_INFO = k_EFriendFlagRequestingInfo,
	FRIEND_FLAG_IGNORED = k_EFriendFlagIgnored,
	FRIEND_FLAG_IGNORED_FRIEND = k_EFriendFlagIgnoredFriend,
	//			FRIEND_FLAG_SUGGESTED = k_EFriendFlagSuggested,
	FRIEND_FLAG_CHAT_MEMBER = k_EFriendFlagChatMember,
	FRIEND_FLAG_ALL = k_EFriendFlagAll
};

enum FriendRelationship {
	FRIEND_RELATION_NONE = k_EFriendRelationshipNone,
	FRIEND_RELATION_BLOCKED = k_EFriendRelationshipBlocked,
	FRIEND_RELATION_REQUEST_RECIPIENT = k_EFriendRelationshipRequestRecipient,
	FRIEND_RELATION_FRIEND = k_EFriendRelationshipFriend,
	FRIEND_RELATION_REQUEST_INITIATOR = k_EFriendRelationshipRequestInitiator,
	FRIEND_RELATION_IGNORED = k_EFriendRelationshipIgnored,
	FRIEND_RELATION_IGNORED_FRIEND = k_EFriendRelationshipIgnoredFriend,
	FRIEND_RELATION_SUGGESTED = k_EFriendRelationshipSuggested_DEPRECATED,
	FRIEND_RELATION_MAX = k_EFriendRelationshipMax
};

enum OverlayToStoreFlag {
	OVERLAY_TO_STORE_FLAG_NONE = k_EOverlayToStoreFlag_None,
	OVERLAY_TO_STORE_FLAG_ADD_TO_CART = k_EOverlayToStoreFlag_AddToCart,
	OVERLAY_TO_STORE_FLAG_AND_TO_CART_AND_SHOW = k_EOverlayToStoreFlag_AddToCartAndShow
};

enum OverlayToWebPageMode {
	OVERLAY_TO_WEB_PAGE_MODE_DEFAULT = k_EActivateGameOverlayToWebPageMode_Default,
	OVERLAY_TO_WEB_PAGE_MODE_MODAL = k_EActivateGameOverlayToWebPageMode_Modal
};

enum PersonaChange {
	PERSONA_CHANGE_NAME = k_EPersonaChangeName,
	PERSONA_CHANGE_STATUS = k_EPersonaChangeStatus,
	PERSONA_CHANGE_COME_ONLINE = k_EPersonaChangeComeOnline,
	PERSONA_CHANGE_GONE_OFFLINE = k_EPersonaChangeGoneOffline,
	PERSONA_CHANGE_GAME_PLAYED = k_EPersonaChangeGamePlayed,
	PERSONA_CHANGE_GAME_SERVER = k_EPersonaChangeGameServer,
	PERSONA_CHANGE_AVATAR = k_EPersonaChangeAvatar,
	PERSONA_CHANGE_JOINED_SOURCE = k_EPersonaChangeJoinedSource,
	PERSONA_CHANGE_LEFT_SOURCE = k_EPersonaChangeLeftSource,
	PERSONA_CHANGE_RELATIONSHIP_CHANGED = k_EPersonaChangeRelationshipChanged,
	PERSONA_CHANGE_NAME_FIRST_SET = k_EPersonaChangeNameFirstSet,
	PERSONA_CHANGE_FACEBOOK_INFO = k_EPersonaChangeBroadcast,
	PERSONA_CHANGE_NICKNAME = k_EPersonaChangeNickname,
	PERSONA_CHANGE_STEAM_LEVEL = k_EPersonaChangeSteamLevel,
	PERSONA_CHANGE_RICH_PRESENCE = k_EPersonaChangeRichPresence
};

enum PersonaState {
	PERSONA_STATE_OFFLINE = k_EPersonaStateOffline,
	PERSONA_STATE_ONLINE = k_EPersonaStateOnline,
	PERSONA_STATE_BUSY = k_EPersonaStateBusy,
	PERSONA_STATE_AWAY = k_EPersonaStateAway,
	PERSONA_STATE_SNOOZE = k_EPersonaStateSnooze,
	PERSONA_STATE_LOOKING_TO_TRADE = k_EPersonaStateLookingToTrade,
	PERSONA_STATE_LOOKING_TO_PLAY = k_EPersonaStateLookingToPlay,
	PERSONA_STATE_INVISIBLE = k_EPersonaStateInvisible,
	PERSONA_STATE_MAX = k_EPersonaStateMax
};

// Game Search enums
enum GameSearchErrorCode {
	// Found in steamclientpublic.h
	GAME_SEARCH_ERROR_CODE_OK = k_EGameSearchErrorCode_OK,
	GAME_SEARCH_ERROR_CODE_SEARCH_AREADY_IN_PROGRESS = k_EGameSearchErrorCode_Failed_Search_Already_In_Progress,
	GAME_SEARCH_ERROR_CODE_NO_SEARCH_IN_PROGRESS = k_EGameSearchErrorCode_Failed_No_Search_In_Progress,
	GAME_SEARCH_ERROR_CODE_NOT_LOBBY_LEADER = k_EGameSearchErrorCode_Failed_Not_Lobby_Leader,
	GAME_SEARCH_ERROR_CODE_NO_HOST_AVAILABLE = k_EGameSearchErrorCode_Failed_No_Host_Available,
	GAME_SEARCH_ERROR_CODE_SEARCH_PARAMS_INVALID = k_EGameSearchErrorCode_Failed_Search_Params_Invalid,
	GAME_SEARCH_ERROR_CODE_OFFLINE = k_EGameSearchErrorCode_Failed_Offline,
	GAME_SEARCH_ERROR_CODE_NOT_AUTHORIZED = k_EGameSearchErrorCode_Failed_NotAuthorized,
	GAME_SEARCH_ERROR_CODE_UNKNOWN_ERROR = k_EGameSearchErrorCode_Failed_Unknown_Error
};

enum PlayerAcceptState {
	// Found in isteammatchmaking.h
	PLAYER_ACCEPT_STATE_UNKNOWN = RequestPlayersForGameResultCallback_t::k_EStateUnknown,
	PLAYER_ACCEPT_STATE_ACCEPTED = RequestPlayersForGameResultCallback_t::k_EStatePlayerAccepted,
	PLAYER_ACCEPT_STATE_DECLINED = RequestPlayersForGameResultCallback_t::k_EStatePlayerDeclined
};

enum PlayerResult {
	// Found in steamclientpublic.h
	PLAYER_RESULT_FAILED_TO_CONNECT = k_EPlayerResultFailedToConnect,
	PLAYER_RESULT_ABANDONED = k_EPlayerResultAbandoned,
	PLAYER_RESULT_KICKED = k_EPlayerResultKicked,
	PLAYER_RESULT_INCOMPLETE = k_EPlayerResultIncomplete,
	PLAYER_RESULT_COMPLETED = k_EPlayerResultCompleted
};


// HTMLSurface enums
enum HTMLKeyModifiers {
	HTML_KEY_MODIFIER_NONE = ISteamHTMLSurface::k_eHTMLKeyModifier_None,
	HTML_KEY_MODIFIER_ALT_DOWN = ISteamHTMLSurface::k_eHTMLKeyModifier_AltDown,
	HTML_KEY_MODIFIER_CTRL_DOWN = ISteamHTMLSurface::k_eHTMLKeyModifier_CtrlDown,
	HTML_KEY_MODIFIER_SHIFT_DOWN = ISteamHTMLSurface::k_eHTMLKeyModifier_ShiftDown
};

enum HTMLMouseButton {
	HTML_MOUSE_BUTTON_LEFT = ISteamHTMLSurface::eHTMLMouseButton_Left,
	HTML_MOUSE_BUTTON_RIGHT = ISteamHTMLSurface::eHTMLMouseButton_Right,
	HTML_MOUSE_BUTTON_MIDDLE = ISteamHTMLSurface::eHTMLMouseButton_Middle
};

enum HTMLMouseCursor {
	HTML_MOUSE_CURSOR_USER = ISteamHTMLSurface::k_EHTMLMouseCursor_User,
	HTML_MOUSE_CURSOR_NONE = ISteamHTMLSurface::k_EHTMLMouseCursor_None,
	HTML_MOUSE_CURSOR_ARROW = ISteamHTMLSurface::k_EHTMLMouseCursor_Arrow,
	HTML_MOUSE_CURSOR_IBEAM = ISteamHTMLSurface::k_EHTMLMouseCursor_IBeam,
	HTML_MOUSE_CURSOR_HOURGLASS = ISteamHTMLSurface::k_EHTMLMouseCursor_Hourglass,
	HTML_MOUSE_CURSOR_WAIT_ARROW = ISteamHTMLSurface::k_EHTMLMouseCursor_WaitArrow,
	HTML_MOUSE_CURSOR_CROSSHAIR = ISteamHTMLSurface::k_EHTMLMouseCursor_Crosshair,
	HTML_MOUSE_CURSOR_UP = ISteamHTMLSurface::k_EHTMLMouseCursor_Up,
	HTML_MOUSE_CURSOR_SIZE_NW = ISteamHTMLSurface::k_EHTMLMouseCursor_SizeNW,
	HTML_MOUSE_CURSOR_SIZE_SE = ISteamHTMLSurface::k_EHTMLMouseCursor_SizeSE,
	HTML_MOUSE_CURSOR_SIZE_NE = ISteamHTMLSurface::k_EHTMLMouseCursor_SizeNE,
	HTML_MOUSE_CURSOR_SIZE_SW = ISteamHTMLSurface::k_EHTMLMouseCursor_SizeSW,
	HTML_MOUSE_CURSOR_SIZE_W = ISteamHTMLSurface::k_EHTMLMouseCursor_SizeW,
	HTML_MOUSE_CURSOR_SIZE_E = ISteamHTMLSurface::k_EHTMLMouseCursor_SizeE,
	HTML_MOUSE_CURSOR_SIZE_N = ISteamHTMLSurface::k_EHTMLMouseCursor_SizeN,
	HTML_MOUSE_CURSOR_SIZE_S = ISteamHTMLSurface::k_EHTMLMouseCursor_SizeS,
	HTML_MOUSE_CURSOR_SIZE_WE = ISteamHTMLSurface::k_EHTMLMouseCursor_SizeWE,
	HTML_MOUSE_CURSOR_SIZE_NS = ISteamHTMLSurface::k_EHTMLMouseCursor_SizeNS,
	HTML_MOUSE_CURSOR_SIZE_ALL = ISteamHTMLSurface::k_EHTMLMouseCursor_SizeAll,
	HTML_MOUSE_CURSOR_CURSOR_NO = ISteamHTMLSurface::k_EHTMLMouseCursor_No,
	HTML_MOUSE_CURSOR_CURSOR_HAND = ISteamHTMLSurface::k_EHTMLMouseCursor_Hand,
	HTML_MOUSE_CURSOR_CURSOR_BLANK = ISteamHTMLSurface::k_EHTMLMouseCursor_Blank,
	HTML_MOUSE_CURSOR_MIDDLE_PAN = ISteamHTMLSurface::k_EHTMLMouseCursor_MiddlePan,
	HTML_MOUSE_CURSOR_NORTH_PAN = ISteamHTMLSurface::k_EHTMLMouseCursor_NorthPan,
	HTML_MOUSE_CURSOR_NORTH_EAST_PAN = ISteamHTMLSurface::k_EHTMLMouseCursor_NorthEastPan,
	HTML_MOUSE_CURSOR_EAST_PAN = ISteamHTMLSurface::k_EHTMLMouseCursor_EastPan,
	HTML_MOUSE_CURSOR_SOUTH_EAST_PAN = ISteamHTMLSurface::k_EHTMLMouseCursor_SouthEastPan,
	HTML_MOUSE_CURSOR_SOUTH_PAN = ISteamHTMLSurface::k_EHTMLMouseCursor_SouthPan,
	HTML_MOUSE_CURSOR_SOUTH_WEST_PAN = ISteamHTMLSurface::k_EHTMLMouseCursor_SouthWestPan,
	HTML_MOUSE_CURSOR_WEST_PAN = ISteamHTMLSurface::k_EHTMLMouseCursor_WestPan,
	HTML_MOUSE_CURSOR_NORTH_WEST_PAN = ISteamHTMLSurface::k_EHTMLMouseCursor_NorthWestPan,
	HTML_MOUSE_CURSOR_ALIAS = ISteamHTMLSurface::k_EHTMLMouseCursor_Alias,
	HTML_MOUSE_CURSOR_CELL = ISteamHTMLSurface::k_EHTMLMouseCursor_Cell,
	HTML_MOUSE_CURSOR_COL_RESIZE = ISteamHTMLSurface::k_EHTMLMouseCursor_ColResize,
	HTML_MOUSE_CURSOR_COPY_CUR = ISteamHTMLSurface::k_EHTMLMouseCursor_CopyCur,
	HTML_MOUSE_CURSOR_VERTICAL_TEXT = ISteamHTMLSurface::k_EHTMLMouseCursor_VerticalText,
	HTML_MOUSE_CURSOR_ROW_RESIZE = ISteamHTMLSurface::k_EHTMLMouseCursor_RowResize,
	HTML_MOUSE_CURSOR_ZOOM_IN = ISteamHTMLSurface::k_EHTMLMouseCursor_ZoomIn,
	HTML_MOUSE_CURSOR_ZOOM_OUT = ISteamHTMLSurface::k_EHTMLMouseCursor_ZoomOut,
	HTML_MOUSE_CURSOR_HELP = ISteamHTMLSurface::k_EHTMLMouseCursor_Help,
	HTML_MOUSE_CURSOR_CUSTOM = ISteamHTMLSurface::k_EHTMLMouseCursor_Custom,
	HTML_MOUSE_CURSOR_SIZE_NWSE = ISteamHTMLSurface::k_EHTMLMouseCursor_SizeNWSE,
	HTML_MOUSE_CURSOR_SIZE_NESW = ISteamHTMLSurface::k_EHTMLMouseCursor_SizeNESW,
	HTML_MOUSE_CURSOR_LAST = ISteamHTMLSurface::k_EHTMLMouseCursor_last
};


// HTTP enums
enum HTTPMethod {
	HTTP_METHOD_INVALID = k_EHTTPMethodInvalid,
	HTTP_METHOD_GET = k_EHTTPMethodGET,
	HTTP_METHOD_HEAD = k_EHTTPMethodHEAD,
	HTTP_METHOD_POST = k_EHTTPMethodPOST,
	HTTP_METHOD_PUT = k_EHTTPMethodPUT,
	HTTP_METHOD_DELETE = k_EHTTPMethodDELETE,
	HTTP_METHOD_OPTIONS = k_EHTTPMethodOPTIONS,
	HTTP_METHOD_PATCH = k_EHTTPMethodPATCH
};

enum HTTPStatusCode {
	HTTP_STATUS_CODE_INVALID = k_EHTTPStatusCodeInvalid,
	HTTP_STATUS_CODE_100_CONTINUE = k_EHTTPStatusCode100Continue,
	HTTP_STATUS_CODE_101_SWITCHING_PROTOCOLS = k_EHTTPStatusCode101SwitchingProtocols,
	HTTP_STATUS_CODE_200_OK = k_EHTTPStatusCode200OK,
	HTTP_STATUS_CODE_201_CREATED = k_EHTTPStatusCode201Created,
	HTTP_STATUS_CODE_202_ACCEPTED = k_EHTTPStatusCode202Accepted,
	HTTP_STATUS_CODE_203_NON_AUTHORITATIVE = k_EHTTPStatusCode203NonAuthoritative,
	HTTP_STATUS_CODE_204_NO_CONTENT = k_EHTTPStatusCode204NoContent,
	HTTP_STATUS_CODE_205_RESET_CONTENT = k_EHTTPStatusCode205ResetContent,
	HTTP_STATUS_CODE_206_PARTIAL_CONTENT = k_EHTTPStatusCode206PartialContent,
	HTTP_STATUS_CODE_300_MULTIPLE_CHOICES = k_EHTTPStatusCode300MultipleChoices,
	HTTP_STATUS_CODE_301_MOVED_PERMANENTLY = k_EHTTPStatusCode301MovedPermanently,
	HTTP_STATUS_CODE_302_FOUND = k_EHTTPStatusCode302Found,
	HTTP_STATUS_CODE_303_SEE_OTHER = k_EHTTPStatusCode303SeeOther,
	HTTP_STATUS_CODE_304_NOT_MODIFIED = k_EHTTPStatusCode304NotModified,
	HTTP_STATUS_CODE_305_USE_PROXY = k_EHTTPStatusCode305UseProxy,
	HTTP_STATUS_CODE_307_TEMPORARY_REDIRECT = k_EHTTPStatusCode307TemporaryRedirect,
	HTTP_STATUS_CODE_308_PERMANENT_REDIRECT = k_EHTTPStatusCode308PermanentRedirect,
	HTTP_STATUS_CODE_400_BAD_REQUEST = k_EHTTPStatusCode400BadRequest,
	HTTP_STATUS_CODE_401_UNAUTHORIZED = k_EHTTPStatusCode401Unauthorized,
	HTTP_STATUS_CODE_402_PAYMENT_REQUIRED = k_EHTTPStatusCode402PaymentRequired,
	HTTP_STATUS_CODE_403_FORBIDDEN = k_EHTTPStatusCode403Forbidden,
	HTTP_STATUS_CODE_404_NOT_FOUND = k_EHTTPStatusCode404NotFound,
	HTTP_STATUS_CODE_405_METHOD_NOT_ALLOWED = k_EHTTPStatusCode405MethodNotAllowed,
	HTTP_STATUS_CODE_406_NOT_ACCEPTABLE = k_EHTTPStatusCode406NotAcceptable,
	HTTP_STATUS_CODE_407_PROXY_AUTH_REQUIRED = k_EHTTPStatusCode407ProxyAuthRequired,
	HTTP_STATUS_CODE_408_REQUEST_TIMEOUT = k_EHTTPStatusCode408RequestTimeout,
	HTTP_STATUS_CODE_409_CONFLICT = k_EHTTPStatusCode409Conflict,
	HTTP_STATUS_CODE_410_GONE = k_EHTTPStatusCode410Gone,
	HTTP_STATUS_CODE_411_LENGTH_REQUIRED = k_EHTTPStatusCode411LengthRequired,
	HTTP_STATUS_CODE_412_PRECONDITION_FAILED = k_EHTTPStatusCode412PreconditionFailed,
	HTTP_STATUS_CODE_413_REQUEST_ENTITY_TOO_LARGE = k_EHTTPStatusCode413RequestEntityTooLarge,
	HTTP_STATUS_CODE_414_REQUEST_URI_TOO_LONG = k_EHTTPStatusCode414RequestURITooLong,
	HTTP_STATUS_CODE_415_UNSUPPORTED_MEDIA_TYPE = k_EHTTPStatusCode415UnsupportedMediaType,
	HTTP_STATUS_CODE_416_REQUESTED_RANGE_NOT_SATISFIABLE = k_EHTTPStatusCode416RequestedRangeNotSatisfiable,
	HTTP_STATUS_CODE_417_EXPECTATION_FAILED = k_EHTTPStatusCode417ExpectationFailed,
	HTTP_STATUS_CODE_4XX_UNKNOWN = k_EHTTPStatusCode4xxUnknown,
	HTTP_STATUS_CODE_429_TOO_MANY_REQUESTS = k_EHTTPStatusCode429TooManyRequests,
	HTTP_STATUS_CODE_444_CONNECTION_CLOSED = k_EHTTPStatusCode444ConnectionClosed,
	HTTP_STATUS_CODE_500_INTERNAL_SERVER_ERROR = k_EHTTPStatusCode500InternalServerError,
	HTTP_STATUS_CODE_501_NOT_IMPLEMENTED = k_EHTTPStatusCode501NotImplemented,
	HTTP_STATUS_CODE_502_BAD_GATEWAY = k_EHTTPStatusCode502BadGateway,
	HTTP_STATUS_CODE_503_SERVICE_UNAVAILABLE = k_EHTTPStatusCode503ServiceUnavailable,
	HTTP_STATUS_CODE_504_GATEWAY_TIMEOUT = k_EHTTPStatusCode504GatewayTimeout,
	HTTP_STATUS_CODE_505_HTTP_VERSION_NOT_SUPPORTED = k_EHTTPStatusCode505HTTPVersionNotSupported,
	HTTP_STATUS_CODE_5XX_UNKNOWN = k_EHTTPStatusCode5xxUnknown
};


// Input enums
enum ControllerHapticLocation {
	CONTROLLER_HAPTIC_LOCATION_LEFT = k_EControllerHapticLocation_Left,
	CONTROLLER_HAPTIC_LOCATION_RIGHT = k_EControllerHapticLocation_Right,
	CONTROLLER_HAPTIC_LOCATION_BOTH = k_EControllerHapticLocation_Both
};

enum ControllerHapticType {
	CONTROLLER_HAPTIC_TYPE_OFF = k_EControllerHapticType_Off,
	CONTROLLER_HAPTIC_TYPE_TICK = k_EControllerHapticType_Tick,
	CONTROLLER_HAPTIC_TYPE_CLICK = k_EControllerHapticType_Click
};

enum ControllerPad {
	STEAM_CONTROLLER_PAD_LEFT = k_ESteamControllerPad_Left,
	STEAM_CONTROLLER_PAD_RIGHT = k_ESteamControllerPad_Right
};

enum InputActionEventType {
	INPUT_ACTION_EVENT_TYPE_DIGITAL_ACTION = ESteamInputActionEventType_DigitalAction,
	INPUT_ACTION_EVENT_TYPE_ANALOG_ACTION = ESteamInputActionEventType_AnalogAction
};

enum InputActionOrigin {
	INPUT_ACTION_ORIGIN_NONE = k_EInputActionOrigin_None,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_A = k_EInputActionOrigin_SteamController_A,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_B = k_EInputActionOrigin_SteamController_B,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_X = k_EInputActionOrigin_SteamController_X,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_Y = k_EInputActionOrigin_SteamController_Y,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTBUMPER = k_EInputActionOrigin_SteamController_LeftBumper,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RIGHTBUMPER = k_EInputActionOrigin_SteamController_RightBumper,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTGRIP = k_EInputActionOrigin_SteamController_LeftGrip,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RIGHTGRIP = k_EInputActionOrigin_SteamController_RightGrip,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_START = k_EInputActionOrigin_SteamController_Start,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_BACK = k_EInputActionOrigin_SteamController_Back,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTPAD_TOUCH = k_EInputActionOrigin_SteamController_LeftPad_Touch,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTPAD_SWIPE = k_EInputActionOrigin_SteamController_LeftPad_Swipe,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTPAD_CLICK = k_EInputActionOrigin_SteamController_LeftPad_Click,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTPAD_DPADNORTH = k_EInputActionOrigin_SteamController_LeftPad_DPadNorth,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTPAD_DPADSOUTH = k_EInputActionOrigin_SteamController_LeftPad_DPadSouth,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTPAD_DPADWEST = k_EInputActionOrigin_SteamController_LeftPad_DPadWest,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTPAD_DPADEAST = k_EInputActionOrigin_SteamController_LeftPad_DPadEast,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RIGHTPAD_TOUCH = k_EInputActionOrigin_SteamController_RightPad_Touch,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RIGHTPAD_SWIPE = k_EInputActionOrigin_SteamController_RightPad_Swipe,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RIGHTPAD_CLICK = k_EInputActionOrigin_SteamController_RightPad_Click,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RIGHTPAD_DPADNORTH = k_EInputActionOrigin_SteamController_RightPad_DPadNorth,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RIGHTPAD_DPADSOUTH = k_EInputActionOrigin_SteamController_RightPad_DPadSouth,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RIGHTPAD_DPADWEST = k_EInputActionOrigin_SteamController_RightPad_DPadWest,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RIGHTPAD_DPADEAST = k_EInputActionOrigin_SteamController_RightPad_DPadEast,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTTRIGGER_PULL = k_EInputActionOrigin_SteamController_LeftTrigger_Pull,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTTRIGGER_CLICK = k_EInputActionOrigin_SteamController_LeftTrigger_Click,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RIGHTTRIGGER_PULL = k_EInputActionOrigin_SteamController_RightTrigger_Pull,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RIGHTTRIGGER_CLICK = k_EInputActionOrigin_SteamController_RightTrigger_Click,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTSTICK_MOVE = k_EInputActionOrigin_SteamController_LeftStick_Move,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTSTICK_CLICK = k_EInputActionOrigin_SteamController_LeftStick_Click,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTSTICK_DPADNORTH = k_EInputActionOrigin_SteamController_LeftStick_DPadNorth,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTSTICK_DPADSOUTH = k_EInputActionOrigin_SteamController_LeftStick_DPadSouth,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTSTICK_DPADWEST = k_EInputActionOrigin_SteamController_LeftStick_DPadWest,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_LEFTSTICK_DPADEAST = k_EInputActionOrigin_SteamController_LeftStick_DPadEast,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_GYRO_MOVE = k_EInputActionOrigin_SteamController_Gyro_Move,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_GYRO_PITCH = k_EInputActionOrigin_SteamController_Gyro_Pitch,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_GYRO_YAW = k_EInputActionOrigin_SteamController_Gyro_Yaw,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_GYRO_ROLL = k_EInputActionOrigin_SteamController_Gyro_Roll,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RESERVED0 = k_EInputActionOrigin_SteamController_Reserved0,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RESERVED1 = k_EInputActionOrigin_SteamController_Reserved1,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RESERVED2 = k_EInputActionOrigin_SteamController_Reserved2,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RESERVED3 = k_EInputActionOrigin_SteamController_Reserved3,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RESERVED4 = k_EInputActionOrigin_SteamController_Reserved4,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RESERVED5 = k_EInputActionOrigin_SteamController_Reserved5,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RESERVED6 = k_EInputActionOrigin_SteamController_Reserved6,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RESERVED7 = k_EInputActionOrigin_SteamController_Reserved7,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RESERVED8 = k_EInputActionOrigin_SteamController_Reserved8,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RESERVED9 = k_EInputActionOrigin_SteamController_Reserved9,
	INPUT_ACTION_ORIGIN_STEAMCONTROLLER_RESERVED10 = k_EInputActionOrigin_SteamController_Reserved10,
	INPUT_ACTION_ORIGIN_PS4_X = k_EInputActionOrigin_PS4_X,
	INPUT_ACTION_ORIGIN_PS4_CIRCLE = k_EInputActionOrigin_PS4_Circle,
	INPUT_ACTION_ORIGIN_PS4_TRIANGLE = k_EInputActionOrigin_PS4_Triangle,
	INPUT_ACTION_ORIGIN_PS4_SQUARE = k_EInputActionOrigin_PS4_Square,
	INPUT_ACTION_ORIGIN_PS4_LEFTBUMPER = k_EInputActionOrigin_PS4_LeftBumper,
	INPUT_ACTION_ORIGIN_PS4_RIGHTBUMPER = k_EInputActionOrigin_PS4_RightBumper,
	INPUT_ACTION_ORIGIN_PS4_OPTIONS = k_EInputActionOrigin_PS4_Options,
	INPUT_ACTION_ORIGIN_PS4_SHARE = k_EInputActionOrigin_PS4_Share,
	INPUT_ACTION_ORIGIN_PS4_LEFTPAD_TOUCH = k_EInputActionOrigin_PS4_LeftPad_Touch,
	INPUT_ACTION_ORIGIN_PS4_LEFTPAD_SWIPE = k_EInputActionOrigin_PS4_LeftPad_Swipe,
	INPUT_ACTION_ORIGIN_PS4_LEFTPAD_CLICK = k_EInputActionOrigin_PS4_LeftPad_Click,
	INPUT_ACTION_ORIGIN_PS4_LEFTPAD_DPADNORTH = k_EInputActionOrigin_PS4_LeftPad_DPadNorth,
	INPUT_ACTION_ORIGIN_PS4_LEFTPAD_DPADSOUTH = k_EInputActionOrigin_PS4_LeftPad_DPadSouth,
	INPUT_ACTION_ORIGIN_PS4_LEFTPAD_DPADWEST = k_EInputActionOrigin_PS4_LeftPad_DPadWest,
	INPUT_ACTION_ORIGIN_PS4_LEFTPAD_DPADEAST = k_EInputActionOrigin_PS4_LeftPad_DPadEast,
	INPUT_ACTION_ORIGIN_PS4_RIGHTPAD_TOUCH = k_EInputActionOrigin_PS4_RightPad_Touch,
	INPUT_ACTION_ORIGIN_PS4_RIGHTPAD_SWIPE = k_EInputActionOrigin_PS4_RightPad_Swipe,
	INPUT_ACTION_ORIGIN_PS4_RIGHTPAD_CLICK = k_EInputActionOrigin_PS4_RightPad_Click,
	INPUT_ACTION_ORIGIN_PS4_RIGHTPAD_DPADNORTH = k_EInputActionOrigin_PS4_RightPad_DPadNorth,
	INPUT_ACTION_ORIGIN_PS4_RIGHTPAD_DPADSOUTH = k_EInputActionOrigin_PS4_RightPad_DPadSouth,
	INPUT_ACTION_ORIGIN_PS4_RIGHTPAD_DPADWEST = k_EInputActionOrigin_PS4_RightPad_DPadWest,
	INPUT_ACTION_ORIGIN_PS4_RIGHTPAD_DPADEAST = k_EInputActionOrigin_PS4_RightPad_DPadEast,
	INPUT_ACTION_ORIGIN_PS4_CENTERPAD_TOUCH = k_EInputActionOrigin_PS4_CenterPad_Touch,
	INPUT_ACTION_ORIGIN_PS4_CENTERPAD_SWIPE = k_EInputActionOrigin_PS4_CenterPad_Swipe,
	INPUT_ACTION_ORIGIN_PS4_CENTERPAD_CLICK = k_EInputActionOrigin_PS4_CenterPad_Click,
	INPUT_ACTION_ORIGIN_PS4_CENTERPAD_DPADNORTH = k_EInputActionOrigin_PS4_CenterPad_DPadNorth,
	INPUT_ACTION_ORIGIN_PS4_CENTERPAD_DPADSOUTH = k_EInputActionOrigin_PS4_CenterPad_DPadSouth,
	INPUT_ACTION_ORIGIN_PS4_CENTERPAD_DPADWEST = k_EInputActionOrigin_PS4_CenterPad_DPadWest,
	INPUT_ACTION_ORIGIN_PS4_CENTERPAD_DPADEAST = k_EInputActionOrigin_PS4_CenterPad_DPadEast,
	INPUT_ACTION_ORIGIN_PS4_LEFTTRIGGER_PULL = k_EInputActionOrigin_PS4_LeftTrigger_Pull,
	INPUT_ACTION_ORIGIN_PS4_LEFTTRIGGER_CLICK = k_EInputActionOrigin_PS4_LeftTrigger_Click,
	INPUT_ACTION_ORIGIN_PS4_RIGHTTRIGGER_PULL = k_EInputActionOrigin_PS4_RightTrigger_Pull,
	INPUT_ACTION_ORIGIN_PS4_RIGHTTRIGGER_CLICK = k_EInputActionOrigin_PS4_RightTrigger_Click,
	INPUT_ACTION_ORIGIN_PS4_LEFTSTICK_MOVE = k_EInputActionOrigin_PS4_LeftStick_Move,
	INPUT_ACTION_ORIGIN_PS4_LEFTSTICK_CLICK = k_EInputActionOrigin_PS4_LeftStick_Click,
	INPUT_ACTION_ORIGIN_PS4_LEFTSTICK_DPADNORTH = k_EInputActionOrigin_PS4_LeftStick_DPadNorth,
	INPUT_ACTION_ORIGIN_PS4_LEFTSTICK_DPADSOUTH = k_EInputActionOrigin_PS4_LeftStick_DPadSouth,
	INPUT_ACTION_ORIGIN_PS4_LEFTSTICK_DPADWEST = k_EInputActionOrigin_PS4_LeftStick_DPadWest,
	INPUT_ACTION_ORIGIN_PS4_LEFTSTICK_DPADEAST = k_EInputActionOrigin_PS4_LeftStick_DPadEast,
	INPUT_ACTION_ORIGIN_PS4_RIGHTSTICK_MOVE = k_EInputActionOrigin_PS4_RightStick_Move,
	INPUT_ACTION_ORIGIN_PS4_RIGHTSTICK_CLICK = k_EInputActionOrigin_PS4_RightStick_Click,
	INPUT_ACTION_ORIGIN_PS4_RIGHTSTICK_DPADNORTH = k_EInputActionOrigin_PS4_RightStick_DPadNorth,
	INPUT_ACTION_ORIGIN_PS4_RIGHTSTICK_DPADSOUTH = k_EInputActionOrigin_PS4_RightStick_DPadSouth,
	INPUT_ACTION_ORIGIN_PS4_RIGHTSTICK_DPADWEST = k_EInputActionOrigin_PS4_RightStick_DPadWest,
	INPUT_ACTION_ORIGIN_PS4_RIGHTSTICK_DPADEAST = k_EInputActionOrigin_PS4_RightStick_DPadEast,
	INPUT_ACTION_ORIGIN_PS4_DPAD_NORTH = k_EInputActionOrigin_PS4_DPad_North,
	INPUT_ACTION_ORIGIN_PS4_DPAD_SOUTH = k_EInputActionOrigin_PS4_DPad_South,
	INPUT_ACTION_ORIGIN_PS4_DPAD_WEST = k_EInputActionOrigin_PS4_DPad_West,
	INPUT_ACTION_ORIGIN_PS4_DPAD_EAST = k_EInputActionOrigin_PS4_DPad_East,
	INPUT_ACTION_ORIGIN_PS4_GYRO_MOVE = k_EInputActionOrigin_PS4_Gyro_Move,
	INPUT_ACTION_ORIGIN_PS4_GYRO_PITCH = k_EInputActionOrigin_PS4_Gyro_Pitch,
	INPUT_ACTION_ORIGIN_PS4_GYRO_YAW = k_EInputActionOrigin_PS4_Gyro_Yaw,
	INPUT_ACTION_ORIGIN_PS4_GYRO_ROLL = k_EInputActionOrigin_PS4_Gyro_Roll,
	INPUT_ACTION_ORIGIN_PS4_DPAD_MOVE = k_EInputActionOrigin_PS4_DPad_Move,
	INPUT_ACTION_ORIGIN_PS4_RESERVED1 = k_EInputActionOrigin_PS4_Reserved1,
	INPUT_ACTION_ORIGIN_PS4_RESERVED2 = k_EInputActionOrigin_PS4_Reserved2,
	INPUT_ACTION_ORIGIN_PS4_RESERVED3 = k_EInputActionOrigin_PS4_Reserved3,
	INPUT_ACTION_ORIGIN_PS4_RESERVED4 = k_EInputActionOrigin_PS4_Reserved4,
	INPUT_ACTION_ORIGIN_PS4_RESERVED5 = k_EInputActionOrigin_PS4_Reserved5,
	INPUT_ACTION_ORIGIN_PS4_RESERVED6 = k_EInputActionOrigin_PS4_Reserved6,
	INPUT_ACTION_ORIGIN_PS4_RESERVED7 = k_EInputActionOrigin_PS4_Reserved7,
	INPUT_ACTION_ORIGIN_PS4_RESERVED8 = k_EInputActionOrigin_PS4_Reserved8,
	INPUT_ACTION_ORIGIN_PS4_RESERVED9 = k_EInputActionOrigin_PS4_Reserved9,
	INPUT_ACTION_ORIGIN_PS4_RESERVED10 = k_EInputActionOrigin_PS4_Reserved10,
	INPUT_ACTION_ORIGIN_XBOXONE_A = k_EInputActionOrigin_XBoxOne_A,
	INPUT_ACTION_ORIGIN_XBOXONE_B = k_EInputActionOrigin_XBoxOne_B,
	INPUT_ACTION_ORIGIN_XBOXONE_X = k_EInputActionOrigin_XBoxOne_X,
	INPUT_ACTION_ORIGIN_XBOXONE_Y = k_EInputActionOrigin_XBoxOne_Y,
	INPUT_ACTION_ORIGIN_XBOXONE_LEFTBUMPER = k_EInputActionOrigin_XBoxOne_LeftBumper,
	INPUT_ACTION_ORIGIN_XBOXONE_RIGHTBUMPER = k_EInputActionOrigin_XBoxOne_RightBumper,
	INPUT_ACTION_ORIGIN_XBOXONE_MENU = k_EInputActionOrigin_XBoxOne_Menu,
	INPUT_ACTION_ORIGIN_XBOXONE_VIEW = k_EInputActionOrigin_XBoxOne_View,
	INPUT_ACTION_ORIGIN_XBOXONE_LEFTTRIGGER_PULL = k_EInputActionOrigin_XBoxOne_LeftTrigger_Pull,
	INPUT_ACTION_ORIGIN_XBOXONE_LEFTTRIGGER_CLICK = k_EInputActionOrigin_XBoxOne_LeftTrigger_Click,
	INPUT_ACTION_ORIGIN_XBOXONE_RIGHTTRIGGER_PULL = k_EInputActionOrigin_XBoxOne_RightTrigger_Pull,
	INPUT_ACTION_ORIGIN_XBOXONE_RIGHTTRIGGER_CLICK = k_EInputActionOrigin_XBoxOne_RightTrigger_Click,
	INPUT_ACTION_ORIGIN_XBOXONE_LEFTSTICK_MOVE = k_EInputActionOrigin_XBoxOne_LeftStick_Move,
	INPUT_ACTION_ORIGIN_XBOXONE_LEFTSTICK_CLICK = k_EInputActionOrigin_XBoxOne_LeftStick_Click,
	INPUT_ACTION_ORIGIN_XBOXONE_LEFTSTICK_DPADNORTH = k_EInputActionOrigin_XBoxOne_LeftStick_DPadNorth,
	INPUT_ACTION_ORIGIN_XBOXONE_LEFTSTICK_DPADSOUTH = k_EInputActionOrigin_XBoxOne_LeftStick_DPadSouth,
	INPUT_ACTION_ORIGIN_XBOXONE_LEFTSTICK_DPADWEST = k_EInputActionOrigin_XBoxOne_LeftStick_DPadWest,
	INPUT_ACTION_ORIGIN_XBOXONE_LEFTSTICK_DPADEAST = k_EInputActionOrigin_XBoxOne_LeftStick_DPadEast,
	INPUT_ACTION_ORIGIN_XBOXONE_RIGHTSTICK_MOVE = k_EInputActionOrigin_XBoxOne_RightStick_Move,
	INPUT_ACTION_ORIGIN_XBOXONE_RIGHTSTICK_CLICK = k_EInputActionOrigin_XBoxOne_RightStick_Click,
	INPUT_ACTION_ORIGIN_XBOXONE_RIGHTSTICK_DPADNORTH = k_EInputActionOrigin_XBoxOne_RightStick_DPadNorth,
	INPUT_ACTION_ORIGIN_XBOXONE_RIGHTSTICK_DPADSOUTH = k_EInputActionOrigin_XBoxOne_RightStick_DPadSouth,
	INPUT_ACTION_ORIGIN_XBOXONE_RIGHTSTICK_DPADWEST = k_EInputActionOrigin_XBoxOne_RightStick_DPadWest,
	INPUT_ACTION_ORIGIN_XBOXONE_RIGHTSTICK_DPADEAST = k_EInputActionOrigin_XBoxOne_RightStick_DPadEast,
	INPUT_ACTION_ORIGIN_XBOXONE_DPAD_NORTH = k_EInputActionOrigin_XBoxOne_DPad_North,
	INPUT_ACTION_ORIGIN_XBOXONE_DPAD_SOUTH = k_EInputActionOrigin_XBoxOne_DPad_South,
	INPUT_ACTION_ORIGIN_XBOXONE_DPAD_WEST = k_EInputActionOrigin_XBoxOne_DPad_West,
	INPUT_ACTION_ORIGIN_XBOXONE_DPAD_EAST = k_EInputActionOrigin_XBoxOne_DPad_East,
	INPUT_ACTION_ORIGIN_XBOXONE_DPAD_MOVE = k_EInputActionOrigin_XBoxOne_DPad_Move,
	INPUT_ACTION_ORIGIN_XBOXONE_LEFTGRIP_LOWER = k_EInputActionOrigin_XBoxOne_LeftGrip_Lower,
	INPUT_ACTION_ORIGIN_XBOXONE_LEFTGRIP_UPPER = k_EInputActionOrigin_XBoxOne_LeftGrip_Upper,
	INPUT_ACTION_ORIGIN_XBOXONE_RIGHTGRIP_LOWER = k_EInputActionOrigin_XBoxOne_RightGrip_Lower,
	INPUT_ACTION_ORIGIN_XBOXONE_RIGHTGRIP_UPPER = k_EInputActionOrigin_XBoxOne_RightGrip_Upper,
	INPUT_ACTION_ORIGIN_XBOXONE_SHARE = k_EInputActionOrigin_XBoxOne_Share,
	INPUT_ACTION_ORIGIN_XBOXONE_RESERVED6 = k_EInputActionOrigin_XBoxOne_Reserved6,
	INPUT_ACTION_ORIGIN_XBOXONE_RESERVED7 = k_EInputActionOrigin_XBoxOne_Reserved7,
	INPUT_ACTION_ORIGIN_XBOXONE_RESERVED8 = k_EInputActionOrigin_XBoxOne_Reserved8,
	INPUT_ACTION_ORIGIN_XBOXONE_RESERVED9 = k_EInputActionOrigin_XBoxOne_Reserved9,
	INPUT_ACTION_ORIGIN_XBOXONE_RESERVED10 = k_EInputActionOrigin_XBoxOne_Reserved10,
	INPUT_ACTION_ORIGIN_XBOX360_A = k_EInputActionOrigin_XBox360_A,
	INPUT_ACTION_ORIGIN_XBOX360_B = k_EInputActionOrigin_XBox360_B,
	INPUT_ACTION_ORIGIN_XBOX360_X = k_EInputActionOrigin_XBox360_X,
	INPUT_ACTION_ORIGIN_XBOX360_Y = k_EInputActionOrigin_XBox360_Y,
	INPUT_ACTION_ORIGIN_XBOX360_LEFTBUMPER = k_EInputActionOrigin_XBox360_LeftBumper,
	INPUT_ACTION_ORIGIN_XBOX360_RIGHTBUMPER = k_EInputActionOrigin_XBox360_RightBumper,
	INPUT_ACTION_ORIGIN_XBOX360_START = k_EInputActionOrigin_XBox360_Start,
	INPUT_ACTION_ORIGIN_XBOX360_BACK = k_EInputActionOrigin_XBox360_Back,
	INPUT_ACTION_ORIGIN_XBOX360_LEFTTRIGGER_PULL = k_EInputActionOrigin_XBox360_LeftTrigger_Pull,
	INPUT_ACTION_ORIGIN_XBOX360_LEFTTRIGGER_CLICK = k_EInputActionOrigin_XBox360_LeftTrigger_Click,
	INPUT_ACTION_ORIGIN_XBOX360_RIGHTTRIGGER_PULL = k_EInputActionOrigin_XBox360_RightTrigger_Pull,
	INPUT_ACTION_ORIGIN_XBOX360_RIGHTTRIGGER_CLICK = k_EInputActionOrigin_XBox360_RightTrigger_Click,
	INPUT_ACTION_ORIGIN_XBOX360_LEFTSTICK_MOVE = k_EInputActionOrigin_XBox360_LeftStick_Move,
	INPUT_ACTION_ORIGIN_XBOX360_LEFTSTICK_CLICK = k_EInputActionOrigin_XBox360_LeftStick_Click,
	INPUT_ACTION_ORIGIN_XBOX360_LEFTSTICK_DPADNORTH = k_EInputActionOrigin_XBox360_LeftStick_DPadNorth,
	INPUT_ACTION_ORIGIN_XBOX360_LEFTSTICK_DPADSOUTH = k_EInputActionOrigin_XBox360_LeftStick_DPadSouth,
	INPUT_ACTION_ORIGIN_XBOX360_LEFTSTICK_DPADWEST = k_EInputActionOrigin_XBox360_LeftStick_DPadWest,
	INPUT_ACTION_ORIGIN_XBOX360_LEFTSTICK_DPADEAST = k_EInputActionOrigin_XBox360_LeftStick_DPadEast,
	INPUT_ACTION_ORIGIN_XBOX360_RIGHTSTICK_MOVE = k_EInputActionOrigin_XBox360_RightStick_Move,
	INPUT_ACTION_ORIGIN_XBOX360_RIGHTSTICK_CLICK = k_EInputActionOrigin_XBox360_RightStick_Click,
	INPUT_ACTION_ORIGIN_XBOX360_RIGHTSTICK_DPADNORTH = k_EInputActionOrigin_XBox360_RightStick_DPadNorth,
	INPUT_ACTION_ORIGIN_XBOX360_RIGHTSTICK_DPADSOUTH = k_EInputActionOrigin_XBox360_RightStick_DPadSouth,
	INPUT_ACTION_ORIGIN_XBOX360_RIGHTSTICK_DPADWEST = k_EInputActionOrigin_XBox360_RightStick_DPadWest,
	INPUT_ACTION_ORIGIN_XBOX360_RIGHTSTICK_DPADEAST = k_EInputActionOrigin_XBox360_RightStick_DPadEast,
	INPUT_ACTION_ORIGIN_XBOX360_DPAD_NORTH = k_EInputActionOrigin_XBox360_DPad_North,
	INPUT_ACTION_ORIGIN_XBOX360_DPAD_SOUTH = k_EInputActionOrigin_XBox360_DPad_South,
	INPUT_ACTION_ORIGIN_XBOX360_DPAD_WEST = k_EInputActionOrigin_XBox360_DPad_West,
	INPUT_ACTION_ORIGIN_XBOX360_DPAD_EAST = k_EInputActionOrigin_XBox360_DPad_East,
	INPUT_ACTION_ORIGIN_XBOX360_DPAD_MOVE = k_EInputActionOrigin_XBox360_DPad_Move,
	INPUT_ACTION_ORIGIN_XBOX360_RESERVED1 = k_EInputActionOrigin_XBox360_Reserved1,
	INPUT_ACTION_ORIGIN_XBOX360_RESERVED2 = k_EInputActionOrigin_XBox360_Reserved2,
	INPUT_ACTION_ORIGIN_XBOX360_RESERVED3 = k_EInputActionOrigin_XBox360_Reserved3,
	INPUT_ACTION_ORIGIN_XBOX360_RESERVED4 = k_EInputActionOrigin_XBox360_Reserved4,
	INPUT_ACTION_ORIGIN_XBOX360_RESERVED5 = k_EInputActionOrigin_XBox360_Reserved5,
	INPUT_ACTION_ORIGIN_XBOX360_RESERVED6 = k_EInputActionOrigin_XBox360_Reserved6,
	INPUT_ACTION_ORIGIN_XBOX360_RESERVED7 = k_EInputActionOrigin_XBox360_Reserved7,
	INPUT_ACTION_ORIGIN_XBOX360_RESERVED8 = k_EInputActionOrigin_XBox360_Reserved8,
	INPUT_ACTION_ORIGIN_XBOX360_RESERVED9 = k_EInputActionOrigin_XBox360_Reserved9,
	INPUT_ACTION_ORIGIN_XBOX360_RESERVED10 = k_EInputActionOrigin_XBox360_Reserved10,
	INPUT_ACTION_ORIGIN_SWITCH_A = k_EInputActionOrigin_Switch_A,
	INPUT_ACTION_ORIGIN_SWITCH_B = k_EInputActionOrigin_Switch_B,
	INPUT_ACTION_ORIGIN_SWITCH_X = k_EInputActionOrigin_Switch_X,
	INPUT_ACTION_ORIGIN_SWITCH_Y = k_EInputActionOrigin_Switch_Y,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTBUMPER = k_EInputActionOrigin_Switch_LeftBumper,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTBUMPER = k_EInputActionOrigin_Switch_RightBumper,
	INPUT_ACTION_ORIGIN_SWITCH_PLUS = k_EInputActionOrigin_Switch_Plus,
	INPUT_ACTION_ORIGIN_SWITCH_MINUS = k_EInputActionOrigin_Switch_Minus,
	INPUT_ACTION_ORIGIN_SWITCH_CAPTURE = k_EInputActionOrigin_Switch_Capture,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTTRIGGER_PULL = k_EInputActionOrigin_Switch_LeftTrigger_Pull,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTTRIGGER_CLICK = k_EInputActionOrigin_Switch_LeftTrigger_Click,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTTRIGGER_PULL = k_EInputActionOrigin_Switch_RightTrigger_Pull,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTTRIGGER_CLICK = k_EInputActionOrigin_Switch_RightTrigger_Click,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTSTICK_MOVE = k_EInputActionOrigin_Switch_LeftStick_Move,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTSTICK_CLICK = k_EInputActionOrigin_Switch_LeftStick_Click,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTSTICK_DPADNORTH = k_EInputActionOrigin_Switch_LeftStick_DPadNorth,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTSTICK_DPADSOUTH = k_EInputActionOrigin_Switch_LeftStick_DPadSouth,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTSTICK_DPADWEST = k_EInputActionOrigin_Switch_LeftStick_DPadWest,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTSTICK_DPADEAST = k_EInputActionOrigin_Switch_LeftStick_DPadEast,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTSTICK_MOVE = k_EInputActionOrigin_Switch_RightStick_Move,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTSTICK_CLICK = k_EInputActionOrigin_Switch_RightStick_Click,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTSTICK_DPADNORTH = k_EInputActionOrigin_Switch_RightStick_DPadNorth,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTSTICK_DPADSOUTH = k_EInputActionOrigin_Switch_RightStick_DPadSouth,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTSTICK_DPADWEST = k_EInputActionOrigin_Switch_RightStick_DPadWest,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTSTICK_DPADEAST = k_EInputActionOrigin_Switch_RightStick_DPadEast,
	INPUT_ACTION_ORIGIN_SWITCH_DPAD_NORTH = k_EInputActionOrigin_Switch_DPad_North,
	INPUT_ACTION_ORIGIN_SWITCH_DPAD_SOUTH = k_EInputActionOrigin_Switch_DPad_South,
	INPUT_ACTION_ORIGIN_SWITCH_DPAD_WEST = k_EInputActionOrigin_Switch_DPad_West,
	INPUT_ACTION_ORIGIN_SWITCH_DPAD_EAST = k_EInputActionOrigin_Switch_DPad_East,
	INPUT_ACTION_ORIGIN_SWITCH_PROGYRO_MOVE = k_EInputActionOrigin_Switch_ProGyro_Move,
	INPUT_ACTION_ORIGIN_SWITCH_PROGYRO_PITCH = k_EInputActionOrigin_Switch_ProGyro_Pitch,
	INPUT_ACTION_ORIGIN_SWITCH_PROGYRO_YAW = k_EInputActionOrigin_Switch_ProGyro_Yaw,
	INPUT_ACTION_ORIGIN_SWITCH_PROGYRO_ROLL = k_EInputActionOrigin_Switch_ProGyro_Roll,
	INPUT_ACTION_ORIGIN_SWITCH_DPAD_MOVE = k_EInputActionOrigin_Switch_DPad_Move,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED1 = k_EInputActionOrigin_Switch_Reserved1,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED2 = k_EInputActionOrigin_Switch_Reserved2,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED3 = k_EInputActionOrigin_Switch_Reserved3,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED4 = k_EInputActionOrigin_Switch_Reserved4,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED5 = k_EInputActionOrigin_Switch_Reserved5,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED6 = k_EInputActionOrigin_Switch_Reserved6,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED7 = k_EInputActionOrigin_Switch_Reserved7,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED8 = k_EInputActionOrigin_Switch_Reserved8,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED9 = k_EInputActionOrigin_Switch_Reserved9,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED10 = k_EInputActionOrigin_Switch_Reserved10,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTGYRO_MOVE = k_EInputActionOrigin_Switch_RightGyro_Move,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTGYRO_PITCH = k_EInputActionOrigin_Switch_RightGyro_Pitch,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTGYRO_YAW = k_EInputActionOrigin_Switch_RightGyro_Yaw,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTGYRO_ROLL = k_EInputActionOrigin_Switch_RightGyro_Roll,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTGYRO_MOVE = k_EInputActionOrigin_Switch_LeftGyro_Move,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTGYRO_PITCH = k_EInputActionOrigin_Switch_LeftGyro_Pitch,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTGYRO_YAW = k_EInputActionOrigin_Switch_LeftGyro_Yaw,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTGYRO_ROLL = k_EInputActionOrigin_Switch_LeftGyro_Roll,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTGRIP_LOWER = k_EInputActionOrigin_Switch_LeftGrip_Lower,
	INPUT_ACTION_ORIGIN_SWITCH_LEFTGRIP_UPPER = k_EInputActionOrigin_Switch_LeftGrip_Upper,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTGRIP_LOWER = k_EInputActionOrigin_Switch_RightGrip_Lower,
	INPUT_ACTION_ORIGIN_SWITCH_RIGHTGRIP_UPPER = k_EInputActionOrigin_Switch_RightGrip_Upper,
	INPUT_ACTION_ORIGIN_SWITCH_JOYCON_BUTTON_N = k_EInputActionOrigin_Switch_JoyConButton_N,
	INPUT_ACTION_ORIGIN_SWITCH_JOYCON_BUTTON_E = k_EInputActionOrigin_Switch_JoyConButton_E,
	INPUT_ACTION_ORIGIN_SWITCH_JOYCON_BUTTON_S = k_EInputActionOrigin_Switch_JoyConButton_S,
	INPUT_ACTION_ORIGIN_SWITCH_JOYCON_BUTTON_W = k_EInputActionOrigin_Switch_JoyConButton_W,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED15 = k_EInputActionOrigin_Switch_Reserved15,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED16 = k_EInputActionOrigin_Switch_Reserved16,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED17 = k_EInputActionOrigin_Switch_Reserved17,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED18 = k_EInputActionOrigin_Switch_Reserved18,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED19 = k_EInputActionOrigin_Switch_Reserved19,
	INPUT_ACTION_ORIGIN_SWITCH_RESERVED20 = k_EInputActionOrigin_Switch_Reserved20,
	INPUT_ACTION_ORIGIN_PS5_X = k_EInputActionOrigin_PS5_X,
	INPUT_ACTION_ORIGIN_PS5_CIRCLE = k_EInputActionOrigin_PS5_Circle,
	INPUT_ACTION_ORIGIN_PS5_TRIANGLE = k_EInputActionOrigin_PS5_Triangle,
	INPUT_ACTION_ORIGIN_PS5_SQUARE = k_EInputActionOrigin_PS5_Square,
	INPUT_ACTION_ORIGIN_PS5_LEFTBUMPER = k_EInputActionOrigin_PS5_LeftBumper,
	INPUT_ACTION_ORIGIN_PS5_RIGHTBUMPER = k_EInputActionOrigin_PS5_RightBumper,
	INPUT_ACTION_ORIGIN_PS5_OPTION = k_EInputActionOrigin_PS5_Option,
	INPUT_ACTION_ORIGIN_PS5_CREATE = k_EInputActionOrigin_PS5_Create,
	INPUT_ACTION_ORIGIN_PS5_MUTE = k_EInputActionOrigin_PS5_Mute,
	INPUT_ACTION_ORIGIN_PS5_LEFTPAD_TOUCH = k_EInputActionOrigin_PS5_LeftPad_Touch,
	INPUT_ACTION_ORIGIN_PS5_LEFTPAD_SWIPE = k_EInputActionOrigin_PS5_LeftPad_Swipe,
	INPUT_ACTION_ORIGIN_PS5_LEFTPAD_CLICK = k_EInputActionOrigin_PS5_LeftPad_Click,
	INPUT_ACTION_ORIGIN_PS5_LEFTPAD_DPADNORTH = k_EInputActionOrigin_PS5_LeftPad_DPadNorth,
	INPUT_ACTION_ORIGIN_PS5_LEFTPAD_DPADSOUTH = k_EInputActionOrigin_PS5_LeftPad_DPadSouth,
	INPUT_ACTION_ORIGIN_PS5_LEFTPAD_DPADWEST = k_EInputActionOrigin_PS5_LeftPad_DPadWest,
	INPUT_ACTION_ORIGIN_PS5_LEFTPAD_DPADEAST = k_EInputActionOrigin_PS5_LeftPad_DPadEast,
	INPUT_ACTION_ORIGIN_PS5_RIGHTPAD_TOUCH = k_EInputActionOrigin_PS5_RightPad_Touch,
	INPUT_ACTION_ORIGIN_PS5_RIGHTPAD_SWIPE = k_EInputActionOrigin_PS5_RightPad_Swipe,
	INPUT_ACTION_ORIGIN_PS5_RIGHTPAD_CLICK = k_EInputActionOrigin_PS5_RightPad_Click,
	INPUT_ACTION_ORIGIN_PS5_RIGHTPAD_DPADNORTH = k_EInputActionOrigin_PS5_RightPad_DPadNorth,
	INPUT_ACTION_ORIGIN_PS5_RIGHTPAD_DPADSOUTH = k_EInputActionOrigin_PS5_RightPad_DPadSouth,
	INPUT_ACTION_ORIGIN_PS5_RIGHTPAD_DPADWEST = k_EInputActionOrigin_PS5_RightPad_DPadWest,
	INPUT_ACTION_ORIGIN_PS5_RIGHTPAD_DPADEAST = k_EInputActionOrigin_PS5_RightPad_DPadEast,
	INPUT_ACTION_ORIGIN_PS5_CENTERPAD_TOUCH = k_EInputActionOrigin_PS5_CenterPad_Touch,
	INPUT_ACTION_ORIGIN_PS5_CENTERPAD_SWIPE = k_EInputActionOrigin_PS5_CenterPad_Swipe,
	INPUT_ACTION_ORIGIN_PS5_CENTERPAD_CLICK = k_EInputActionOrigin_PS5_CenterPad_Click,
	INPUT_ACTION_ORIGIN_PS5_CENTERPAD_DPADNORTH = k_EInputActionOrigin_PS5_CenterPad_DPadNorth,
	INPUT_ACTION_ORIGIN_PS5_CENTERPAD_DPADSOUTH = k_EInputActionOrigin_PS5_CenterPad_DPadSouth,
	INPUT_ACTION_ORIGIN_PS5_CENTERPAD_DPADWEST = k_EInputActionOrigin_PS5_CenterPad_DPadWest,
	INPUT_ACTION_ORIGIN_PS5_CENTERPAD_DPADEAST = k_EInputActionOrigin_PS5_CenterPad_DPadEast,
	INPUT_ACTION_ORIGIN_PS5_LEFTTRIGGER_PULL = k_EInputActionOrigin_PS5_LeftTrigger_Pull,
	INPUT_ACTION_ORIGIN_PS5_LEFTTRIGGER_CLICK = k_EInputActionOrigin_PS5_LeftTrigger_Click,
	INPUT_ACTION_ORIGIN_PS5_RIGHTTRIGGER_PULL = k_EInputActionOrigin_PS5_RightTrigger_Pull,
	INPUT_ACTION_ORIGIN_PS5_RIGHTTRIGGER_CLICK = k_EInputActionOrigin_PS5_RightTrigger_Click,
	INPUT_ACTION_ORIGIN_PS5_LEFTSTICK_MOVE = k_EInputActionOrigin_PS5_LeftStick_Move,
	INPUT_ACTION_ORIGIN_PS5_LEFTSTICK_CLICK = k_EInputActionOrigin_PS5_LeftStick_Click,
	INPUT_ACTION_ORIGIN_PS5_LEFTSTICK_DPADNORTH = k_EInputActionOrigin_PS5_LeftStick_DPadNorth,
	INPUT_ACTION_ORIGIN_PS5_LEFTSTICK_DPADSOUTH = k_EInputActionOrigin_PS5_LeftStick_DPadSouth,
	INPUT_ACTION_ORIGIN_PS5_LEFTSTICK_DPADWEST = k_EInputActionOrigin_PS5_LeftStick_DPadWest,
	INPUT_ACTION_ORIGIN_PS5_LEFTSTICK_DPADEAST = k_EInputActionOrigin_PS5_LeftStick_DPadEast,
	INPUT_ACTION_ORIGIN_PS5_RIGHTSTICK_MOVE = k_EInputActionOrigin_PS5_RightStick_Move,
	INPUT_ACTION_ORIGIN_PS5_RIGHTSTICK_CLICK = k_EInputActionOrigin_PS5_RightStick_Click,
	INPUT_ACTION_ORIGIN_PS5_RIGHTSTICK_DPADNORTH = k_EInputActionOrigin_PS5_RightStick_DPadNorth,
	INPUT_ACTION_ORIGIN_PS5_RIGHTSTICK_DPADSOUTH = k_EInputActionOrigin_PS5_RightStick_DPadSouth,
	INPUT_ACTION_ORIGIN_PS5_RIGHTSTICK_DPADWEST = k_EInputActionOrigin_PS5_RightStick_DPadWest,
	INPUT_ACTION_ORIGIN_PS5_RIGHTSTICK_DPADEAST = k_EInputActionOrigin_PS5_RightStick_DPadEast,
	INPUT_ACTION_ORIGIN_PS5_DPAD_NORTH = k_EInputActionOrigin_PS5_DPad_North,
	INPUT_ACTION_ORIGIN_PS5_DPAD_SOUTH = k_EInputActionOrigin_PS5_DPad_South,
	INPUT_ACTION_ORIGIN_PS5_DPAD_WEST = k_EInputActionOrigin_PS5_DPad_West,
	INPUT_ACTION_ORIGIN_PS5_DPAD_EAST = k_EInputActionOrigin_PS5_DPad_East,
	INPUT_ACTION_ORIGIN_PS5_GYRO_MOVE = k_EInputActionOrigin_PS5_Gyro_Move,
	INPUT_ACTION_ORIGIN_PS5_GYRO_PITCH = k_EInputActionOrigin_PS5_Gyro_Pitch,
	INPUT_ACTION_ORIGIN_PS5_GYRO_YAW = k_EInputActionOrigin_PS5_Gyro_Yaw,
	INPUT_ACTION_ORIGIN_PS5_GYRO_ROLL = k_EInputActionOrigin_PS5_Gyro_Roll,
	INPUT_ACTION_ORIGIN_PS5_DPAD_MOVE = k_EInputActionOrigin_PS5_DPad_Move,
	INPUT_ACTION_ORIGIN_PS5_LEFTGRIP = k_EInputActionOrigin_PS5_LeftGrip,
	INPUT_ACTION_ORIGIN_PS5_RIGHTGRIP = k_EInputActionOrigin_PS5_RightGrip,
	INPUT_ACTION_ORIGIN_PS5_LEFTFN = k_EInputActionOrigin_PS5_LeftFn,
	INPUT_ACTION_ORIGIN_PS5_RIGHTFN = k_EInputActionOrigin_PS5_RightFn,
	INPUT_ACTION_ORIGIN_PS5_RESERVED5 = k_EInputActionOrigin_PS5_Reserved5,
	INPUT_ACTION_ORIGIN_PS5_RESERVED6 = k_EInputActionOrigin_PS5_Reserved6,
	INPUT_ACTION_ORIGIN_PS5_RESERVED7 = k_EInputActionOrigin_PS5_Reserved7,
	INPUT_ACTION_ORIGIN_PS5_RESERVED8 = k_EInputActionOrigin_PS5_Reserved8,
	INPUT_ACTION_ORIGIN_PS5_RESERVED9 = k_EInputActionOrigin_PS5_Reserved9,
	INPUT_ACTION_ORIGIN_PS5_RESERVED10 = k_EInputActionOrigin_PS5_Reserved10,
	INPUT_ACTION_ORIGIN_PS5_RESERVED11 = k_EInputActionOrigin_PS5_Reserved11,
	INPUT_ACTION_ORIGIN_PS5_RESERVED12 = k_EInputActionOrigin_PS5_Reserved12,
	INPUT_ACTION_ORIGIN_PS5_RESERVED13 = k_EInputActionOrigin_PS5_Reserved13,
	INPUT_ACTION_ORIGIN_PS5_RESERVED14 = k_EInputActionOrigin_PS5_Reserved14,
	INPUT_ACTION_ORIGIN_PS5_RESERVED15 = k_EInputActionOrigin_PS5_Reserved15,
	INPUT_ACTION_ORIGIN_PS5_RESERVED16 = k_EInputActionOrigin_PS5_Reserved16,
	INPUT_ACTION_ORIGIN_PS5_RESERVED17 = k_EInputActionOrigin_PS5_Reserved17,
	INPUT_ACTION_ORIGIN_PS5_RESERVED18 = k_EInputActionOrigin_PS5_Reserved18,
	INPUT_ACTION_ORIGIN_PS5_RESERVED19 = k_EInputActionOrigin_PS5_Reserved19,
	INPUT_ACTION_ORIGIN_PS5_RESERVED20 = k_EInputActionOrigin_PS5_Reserved20,
	INPUT_ACTION_ORIGIN_STEAMDECK_A = k_EInputActionOrigin_SteamDeck_A,
	INPUT_ACTION_ORIGIN_STEAMDECK_B = k_EInputActionOrigin_SteamDeck_B,
	INPUT_ACTION_ORIGIN_STEAMDECK_X = k_EInputActionOrigin_SteamDeck_X,
	INPUT_ACTION_ORIGIN_STEAMDECK_Y = k_EInputActionOrigin_SteamDeck_Y,
	INPUT_ACTION_ORIGIN_STEAMDECK_L1 = k_EInputActionOrigin_SteamDeck_L1,
	INPUT_ACTION_ORIGIN_STEAMDECK_R1 = k_EInputActionOrigin_SteamDeck_R1,
	INPUT_ACTION_ORIGIN_STEAMDECK_MENU = k_EInputActionOrigin_SteamDeck_Menu,
	INPUT_ACTION_ORIGIN_STEAMDECK_VIEW = k_EInputActionOrigin_SteamDeck_View,
	INPUT_ACTION_ORIGIN_STEAMDECK_LEFTPAD_TOUCH = k_EInputActionOrigin_SteamDeck_LeftPad_Touch,
	INPUT_ACTION_ORIGIN_STEAMDECK_LEFTPAD_SWIPE = k_EInputActionOrigin_SteamDeck_LeftPad_Swipe,
	INPUT_ACTION_ORIGIN_STEAMDECK_LEFTPAD_CLICK = k_EInputActionOrigin_SteamDeck_LeftPad_Click,
	INPUT_ACTION_ORIGIN_STEAMDECK_LEFTPAD_DPADNORTH = k_EInputActionOrigin_SteamDeck_LeftPad_DPadNorth,
	INPUT_ACTION_ORIGIN_STEAMDECK_LEFTPAD_DPADSOUTH = k_EInputActionOrigin_SteamDeck_LeftPad_DPadSouth,
	INPUT_ACTION_ORIGIN_STEAMDECK_LEFTPAD_DPADWEST = k_EInputActionOrigin_SteamDeck_LeftPad_DPadWest,
	INPUT_ACTION_ORIGIN_STEAMDECK_LEFTPAD_DPADEAST = k_EInputActionOrigin_SteamDeck_LeftPad_DPadEast,
	INPUT_ACTION_ORIGIN_STEAMDECK_RIGHTPAD_TOUCH = k_EInputActionOrigin_SteamDeck_RightPad_Touch,
	INPUT_ACTION_ORIGIN_STEAMDECK_RIGHTPAD_SWIPE = k_EInputActionOrigin_SteamDeck_RightPad_Swipe,
	INPUT_ACTION_ORIGIN_STEAMDECK_RIGHTPAD_CLICK = k_EInputActionOrigin_SteamDeck_RightPad_Click,
	INPUT_ACTION_ORIGIN_STEAMDECK_RIGHTPAD_DPADNORTH = k_EInputActionOrigin_SteamDeck_RightPad_DPadNorth,
	INPUT_ACTION_ORIGIN_STEAMDECK_RIGHTPAD_DPADSOUTH = k_EInputActionOrigin_SteamDeck_RightPad_DPadSouth,
	INPUT_ACTION_ORIGIN_STEAMDECK_RIGHTPAD_DPADWEST = k_EInputActionOrigin_SteamDeck_RightPad_DPadWest,
	INPUT_ACTION_ORIGIN_STEAMDECK_RIGHTPAD_DPADEAST = k_EInputActionOrigin_SteamDeck_RightPad_DPadEast,
	INPUT_ACTION_ORIGIN_STEAMDECK_L2_SOFTPULL = k_EInputActionOrigin_SteamDeck_L2_SoftPull,
	INPUT_ACTION_ORIGIN_STEAMDECK_L2 = k_EInputActionOrigin_SteamDeck_L2,
	INPUT_ACTION_ORIGIN_STEAMDECK_R2_SOFTPULL = k_EInputActionOrigin_SteamDeck_R2_SoftPull,
	INPUT_ACTION_ORIGIN_STEAMDECK_R2 = k_EInputActionOrigin_SteamDeck_R2,
	INPUT_ACTION_ORIGIN_STEAMDECK_LEFTSTICK_MOVE = k_EInputActionOrigin_SteamDeck_LeftStick_Move,
	INPUT_ACTION_ORIGIN_STEAMDECK_L3 = k_EInputActionOrigin_SteamDeck_L3,
	INPUT_ACTION_ORIGIN_STEAMDECK_LEFTSTICK_DPADNORTH = k_EInputActionOrigin_SteamDeck_LeftStick_DPadNorth,
	INPUT_ACTION_ORIGIN_STEAMDECK_LEFTSTICK_DPADSOUTH = k_EInputActionOrigin_SteamDeck_LeftStick_DPadSouth,
	INPUT_ACTION_ORIGIN_STEAMDECK_LEFTSTICK_DPADWEST = k_EInputActionOrigin_SteamDeck_LeftStick_DPadWest,
	INPUT_ACTION_ORIGIN_STEAMDECK_LEFTSTICK_DPADEAST = k_EInputActionOrigin_SteamDeck_LeftStick_DPadEast,
	INPUT_ACTION_ORIGIN_STEAMDECK_LEFTSTICK_TOUCH = k_EInputActionOrigin_SteamDeck_LeftStick_Touch,
	INPUT_ACTION_ORIGIN_STEAMDECK_RIGHTSTICK_MOVE = k_EInputActionOrigin_SteamDeck_RightStick_Move,
	INPUT_ACTION_ORIGIN_STEAMDECK_R3 = k_EInputActionOrigin_SteamDeck_R3,
	INPUT_ACTION_ORIGIN_STEAMDECK_RIGHTSTICK_DPADNORTH = k_EInputActionOrigin_SteamDeck_RightStick_DPadNorth,
	INPUT_ACTION_ORIGIN_STEAMDECK_RIGHTSTICK_DPADSOUTH = k_EInputActionOrigin_SteamDeck_RightStick_DPadSouth,
	INPUT_ACTION_ORIGIN_STEAMDECK_RIGHTSTICK_DPADWEST = k_EInputActionOrigin_SteamDeck_RightStick_DPadWest,
	INPUT_ACTION_ORIGIN_STEAMDECK_RIGHTSTICK_DPADEAST = k_EInputActionOrigin_SteamDeck_RightStick_DPadEast,
	INPUT_ACTION_ORIGIN_STEAMDECK_RIGHTSTICK_TOUCH = k_EInputActionOrigin_SteamDeck_RightStick_Touch,
	INPUT_ACTION_ORIGIN_STEAMDECK_L4 = k_EInputActionOrigin_SteamDeck_L4,
	INPUT_ACTION_ORIGIN_STEAMDECK_R4 = k_EInputActionOrigin_SteamDeck_R4,
	INPUT_ACTION_ORIGIN_STEAMDECK_L5 = k_EInputActionOrigin_SteamDeck_L5,
	INPUT_ACTION_ORIGIN_STEAMDECK_R5 = k_EInputActionOrigin_SteamDeck_R5,
	INPUT_ACTION_ORIGIN_STEAMDECK_DPAD_MOVE = k_EInputActionOrigin_SteamDeck_DPad_Move,
	INPUT_ACTION_ORIGIN_STEAMDECK_DPAD_NORTH = k_EInputActionOrigin_SteamDeck_DPad_North,
	INPUT_ACTION_ORIGIN_STEAMDECK_DPAD_SOUTH = k_EInputActionOrigin_SteamDeck_DPad_South,
	INPUT_ACTION_ORIGIN_STEAMDECK_DPAD_WEST = k_EInputActionOrigin_SteamDeck_DPad_West,
	INPUT_ACTION_ORIGIN_STEAMDECK_DPAD_EAST = k_EInputActionOrigin_SteamDeck_DPad_East,
	INPUT_ACTION_ORIGIN_STEAMDECK_GYRO_MOVE = k_EInputActionOrigin_SteamDeck_Gyro_Move,
	INPUT_ACTION_ORIGIN_STEAMDECK_GYRO_PITCH = k_EInputActionOrigin_SteamDeck_Gyro_Pitch,
	INPUT_ACTION_ORIGIN_STEAMDECK_GYRO_YAW = k_EInputActionOrigin_SteamDeck_Gyro_Yaw,
	INPUT_ACTION_ORIGIN_STEAMDECK_GYRO_ROLL = k_EInputActionOrigin_SteamDeck_Gyro_Roll,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED1 = k_EInputActionOrigin_SteamDeck_Reserved1,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED2 = k_EInputActionOrigin_SteamDeck_Reserved2,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED3 = k_EInputActionOrigin_SteamDeck_Reserved3,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED4 = k_EInputActionOrigin_SteamDeck_Reserved4,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED5 = k_EInputActionOrigin_SteamDeck_Reserved5,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED6 = k_EInputActionOrigin_SteamDeck_Reserved6,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED7 = k_EInputActionOrigin_SteamDeck_Reserved7,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED8 = k_EInputActionOrigin_SteamDeck_Reserved8,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED9 = k_EInputActionOrigin_SteamDeck_Reserved9,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED10 = k_EInputActionOrigin_SteamDeck_Reserved10,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED11 = k_EInputActionOrigin_SteamDeck_Reserved11,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED12 = k_EInputActionOrigin_SteamDeck_Reserved12,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED13 = k_EInputActionOrigin_SteamDeck_Reserved13,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED14 = k_EInputActionOrigin_SteamDeck_Reserved14,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED15 = k_EInputActionOrigin_SteamDeck_Reserved15,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED16 = k_EInputActionOrigin_SteamDeck_Reserved16,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED17 = k_EInputActionOrigin_SteamDeck_Reserved17,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED18 = k_EInputActionOrigin_SteamDeck_Reserved18,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED19 = k_EInputActionOrigin_SteamDeck_Reserved19,
	INPUT_ACTION_ORIGIN_STEAMDECK_RESERVED20 = k_EInputActionOrigin_SteamDeck_Reserved20,
	INPUT_ACTION_ORIGIN_HORIPAD_M1 = k_EInputActionOrigin_Horipad_M1,
	INPUT_ACTION_ORIGIN_HORIPAD_M2 = k_EInputActionOrigin_Horipad_M2,
	INPUT_ACTION_ORIGIN_HORIPAD_L4 = k_EInputActionOrigin_Horipad_L4,
	INPUT_ACTION_ORIGIN_HORIPAD_R4 = k_EInputActionOrigin_Horipad_R4,
	INPUT_ACTION_ORIGIN_COUNT = k_EInputActionOrigin_Count,
	INPUT_ACTION_ORIGIN_MAXIMUM_POSSIBLE_VALUE = k_EInputActionOrigin_MaximumPossibleValue
};

enum InputConfigurationEnableType {
	INPUT_CONFIGURATION_ENABLE_TYPE_NONE = k_ESteamInputConfigurationEnableType_None,
	INPUT_CONFIGURATION_ENABLE_TYPE_PLAYSTATION = k_ESteamInputConfigurationEnableType_Playstation,
	INPUT_CONFIGURATION_ENABLE_TYPE_XBOX = k_ESteamInputConfigurationEnableType_Xbox,
	INPUT_CONFIGURATION_ENABLE_TYPE_GENERIC = k_ESteamInputConfigurationEnableType_Generic,
	INPUT_CONFIGURATION_ENABLE_TYPE_SWITCH = k_ESteamInputConfigurationEnableType_Switch
};

enum InputGlyphSize {
	INPUT_GLYPH_SIZE_SMALL = k_ESteamInputGlyphSize_Small,
	INPUT_GLYPH_SIZE_MEDIUM = k_ESteamInputGlyphSize_Medium,
	INPUT_GLYPH_SIZE_LARGE = k_ESteamInputGlyphSize_Large,
	INPUT_GLYPH_SIZE_COUNT = k_ESteamInputGlyphSize_Count
};

enum InputGlyphStyle {
	INPUT_GLYPH_STYLE_KNOCKOUT = ESteamInputGlyphStyle_Knockout,
	INPUT_GLYPH_STYLE_LIGHT = ESteamInputGlyphStyle_Light,
	INPUT_GLYPH_STYLE_DARK = ESteamInputGlyphStyle_Dark,
	INPUT_GLYPH_STYLE_NEUTRAL_COLOR_ABXY = ESteamInputGlyphStyle_NeutralColorABXY,
	INPUT_GLYPH_STYLE_SOLID_ABXY = ESteamInputGlyphStyle_SolidABXY
};

enum InputLEDFlag {
	INPUT_LED_FLAG_SET_COLOR = k_ESteamInputLEDFlag_SetColor,
	INPUT_LED_FLAG_RESTORE_USER_DEFAULT = k_ESteamInputLEDFlag_RestoreUserDefault
};

enum InputSourceMode {
	INPUT_SOURCE_MODE_NONE = k_EInputSourceMode_None,
	INPUT_SOURCE_MODE_DPAD = k_EInputSourceMode_Dpad,
	INPUT_SOURCE_MODE_BUTTONS = k_EInputSourceMode_Buttons,
	INPUT_SOURCE_MODE_FOUR_BUTTONS = k_EInputSourceMode_FourButtons,
	INPUT_SOURCE_MODE_ABSOLUTE_MOUSE = k_EInputSourceMode_AbsoluteMouse,
	INPUT_SOURCE_MODE_RELATIVE_MOUSE = k_EInputSourceMode_RelativeMouse,
	INPUT_SOURCE_MODE_JOYSTICK_MOVE = k_EInputSourceMode_JoystickMove,
	INPUT_SOURCE_MODE_JOYSTICK_MOUSE = k_EInputSourceMode_JoystickMouse,
	INPUT_SOURCE_MODE_JOYSTICK_CAMERA = k_EInputSourceMode_JoystickCamera,
	INPUT_SOURCE_MODE_SCROLL_WHEEL = k_EInputSourceMode_ScrollWheel,
	INPUT_SOURCE_MODE_TRIGGER = k_EInputSourceMode_Trigger,
	INPUT_SOURCE_MODE_TOUCH_MENU = k_EInputSourceMode_TouchMenu,
	INPUT_SOURCE_MODE_MOUSE_JOYSTICK = k_EInputSourceMode_MouseJoystick,
	INPUT_SOURCE_MODE_MOUSE_REGION = k_EInputSourceMode_MouseRegion,
	INPUT_SOURCE_MODE_RADIAL_MENU = k_EInputSourceMode_RadialMenu,
	INPUT_SOURCE_MODE_SINGLE_BUTTON = k_EInputSourceMode_SingleButton,
	INPUT_SOURCE_MODE_SWITCH = k_EInputSourceMode_Switches
};

enum InputType {
	INPUT_TYPE_UNKNOWN = k_ESteamInputType_Unknown,
	INPUT_TYPE_STEAM_CONTROLLER = k_ESteamInputType_SteamController,
	INPUT_TYPE_XBOX360_CONTROLLER = k_ESteamInputType_XBox360Controller,
	INPUT_TYPE_XBOXONE_CONTROLLER = k_ESteamInputType_XBoxOneController,
	INPUT_TYPE_GENERIC_XINPUT = k_ESteamInputType_GenericGamepad,
	INPUT_TYPE_PS4_CONTROLLER = k_ESteamInputType_PS4Controller,
	INPUT_TYPE_APPLE_MFI_CONTROLLER = k_ESteamInputType_AppleMFiController,
	INPUT_TYPE_ANDROID_CONTROLLER = k_ESteamInputType_AndroidController,
	INPUT_TYPE_SWITCH_JOYCON_PAIR = k_ESteamInputType_SwitchJoyConPair,
	INPUT_TYPE_SWITCH_JOYCON_SINGLE = k_ESteamInputType_SwitchJoyConSingle,
	INPUT_TYPE_SWITCH_PRO_CONTROLLER = k_ESteamInputType_SwitchProController,
	INPUT_TYPE_MOBILE_TOUCH = k_ESteamInputType_MobileTouch,
	INPUT_TYPE_PS3_CONTROLLER = k_ESteamInputType_PS3Controller,
	INPUT_TYPE_PS5_CONTROLLER = k_ESteamInputType_PS5Controller,
	INPUT_TYPE_STEAM_DECK_CONTROLLER = k_ESteamInputType_SteamDeckController,
	INPUT_TYPE_COUNT = k_ESteamInputType_Count,
	INPUT_TYPE_MAXIMUM_POSSIBLE_VALUE = k_ESteamInputType_MaximumPossibleValue
};

enum SCEPadTriggerEffectMode {
	// Found in isteamdualsense.h
	PAD_TRIGGER_EFFECT_MODE_OFF = SCE_PAD_TRIGGER_EFFECT_MODE_OFF,
	PAD_TRIGGER_EFFECT_MODE_FEEDBACK = SCE_PAD_TRIGGER_EFFECT_MODE_FEEDBACK,
	PAD_TRIGGER_EFFECT_MODE_WEAPON = SCE_PAD_TRIGGER_EFFECT_MODE_WEAPON,
	PAD_TRIGGER_EFFECT_MODE_VIBRATION = SCE_PAD_TRIGGER_EFFECT_MODE_VIBRATION,
	PAD_TRIGGER_EFFECT_MODE_MULTIPLE_POSITION_FEEDBACK = SCE_PAD_TRIGGER_EFFECT_MODE_MULTIPLE_POSITION_FEEDBACK,
	PAD_TRIGGER_EFFECT_MODE_SLOPE_FEEDBACK = SCE_PAD_TRIGGER_EFFECT_MODE_SLOPE_FEEDBACK,
	PAD_TRIGGER_EFFECT_MODE_MULTIPLE_POSITION_VIBRATION = SCE_PAD_TRIGGER_EFFECT_MODE_MULTIPLE_POSITION_VIBRATION
};

enum XboxOrigin {
	XBOX_ORIGIN_A = k_EXboxOrigin_A,
	XBOX_ORIGIN_B = k_EXboxOrigin_B,
	XBOX_ORIGIN_X = k_EXboxOrigin_X,
	XBOX_ORIGIN_Y = k_EXboxOrigin_Y,
	XBOX_ORIGIN_LEFT_BUMPER = k_EXboxOrigin_LeftBumper,
	XBOX_ORIGIN_RIGHT_BUMPER = k_EXboxOrigin_RightBumper,
	XBOX_ORIGIN_MENU = k_EXboxOrigin_Menu,
	XBOX_ORIGIN_VIEW = k_EXboxOrigin_View,
	XBOX_ORIGIN_LEFT_TRIGGER_PULL = k_EXboxOrigin_LeftTrigger_Pull,
	XBOX_ORIGIN_LEFT_TRIGGER_CLICK = k_EXboxOrigin_LeftTrigger_Click,
	XBOX_ORIGIN_RIGHT_TRIGGER_PULL = k_EXboxOrigin_RightTrigger_Pull,
	XBOX_ORIGIN_RIGHT_TRIGGER_CLICK = k_EXboxOrigin_RightTrigger_Click,
	XBOX_ORIGIN_LEFT_STICK_MOVE = k_EXboxOrigin_LeftStick_Move,
	XBOX_ORIGIN_LEFT_STICK_CLICK = k_EXboxOrigin_LeftStick_Click,
	XBOX_ORIGIN_LEFT_STICK_DPAD_NORTH = k_EXboxOrigin_LeftStick_DPadNorth,
	XBOX_ORIGIN_LEFT_STICK_DPAD_SOUTH = k_EXboxOrigin_LeftStick_DPadSouth,
	XBOX_ORIGIN_LEFT_STICK_DPAD_WEST = k_EXboxOrigin_LeftStick_DPadWest,
	XBOX_ORIGIN_LEFT_STICK_DPAD_EAT = k_EXboxOrigin_LeftStick_DPadEast,
	XBOX_ORIGIN_RIGHT_STICK_MOVE = k_EXboxOrigin_RightStick_Move,
	XBOX_ORIGIN_RIGHT_STICK_CLICK = k_EXboxOrigin_RightStick_Click,
	XBOX_ORIGIN_RIGHT_STICK_DPAD_NORTH = k_EXboxOrigin_RightStick_DPadNorth,
	XBOX_ORIGIN_RIGHT_STICK_DPAD_SOUTH = k_EXboxOrigin_RightStick_DPadSouth,
	XBOX_ORIGIN_RIGHT_STICK_DPAD_WEST = k_EXboxOrigin_RightStick_DPadWest,
	XBOX_ORIGIN_RIGHT_STICK_DPAD_EAST = k_EXboxOrigin_RightStick_DPadEast,
	XBOX_ORIGIN_DPAD_NORTH = k_EXboxOrigin_DPad_North,
	XBOX_ORIGIN_DPAD_SOUTH = k_EXboxOrigin_DPad_South,
	XBOX_ORIGIN_DPAD_WEST = k_EXboxOrigin_DPad_West,
	XBOX_ORIGIN_DPAD_EAST = k_EXboxOrigin_DPad_East,
	XBOX_ORIGIN_COUNT = k_EXboxOrigin_Count
};


// Inventory enums
enum ItemFlags {
	STEAM_ITEM_NO_TRADE = k_ESteamItemNoTrade,
	STEAM_ITEM_REMOVED = k_ESteamItemRemoved,
	STEAM_ITEM_CONSUMED = k_ESteamItemConsumed
};


// Matchmaking enums
enum ChatMemberStateChange {
	CHAT_MEMBER_STATE_CHANGE_ENTERED = k_EChatMemberStateChangeEntered,
	CHAT_MEMBER_STATE_CHANGE_LEFT = k_EChatMemberStateChangeLeft,
	CHAT_MEMBER_STATE_CHANGE_DISCONNECTED = k_EChatMemberStateChangeDisconnected,
	CHAT_MEMBER_STATE_CHANGE_KICKED = k_EChatMemberStateChangeKicked,
	CHAT_MEMBER_STATE_CHANGE_BANNED = k_EChatMemberStateChangeBanned
};

enum LobbyComparison {
	LOBBY_COMPARISON_EQUAL_TO_OR_LESS_THAN = k_ELobbyComparisonEqualToOrLessThan,
	LOBBY_COMPARISON_LESS_THAN = k_ELobbyComparisonLessThan,
	LOBBY_COMPARISON_EQUAL = k_ELobbyComparisonEqual,
	LOBBY_COMPARISON_GREATER_THAN = k_ELobbyComparisonGreaterThan,
	LOBBY_COMPARISON_EQUAL_TO_GREATER_THAN = k_ELobbyComparisonEqualToOrGreaterThan,
	LOBBY_COMPARISON_NOT_EQUAL = k_ELobbyComparisonNotEqual
};

enum LobbyDistanceFilter {
	LOBBY_DISTANCE_FILTER_CLOSE = k_ELobbyDistanceFilterClose,
	LOBBY_DISTANCE_FILTER_DEFAULT = k_ELobbyDistanceFilterDefault,
	LOBBY_DISTANCE_FILTER_FAR = k_ELobbyDistanceFilterFar,
	LOBBY_DISTANCE_FILTER_WORLDWIDE = k_ELobbyDistanceFilterWorldwide
};

enum LobbyType {
	LOBBY_TYPE_PRIVATE = k_ELobbyTypePrivate,
	LOBBY_TYPE_FRIENDS_ONLY = k_ELobbyTypeFriendsOnly,
	LOBBY_TYPE_PUBLIC = k_ELobbyTypePublic,
	LOBBY_TYPE_INVISIBLE = k_ELobbyTypeInvisible,
	LOBBY_TYPE_PRIVATE_UNIQUE = k_ELobbyTypePrivateUnique

};


// Matchmaking Servers enums
enum MatchMakingServerResponse {
	// Found in matchmakingtypes.h
	SERVER_RESPONDED = eServerResponded,
	SERVER_FAILED_TO_RESPOND = eServerFailedToRespond,
	NO_SERVERS_LISTED_ON_MASTER_SERVER = eNoServersListedOnMasterServer
};


// Music enums
enum AudioPlaybackStatus {
	AUDIO_PLAYBACK_UNDEFINED = AudioPlayback_Undefined,
	AUDIO_PLAYBACK_PLAYING = AudioPlayback_Playing,
	AUDIO_PLAYBACK_PAUSED = AudioPlayback_Paused,
	AUDIO_PLAYBACK_IDLE = AudioPlayback_Idle
};


// Networking enums
enum P2PSend {
	P2P_SEND_UNRELIABLE = k_EP2PSendUnreliable,
	P2P_SEND_UNRELIABLE_NO_DELAY = k_EP2PSendUnreliableNoDelay,
	P2P_SEND_RELIABLE = k_EP2PSendReliable,
	P2P_SEND_RELIABLE_WITH_BUFFERING = k_EP2PSendReliableWithBuffering
};

enum P2PSessionError {
	P2P_SESSION_ERROR_NONE = k_EP2PSessionErrorNone,
	P2P_SESSION_ERROR_NOT_RUNNING_APP = k_EP2PSessionErrorNotRunningApp_DELETED,
	P2P_SESSION_ERROR_NO_RIGHTS_TO_APP = k_EP2PSessionErrorNoRightsToApp,
	P2P_SESSION_ERROR_DESTINATION_NOT_LOGGED_ON = k_EP2PSessionErrorDestinationNotLoggedIn_DELETED,
	P2P_SESSION_ERROR_TIMEOUT = k_EP2PSessionErrorTimeout,
	P2P_SESSION_ERROR_MAX = k_EP2PSessionErrorMax
};

enum SocketConnectionType {
	NET_SOCKET_CONNECTION_TYPE_NOT_CONNECTED = k_ESNetSocketConnectionTypeNotConnected,
	NET_SOCKET_CONNECTION_TYPE_UDP = k_ESNetSocketConnectionTypeUDP,
	NET_SOCKET_CONNECTION_TYPE_UDP_RELAY = k_ESNetSocketConnectionTypeUDPRelay
};

enum SocketState {
	NET_SOCKET_STATE_INVALID = k_ESNetSocketStateInvalid,
	NET_SOCKET_STATE_CONNECTED = k_ESNetSocketStateConnected,
	NET_SOCKET_STATE_INITIATED = k_ESNetSocketStateInitiated,
	NET_SOCKET_STATE_LOCAL_CANDIDATE_FOUND = k_ESNetSocketStateLocalCandidatesFound,
	NET_SOCKET_STATE_RECEIVED_REMOTE_CANDIDATES = k_ESNetSocketStateReceivedRemoteCandidates,
	NET_SOCKET_STATE_CHALLENGE_HANDSHAKE = k_ESNetSocketStateChallengeHandshake,
	NET_SOCKET_STATE_DISCONNECTING = k_ESNetSocketStateDisconnecting,
	NET_SOCKET_STATE_LOCAL_DISCONNECT = k_ESNetSocketStateLocalDisconnect,
	NET_SOCKET_STATE_TIMEOUT_DURING_CONNECT = k_ESNetSocketStateTimeoutDuringConnect,
	NET_SOCKET_STATE_REMOTE_END_DISCONNECTED = k_ESNetSocketStateRemoteEndDisconnected,
	NET_SOCKET_STATE_BROKEN = k_ESNetSocketStateConnectionBroken
};


// Networking Utils enums
enum NetworkingAvailability {
	// Found in steamnetworkingtypes.h
	NETWORKING_AVAILABILITY_CANNOT_TRY = k_ESteamNetworkingAvailability_CannotTry,
	NETWORKING_AVAILABILITY_FAILED = k_ESteamNetworkingAvailability_Failed,
	NETWORKING_AVAILABILITY_PREVIOUSLY = k_ESteamNetworkingAvailability_Previously,
	NETWORKING_AVAILABILITY_RETRYING = k_ESteamNetworkingAvailability_Retrying,
	NETWORKING_AVAILABILITY_NEVER_TRIED = k_ESteamNetworkingAvailability_NeverTried,
	NETWORKING_AVAILABILITY_WAITING = k_ESteamNetworkingAvailability_Waiting,
	NETWORKING_AVAILABILITY_ATTEMPTING = k_ESteamNetworkingAvailability_Attempting,
	NETWORKING_AVAILABILITY_CURRENT = k_ESteamNetworkingAvailability_Current,
	NETWORKING_AVAILABILITY_UNKNOWN = k_ESteamNetworkingAvailability_Unknown,
	NETWORKING_AVAILABILITY_FORCE_32BIT = k_ESteamNetworkingAvailability__Force32bit
};

enum NetworkingConfigDataType {
	// Found in steamnetworkingtypes.h
	NETWORKING_CONFIG_TYPE_INT32 = k_ESteamNetworkingConfig_Int32,
	NETWORKING_CONFIG_TYPE_INT64 = k_ESteamNetworkingConfig_Int64,
	NETWORKING_CONFIG_TYPE_FLOAT = k_ESteamNetworkingConfig_Float,
	NETWORKING_CONFIG_TYPE_STRING = k_ESteamNetworkingConfig_String,
	NETWORKING_CONFIG_TYPE_FUNCTION_PTR = k_ESteamNetworkingConfig_Ptr,
	NETWORKING_CONFIG_TYPE_FORCE_32BIT = k_ESteamNetworkingConfigDataType__Force32Bit
};

enum NetworkingConfigScope {
	// Found in steamnetworkingtypes.h
	NETWORKING_CONFIG_SCOPE_GLOBAL = k_ESteamNetworkingConfig_Global,
	NETWORKING_CONFIG_SCOPE_SOCKETS_INTERFACE = k_ESteamNetworkingConfig_SocketsInterface,
	NETWORKING_CONFIG_SCOPE_LISTEN_SOCKET = k_ESteamNetworkingConfig_ListenSocket,
	NETWORKING_CONFIG_SCOPE_CONNECTION = k_ESteamNetworkingConfig_Connection,
	NETWORKING_CONFIG_SCOPE_FORCE_32BIT = k_ESteamNetworkingConfigScope__Force32Bit
};

enum NetworkingConfigValue {
	// Found in steamnetworkingtypes.h
	NETWORKING_CONFIG_INVALID = k_ESteamNetworkingConfig_Invalid,
	NETWORKING_CONFIG_FAKE_PACKET_LOSS_SEND = k_ESteamNetworkingConfig_FakePacketLoss_Send,
	NETWORKING_CONFIG_FAKE_PACKET_LOSS_RECV = k_ESteamNetworkingConfig_FakePacketLoss_Recv,
	NETWORKING_CONFIG_FAKE_PACKET_LAG_SEND = k_ESteamNetworkingConfig_FakePacketLag_Send,
	NETWORKING_CONFIG_FAKE_PACKET_LAG_RECV = k_ESteamNetworkingConfig_FakePacketLag_Recv,
	NETWORKING_CONFIG_FAKE_PACKET_JITTER_SEND_AVG = k_ESteamNetworkingConfig_FakePacketJitter_Send_Avg,
	NETWORKING_CONFIG_FAKE_PACKET_JITTER_SEND_MAX = k_ESteamNetworkingConfig_FakePacketJitter_Send_Max,
	NETWORKING_CONFIG_FAKE_PACKET_JITTER_SEND_PCT = k_ESteamNetworkingConfig_FakePacketJitter_Send_Pct,
	NETWORKING_CONFIG_FAKE_PACKET_JITTER_RECV_AVG = k_ESteamNetworkingConfig_FakePacketJitter_Recv_Avg,
	NETWORKING_CONFIG_FAKE_PACKET_JITTER_RECV_MAX = k_ESteamNetworkingConfig_FakePacketJitter_Recv_Max,
	NETWORKING_CONFIG_FAKE_PACKET_JITTER_RECV_PCT = k_ESteamNetworkingConfig_FakePacketJitter_Recv_Pct,
	NETWORKING_CONFIG_FAKE_PACKET_REORDER_SEND = k_ESteamNetworkingConfig_FakePacketReorder_Send,
	NETWORKING_CONFIG_FAKE_PACKET_REORDER_RECV = k_ESteamNetworkingConfig_FakePacketReorder_Recv,
	NETWORKING_CONFIG_FAKE_PACKET_REORDER_TIME = k_ESteamNetworkingConfig_FakePacketReorder_Time,
	NETWORKING_CONFIG_FAKE_PACKET_DUP_SEND = k_ESteamNetworkingConfig_FakePacketDup_Send,
	NETWORKING_CONFIG_FAKE_PACKET_DUP_REVC = k_ESteamNetworkingConfig_FakePacketDup_Recv,
	NETWORKING_CONFIG_FAKE_PACKET_DUP_TIME_MAX = k_ESteamNetworkingConfig_FakePacketDup_TimeMax,
	NETWORKING_CONFIG_PACKET_TRACE_MAX_BYTES = k_ESteamNetworkingConfig_PacketTraceMaxBytes,
	NETWORKING_CONFIG_FAKE_RATE_LIMIT_SEND_RATE = k_ESteamNetworkingConfig_FakeRateLimit_Send_Rate,
	NETWORKING_CONFIG_FAKE_RATE_LIMIT_SEND_BURST = k_ESteamNetworkingConfig_FakeRateLimit_Send_Burst,
	NETWORKING_CONFIG_FAKE_RATE_LIMIT_RECV_RATE = k_ESteamNetworkingConfig_FakeRateLimit_Recv_Rate,
	NETWORKING_CONFIG_FAKE_RATE_LIMIT_RECV_BURST = k_ESteamNetworkingConfig_FakeRateLimit_Recv_Burst,
	NETWORKING_CONFIG_OUT_OF_ORDER_CORRECTION_WINDOW_MICROSECONDS = k_ESteamNetworkingConfig_OutOfOrderCorrectionWindowMicroseconds,
	NETWORKING_CONFIG_CONNECTION_USER_DATA = k_ESteamNetworkingConfig_ConnectionUserData,
	NETWORKING_CONFIG_TIMEOUT_INITIAL = k_ESteamNetworkingConfig_TimeoutInitial,
	NETWORKING_CONFIG_TIMEOUT_CONNECTED = k_ESteamNetworkingConfig_TimeoutConnected,
	NETWORKING_CONFIG_SEND_BUFFER_SIZE = k_ESteamNetworkingConfig_SendBufferSize,
	NETWORKING_CONFIG_RECV_BUFFER_SIZE = k_ESteamNetworkingConfig_RecvBufferSize,
	NETWORKING_CONFIG_RECV_BUFFER_MESSAGES = k_ESteamNetworkingConfig_RecvBufferMessages,
	NETWORKING_CONFIG_RECV_MAX_MESSAGE_SIZE = k_ESteamNetworkingConfig_RecvMaxMessageSize,
	NETWORKING_CONFIG_RECV_MAX_SEGMENTS_PER_PACKET = k_ESteamNetworkingConfig_RecvMaxSegmentsPerPacket,
	NETWORKING_CONFIG_SEND_RATE_MIN = k_ESteamNetworkingConfig_SendRateMin,
	NETWORKING_CONFIG_SEND_RATE_MAX = k_ESteamNetworkingConfig_SendRateMax,
	NETWORKING_CONFIG_NAGLE_TIME = k_ESteamNetworkingConfig_NagleTime,
	NETWORKING_CONFIG_IP_ALLOW_WITHOUT_AUTH = k_ESteamNetworkingConfig_IP_AllowWithoutAuth,
	NETWORKING_CONFIG_IP_LOCAL_HOST_ALLOW_WITHOUT_AUTH = k_ESteamNetworkingConfig_IPLocalHost_AllowWithoutAuth,
	NETWORKING_CONFIG_MTU_PACKET_SIZE = k_ESteamNetworkingConfig_MTU_PacketSize,
	NETWORKING_CONFIG_MTU_DATA_SIZE = k_ESteamNetworkingConfig_MTU_DataSize,
	NETWORKING_CONFIG_UNENCRYPTED = k_ESteamNetworkingConfig_Unencrypted,
	NETWORKING_CONFIG_SYMMETRIC_CONNECT = k_ESteamNetworkingConfig_SymmetricConnect,
	NETWORKING_CONFIG_LOCAL_VIRTUAL_PORT = k_ESteamNetworkingConfig_LocalVirtualPort,
	NETWORKING_CONFIG_DUAL_WIFI_ENABLE = k_ESteamNetworkingConfig_DualWifi_Enable,
	NETWORKING_CONFIG_ENABLE_DIAGNOSTICS_UI = k_ESteamNetworkingConfig_EnableDiagnosticsUI,
	NETWORKING_CONFIG_SEND_TIME_SINCE_PREVIOUS_PACKET = k_ESteamNetworkingConfig_SendTimeSincePreviousPacket,
	NETWORKING_CONFIG_SDR_CLIENT_CONSEC_PING_TIMEOUT_FAIL_INITIAL = k_ESteamNetworkingConfig_SDRClient_ConsecutitivePingTimeoutsFailInitial,
	NETWORKING_CONFIG_SDR_CLIENT_CONSEC_PING_TIMEOUT_FAIL = k_ESteamNetworkingConfig_SDRClient_ConsecutitivePingTimeoutsFail,
	NETWORKING_CONFIG_SDR_CLIENT_MIN_PINGS_BEFORE_PING_ACCURATE = k_ESteamNetworkingConfig_SDRClient_MinPingsBeforePingAccurate,
	NETWORKING_CONFIG_SDR_CLIENT_SINGLE_SOCKET = k_ESteamNetworkingConfig_SDRClient_SingleSocket,
	NETWORKING_CONFIG_SDR_CLIENT_FORCE_RELAY_CLUSTER = k_ESteamNetworkingConfig_SDRClient_ForceRelayCluster,
	NETWORKING_CONFIG_SDR_CLIENT_DEV_TICKET = k_ESteamNetworkingConfig_SDRClient_DevTicket,
	NETWORKING_CONFIG_SDR_CLIENT_FORCE_PROXY_ADDR = k_ESteamNetworkingConfig_SDRClient_ForceProxyAddr,
	NETWORKING_CONFIG_SDR_CLIENT_FAKE_CLUSTER_PING = k_ESteamNetworkingConfig_SDRClient_FakeClusterPing,
	NETWORKING_CONFIG_SDR_CLIENT_LIMIT_PING_PROBES_TO_NEAREST_N = k_ESteamNetworkingConfig_SDRClient_LimitPingProbesToNearestN,
	NETWORKING_CONFIG_LOG_LEVEL_ACK_RTT = k_ESteamNetworkingConfig_LogLevel_AckRTT,
	NETWORKING_CONFIG_LOG_LEVEL_PACKET_DECODE = k_ESteamNetworkingConfig_LogLevel_PacketDecode,
	NETWORKING_CONFIG_LOG_LEVEL_MESSAGE = k_ESteamNetworkingConfig_LogLevel_Message,
	NETWORKING_CONFIG_LOG_LEVEL_PACKET_GAPS = k_ESteamNetworkingConfig_LogLevel_PacketGaps,
	NETWORKING_CONFIG_LOG_LEVEL_P2P_RENDEZVOUS = k_ESteamNetworkingConfig_LogLevel_P2PRendezvous,
	NETWORKING_CONFIG_LOG_LEVEL_SRD_RELAY_PINGS = k_ESteamNetworkingConfig_LogLevel_SDRRelayPings,
	NETWORKING_CONFIG_CALLBACK_CONNECTION_STATUS_CHANGED = k_ESteamNetworkingConfig_Callback_ConnectionStatusChanged,
	NETWORKING_CONFIG_CALLBACK_AUTH_STATUS_CHANGED = k_ESteamNetworkingConfig_Callback_AuthStatusChanged,
	NETWORKING_CONFIG_CALLBACK_RELAY_NETWORK_STATUS_CHANGED = k_ESteamNetworkingConfig_Callback_RelayNetworkStatusChanged,
	NETWORKING_CONFIG_CALLBACK_MESSAGE_SESSION_REQUEST = k_ESteamNetworkingConfig_Callback_MessagesSessionRequest,
	NETWORKING_CONFIG_CALLBACK_MESSAGES_SESSION_FAILED = k_ESteamNetworkingConfig_Callback_MessagesSessionFailed,
	NETWORKING_CONFIG_CALLBACK_CREATE_CONNECTION_SIGNALING = k_ESteamNetworkingConfig_Callback_CreateConnectionSignaling,
	NETWORKING_CONFIG_CALLBACK_FAKE_IP_RESULT = k_ESteamNetworkingConfig_Callback_FakeIPResult,
	NETWORKING_CONFIG_P2P_STUN_SERVER_LIST = k_ESteamNetworkingConfig_P2P_STUN_ServerList,
	NETWORKING_CONFIG_P2P_TRANSPORT_ICE_ENABLE = k_ESteamNetworkingConfig_P2P_Transport_ICE_Enable,
	NETWORKING_CONFIG_P2P_TRANSPORT_ICE_PENALTY = k_ESteamNetworkingConfig_P2P_Transport_ICE_Penalty,
	NETWORKING_CONFIG_P2P_TRANSPORT_SDR_PENALTY = k_ESteamNetworkingConfig_P2P_Transport_SDR_Penalty,
	NETWORKING_CONFIG_P2P_TURN_SERVER_LIST = k_ESteamNetworkingConfig_P2P_TURN_ServerList,
	NETWORKING_CONFIG_P2P_TURN_USER_LIST = k_ESteamNetworkingConfig_P2P_TURN_UserList,
	NETWORKING_CONFIG_P2P_TURN_PASS_LIST = k_ESteamNetworkingConfig_P2P_TURN_PassList,
	NETWORKING_CONFIG_P2P_TRANSPORT_ICE_IMPLEMENTATION = k_ESteamNetworkingConfig_P2P_Transport_ICE_Implementation,
	NETWORKING_CONFIG_ECN = k_ESteamNetworkingConfig_ECN,
	NETWORKING_CONFIG_VALUE_FORCE32BIT = k_ESteamNetworkingConfigValue__Force32Bit
};

enum NetworkingConnectionEnd {
	// Found in steamnetworkingtypes.h
	CONNECTION_END_INVALID = k_ESteamNetConnectionEnd_Invalid,
	CONNECTION_END_APP_MIN = k_ESteamNetConnectionEnd_App_Min,
	CONNECTION_END_APP_GENERIC = k_ESteamNetConnectionEnd_App_Generic,
	CONNECTION_END_APP_MAX = k_ESteamNetConnectionEnd_App_Max,
	CONNECTION_END_APP_EXCEPTION_MIN = k_ESteamNetConnectionEnd_AppException_Min,
	CONNECTION_END_APP_EXCEPTION_GENERIC = k_ESteamNetConnectionEnd_AppException_Generic,
	CONNECTION_END_APP_EXCEPTION_MAX = k_ESteamNetConnectionEnd_AppException_Max,
	CONNECTION_END_LOCAL_MIN = k_ESteamNetConnectionEnd_Local_Min,
	CONNECTION_END_LOCAL_OFFLINE_MODE = k_ESteamNetConnectionEnd_Local_OfflineMode,
	CONNECTION_END_LOCAL_MANY_RELAY_CONNECTIVITY = k_ESteamNetConnectionEnd_Local_ManyRelayConnectivity,
	CONNECTION_END_LOCAL_HOSTED_SERVER_PRIMARY_RELAY = k_ESteamNetConnectionEnd_Local_HostedServerPrimaryRelay,
	CONNECTION_END_LOCAL_NETWORK_CONFIG = k_ESteamNetConnectionEnd_Local_NetworkConfig,
	CONNECTION_END_LOCAL_RIGHTS = k_ESteamNetConnectionEnd_Local_Rights,
	CONNECTION_END_NO_PUBLIC_ADDRESS = k_ESteamNetConnectionEnd_Local_P2P_ICE_NoPublicAddresses,
	CONNECTION_END_LOCAL_MAX = k_ESteamNetConnectionEnd_Local_Max,
	CONNECTION_END_REMOVE_MIN = k_ESteamNetConnectionEnd_Remote_Min,
	CONNECTION_END_REMOTE_TIMEOUT = k_ESteamNetConnectionEnd_Remote_Timeout,
	CONNECTION_END_REMOTE_BAD_CRYPT = k_ESteamNetConnectionEnd_Remote_BadCrypt,
	CONNECTION_END_REMOTE_BAD_CERT = k_ESteamNetConnectionEnd_Remote_BadCert,
	CONNECTION_END_BAD_PROTOCOL_VERSION = k_ESteamNetConnectionEnd_Remote_BadProtocolVersion,
	CONNECTION_END_REMOTE_P2P_ICE_NO_PUBLIC_ADDRESSES = k_ESteamNetConnectionEnd_Remote_P2P_ICE_NoPublicAddresses,
	CONNECTION_END_REMOTE_MAX = k_ESteamNetConnectionEnd_Remote_Max,
	CONNECTION_END_MISC_MIN = k_ESteamNetConnectionEnd_Misc_Min,
	CONNECTION_END_MISC_GENERIC = k_ESteamNetConnectionEnd_Misc_Generic,
	CONNECTION_END_MISC_INTERNAL_ERROR = k_ESteamNetConnectionEnd_Misc_InternalError,
	CONNECTION_END_MISC_TIMEOUT = k_ESteamNetConnectionEnd_Misc_Timeout,
	CONNECTION_END_MISC_STEAM_CONNECTIVITY = k_ESteamNetConnectionEnd_Misc_SteamConnectivity,
	CONNECTION_END_MISC_NO_RELAY_SESSIONS_TO_CLIENT = k_ESteamNetConnectionEnd_Misc_NoRelaySessionsToClient,
	CONNECTION_END_MISC_P2P_RENDEZVOUS = k_ESteamNetConnectionEnd_Misc_P2P_Rendezvous,
	CONNECTION_END_MISC_P2P_NAT_FIREWALL = k_ESteamNetConnectionEnd_Misc_P2P_NAT_Firewall,
	CONNECTION_END_MISC_PEER_SENT_NO_CONNECTION = k_ESteamNetConnectionEnd_Misc_PeerSentNoConnection,
	CONNECTION_END_MISC_MAX = k_ESteamNetConnectionEnd_Misc_Max,
	CONNECTION_END_FORCE32BIT = k_ESteamNetConnectionEnd__Force32Bit
};

enum NetworkingConnectionState {
	// Found in steamnetworkingtypes.h
	CONNECTION_STATE_NONE = k_ESteamNetworkingConnectionState_None,
	CONNECTION_STATE_CONNECTING = k_ESteamNetworkingConnectionState_Connecting,
	CONNECTION_STATE_FINDING_ROUTE = k_ESteamNetworkingConnectionState_FindingRoute,
	CONNECTION_STATE_CONNECTED = k_ESteamNetworkingConnectionState_Connected,
	CONNECTION_STATE_CLOSED_BY_PEER = k_ESteamNetworkingConnectionState_ClosedByPeer,
	CONNECTION_STATE_PROBLEM_DETECTED_LOCALLY = k_ESteamNetworkingConnectionState_ProblemDetectedLocally,
	CONNECTION_STATE_FIN_WAIT = k_ESteamNetworkingConnectionState_FinWait,
	CONNECTION_STATE_LINGER = k_ESteamNetworkingConnectionState_Linger,
	CONNECTION_STATE_DEAD = k_ESteamNetworkingConnectionState_Dead,
	CONNECTION_STATE_FORCE_32BIT = k_ESteamNetworkingConnectionState__Force32Bit
};

enum NetworkingFakeIPType {
	// Found in steamnetworkingtypes.h
	FAKE_IP_TYPE_INVALID = k_ESteamNetworkingFakeIPType_Invalid,
	FAKE_IP_TYPE_NOT_FAKE = k_ESteamNetworkingFakeIPType_NotFake,
	FAKE_IP_TYPE_GLOBAL_IPV4 = k_ESteamNetworkingFakeIPType_GlobalIPv4,
	FAKE_IP_TYPE_LOCAL_IPV4 = k_ESteamNetworkingFakeIPType_LocalIPv4,
	FAKE_IP_TYPE_FORCE32BIT = k_ESteamNetworkingFakeIPType__Force32Bit
};

enum NetworkingGetConfigValueResult {
	// Found in steamnetworkingtypes.h
	NETWORKING_GET_CONFIG_VALUE_BAD_VALUE = k_ESteamNetworkingGetConfigValue_BadValue,
	NETWORKING_GET_CONFIG_VALUE_BAD_SCOPE_OBJ = k_ESteamNetworkingGetConfigValue_BadScopeObj,
	NETWORKING_GET_CONFIG_VALUE_BUFFER_TOO_SMALL = k_ESteamNetworkingGetConfigValue_BufferTooSmall,
	NETWORKING_GET_CONFIG_VALUE_OK = k_ESteamNetworkingGetConfigValue_OK,
	NETWORKING_GET_CONFIG_VALUE_OK_INHERITED = k_ESteamNetworkingGetConfigValue_OKInherited,
	NETWORKING_GET_CONFIG_VALUE_FORCE_32BIT = k_ESteamNetworkingGetConfigValueResult__Force32Bit
};

enum NetworkingIdentityType {
	// Found in steamnetworkingtypes.h
	IDENTITY_TYPE_INVALID = k_ESteamNetworkingIdentityType_Invalid,
	IDENTITY_TYPE_STEAMID = k_ESteamNetworkingIdentityType_SteamID,
	IDENTITY_TYPE_IP_ADDRESS = k_ESteamNetworkingIdentityType_IPAddress,
	IDENTITY_TYPE_GENERIC_STRING = k_ESteamNetworkingIdentityType_GenericString,
	IDENTITY_TYPE_GENERIC_BYTES = k_ESteamNetworkingIdentityType_GenericBytes,
	IDENTITY_TYPE_UNKNOWN_TYPE = k_ESteamNetworkingIdentityType_UnknownType,
	IDENTITY_TYPE_XBOX_PAIRWISE = k_ESteamNetworkingIdentityType_XboxPairwiseID,
	IDENTITY_TYPE_SONY_PSN = k_ESteamNetworkingIdentityType_SonyPSN,
	IDENTITY_TYPE_FORCE_32BIT = k_ESteamNetworkingIdentityType__Force32bit
};

enum NetworkingSocketsDebugOutputType {
	// Found in steamnetworkingtypes.h
	NETWORKING_SOCKET_DEBUG_OUTPUT_TYPE_NONE = k_ESteamNetworkingSocketsDebugOutputType_None,
	NETWORKING_SOCKET_DEBUG_OUTPUT_TYPE_BUG = k_ESteamNetworkingSocketsDebugOutputType_Bug,
	NETWORKING_SOCKET_DEBUG_OUTPUT_TYPE_ERROR = k_ESteamNetworkingSocketsDebugOutputType_Error,
	NETWORKING_SOCKET_DEBUG_OUTPUT_TYPE_IMPORTANT = k_ESteamNetworkingSocketsDebugOutputType_Important,
	NETWORKING_SOCKET_DEBUG_OUTPUT_TYPE_WARNING = k_ESteamNetworkingSocketsDebugOutputType_Warning,
	NETWORKING_SOCKET_DEBUG_OUTPUT_TYPE_MSG = k_ESteamNetworkingSocketsDebugOutputType_Msg,
	NETWORKING_SOCKET_DEBUG_OUTPUT_TYPE_VERBOSE = k_ESteamNetworkingSocketsDebugOutputType_Verbose,
	NETWORKING_SOCKET_DEBUG_OUTPUT_TYPE_DEBUG = k_ESteamNetworkingSocketsDebugOutputType_Debug,
	NETWORKING_SOCKET_DEBUG_OUTPUT_TYPE_EVERYTHING = k_ESteamNetworkingSocketsDebugOutputType_Everything,
	NETWORKING_SOCKET_DEBUG_OUTPUT_TYPE_FORCE_32BIT = k_ESteamNetworkingSocketsDebugOutputType__Force32Bit
};


// Parental Settings enums
enum ParentalFeature {
	// Found in isteamparentalsettings.h
	FEATURE_INVALID = k_EFeatureInvalid,
	FEATURE_STORE = k_EFeatureStore,
	FEATURE_COMMUNITY = k_EFeatureCommunity,
	FEATURE_PROFILE = k_EFeatureProfile,
	FEATURE_FRIENDS = k_EFeatureFriends,
	FEATURE_NEWS = k_EFeatureNews,
	FEATURE_TRADING = k_EFeatureTrading,
	FEATURE_SETTINGS = k_EFeatureSettings,
	FEATURE_CONSOLE = k_EFeatureConsole,
	FEATURE_BROWSER = k_EFeatureBrowser,
	FEATURE_PARENTAL_SETUP = k_EFeatureParentalSetup,
	FEATURE_LIBRARY = k_EFeatureLibrary,
	FEATURE_TEST = k_EFeatureTest,
	FEATURE_SITE_LICENSE = k_EFeatureSiteLicense,
	FEATURE_KIOSK_MODE = k_EFeatureKioskMode_Deprecated,
	FEATURE_BLOCK_ALWAYS = k_EFeatureBlockAlways,
	FEATURE_MAX = k_EFeatureMax
};


// Steam Parties enums
enum PartyBeaconLocationData {
	// Found in isteammatchmaking.h
	STEAM_PARTY_BEACON_LOCATION_DATA_INVALID = k_ESteamPartyBeaconLocationDataInvalid,
	STEAM_PARTY_BEACON_LOCATION_DATA_NAME = k_ESteamPartyBeaconLocationDataName,
	STEAM_PARTY_BEACON_LOCATION_DATA_URL_SMALL = k_ESteamPartyBeaconLocationDataIconURLSmall,
	STEAM_PARTY_BEACON_LOCATION_DATA_URL_MEDIUM = k_ESteamPartyBeaconLocationDataIconURLMedium,
	STEAM_PARTY_BEACON_LOCATION_DATA_URL_LARGE = k_ESteamPartyBeaconLocationDataIconURLLarge
};
enum PartyBeaconLocationType {
	// Found in isteammatchmaking.h
	STEAM_PARTY_BEACON_LOCATION_TYPE_INVALID = k_ESteamPartyBeaconLocationType_Invalid,
	STEAM_PARTY_BEACON_LOCATION_TYPE_CHAT_GROUP = k_ESteamPartyBeaconLocationType_ChatGroup,
	STEAM_PARTY_BEACON_LOCATION_TYPE_MAX = k_ESteamPartyBeaconLocationType_Max
};


// Remote Play enums
enum DeviceFormFactor {
	// Found in isteamremoteplay.h
	FORM_FACTOR_UNKNOWN = k_ESteamDeviceFormFactorUnknown,
	FORM_FACTOR_PHONE = k_ESteamDeviceFormFactorPhone,
	FORM_FACTOR_TABLET = k_ESteamDeviceFormFactorTablet,
	FORM_FACTOR_COMPUTER = k_ESteamDeviceFormFactorComputer,
	FORM_FACTOR_TV = k_ESteamDeviceFormFactorTV,
	FORM_FACTOR_VR_HEADSET = k_ESteamDeviceFormFactorVRHeadset
};

enum RemotePlayInputType {
	// Found in isteamremoteplay.h
	REMOTE_PLAY_INPUT_UNKNOWN = k_ERemotePlayInputUnknown,
	REMOTE_PLAY_INPUT_MOUSE_MOTION = k_ERemotePlayInputMouseMotion,
	REMOTE_PLAY_INPUT_MOUSE_BUTTON_DOWN = k_ERemotePlayInputMouseButtonDown,
	REMOTE_PLAY_INPUT_MOUSE_BUTTON_UP = k_ERemotePlayInputMouseButtonUp,
	REMOTE_PLAY_INPUT_MOUSE_WHEEL = k_ERemotePlayInputMouseWheel,
	REMOTE_PLAY_INPUT_KEY_DOWN = k_ERemotePlayInputKeyDown,
	REMOTE_PLAY_INPUT_KEY_UP = k_ERemotePlayInputKeyUp
};

enum RemotePlayKeyModifier {
	// Found in isteamremoteplay.h
	REMOTE_PLAY_KEY_MODIFIER_NONE = k_ERemotePlayKeyModifierNone,
	REMOTE_PLAY_KEY_MODIFIER_LEFT_SHIFT = k_ERemotePlayKeyModifierLeftShift,
	REMOTE_PLAY_KEY_MODIFIER_RIGHT_SHIFT = k_ERemotePlayKeyModifierRightShift,
	REMOTE_PLAY_KEY_MODIFIER_LEFT_CONTROL = k_ERemotePlayKeyModifierLeftControl,
	REMOTE_PLAY_KEY_MODIFIER_RIGHT_CONTROL = k_ERemotePlayKeyModifierRightControl,
	REMOTE_PLAY_KEY_MODIFIER_LEFT_ALT = k_ERemotePlayKeyModifierLeftAlt,
	REMOTE_PLAY_KEY_MODIFIER_RIGHT_ALT = k_ERemotePlayKeyModifierRightAlt,
	REMOTE_PLAY_KEY_MODIFIER_LEFT_GUI = k_ERemotePlayKeyModifierLeftGUI,
	REMOTE_PLAY_KEY_MODIFIER_RIGHT_GUI = k_ERemotePlayKeyModifierRightGUI,
	REMOTE_PLAY_KEY_MODIFIER_NUM_LOCK = k_ERemotePlayKeyModifierNumLock,
	REMOTE_PLAY_KEY_MODIFIER_CAPS_LOCK = k_ERemotePlayKeyModifierCapsLock,
	REMOTE_PLAY_KEY_MODIFIER_MASK = k_ERemotePlayKeyModifierMask
};

enum RemotePlayMouseButton {
	// Found in isteamremoteplay.h
	REMOTE_PLAY_MOUSE_BUTTON_LEFT = k_ERemotePlayMouseButtonLeft,
	REMOTE_PLAY_MOUSE_BUTTON_RIGHT = k_ERemotePlayMouseButtonRight,
	REMOTE_PLAY_MOUSE_BUTTON_MIDDLE = k_ERemotePlayMouseButtonMiddle,
	REMOTE_PLAY_MOUSE_BUTTON_X1 = k_ERemotePlayMouseButtonX1,
	REMOTE_PLAY_MOUSE_BUTTON_X2 = k_ERemotePlayMouseButtonX2
};

enum RemotePlayMouseWheelDirection {
	// Found in isteamremoteplay.h
	REMOTE_PLAY_MOUSE_WHEEL_UP = k_ERemotePlayMouseWheelUp,
	REMOTE_PLAY_MOUSE_WHEEL_DOWN = k_ERemotePlayMouseWheelDown,
	REMOTE_PLAY_MOUSE_WHEEL_LEFT = k_ERemotePlayMouseWheelLeft,
	REMOTE_PLAY_MOUSE_WHEEL_RIGHT = k_ERemotePlayMouseWheelRight
};

enum RemotePlayScancode {
	// Found in isteamremoteplay.h
	REMOTE_PLAYER_SCANCODE_UNKNOWN = k_ERemotePlayScancodeUnknown,
	REMOTE_PLAYER_SCANCODE_A = k_ERemotePlayScancodeA,
	REMOTE_PLAYER_SCANCODE_B = k_ERemotePlayScancodeB,
	REMOTE_PLAYER_SCANCODE_C = k_ERemotePlayScancodeC,
	REMOTE_PLAYER_SCANCODE_D = k_ERemotePlayScancodeD,
	REMOTE_PLAYER_SCANCODE_E = k_ERemotePlayScancodeE,
	REMOTE_PLAYER_SCANCODE_F = k_ERemotePlayScancodeF,
	REMOTE_PLAYER_SCANCODE_G = k_ERemotePlayScancodeG,
	REMOTE_PLAYER_SCANCODE_H = k_ERemotePlayScancodeH,
	REMOTE_PLAYER_SCANCODE_I = k_ERemotePlayScancodeI,
	REMOTE_PLAYER_SCANCODE_J = k_ERemotePlayScancodeJ,
	REMOTE_PLAYER_SCANCODE_K = k_ERemotePlayScancodeK,
	REMOTE_PLAYER_SCANCODE_L = k_ERemotePlayScancodeL,
	REMOTE_PLAYER_SCANCODE_M = k_ERemotePlayScancodeM,
	REMOTE_PLAYER_SCANCODE_N = k_ERemotePlayScancodeN,
	REMOTE_PLAYER_SCANCODE_O = k_ERemotePlayScancodeO,
	REMOTE_PLAYER_SCANCODE_P = k_ERemotePlayScancodeP,
	REMOTE_PLAYER_SCANCODE_Q = k_ERemotePlayScancodeQ,
	REMOTE_PLAYER_SCANCODE_R = k_ERemotePlayScancodeR,
	REMOTE_PLAYER_SCANCODE_S = k_ERemotePlayScancodeS,
	REMOTE_PLAYER_SCANCODE_T = k_ERemotePlayScancodeT,
	REMOTE_PLAYER_SCANCODE_U = k_ERemotePlayScancodeU,
	REMOTE_PLAYER_SCANCODE_V = k_ERemotePlayScancodeV,
	REMOTE_PLAYER_SCANCODE_W = k_ERemotePlayScancodeW,
	REMOTE_PLAYER_SCANCODE_X = k_ERemotePlayScancodeX,
	REMOTE_PLAYER_SCANCODE_Y = k_ERemotePlayScancodeY,
	REMOTE_PLAYER_SCANCODE_Z = k_ERemotePlayScancodeZ,
	REMOTE_PLAYER_SCANCODE_1 = k_ERemotePlayScancode1,
	REMOTE_PLAYER_SCANCODE_2 = k_ERemotePlayScancode2,
	REMOTE_PLAYER_SCANCODE_3 = k_ERemotePlayScancode3,
	REMOTE_PLAYER_SCANCODE_4 = k_ERemotePlayScancode4,
	REMOTE_PLAYER_SCANCODE_5 = k_ERemotePlayScancode5,
	REMOTE_PLAYER_SCANCODE_6 = k_ERemotePlayScancode6,
	REMOTE_PLAYER_SCANCODE_7 = k_ERemotePlayScancode7,
	REMOTE_PLAYER_SCANCODE_8 = k_ERemotePlayScancode8,
	REMOTE_PLAYER_SCANCODE_9 = k_ERemotePlayScancode9,
	REMOTE_PLAYER_SCANCODE_0 = k_ERemotePlayScancode0,
	REMOTE_PLAYER_SCANCODE_RETURN = k_ERemotePlayScancodeReturn,
	REMOTE_PLAYER_SCANCODE_ESCAPE = k_ERemotePlayScancodeEscape,
	REMOTE_PLAYER_SCANCODE_BACKSPACE = k_ERemotePlayScancodeBackspace,
	REMOTE_PLAYER_SCANCODE_TAB = k_ERemotePlayScancodeTab,
	REMOTE_PLAYER_SCANCODE_SPACE = k_ERemotePlayScancodeSpace,
	REMOTE_PLAYER_SCANCODE_MINUS = k_ERemotePlayScancodeMinus,
	REMOTE_PLAYER_SCANCODE_EQUALS = k_ERemotePlayScancodeEquals,
	REMOTE_PLAYER_SCANCODE_LEFT_BRACKET = k_ERemotePlayScancodeLeftBracket,
	REMOTE_PLAYER_SCANCODE_RIGHT_BRACKET = k_ERemotePlayScancodeRightBracket,
	REMOTE_PLAYER_SCANCODE_BACKSLASH = k_ERemotePlayScancodeBackslash,
	REMOTE_PLAYER_SCANCODE_SEMICOLON = k_ERemotePlayScancodeSemicolon,
	REMOTE_PLAYER_SCANCODE_APOSTROPHE = k_ERemotePlayScancodeApostrophe,
	REMOTE_PLAYER_SCANCODE_GRAVE = k_ERemotePlayScancodeGrave,
	REMOTE_PLAYER_SCANCODE_COMMA = k_ERemotePlayScancodeComma,
	REMOTE_PLAYER_SCANCODE_PERIOD = k_ERemotePlayScancodePeriod,
	REMOTE_PLAYER_SCANCODE_SLASH = k_ERemotePlayScancodeSlash,
	REMOTE_PLAYER_SCANCODE_CAPSLOCK = k_ERemotePlayScancodeCapsLock,
	REMOTE_PLAYER_SCANCODE_F1 = k_ERemotePlayScancodeF1,
	REMOTE_PLAYER_SCANCODE_F2 = k_ERemotePlayScancodeF2,
	REMOTE_PLAYER_SCANCODE_F3 = k_ERemotePlayScancodeF3,
	REMOTE_PLAYER_SCANCODE_F4 = k_ERemotePlayScancodeF4,
	REMOTE_PLAYER_SCANCODE_F5 = k_ERemotePlayScancodeF5,
	REMOTE_PLAYER_SCANCODE_F6 = k_ERemotePlayScancodeF6,
	REMOTE_PLAYER_SCANCODE_F7 = k_ERemotePlayScancodeF7,
	REMOTE_PLAYER_SCANCODE_F8 = k_ERemotePlayScancodeF8,
	REMOTE_PLAYER_SCANCODE_F9 = k_ERemotePlayScancodeF9,
	REMOTE_PLAYER_SCANCODE_F10 = k_ERemotePlayScancodeF10,
	REMOTE_PLAYER_SCANCODE_F11 = k_ERemotePlayScancodeF11,
	REMOTE_PLAYER_SCANCODE_F12 = k_ERemotePlayScancodeF12,
	REMOTE_PLAYER_SCANCODE_INSERT = k_ERemotePlayScancodeInsert,
	REMOTE_PLAYER_SCANCODE_HOME = k_ERemotePlayScancodeHome,
	REMOTE_PLAYER_SCANCODE_PAGE_UP = k_ERemotePlayScancodePageUp,
	REMOTE_PLAYER_SCANCODE_DELETE = k_ERemotePlayScancodeDelete,
	REMOTE_PLAYER_SCANCODE_END = k_ERemotePlayScancodeEnd,
	REMOTE_PLAYER_SCANCODE_PAGE_DOWN = k_ERemotePlayScancodePageDown,
	REMOTE_PLAYER_SCANCODE_RIGHT = k_ERemotePlayScancodeRight,
	REMOTE_PLAYER_SCANCODE_LEFT = k_ERemotePlayScancodeLeft,
	REMOTE_PLAYER_SCANCODE_DOWN = k_ERemotePlayScancodeDown,
	REMOTE_PLAYER_SCANCODE_UP = k_ERemotePlayScancodeUp,
	REMOTE_PLAYER_SCANCODE_LEFT_CONTROL = k_ERemotePlayScancodeLeftControl,
	REMOTE_PLAYER_SCANCODE_LEFT_SHIFT = k_ERemotePlayScancodeLeftShift,
	REMOTE_PLAYER_SCANCODE_LEFT_ALT = k_ERemotePlayScancodeLeftAlt,
	REMOTE_PLAYER_SCANCODE_LEFT_GUI = k_ERemotePlayScancodeLeftGUI,
	REMOTE_PLAYER_SCANCODE_RIGHT_CONTROL = k_ERemotePlayScancodeRightControl,
	REMOTE_PLAYER_SCANCODE_RIGHT_SHIFT = k_ERemotePlayScancodeRightShift,
	REMOTE_PLAYER_SCANCODE_RIGHT_ALT = k_ERemotePlayScancodeRightALT,
	REMOTE_PLAYER_SCANCODE_RIGHT_GUI = k_ERemotePlayScancodeRightGUI
};


// Remote Storage enums
enum FilePathType {
	// Found in isteamremotestorage.h
	FILE_PATH_TYPE_INVALID = k_ERemoteStorageFilePathType_Invalid,
	FILE_PATH_TYPE_ABSOLUTE = k_ERemoteStorageFilePathType_Absolute,
	FILE_PATH_TYPE_API_FILENAME = k_ERemoteStorageFilePathType_APIFilename
};

enum LocalFileChange {
	// Found in isteamremotestorage.h
	LOCAL_FILE_CHANGE_INVALID = k_ERemoteStorageLocalFileChange_Invalid,
	LOCAL_FILE_CHANGE_FILE_UPDATED = k_ERemoteStorageLocalFileChange_FileUpdated,
	LOCAL_FILE_CHANGE_FILE_DELETED = k_ERemoteStorageLocalFileChange_FileDeleted
};

enum RemoteStoragePlatform : uint32_t {
	// Found in isteamremotestorage.h
	REMOTE_STORAGE_PLATFORM_NONE = k_ERemoteStoragePlatformNone,
	REMOTE_STORAGE_PLATFORM_WINDOWS = k_ERemoteStoragePlatformWindows,
	REMOTE_STORAGE_PLATFORM_OSX = k_ERemoteStoragePlatformOSX,
	REMOTE_STORAGE_PLATFORM_PS3 = k_ERemoteStoragePlatformPS3,
	REMOTE_STORAGE_PLATFORM_LINUX = k_ERemoteStoragePlatformLinux,
	REMOTE_STORAGE_PLATFORM_SWITCH = k_ERemoteStoragePlatformSwitch,
	REMOTE_STORAGE_PLATFORM_ANDROID = k_ERemoteStoragePlatformAndroid,
	REMOTE_STORAGE_PLATFORM_IOS = k_ERemoteStoragePlatformIOS,
	REMOTE_STORAGE_PLATFORM_ALL = k_ERemoteStoragePlatformAll
};

enum RemoteStoragePublishedFileVisibility {
	// Found in isteamremotestorage.h
	REMOTE_STORAGE_PUBLISHED_VISIBILITY_PUBLIC = k_ERemoteStoragePublishedFileVisibilityPublic,
	REMOTE_STORAGE_PUBLISHED_VISIBILITY_FRIENDS_ONLY = k_ERemoteStoragePublishedFileVisibilityFriendsOnly,
	REMOTE_STORAGE_PUBLISHED_VISIBILITY_PRIVATE = k_ERemoteStoragePublishedFileVisibilityPrivate,
	REMOTE_STORAGE_PUBLISHED_VISIBILITY_UNLISTED = k_ERemoteStoragePublishedFileVisibilityUnlisted
};

enum UGCReadAction {
	// Found in isteamremotestorage.h
	UGC_READ_CONTINUE_READING_UNTIL_FINISHED = k_EUGCRead_ContinueReadingUntilFinished,
	UGC_READ_CONTINUE_READING = k_EUGCRead_ContinueReading,
	UGC_READ_CLOSE = k_EUGCRead_Close
};

enum WorkshopEnumerationType {
	// Found in isteamremotestorage.h
	WORKSHOP_ENUMERATION_TYPE_RANKED_BY_VOTE = k_EWorkshopEnumerationTypeRankedByVote,
	WORKSHOP_ENUMERATION_TYPE_RECENT = k_EWorkshopEnumerationTypeRecent,
	WORKSHOP_ENUMERATION_TYPE_TRENDING = k_EWorkshopEnumerationTypeTrending,
	WORKSHOP_ENUMERATION_TYPE_FAVORITES_OF_FRIENDS = k_EWorkshopEnumerationTypeFavoritesOfFriends,
	WORKSHOP_ENUMERATION_TYPE_VOTED_BY_FRIENDS = k_EWorkshopEnumerationTypeVotedByFriends,
	WORKSHOP_ENUMERATION_TYPE_CONTENT_BY_FRIENDS = k_EWorkshopEnumerationTypeContentByFriends,
	WORKSHOP_ENUMERATION_TYPE_RECENT_FROM_FOLLOWED_USERS = k_EWorkshopEnumerationTypeRecentFromFollowedUsers
};

enum WorkshopFileAction {
	// Found in isteamremotestorage.h
	WORKSHOP_FILE_ACTION_PLAYED = k_EWorkshopFileActionPlayed,
	WORKSHOP_FILE_ACTION_COMPLETED = k_EWorkshopFileActionCompleted
};

enum WorkshopFileType {
	// Found in isteamremotestorage.h
	WORKSHOP_FILE_TYPE_FIRST = k_EWorkshopFileTypeFirst,
	WORKSHOP_FILE_TYPE_COMMUNITY = k_EWorkshopFileTypeCommunity,
	WORKSHOP_FILE_TYPE_MICROTRANSACTION = k_EWorkshopFileTypeMicrotransaction,
	WORKSHOP_FILE_TYPE_COLLECTION = k_EWorkshopFileTypeCollection,
	WORKSHOP_FILE_TYPE_ART = k_EWorkshopFileTypeArt,
	WORKSHOP_FILE_TYPE_VIDEO = k_EWorkshopFileTypeVideo,
	WORKSHOP_FILE_TYPE_SCREENSHOT = k_EWorkshopFileTypeScreenshot,
	WORKSHOP_FILE_TYPE_GAME = k_EWorkshopFileTypeGame,
	WORKSHOP_FILE_TYPE_SOFTWARE = k_EWorkshopFileTypeSoftware,
	WORKSHOP_FILE_TYPE_CONCEPT = k_EWorkshopFileTypeConcept,
	WORKSHOP_FILE_TYPE_WEB_GUIDE = k_EWorkshopFileTypeWebGuide,
	WORKSHOP_FILE_TYPE_INTEGRATED_GUIDE = k_EWorkshopFileTypeIntegratedGuide,
	WORKSHOP_FILE_TYPE_MERCH = k_EWorkshopFileTypeMerch,
	WORKSHOP_FILE_TYPE_CONTROLLER_BINDING = k_EWorkshopFileTypeControllerBinding,
	WORKSHOP_FILE_TYPE_STEAMWORKS_ACCESS_INVITE = k_EWorkshopFileTypeSteamworksAccessInvite,
	WORKSHOP_FILE_TYPE_STEAM_VIDEO = k_EWorkshopFileTypeSteamVideo,
	WORKSHOP_FILE_TYPE_GAME_MANAGED_ITEM = k_EWorkshopFileTypeGameManagedItem,
	WORKSHOP_FILE_TYPE_CLIP = k_EWorkshopFileTypeClip,
	WORKSHOP_FILE_TYPE_MAX = k_EWorkshopFileTypeMax
};

enum WorkshopVideoProvider {
	// Found in isteamremotestorage.h
	WORKSHOP_VIDEO_PROVIDER_NONE = k_EWorkshopVideoProviderNone,
	WORKSHOP_VIDEO_PROVIDER_YOUTUBE = k_EWorkshopVideoProviderYoutube
};

enum WorkshopVote {
	// Found in isteamremotestorage.h
	WORKSHOP_VOTE_UNVOTED = k_EWorkshopVoteUnvoted,
	WORKSHOP_VOTE_FOR = k_EWorkshopVoteFor,
	WORKSHOP_VOTE_AGAINST = k_EWorkshopVoteAgainst,
	WORKSHOP_VOTE_LATER = k_EWorkshopVoteLater
};


// Screenshot enums
enum VRScreenshotType {
	// Found in isteamscreenshots.h
	VR_SCREENSHOT_TYPE_NONE = k_EVRScreenshotType_None,
	VR_SCREENSHOT_TYPE_MONO = k_EVRScreenshotType_Mono,
	VR_SCREENSHOT_TYPE_STEREO = k_EVRScreenshotType_Stereo,
	VR_SCREENSHOT_TYPE_MONO_CUBE_MAP = k_EVRScreenshotType_MonoCubemap,
	VR_SCREENSHOT_TYPE_MONO_PANORAMA = k_EVRScreenshotType_MonoPanorama,
	VR_SCREENSHOT_TYPE_STEREO_PANORAMA = k_EVRScreenshotType_StereoPanorama
};


// Timeline enums
enum TimelineGameMode {
	// Found in isteamtimeline.h
	TIMELINE_GAME_MODE_INVALID = k_ETimelineGameMode_Invalid,
	TIMELINE_GAME_MODE_PLAYING = k_ETimelineGameMode_Playing,
	TIMELINE_GAME_MODE_STAGING = k_ETimelineGameMode_Staging,
	TIMELINE_GAME_MODE_MENUS = k_ETimelineGameMode_Menus,
	TIMELINE_GAME_MODE_LOADING_SCREEN = k_ETimelineGameMode_LoadingScreen,
	TIMELINE_GAME_MODE_MAX = k_ETimelineGameMode_Max
};

enum TimelineEventClipPriority {
	// Found in isteamtimeline.h
	TIMELINE_EVENT_CLIP_PRIORITY_INVALID = k_ETimelineEventClipPriority_Invalid,
	TIMELINE_EVENT_CLIP_PRIORITY_NONE = k_ETimelineEventClipPriority_None,
	TIMELINE_EVENT_CLIP_PRIORITY_STANDARD = k_ETimelineEventClipPriority_Standard,
	TIMELINE_EVENT_CLIP_PRIORITY_FEATURED = k_ETimelineEventClipPriority_Featured
};


// UGC enums
enum ItemPreviewType {
	// Found in isteamugc.h
	ITEM_PREVIEW_TYPE_IMAGE = k_EItemPreviewType_Image,
	ITEM_PREVIEW_TYPE_YOUTUBE_VIDEO = k_EItemPreviewType_YouTubeVideo,
	ITEM_PREVIEW_TYPE_SKETCHFAB = k_EItemPreviewType_Sketchfab,
	ITEM_PREVIEW_TYPE_ENVIRONMENTMAP_HORIZONTAL_CROSS = k_EItemPreviewType_EnvironmentMap_HorizontalCross,
	ITEM_PREVIEW_TYPE_ENVIRONMENTMAP_LAT_LONG = k_EItemPreviewType_EnvironmentMap_LatLong,
	ITEM_PREVIEW_TYPE_CLIP = k_EItemPreviewType_Clip,
	ITEM_PREVIEW_TYPE_RESERVED_MAX = k_EItemPreviewType_ReservedMax
};

enum ItemState {
	// Found in isteamugc.h
	ITEM_STATE_NONE = k_EItemStateNone,
	ITEM_STATE_SUBSCRIBED = k_EItemStateSubscribed,
	ITEM_STATE_LEGACY_ITEM = k_EItemStateLegacyItem,
	ITEM_STATE_INSTALLED = k_EItemStateInstalled,
	ITEM_STATE_NEEDS_UPDATE = k_EItemStateNeedsUpdate,
	ITEM_STATE_DOWNLOADING = k_EItemStateDownloading,
	ITEM_STATE_DOWNLOAD_PENDING = k_EItemStateDownloadPending,
	ITEM_STATE_DISABLED_LOCALLY = k_EItemStateDisabledLocally
};

enum ItemStatistic {
	// Found in isteamugc.h
	ITEM_STATISTIC_NUM_SUBSCRIPTIONS = k_EItemStatistic_NumSubscriptions,
	ITEM_STATISTIC_NUM_FAVORITES = k_EItemStatistic_NumFavorites,
	ITEM_STATISTIC_NUM_FOLLOWERS = k_EItemStatistic_NumFollowers,
	ITEM_STATISTIC_NUM_UNIQUE_SUBSCRIPTIONS = k_EItemStatistic_NumUniqueSubscriptions,
	ITEM_STATISTIC_NUM_UNIQUE_FAVORITES = k_EItemStatistic_NumUniqueFavorites,
	ITEM_STATISTIC_NUM_UNIQUE_FOLLOWERS = k_EItemStatistic_NumUniqueFollowers,
	ITEM_STATISTIC_NUM_UNIQUE_WEBSITE_VIEWS = k_EItemStatistic_NumUniqueWebsiteViews,
	ITEM_STATISTIC_REPORT_SCORE = k_EItemStatistic_ReportScore,
	ITEM_STATISTIC_NUM_SECONDS_PLAYED = k_EItemStatistic_NumSecondsPlayed,
	ITEM_STATISTIC_NUM_PLAYTIME_SESSIONS = k_EItemStatistic_NumPlaytimeSessions,
	ITEM_STATISTIC_NUM_COMMENTS = k_EItemStatistic_NumComments,
	ITEM_STATISTIC_NUM_SECONDS_PLAYED_DURING_TIME_PERIOD = k_EItemStatistic_NumSecondsPlayedDuringTimePeriod,
	ITEM_STATISTIC_NUM_PLAYTIME_SESSIONS_DURING_TIME_PERIOD = k_EItemStatistic_NumPlaytimeSessionsDuringTimePeriod
};

enum ItemUpdateStatus {
	// Found in isteamugc.h
	ITEM_UPDATE_STATUS_INVALID = k_EItemUpdateStatusInvalid,
	ITEM_UPDATE_STATUS_PREPARING_CONFIG = k_EItemUpdateStatusPreparingConfig,
	ITEM_UPDATE_STATUS_PREPARING_CONTENT = k_EItemUpdateStatusPreparingContent,
	ITEM_UPDATE_STATUS_UPLOADING_CONTENT = k_EItemUpdateStatusUploadingContent,
	ITEM_UPDATE_STATUS_UPLOADING_PREVIEW_FILE = k_EItemUpdateStatusUploadingPreviewFile,
	ITEM_UPDATE_STATUS_COMMITTING_CHANGES = k_EItemUpdateStatusCommittingChanges
};

enum UGCContentDescriptorID {
	// Found in isteamugc.h
	UGC_CONTENT_DESCRIPTOR_NUDITY_OR_SEXUAL_CONTENT = k_EUGCContentDescriptor_NudityOrSexualContent,
	UGC_CONTENT_DESCRIPTOR_FREQUENT_VIOLENCE_OR_GORE = k_EUGCContentDescriptor_FrequentViolenceOrGore,
	UGC_CONTENT_DESCRIPTOR_ADULT_ONLY_SEXUAL_CONTENT = k_EUGCContentDescriptor_AdultOnlySexualContent,
	UGC_CONTENT_DESCRIPTOR_GRATUITOUS_SEXUAL_CONTENT = k_EUGCContentDescriptor_GratuitousSexualContent,
	UGC_CONTENT_DESCRIPTOR_ANY_MATURE_CONTENT = k_EUGCContentDescriptor_AnyMatureContent
};

enum UGCMatchingUGCType {
	// Found in isteamugc.h
	UGC_MATCHING_UGC_TYPE_ITEMS = k_EUGCMatchingUGCType_Items,
	UGC_MATCHING_UGC_TYPE_ITEMS_MTX = k_EUGCMatchingUGCType_Items_Mtx,
	UGC_MATCHING_UGC_TYPE_ITEMS_READY_TO_USE = k_EUGCMatchingUGCType_Items_ReadyToUse,
	UGC_MATCHING_UGC_TYPE_COLLECTIONS = k_EUGCMatchingUGCType_Collections,
	UGC_MATCHING_UGC_TYPE_ARTWORK = k_EUGCMatchingUGCType_Artwork,
	UGC_MATCHING_UGC_TYPE_VIDEOS = k_EUGCMatchingUGCType_Videos,
	UGC_MATCHING_UGC_TYPE_SCREENSHOTS = k_EUGCMatchingUGCType_Screenshots,
	UGC_MATCHING_UGC_TYPE_ALL_GUIDES = k_EUGCMatchingUGCType_AllGuides,
	UGC_MATCHING_UGC_TYPE_WEB_GUIDES = k_EUGCMatchingUGCType_WebGuides,
	UGC_MATCHING_UGC_TYPE_INTEGRATED_GUIDES = k_EUGCMatchingUGCType_IntegratedGuides,
	UGC_MATCHING_UGC_TYPE_USABLE_IN_GAME = k_EUGCMatchingUGCType_UsableInGame,
	UGC_MATCHING_UGC_TYPE_CONTROLLER_BINDINGS = k_EUGCMatchingUGCType_ControllerBindings,
	UGC_MATCHING_UGC_TYPE_GAME_MANAGED_ITEMS = k_EUGCMatchingUGCType_GameManagedItems,
	UGC_MATCHING_UGC_TYPE_ALL = k_EUGCMatchingUGCType_All
};

enum UGCQuery {
	// Found in isteamugc.h
	UGC_QUERY_RANKED_BY_VOTE = k_EUGCQuery_RankedByVote,
	UGC_QUERY_RANKED_BY_PUBLICATION_DATE = k_EUGCQuery_RankedByPublicationDate,
	UGC_QUERY_ACCEPTED_FOR_GAME_RANKED_BY_ACCEPTANCE_DATE = k_EUGCQuery_AcceptedForGameRankedByAcceptanceDate,
	UGC_QUERY_RANKED_BY_TREND = k_EUGCQuery_RankedByTrend,
	UGC_QUERY_FAVORITED_BY_FRIENDS_RANKED_BY_PUBLICATION_DATE = k_EUGCQuery_FavoritedByFriendsRankedByPublicationDate,
	UGC_QUERY_CREATED_BY_FRIENDS_RANKED_BY_PUBLICATION_DATE = k_EUGCQuery_CreatedByFriendsRankedByPublicationDate,
	UGC_QUERY_RANKED_BY_NUM_TIMES_REPORTED = k_EUGCQuery_RankedByNumTimesReported,
	UGC_QUERY_CREATED_BY_FOLLOWED_USERS_RANKED_BY_PUBLICATION_DATE = k_EUGCQuery_CreatedByFollowedUsersRankedByPublicationDate,
	UGC_QUERY_NOT_YET_RATED = k_EUGCQuery_NotYetRated,
	UGC_QUERY_RANKED_BY_TOTAL_VOTES_ASC = k_EUGCQuery_RankedByTotalVotesAsc,
	UGC_QUERY_RANKED_BY_VOTES_UP = k_EUGCQuery_RankedByVotesUp,
	UGC_QUERY_RANKED_BY_TEXT_SEARCH = k_EUGCQuery_RankedByTextSearch,
	UGC_QUERY_RANKED_BY_TOTAL_UNIQUE_SUBSCRIPTIONS = k_EUGCQuery_RankedByTotalUniqueSubscriptions,
	UGC_QUERY_RANKED_BY_PLAYTIME_TREND = k_EUGCQuery_RankedByPlaytimeTrend,
	UGC_QUERY_RANKED_BY_TOTAL_PLAYTIME = k_EUGCQuery_RankedByTotalPlaytime,
	UGC_QUERY_RANKED_BY_AVERAGE_PLAYTIME_TREND = k_EUGCQuery_RankedByAveragePlaytimeTrend,
	UGC_QUERY_RANKED_BY_LIFETIME_AVERAGE_PLAYTIME = k_EUGCQuery_RankedByLifetimeAveragePlaytime,
	UGC_QUERY_RANKED_BY_PLAYTIME_SESSIONS_TREND = k_EUGCQuery_RankedByPlaytimeSessionsTrend,
	UGC_QUERY_RANKED_BY_LIFETIME_PLAYTIME_SESSIONS = k_EUGCQuery_RankedByLifetimePlaytimeSessions,
	UGC_QUERY_RANKED_BY_LAST_UPDATED_DATE = k_EUGCQuery_RankedByLastUpdatedDate
};

enum UserUGCList {
	// Found in isteamugc.h
	USER_UGC_LIST_PUBLISHED = k_EUserUGCList_Published,
	USER_UGC_LIST_VOTED_ON = k_EUserUGCList_VotedOn,
	USER_UGC_LIST_VOTED_UP = k_EUserUGCList_VotedUp,
	USER_UGC_LIST_VOTED_DOWN = k_EUserUGCList_VotedDown,
	USER_UGC_LIST_WILL_VOTE_LATER = k_EUserUGCList_WillVoteLater,
	USER_UGC_LIST_FAVORITED = k_EUserUGCList_Favorited,
	USER_UGC_LIST_SUBSCRIBED = k_EUserUGCList_Subscribed,
	USER_UGC_LIST_USED_OR_PLAYED = k_EUserUGCList_UsedOrPlayed,
	USER_UGC_LIST_FOLLOWED = k_EUserUGCList_Followed
};

enum UserUGCListSortOrder {
	// Found in isteamugc.h
	USER_UGC_LIST_SORT_ORDER_CREATION_ORDER_DESC = k_EUserUGCListSortOrder_CreationOrderDesc,
	USER_UGC_LIST_SORT_ORDER_CREATION_ORDER_ASC = k_EUserUGCListSortOrder_CreationOrderAsc,
	USER_UGC_LIST_SORT_ORDER_TITLE_ASC = k_EUserUGCListSortOrder_TitleAsc,
	USER_UGC_LIST_SORT_ORDER_LAST_UPDATED_DESC = k_EUserUGCListSortOrder_LastUpdatedDesc,
	USER_UGC_LIST_SORT_ORDER_SUBSCRIPTION_DATE_DESC = k_EUserUGCListSortOrder_SubscriptionDateDesc,
	USER_UGC_LIST_SORT_ORDER_VOTE_SCORE_DESC = k_EUserUGCListSortOrder_VoteScoreDesc,
	USER_UGC_LIST_SORT_ORDER_FOR_MODERATION = k_EUserUGCListSortOrder_ForModeration
};


// User enums
enum FailureType {
	// Found in isteamuser.h
	FAILURE_FLUSHED_CALLBACK_QUEUE = IPCFailure_t::k_EFailureFlushedCallbackQueue,
	FAILURE_PIPE_FAIL = IPCFailure_t::k_EFailurePipeFail
};

enum DurationControlNotification {
	// Found in steamclientpublic.h
	DURATION_CONTROL_NOTIFICATION_NONE = k_EDurationControlNotification_None,
	DURATION_CONTROL_NOTIFICATION_1_HOUR = k_EDurationControlNotification_1Hour,
	DURATION_CONTROL_NOTIFICATION_3_HOURS = k_EDurationControlNotification_3Hours,
	DURATION_CONTROL_NOTIFICATION_HALF_PROGRESS = k_EDurationControlNotification_HalfProgress,
	DURATION_CONTROL_NOTIFICATION_NO_PROGRESS = k_EDurationControlNotification_NoProgress,
	DURATION_CONTROL_NOTIFICATION_EXIT_SOON_3H = k_EDurationControlNotification_ExitSoon_3h,
	DURATION_CONTROL_NOTIFICATION_EXIT_SOON_5H = k_EDurationControlNotification_ExitSoon_5h,
	DURATION_CONTROL_NOTIFICATION_EXIT_SOON_NIGHT = k_EDurationControlNotification_ExitSoon_Night
};

enum DurationControlOnlineState {
	// Found in steamclientpublic.h
	DURATION_CONTROL_ONLINE_STATE_INVALID = k_EDurationControlOnlineState_Invalid,
	DURATION_CONTROL_ONLINE_STATE_OFFLINE = k_EDurationControlOnlineState_Offline,
	DURATION_CONTROL_ONLINE_STATE_ONLINE = k_EDurationControlOnlineState_Online,
	DURATION_CONTROL_ONLINE_STATE_ONLINE_HIGH_PRIORITY = k_EDurationControlOnlineState_OnlineHighPri
};

enum DurationControlProgress {
	// Found in steamclientpublic.h
	DURATION_CONTROL_PROGRESS_FULL = k_EDurationControlProgress_Full,
	DURATION_CONTROL_PROGRESS_HALF = k_EDurationControlProgress_Half,
	DURATION_CONTROL_PROGRESS_NONE = k_EDurationControlProgress_None,
	DURATION_CONTROL_EXIT_SOON_3H = k_EDurationControl_ExitSoon_3h,
	DURATION_CONTROL_EXIT_SOON_5H = k_EDurationControl_ExitSoon_5h,
	DURATION_CONTROL_EXIT_SOON_NIGHT = k_EDurationControl_ExitSoon_Night
};


// User Stats enums
enum LeaderboardDataRequest {
	// Found in isteamuserstats.h
	LEADERBOARD_DATA_REQUEST_GLOBAL = k_ELeaderboardDataRequestGlobal,
	LEADERBOARD_DATA_REQUEST_GLOBAL_AROUND_USER = k_ELeaderboardDataRequestGlobalAroundUser,
	LEADERBOARD_DATA_REQUEST_FRIENDS = k_ELeaderboardDataRequestFriends,
	LEADERBOARD_DATA_REQUEST_USERS = k_ELeaderboardDataRequestUsers
};

enum LeaderboardDisplayType {
	// Found in isteamuserstats.h
	LEADERBOARD_DISPLAY_TYPE_NONE = k_ELeaderboardDisplayTypeNone,
	LEADERBOARD_DISPLAY_TYPE_NUMERIC = k_ELeaderboardDisplayTypeNumeric,
	LEADERBOARD_DISPLAY_TYPE_TIME_SECONDS = k_ELeaderboardDisplayTypeTimeSeconds,
	LEADERBOARD_DISPLAY_TYPE_TIME_MILLISECONDS = k_ELeaderboardDisplayTypeTimeMilliSeconds
};

enum LeaderboardSortMethod {
	// Found in isteamuserstats.h
	LEADERBOARD_SORT_METHOD_NONE = k_ELeaderboardSortMethodNone,
	LEADERBOARD_SORT_METHOD_ASCENDING = k_ELeaderboardSortMethodAscending,
	LEADERBOARD_SORT_METHOD_DESCENDING = k_ELeaderboardSortMethodDescending
};

enum LeaderboardUploadScoreMethod {
	// Found in isteamuserstats.h
	LEADERBOARD_UPLOAD_SCORE_METHOD_NONE = k_ELeaderboardUploadScoreMethodNone,
	LEADERBOARD_UPLOAD_SCORE_METHOD_KEEP_BEST = k_ELeaderboardUploadScoreMethodKeepBest,
	LEADERBOARD_UPLOAD_SCORE_METHOD_FORCE_UPDATE = k_ELeaderboardUploadScoreMethodForceUpdate
};


// Utils enums
enum CheckFileSignature {
	// Found in isteamutils.h
	CHECK_FILE_SIGNATURE_INVALID_SIGNATURE = k_ECheckFileSignatureInvalidSignature,
	CHECK_FILE_SIGNATURE_VALID_SIGNATURE = k_ECheckFileSignatureValidSignature,
	CHECK_FILE_SIGNATURE_FILE_NOT_FOUND = k_ECheckFileSignatureFileNotFound,
	CHECK_FILE_SIGNATURE_NO_SIGNATURES_FOUND_FOR_THIS_APP = k_ECheckFileSignatureNoSignaturesFoundForThisApp,
	CHECK_FILE_SIGNATURE_NO_SIGNATURES_FOUND_FOR_THIS_FILE = k_ECheckFileSignatureNoSignaturesFoundForThisFile
};

enum GamepadTextInputLineMode {
	// Found in isteamutils.h
	GAMEPAD_TEXT_INPUT_LINE_MODE_SINGLE_LINE = k_EGamepadTextInputLineModeSingleLine,
	GAMEPAD_TEXT_INPUT_LINE_MODE_MULTIPLE_LINES = k_EGamepadTextInputLineModeMultipleLines
};

enum GamepadTextInputMode {
	// Found in isteamutils.h
	GAMEPAD_TEXT_INPUT_MODE_NORMAL = k_EGamepadTextInputModeNormal,
	GAMEPAD_TEXT_INPUT_MODE_PASSWORD = k_EGamepadTextInputModePassword
};

enum FloatingGamepadTextInputMode {
	// Found in isteamutils.h
	FLOATING_GAMEPAD_TEXT_INPUT_MODE_SINGLE_LINE = k_EFloatingGamepadTextInputModeModeSingleLine,
	FLOATING_GAMEPAD_TEXT_INPUT_MODE_MULTIPLE_LINES = k_EFloatingGamepadTextInputModeModeMultipleLines,
	FLOATING_GAMEPAD_TEXT_INPUT_MODE_EMAIL = k_EFloatingGamepadTextInputModeModeEmail,
	FLOATING_GAMEPAD_TEXT_INPUT_MODE_NUMERIC = k_EFloatingGamepadTextInputModeModeNumeric
};

enum APICallFailure {
	// Found in isteamutils.h
	STEAM_API_CALL_FAILURE_NONE = k_ESteamAPICallFailureNone,
	STEAM_API_CALL_FAILURE_STEAM_GONE = k_ESteamAPICallFailureSteamGone,
	STEAM_API_CALL_FAILURE_NETWORK_FAILURE = k_ESteamAPICallFailureNetworkFailure,
	STEAM_API_CALL_FAILURE_INVALID_HANDLE = k_ESteamAPICallFailureInvalidHandle,
	STEAM_API_CALL_FAILURE_MISMATCHED_CALLBACK = k_ESteamAPICallFailureMismatchedCallback
};

enum TextFilteringContext {
	// Found in isteamutils.h
	TEXT_FILTERING_CONTEXT_UNKNOWN = k_ETextFilteringContextUnknown,
	TEXT_FILTERING_CONTEXT_GAME_CONTENT = k_ETextFilteringContextGameContent,
	TEXT_FILTERING_CONTEXT_CHAT = k_ETextFilteringContextChat,
	TEXT_FILTERING_CONTEXT_NAME = k_ETextFilteringContextName
};


#endif // GODOTSTEAM_ENUMS_H