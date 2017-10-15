// Copyright © 2016, Zachary Hembree, All Rights Reserved.
// Novus HUD for Garry's Mod
// Gamemode Profile: Trouble in Terrorist Town
// 10/8/2016

local defaultColor = white(1)

function novusHUDProfile(ply, cfg)
	local profile = {}
	
	// Team Colors
	local traitorColor = cfg["traitorColor"]
	local detectiveColor = cfg["detectiveColor"]
	local innocentColor = cfg["innocentColor"]
	
	// TTT Data
	local roundStateTable = {
	[ROUND_WAIT]   = "round_wait",
	[ROUND_PREP]   = "round_prep",
	[ROUND_ACTIVE] = "round_active",
	[ROUND_POST]   = "round_post"}

	local LANG = LANG.GetUnsafeLanguageTable()
	local roundState = string.upper(LANG[roundStateTable[GAMEMODE.round_state]])
	local time = util.SimpleTime(math.max(0, GetGlobalFloat("ttt_round_end", 0) - CurTime()), "%02i:%02i")
	local hasteTime = util.SimpleTime(math.max(0, GetGlobalFloat("ttt_haste_end", 0) - CurTime()), "%02i:%02i")
	local radarTime = math.max(0, RADAR.endtime - CurTime())
	
	// Don't draw hp and wep info if spectating.
	if ply:Team() != TEAM_SPEC then
		profile["drawHP"] = true
		profile["drawWep"] = true
	else
		profile["drawHP"] = false
		profile["drawWep"] = false
	end

	// TTT wepname translation
	profile["wepTranslate"] = true
	
	// Execute user input on key press or release
	profile["executeOnPress"] = false
	
	// Primary Indicators -- HP, Team and Weapons
	if GAMEMODE.round_state != ROUND_PREP then
		if ply:IsTraitor() then
			profile["primaryIndicators"] = {traitorColor, black(1), string.upper(LANG.traitor), traitorColor, black(1)}
		elseif ply:IsDetective() then
			profile["primaryIndicators"] = {detectiveColor, black(1), string.upper(LANG.detective), detectiveColor, black(1)}
		elseif ply:IsTerror() then
			profile["primaryIndicators"] = {innocentColor, black(1), string.upper(LANG.innocent), innocentColor, black(1)}
		end
	else
		profile["primaryIndicators"] = {defaultColor, black(1), "TERRORIST", black(1), white(1)}
	end

	// Secondary Indicators
	profile["secondaryIndicators"] = {}
	
	if GAMEMODE.round_state != ROUND_PREP then
		// Armor
		if ply:HasEquipmentItem(EQUIP_ARMOR) then
			table.insert(profile["secondaryIndicators"], {"ARMOR", 1, 0})
		end
				
		// Radar
		if ply:HasEquipmentItem(EQUIP_RADAR) then
			local radarModifier = math.min(1, 1 - (math.Round(radarTime, 1) / 30))
			table.insert(profile["secondaryIndicators"], {"RADAR", radarModifier, 0})
		end
				
		// Diguise
		if ply:HasEquipmentItem(EQUIP_DISGUISE) then
			local disguiseModifier = 0
			if ply:GetNWBool("disguised") then
				disguiseModifier = 1
			end
			table.insert(profile["secondaryIndicators"], {"DISGUISE", disguiseModifier, 0})
		end
	end
	
	// Timer
	profile["tertiaryIndicators"] = {}
	
	if GAMEMODE.round_state == ROUND_WAIT then
		table.insert(profile["tertiaryIndicators"], {false, roundState, nil, white(1), black(1)})
	elseif HasteMode() && GAMEMODE.round_state != ROUND_PREP && GAMEMODE.round_state != ROUND_POST then	
		table.insert(profile["tertiaryIndicators"], {true, time, LANG.hastemode, white(1), black(1)})
	else
		table.insert(profile["tertiaryIndicators"], {true, time, roundState, white(1), black(1)})
	end
	
	// Target Info
	profile["drawCustomTargetInfo"] = false
	
	// Round End Notifications
	profile["drawRoundEndNotification"] = false
	
	// Tips
	profile["drawTips"] = true
	
	// Round Start Popups
	profile["drawPopups"] = true
	
	// Event Messages
	profile["drawEvents"] = true
	profile["messageTime"] = 5
	
	return profile
end