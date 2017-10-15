// Copyright © 2016, Zachary Hembree, All Rights Reserved.
// Novus HUD for Garry's Mod
// 10/8/2016

include("nlib.lua")
include("nmessagestack.lua")
include("nweaponmenu.lua")

novusBorder = 16
local novusHUDBaseHeight = 50
local novusHUDBaseWidth = 342

local secondaryIndicatorCache = {}
local secondaryModifiers = {}
local secondaryY = {}

local function drawSecondaryIndicators(x, y, height, width, verticalAlignment, secondaryIndicators)
	local secondaryHeight = math.Round(height / 2)
	local secondaryWidth = math.Round((width - 6) / 4)
	
	for k, v in pairs(secondaryIndicators) do
		secondaryIndicatorCache[k] = v
	end
	
	for k, v in pairs(secondaryIndicatorCache) do
		if secondaryModifiers[k] == nil then
			secondaryModifiers[k] = 0
		end
		
		if secondaryY[k] == nil then
			secondaryY[k] = y + secondaryHeight + 2
		end
		
		if verticalAlignment == 1 then
			secondaryIndicator(v[1], secondaryHeight, secondaryWidth, -2, secondaryModifiers[k], x + ((secondaryWidth + 2) * (k - 1)), secondaryY[k] + height + secondaryHeight)
		else
			secondaryIndicator(v[1], secondaryHeight, secondaryWidth, 2, secondaryModifiers[k], x + ((secondaryWidth + 2) * (k - 1)), secondaryY[k])
		end
		
		if secondaryIndicators[k] != nil then
			secondaryY[k] = nLerp(.1, secondaryY[k], y)
		else
			secondaryY[k] = nLerp(.1, secondaryY[k], y + secondaryHeight + 2)
				
			if secondaryY[k] <= y + secondaryHeight + 2 then
				table.remove(secondaryIndicatorCache, k)
				table.remove(secondaryY, k)
			end
		end
			
		secondaryModifiers[k] =  nLerp(0.05, secondaryModifiers[k], v[2])
	end	
end

local health = 0

local function drawPlayerInfo(ply, height, width, horizontalAlignment, verticalAlignment, bgAccent, textAccent, secondaryText, secondaryIndicators)
	local x = 0
	local y = 0
	
	health = math.min(100, (health == ply:Health() && health) || nLerp(0.1, health, ply:Health()))
	health = math.max(0, health)
	local hpModifier = math.min( health / 100, 1 )
	local text = math.Round(health) .. "HP"
	
	if horizontalAlignment == 1 then
		x = ScrW() - (width + novusBorder)
	elseif horizontalAlignment == 0 then
		x = (ScrW() / 2) - (width / 2)
	else
		x = novusBorder
	end

	if verticalAlignment == 1 then
		y = novusBorder
	elseif verticalAlignment == 0 then
		y = (ScrH() / 2) - (height / 2)
	else
		y = ScrH() - (height + novusBorder)
	end
	
	drawSecondaryIndicators(x, y, height, width, verticalAlignment, secondaryIndicators)
	primaryIndicator(black(1), bgAccent, white(1), textAccent, "novusInfo", text, secondaryText, height, width, hpModifier, x, y, 0)
end

local function drawTertiaryIndicators(height, width, tScale, tertiaryIndicators)
	if tScale == nil then tScale = 1 end
	
	height = math.Round(height)
	width = math.Round((width / 2) * tScale)
	local len = table.getn(tertiaryIndicators)
	local totalWidth = len * (width + 2)
	local xC = (ScrW() - totalWidth) / 2
	local y = ScrH() - (height + novusBorder)
		
	for k, v in pairs(tertiaryIndicators) do
		local x = xC + ((k - 1) * (width + 2))
		tertiaryIndicator(x, y, height, width, k, v[1], v[2], v[3], v[4], v[5])
	end
end

local function spectateInfo(ply, height, width, x, y, target, targetColor)
	local font = "novusInfo"	
	secondaryBase(white(1), targetColor, font, target:Nick(), TEXT_ALIGN_CENTER, height, width, 16, 16)
end

local function targetInfo(ply, x, y, target, targetColor, secondaryTargetInfo, fontL, fontS)
	surface.SetFont(fontL)
	local targetName = target:Nick()
	local nameW, nameH = surface.GetTextSize(targetName)
	local targetHealth = target:Health() .. "HP"
	surface.SetFont(fontS)
	local healthW, healthH = surface.GetTextSize(targetHealth)
	local width = 0
	
	if nameW > healthW then
		width = nameW
	else
		width = healthW
	end
	
	surface.SetDrawColor(white(1))
	surface.DrawRect( x - ((width + 4) / 2), y - ((nameH + 4) / 2), width + 4, nameH + 4 )	
	drawText(targetName, fontL, x, y, targetColor, TEXT_ALIGN_CENTER)

	surface.SetDrawColor(white(1))
	surface.DrawRect( x - ((width + 4) / 2), y + (nameH - (healthH / 2) + 1) - 2, width + 4, healthH + 4 )		
	drawText(string.upper(targetHealth), fontS, x, y + nameH + 2, black(1), TEXT_ALIGN_CENTER)
end

local function drawTargetInfo(ply, height, width, teamColors, secondaryTargetInfo)
	local fontL = "novusInfo"
	local fontS = "novusInfoSmallerB"
	local spectatedPlayer = ply:GetObserverTarget()
	local target = ply:GetEyeTraceNoCursor()["Entity"]
	local targetColor = white(1)
	local playerList = player.GetAll()
	local x = (ScrW() / 2)
	local y = (ScrH() / 2) + 32
	width = math.Round(width / 2)
	
	if IsValid(spectatedPlayer) then
		for k, v in pairs(teamColors) do
			if spectatedPlayer:Team() == k then
				targetColor = v[1]
			end
		end
		
		if ply != spectatedPlayer then
			if ply:Team() == spectatedPlayer:Team() then		
				spectateInfo(ply, height, width, x, y, spectatedPlayer, targetColor)
			end
		end
	else
		for k, v in pairs(playerList) do
			if v == target then
				local targetName = string.upper(v:Nick())
				
				for k, v in pairs(teamColors) do
					if ply:Team() == k then
						targetColor = v[1]
					end
				end
		
				if ply:Team() == v:Team() then		
					targetInfo(ply, x, y, target, targetColor, secondaryTargetInfo, fontL, fontS)
				end
			end
		end
	end
end

local indicatorColors = {}
indicatorColors[1] = white(1)
indicatorColors[2] = black(1)
indicatorColors[4] = black(1)
indicatorColors[5] = white(1)

local transitionSpeed = .05

function novusHUD(ply, cfg, hudScale, textScale, hudScaleLock)
	local height = math.Round(novusHUDBaseHeight * hudScale)
	local width = math.Round(novusHUDBaseWidth * hudScale)

	if cfg["primaryIndicators"] != nil then
		for k, v in pairs(indicatorColors) do
			if v != cfg["primaryIndicators"][k] then
				v.r = nLerp(transitionSpeed, v.r, cfg["primaryIndicators"][k].r)
				v.g = nLerp(transitionSpeed, v.g, cfg["primaryIndicators"][k].g)
				v.b = nLerp(transitionSpeed, v.b, cfg["primaryIndicators"][k].b)
				v.a = nLerp(transitionSpeed, v.a, cfg["primaryIndicators"][k].a)
			end
		end	
		
		if cfg["drawHP"] && ply:Alive() then
			drawPlayerInfo(ply, height, width, -1, -1, indicatorColors[1], indicatorColors[2], cfg["primaryIndicators"][3], cfg["secondaryIndicators"])
		end
		
		if cfg["drawWep"] && ply:Alive() then
			drawWeaponInfo(ply, height, width, 1, -1, indicatorColors[4], indicatorColors[5], cfg["wepTranslate"], cfg["executeOnPress"])
		end
	end
	
	if cfg["tertiaryIndicators"] != nil then
		drawTertiaryIndicators(height, width, cfg["tScale"], cfg["tertiaryIndicators"])
	end
	
	if cfg["drawCustomTargetInfo"] then
		drawTargetInfo(ply, height, width, cfg["targetTeamColors"], cfg["secondaryTargetInfo"])
	end
	
	messageStack(hudScale, textScale, hudScaleLock, cfg["drawRoundEndNotification"], cfg["drawTips"], cfg["drawPopups"], cfg["drawEvents"], cfg["messageTime"])
end