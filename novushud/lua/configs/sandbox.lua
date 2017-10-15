// Copyright © 2016, Zachary Hembree, All Rights Reserved.
// Novus HUD for Garry's Mod
// Gamemode Configuration: Sandbox -- Sandbox is not officially supported at this time; this is a fallback configuration.
// 9/7/2016

function novusHUDConfig()
	local cfg = {}

	// Fonts
	// Note: Font size and weight will vary depending on individual user's scaling settings.	
	cfg["novusInfo"] = {"Raleway", 25, 400} -- HP and Weapons indicators
	cfg["novusInfoSmallerB"] = {"Raleway", 16, 600} -- White layer of secondary indicators (credit shop item indicators)
	cfg["novusInfoSmallerT"] = {"Raleway", 16, 400} -- Black layer
	cfg["novusTips"] = {"Raleway", 15, 400} -- Tips menu and round start popups
	cfg["novusNotifications"] = {"Raleway", 14, 500} -- Event notifications (for when you find bodies, recieve credits, and stuff like that)t)
	
	return cfg
end