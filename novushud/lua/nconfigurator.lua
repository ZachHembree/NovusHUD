// Copyright © 2016, Zachary Hembree, All Rights Reserved.
// Novus HUD for Garry's Mod
// 12/30/16

hook.Add( "InitPostEntity", "nConfiguratorNotice", function()
	LocalPlayer():ChatPrint( "[Novus HUD] The HUD configuration menu can be accessed with the console command novusConfig or by typing !nconfig in chat." )
end )

local cfgElements = {
{"Sort weapons list in descending order", "novus_wepSort", 1},
{"Quick weapon selection.", "novus_wepSelectMode", 1},
{"HUD animations", "novus_hudAnimations", 1},
{"Animation Speed", "novus_hudAnimationSpeed", 0},
{"Lock text scaling to hud scale", "novus_textScalingLock", 1},
{"HUD scaling", "novus_hudScale", 0},
{"HUD text scaling", "novus_hudTextScale", 0}}

local frameTime = 1/60
hook.Add("HUDPaint", "novusFrameTime", function() frameTime = RealFrameTime() end)

local function nLerp(rate, start, endPoint, precision)
	if animations == nil then animations = cvars.Bool("novus_hudAnimations") end
	if animationSpeed == nil then animationSpeed = cvars.Number("novus_hudAnimationSpeed") end
	if precision == nil then precision = 2 end
	
	if rate != nil && start != nil && endPoint != nil then
		local delta = math.Round((endPoint - start), precision)
	
		if animations && delta != 0 then
			rate = (rate * (frameTime / (1/60))) * animationSpeed
	
			if endPoint > start then
				start = math.min(endPoint, Lerp(rate, start, endPoint * 1.01))
			else
				start = math.max(endPoint, Lerp(rate, start, endPoint / 1.01))
			end
		else
			start = endPoint
		end
		
		return start
	end
end

surface.CreateFont("novusSettingsHeader",{font = "Oswald", size = 52, weight = 0})
surface.CreateFont("novusSettings",{font = "Raleway", size = 13, weight = 700})
surface.CreateFont("novusClose",{font = "Raleway", size = 26, weight = 400})

local function drawTextLabel(name, text, x, y, font, parent)
	name:SetParent(parent)
	name:SetText(text)
	name:SetFont(font)
	name:SetTextColor(color_black)
	name:SetPos(x,y + 4)
	name:SetSize(600,8)
end

local function enable(on, off, cmd)
	on.DoClick = function()
		RunConsoleCommand(cmd, "0")
		on:SetVisible(false)
		off:SetVisible(true)
	end	
end

local function disable(on, off, cmd)
	off.DoClick = function()
		RunConsoleCommand(cmd, "1")
		on:SetVisible(true)
		off:SetVisible(false)
	end	
end

local function setButtonVisibility(on, off, cmd)
	local function checkVisibility()
		if cvars.Bool(cmd) then
			off:SetVisible(false)
			on:SetVisible(true)
		else
			on:SetVisible(false)
			off:SetVisible(true)
		end
	end
	
	checkVisibility()
	cvars.AddChangeCallback(cmd, checkVisibility)
end

local function drawButtonOn(name, x, y, width, height, parent)
	name:SetParent(parent)
	name:SetSize(width, height)
	name:SetPos(x, y)
	name:SetText("")
	name.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(45, 105, 155, 255))
		draw.RoundedBox( 0, w - 10, 1, w - 28, h - 2, white(1))
	end
end

local function drawButtonOff(name, x, y, width, height, parent)
	name:SetParent(parent)
	name:SetSize(width, height)
	name:SetPos(x, y)
	name:SetText("")
	name.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, black(1))
		draw.RoundedBox( 0, 4, 1, w - 28, h - 2, white(1))
	end
end

local function toggleButton(cmd, on, off, x, y, parent)	
	local width = 34
	local height = 12
	x = x - width - 4
	y = y - (height / 2)
	
	drawButtonOn(on, x, y, width, height, parent)
	drawButtonOff(off, x, y, width, height, parent)
	enable(on,off,cmd)
	disable(on,off,cmd)
	setButtonVisibility(on,off,cmd)
end

local function drawSlider(cmd, name, x, y, width, height, font, parent)
	name:SetParent(parent)
	name:SetPos( x + (width / 2) - 3, y )			
	name:SetSize((width / 2) - 43, height - 8)	
	name:SetMin(.9)				
	name:SetMax(1.2)				
	name:SetDecimals(2)			
	name:SetConVar(cmd)
	
	// Override default label size
	function name:PerformLayout() name.Label:SetWide(0) end
	
	// Text
	name.TextArea:SetParent(parent)
	name.TextArea:SetWide(34)
	name.TextArea:SetFont(font)
	
	// Bar
	name.Slider.Paint = function( self, w, h )
		surface.SetDrawColor(black(1))
		surface.DrawRect(0, (height / 2) - 5, width, 2)
	end
	
	// Knob
	name.Slider.Knob:SetSize(3, 12)
	name.Slider.Knob.Paint = function( self, w, h )
		surface.SetDrawColor(black(1))
		surface.DrawRect(0, 0, w, h)
	end
end

local function configElement(x, y, width, height, members, parent, text, cmd, type)
	members[1]:SetParent(parent)
	members[1]:SetPos(x, y)
	members[1]:SetSize(width, height)
	members[1]:SetText("")
	members[1]:SetColor(Color(0,0,0,0))
	members[1].Paint = function( self, w, h )
		surface.SetDrawColor(white(1))
		surface.DrawRect(0, 0, width, height)
	end
	
	local font = "novusSettings"
	drawTextLabel(members[2], text, 4, 4, font, members[1])
	
	if type == 1 then
		toggleButton(cmd, members[3], members[4], width, height / 2, members[1], "OverrideServerName")
	elseif type == 0 then
		drawSlider(cmd, members[3], 4, 4, width, height, font, members[1])
	else
	
	end
end

local novusConfigurator = nil

local function drawConfigurator()
	local len = table.getn(cfgElements)
	local elementHeight = 24
	local height = 48 + ((elementHeight + 2) * len) + 6 + 24
	local width = 620
	local x = (ScrW()/2) - (width / 2)
	local y = (ScrH()/2) - (height / 2)
	
	novusConfigurator = vgui.Create( "DFrame")
	novusConfigurator:SetPos(x, y)
	novusConfigurator:SetSize( width, height )
	novusConfigurator:SetTitle( "" )
	novusConfigurator:ShowCloseButton(false)
	novusConfigurator:SetDraggable(false)
	novusConfigurator:SetVisible(true)
	novusConfigurator:MakePopup()
	novusConfigurator.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, black(.8) ) 
		draw.RoundedBox( 0, 0, 0, w, 48, white(1) ) 
		draw.DrawText("HUD SETTINGS", "novusSettingsHeader", self:GetWide()/2, -4, black(1), TEXT_ALIGN_CENTER)
	end
	
	for k, v in pairs(cfgElements) do
		v[4] = vgui.Create("DLabel")
		v[5] = vgui.Create("DLabel")

		if v[3] == 1 then
			v[6] = vgui.Create("DButton")
			v[7] = vgui.Create("DButton")
		elseif v[3] == 0 then
			v[6] = vgui.Create("DNumSlider")
		end
		
		local members = {v[4], v[5], v[6], v[7]}		
		local y = 52 + ((k - 1) * (elementHeight + 2))
		
		v[1] = string.upper(v[1])
		
		configElement(4, y, width - 8, elementHeight, members, novusConfigurator, v[1], v[2], v[3])
	end
	
	// Reset
	local reset = vgui.Create( "DButton" )
	reset:SetParent(novusConfigurator)
	reset:SetPos( 0, height - elementHeight)
	reset:SetText("")
	reset:SetSize((width / 2) - 1, elementHeight )
	reset.Paint = function( self, w, h )	
		surface.SetDrawColor(white(1))
		surface.DrawRect(0, 0, w, h)
		
		surface.SetFont( "novusClose" )
		local text = "RESET"
		local textW, textH = surface.GetTextSize(text)
		
		surface.SetTextColor(black(1))
		surface.SetTextPos( (w / 2) - (textW / 2), -1)
		surface.DrawText( text )
	end
	reset.DoClick = function()
		RunConsoleCommand("novus_hudReset")
	end
	
	// Close
	local close = vgui.Create( "DButton" )
	close:SetParent(novusConfigurator)
	close:SetPos((width / 2) + 1, height - elementHeight)
	close:SetText("")
	close:SetSize((width / 2) - 1, elementHeight )
	close.Paint = function( self, w, h )	
		surface.SetDrawColor(white(1))
		surface.DrawRect(0, 0, w, h)
		
		surface.SetFont( "novusClose" )
		local text = "CLOSE"
		local textW, textH = surface.GetTextSize(text)
		
		surface.SetTextColor(black(1))
		surface.SetTextPos( (w / 2) - (textW / 2), -1)
		surface.DrawText( text )
	end
	close.DoClick = function()
		novusConfigurator:SetVisible(false)
	end
end

local function toggleConfigurator()
	if novusConfigurator == nil then
		drawConfigurator()
	elseif novusConfigurator:IsVisible() then
		novusConfigurator:SetVisible(false)
	else
		novusConfigurator:SetVisible(true)
	end
end

net.Receive("nConfigurator", function() toggleConfigurator() end)
concommand.Add("novusConfig", toggleConfigurator)