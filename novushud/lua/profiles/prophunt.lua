// Copyright © 2016, Zachary Hembree, All Rights Reserved.
// Novus HUD for Garry's Mod
// Gamemode Profile: Prop Hunt
// 10/8/2016

local defaultColor = white(1)
local teams = {}
teams[TEAM_PROPS] = {nil, "PROP"}
teams[TEAM_HUNTERS] = {nil, "HUNTER"}

function novusHUDProfile(ply, cfg)
	// Team Colors
	teams[TEAM_PROPS][1] = cfg["propColor"]
	teams[TEAM_HUNTERS][1] = cfg["hunterColor"]
	
	local round = GetGlobalInt( "RoundNumber", 0 )
	local time = math.max(0, GetGlobalFloat("RoundEndTime", 0) - CurTime())
	time = formatTime(time, "%02i:%02i")
	
	local profile = {}
	
	// Don't draw hp and wep info if spectating.
	if ply:Team() != TEAM_SPECTATOR && ply:Team() != TEAM_UNASSIGNED then
		profile["drawHP"] = true
		profile["drawWep"] = true
	else
		profile["drawHP"] = false
		profile["drawWep"] = false
	end

	// TTT wepname translation
	profile["wepTranslate"] = false
	
	// Execute user input on key press or release
	profile["executeOnPress"] = true
	
	// Primary Indicators -- HP, Team and Weapons	
	profile["primaryIndicators"] = {defaultColor, black(1), "", black(1), white(1)}
	
	for k, v in pairs(teams) do
		if ply:Team() == k then
			profile["primaryIndicators"] = {v[1], black(1), v[2], v[1], black(1)}
		end
	end
	
	// Secondary Indicators
	profile["secondaryIndicators"] = {}
	
	// Tertiary Indicators 	
	profile["tertiaryIndicators"] = {}
	
	if round != 0 then
		profile["tScale"] = .5
		
		// Round Number
		table.insert(profile["tertiaryIndicators"], {true, round, "ROUND", white(1), black(1)})
		// Timer
		table.insert(profile["tertiaryIndicators"], {true, time, "TIME", white(1), black(1)})
	else
		profile["tScale"] = 1
		
		// Waiting Indicator
		table.insert(profile["tertiaryIndicators"], {false, "WAITING", nil, white(1), black(1)})
	end
	
	// Target Info
	profile["drawCustomTargetInfo"] = true
	profile["targetTeamColors"] = teams
	
	// Round End Notifications
	profile["drawRoundEndNotification"] = true
	
	// Tips
	profile["drawTips"] = false
	
	// Popups
	profile["drawPopups"] = true
	
	// Event Messages
	profile["drawEvents"] = true
	profile["messageTime"] = 6
	
	return profile
end