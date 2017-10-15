// Copyright © 2016, Zachary Hembree, All Rights Reserved.
// Novus HUD for Garry's Mod
// Gamemode Profile: Sandbox -- Sandbox is not officially supported at this time; this is a fallback configuration.
// 10/8/2016

local defaultColor = white(1)

function novusHUDProfile(ply)
	local profile = {}
	
	profile["drawHP"] = true
	profile["drawWep"] = true

	// TTT wepname translation
	profile["wepTranslate"] = false
	
	// Execute user input on key press or release
	profile["executeOnPress"] = true
	
	// Primary Indicators -- HP, Team and Weapons
	profile["primaryIndicators"] = {defaultColor, black(1), "", black(1), white(1)}

	// Secondary Indicators
	profile["secondaryIndicators"] = {}
	
	// Timer
	profile["tertiaryIndicators"] = {}
	
	// Target Info
	profile["drawCustomTargetInfo"] = false
	
	// Round End Notifications
	profile["drawRoundEndNotification"] = false
	
	// Tips
	profile["drawTips"] = false
	
	// Popups
	profile["drawPopups"] = false
	
	// Event Messages
	profile["drawEvents"] = false
	
	return profile
end