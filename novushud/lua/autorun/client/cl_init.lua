// Copyright © 2016, Zachary Hembree, All Rights Reserved.
// Novus HUD for Garry's Mod
// 4/18/17

surface.CreateFont("novusLarge", {font = "Raleway", size = 50, weight = 200})
surface.CreateFont("novusSmall", {font = "Raleway", size = 22, weight = 400})

include("nhud.lua")
include("nconfigurator.lua")

CreateClientConVar("novus_wepSort", 0, true, false, "Set to 0 to sort weapons list in ascending order or 1 for descending order.")
CreateClientConVar("novus_wepSelectMode", 1, true, false, "Set to 0 to disable quick weapon selection.")
CreateClientConVar("novus_hudAnimations", 1, true, false, "Set to 0 to disable HUD animations or 1 to enable them.")
CreateClientConVar("novus_hudAnimationSpeed", 1, true, false)
CreateClientConVar("novus_textScalingLock", 1, true, false, "Set to 0 to scale text independently of the HUD scaling.")
CreateClientConVar("novus_hudScale", .93, true, false)
CreateClientConVar("novus_hudTextScale", 1, true, false)

concommand.Add("novus_hudReset", function()
	RunConsoleCommand("novus_wepSort", "0")
	RunConsoleCommand("novus_hudAnimations", "1")
	RunConsoleCommand("novus_hudAnimationSpeed", "1.00")
	RunConsoleCommand("novus_textScalingLock", "1")
	RunConsoleCommand("novus_hudScale", "1.00")
	RunConsoleCommand("novus_hudTextScale", "1.00")
end)

// Gamemode Profiles
local cfg = {}
local profileLoaded = false
local cfgLoaded = false
local ply = nil
local plyInit = false
local profileList = {}
local textScaling = 0
local weightScaling = 1

profileList["Sandbox"] = {"sandbox"}
profileList["Trouble in Terrorist Town"] = {"terrortown"}
profileList["Prop Hunt"] = {"prophunt", "prop_hunt"}

local settingsUpdated = false
local textScale = math.Round(cvars.Number("novus_hudTextScale"), 2)
local hudScale =  math.Round(cvars.Number("novus_hudScale"), 2)
local scalingLock = cvars.Bool("novus_textScalingLock")

local function updateSettings()
	settingsUpdated = false
	textScale = math.Round(cvars.Number("novus_hudTextScale"), 2)
	hudScale =  math.Round(cvars.Number("novus_hudScale"), 2)
	scalingLock = cvars.Bool("novus_textScalingLock")
end

cvars.AddChangeCallback("novus_hudTextScale", updateSettings)
cvars.AddChangeCallback("novus_hudScale", updateSettings)
cvars.AddChangeCallback("novus_textScalingLock", updateSettings)

hook.Add( "InitPostEntity", "novusHUDClientInit", function()
	if !profileLoaded then
		for k, v in pairs(profileList) do
			if GAMEMODE_NAME == v[1] || GAMEMODE_NAME == v[2] then
				include("profiles/" .. v[1] .. ".lua")
				include("overrides/" .. v[1] .. ".lua")
				include("configs/" .. v[1] .. ".lua")
				
				print("[Novus HUD] Profile for " .. k .. " loaded.")
				profileLoaded = true
			end
		end
	end
	
	if !profileLoaded then
		print("[Novus HUD] WARNING!: Unsupported gamemode detected! Defaulting to Sandbox profile...")			
		include("profiles/sandbox.lua")
		print("[Novus HUD] Profile for Sandbox loaded.")
		profileLoaded = true
	end
	
	if profileLoaded then
		hook.Add( "HUDPaint", "novusHUDClient", function()	
			if !cfgLoaded then
				cfg = novusHUDConfig()
				setOverrideConfig(cfg)
				cfgLoaded = true
			end

			if !settingsUpdated then	
				if !scalingLock then
					textScaling = textScale
					weightScaling = 1 + ( 1 - textScaling)
				else
					textScaling = hudScale
					weightScaling = 1 + ( 1 - hudScale)
				end
						
				surface.CreateFont("novusInfo",			{font = cfg["novusInfo"][1], size = cfg["novusInfo"][2] * textScaling, weight = cfg["novusInfo"][3] * weightScaling})
				surface.CreateFont("novusInfoSmallerB", {font = cfg["novusInfoSmallerB"][1], size = cfg["novusInfoSmallerB"][2] * textScaling, weight = cfg["novusInfoSmallerB"][3]})
				surface.CreateFont("novusInfoSmallerT", {font = cfg["novusInfoSmallerT"][1], size = cfg["novusInfoSmallerT"][2] * textScaling, weight = cfg["novusInfoSmallerT"][3]})
				surface.CreateFont("novusTips", 		{font = cfg["novusTips"][1], size = cfg["novusTips"][2] * textScaling, weight = cfg["novusTips"][3] * weightScaling})
				surface.CreateFont("novusNotifications",{font = cfg["novusNotifications"][1], size = cfg["novusNotifications"][2] * textScaling, weight = cfg["novusNotifications"][3] * weightScaling})
				
				settingsUpdated = true		
			end
				
			if !plyInit then
				ply = LocalPlayer()
				plyInit = true
			end
					
			if plyInit then
				local profile = novusHUDProfile(ply, cfg)
				novusHUD(ply, profile, hudScale, textScale, scalingLock)
			end
		end)
	end
end)

// Hide default GMod UI
local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true, 
	CHudSecondaryAmmo = true,
	CHudWeaponSelection = true
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then return false end
end)
