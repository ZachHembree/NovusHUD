// Copyright © 2016, Zachary Hembree, All Rights Reserved.
// Novus HUD for Garry's Mod
// 9/14/2016

AddCSLuaFile("nlib.lua")
AddCSLuaFile("nhud.lua")
AddCSLuaFile("nmessagestack.lua")
AddCSLuaFile("nweaponmenu.lua")
AddCSLuaFile("nconfigurator.lua")

// Gamemode Profiles
local profileLoaded = false
local profileList = {}
profileList["Sandbox"] = {"sandbox"}
profileList["Trouble in Terrorist Town"] = {"terrortown"}
profileList["Prop Hunt"] = {"prophunt", "prop_hunt"}

hook.Add( "InitPostEntity", "novusHUDserverInit", function()
	if !profileLoaded then
		for k, v in pairs(profileList) do
			if GAMEMODE_NAME == v[1] || GAMEMODE_NAME == v[2] then
				AddCSLuaFile("profiles/" .. v[1] .. ".lua")
				AddCSLuaFile("overrides/" .. v[1] .. ".lua")
				AddCSLuaFile("configs/" .. v[1] .. ".lua")
				include("overrides/" .. v[1] .. ".lua")
				
				print("[Novus HUD] Profile for " .. k .. " loaded.")
				profileLoaded = true
			end
		end
	end
	
	if !profileLoaded then
		print("[Novus HUD] WARNING!: Unsupported gamemode detected! Defaulting to Sandbox profile...")		
		AddCSLuaFile("overrides/sandbox.lua")
		include("overrides/sandbox.lua")
		print("[Novus HUD] Profile for Sandbox loaded.")
		profileLoaded = true
	end
end)

util.AddNetworkString("nConfigurator")

function chatCommand(ply, text)
	if text == "!nconfig" then
		net.Start('nConfigurator')
		net.Send(ply)
	end
end
hook.Add("PlayerSay", "ConToOpenMotd", chatCommand)

// Fonts and licenses
resource.AddFile("resource/fonts/raleway-black.ttf")
resource.AddFile("resource/fonts/raleway-blackitalic.ttf")
resource.AddFile("resource/fonts/raleway-bold.ttf")
resource.AddFile("resource/fonts/raleway-bolditalic.ttf")
resource.AddFile("resource/fonts/raleway-extrabold.ttf")
resource.AddFile("resource/fonts/raleway-extrabolditalic.ttf")
resource.AddFile("resource/fonts/raleway-extralight.ttf")
resource.AddFile("resource/fonts/raleway-extralightitalic.ttf")
resource.AddFile("resource/fonts/raleway-italic.ttf")
resource.AddFile("resource/fonts/raleway-light.ttf")
resource.AddFile("resource/fonts/raleway-lightitalic.ttf")
resource.AddFile("resource/fonts/raleway-medium.ttf")
resource.AddFile("resource/fonts/raleway-mediumItalic.ttf")
resource.AddFile("resource/fonts/raleway-regular.ttf")
resource.AddFile("resource/fonts/raleway-semibold.ttf")
resource.AddFile("resource/fonts/raleway-semibolditalic.ttf")
resource.AddFile("resource/fonts/raleway-thin.ttf")
resource.AddFile("resource/fonts/raleway-thinitalic.ttf")
resource.AddFile("resource/fonts/raleway-license.txt")
resource.AddFile("resource/fonts/oswald-extralight.ttf")
resource.AddFile("resource/fonts/oswald-license.txt")