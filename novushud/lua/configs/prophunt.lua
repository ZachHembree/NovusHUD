// Copyright © 2016, Zachary Hembree, All Rights Reserved.
// Novus HUD for Garry's Mod
// Gamemode Configuration: Prop Hunt
// 9/7/2016

function novusHUDConfig()
	local cfg = {}

	// Team Colors in RGBA format
	cfg["propColor"] = Color(150, 40, 40, 255)
	cfg["hunterColor"] = Color(40, 105, 155, 255)

	// Fonts
	// Note: Font size and weight will vary depending on individual user's scaling settings.	
	cfg["novusInfo"] = {"Raleway", 25, 400} -- HP and Weapons indicators
	cfg["novusInfoSmallerB"] = {"Raleway", 16, 600} -- White layer of secondary indicators (credit shop item indicators)
	cfg["novusInfoSmallerT"] = {"Raleway", 16, 400} -- Black layer
	cfg["novusTips"] = {"Raleway", 15, 400} -- Tips menu and round start popups
	cfg["novusNotifications"] = {"Raleway", 14, 500} -- Event notifications (for when you find bodies, recieve credits, and stuff like that)
	return cfg
end