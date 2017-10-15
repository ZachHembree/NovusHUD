// Copyright © 2016, Zachary Hembree, All Rights Reserved.
// Novus HUD for Garry's Mod
// 10/8/2016

local hudScale = nil
local textScale = nil
local hudScaleLock = nil
local updateWrapping = true

local function updateTextWrapping(text, font, width, padding, lineBreaks)	
	for k, v in pairs(text) do
		if k != 0 then
			if v[1] == nil || updateWrapping then
				if v[0] != nil then
					v[1] = wrapText(v[0], font, width - padding, lineBreaks)
				end
			end
		end
	end
	
	return text
end

local function eventMessage(x, y, padding, width, height, backgroundColor, typeColor, text, font)
	drawTextBox(x, y, padding, width, height, backgroundColor, text, TEXT_ALIGN_CENTER, 0, font)
	surface.SetDrawColor(typeColor)
	surface.DrawRect(x - (width / 2), y - 2, width, 2)
end

local messagePadding = 8
local messageWidth = 416
local pOffset = 16
local pMessageY = 0
local deletePMessage = false
local pMessage = {}
pMessage[1] = {}
pMessage[1][0] = nil
pMessage[1][1] = {}

function addPermaMessage(text)
	if text != nil then
		pMessage[1][0] = string.upper(text)
	end
end

function removePermaMessage()
	if !deletePMessage then
		deletePMessage = true
	end
end

local function drawPermaMessage()
	local font = "novusNotifications"
	local width = math.Round(messageWidth * hudScale)

	pMessage = updateTextWrapping(pMessage, font, width, messagePadding)

	if pMessage[1][1][1] != nil then
		local lineSpacing = draw.GetFontHeight(font)
		local length = table.getn(pMessage[1][1])
		local height = 24 + (lineSpacing * (length - 1))
		local x = (ScrW() / 2)

		if !deletePMessage then
			pMessageY = nLerp(.15, pMessageY, 20)
			pOffset = nLerp(.15, pOffset, pMessageY + height)
		else
			pMessageY = nLerp(.25, pMessageY, -(height + 4))
			pOffset = nLerp(.25, pOffset, 16)

			if pMessageY < -(height + 2) then
				deletePMessage = false
				pMessage[1][0] = nil
				pMessage[1][1] = {}
				pOffset = 16
			end
		end

		local y = pMessageY		
		eventMessage(x, y, (messagePadding / 2), width, height, black(1), white(1), pMessage[1][1], font)
	end
end

local messages = {}
local messageCount = 0
local messageOffset = 0
local messageTime = 4
local removeMessage = false
local messageColorOverride = {}
messageColorOverride[0] = {Color(150, 0, 0, 200), Color(0, 0, 150, 200), Color(0, 50, 0, 200)}
messageColorOverride[1] = {Color(190, 40, 40, 255), Color(45, 105, 195, 255), Color(35, 125, 70, 255)}

function addEventMessage(text, color)
	local tagColor = white(1)

	if color != nil then tagColor = color end

	for k, v in pairs(messageColorOverride[0]) do
		if v == color then
			tagColor = messageColorOverride[1][k]
		end
	end

	if messageCount == 0 then
		if timer.Exists("novusMessageTimer") then timer.Remove("novusMessageTimer") end
		removeMessage = false
	end

	messageCount = messageCount + 1

	messages[messageCount] = {}
	messages[messageCount][0] = string.upper(text)
	messages[messageCount][1] = nil
	messages[messageCount][2] = tagColor
	messages[messageCount][3] = 0
	messages[messageCount][4] = 0
end

local function drawEventMessages()
	if messageCount > 0 then
		local width = math.Round(messageWidth * hudScale)
		local x = (ScrW() / 2)
		local y = pOffset
		local font = "novusNotifications"
		local textHeight = draw.GetFontHeight(font)
		local lineSpacing = textHeight
		local msgY = 0

		messages = updateTextWrapping(messages, font, width, messagePadding)

		for k, v in pairs(messages) do
			if k != 0 then
				if v[1] != nil then
					local length = table.getn(v[1])
					msgY = y + messageOffset + 6
					v[4] = 24 + (lineSpacing * (length - 1))

					if !removeMessage then
						if v[3] == 0 then v[3] = -v[4] - 16 end
						v[3] = nLerp(.15, v[3], msgY)
					elseif v == messages[1] then
						v[3] = nLerp(.25, v[3], -v[4])
					end

					if !timer.Exists("novusMessageTimer") then
						if messageCount > 3 then messageTime = (messageTime / 2) end

						timer.Create("novusMessageTimer", messageTime, 1, function()
							removeMessage = true
						end)
					end

					eventMessage(x, v[3], (messagePadding / 2), width, v[4], black(1), v[2], v[1], font)
					messageOffset = messageOffset + (lineSpacing * (length - 1)) + 30
				end
			end
		end

		if messages[1][3] < -messages[1][4] + 1 && removeMessage then
			table.remove (messages, 1)
			removeMessage = false
			messageCount = messageCount - 1
		end

		messageOffset = 0
	end
end

local function getMsgModifier(modifier, visible)
	if visible then
		modifier = nLerp(.05, modifier, 1, 3)
	else
		modifier = nLerp(.15, modifier, 0, 3)
	end

	return modifier
end

local roundEnd = {}
local roundEndModifer = 0
local roundEndRemoval = false

function addRoundEndNotification(primaryText, secondaryText, color)
	if timer.Exists("novusRoundEndTimer") then timer.Remove("novusRoundEndTimer") end
	if color == nil then color = white(1) end
	roundEndRemoval = false
	roundEndModifer = 0
	
	roundEnd = {}
	roundEnd[1] = string.upper(primaryText)
	roundEnd[2] = string.upper(secondaryText)
	roundEnd[3] = color 
end

function removeRoundEndNotification()
	if !roundEndRemoval then
		roundEndRemoval = true
	end
end

local function roundEndNotification(x, y, width, height, modifier, background, primaryTextColor, secondaryTextColor, primaryText, secondaryText, largeFont, smallFont)
	local textHeightLarge = draw.GetFontHeight(largeFont)
	local textHeightSmall = draw.GetFontHeight(smallFont)
	
	surface.SetDrawColor(background)	
	surface.DrawRect(x, y + 8, width, height - 16)
	
	surface.SetDrawColor(white(1))
	surface.DrawRect(x + (width / 2) - (width / 2 * modifier), y, 2, height)
	surface.SetDrawColor(white(1))
	surface.DrawRect(x + (width / 2) + (width / 2 * modifier) - 2, y, 2, height)
	
	drawText(primaryText, largeFont, x, y - (textHeightSmall / 2) - 4, primaryTextColor, TEXT_ALIGN_CENTER, height, width)
	drawText(secondaryText, smallFont, x, y + (textHeightLarge / 2) - 4, secondaryTextColor, TEXT_ALIGN_CENTER, height, width)
end

local function drawRoundEndNotification()	
	if roundEnd[1] != nil then
		roundEndModifer = getMsgModifier(roundEndModifer, !roundEndRemoval)
	end

	if roundEnd[1] != nil && roundEndModifer != 0 then
		local background = black(.94)
		local textColor = white(1)		
		local largeFont = "novusLarge"		
		local smallFont = "novusSmall"		
		local height = 104
		local width = 768
		local x = (ScrW() / 2) - (width / 2)
		local y = (ScrH() / 2) - (height / 2)
		local offset = (width - (width * roundEndModifer)) / 2
		
		if roundEndModifer < 1 then
			render.SetScissorRect((x + offset), (y + height), (width * roundEndModifer) + (x + offset), height, true)
				roundEndNotification(x, y, width, height, roundEndModifer, background, textColor, roundEnd[3], roundEnd[1], roundEnd[2], largeFont, smallFont)
			render.SetScissorRect(0, 0, 0, 0, false )
		else
			roundEndNotification(x, y, width, height, roundEndModifer, background, textColor, roundEnd[3], roundEnd[1], roundEnd[2], largeFont, smallFont)
		end
	end
end

local popupPadding = 16
local popupWidth = 416
local popupModifier = 0
local popupRemoval = false
local popup = {}
popup[1] = {}

function addPopup(text, lineBreaks)
	popup[1][0] = string.upper(text)
	popup[1][1] = nil
	popup[1][2] = lineBreaks
end

local function drawPopups()
	if popup[1][0] != nil then
		popupModifier = getMsgModifier(popupModifier, !popupRemoval)
	end

	if popup[1][0] != nil && popupModifier != 0 then
		local font = "novusTips"
		local lineSpacing = draw.GetFontHeight(font)
		local width = math.Round(popupWidth * hudScale)
		local x = (ScrW() / 2) - (width / 2)
		local y = ScrH() - (32 + ((72 * hudScale) + 2) + 8)
		local offset = (width - (width * popupModifier)) / 2

		popup = updateTextWrapping(popup, font, width, popupPadding, popup[1][2])

		if popup[1][1] != nil then
			local length = table.getn(popup[1][1])
			local height = (lineSpacing * length) + (popupPadding)

			if popupModifier < 1 then
				render.SetScissorRect((x + offset), (y + 20), (width * popupModifier) + (x + offset), height, true)
					drawTextBox(x, y, popupPadding, width, height, black(1), popup[1][1], TEXT_ALIGN_LEFT, 1, font)
				render.SetScissorRect(0, 0, 0, 0, false )
			else
				drawTextBox(x, y, popupPadding, width, height, black(1), popup[1][1], TEXT_ALIGN_LEFT, 1, font)
			end

			if !timer.Exists("novusPopupTimer") then
				timer.Create("novusPopupTimer", 12, 1, function()
					popupRemoval = true
				end)
			end

			if popupModifier == 0 && popupRemoval then
				popup[1] = {}
				popupRemoval = false
				popupModifier = 0
			end
		end
	end
end

local tips = {}
local tip = 1
local tipCount = 0
local tipPadding = 16
local tipWidth = 416
local tipModifier = 0
novusNotificationsVisible = true

function addTip(text)
	if text != nil then
		tipCount = tipCount + 1

		tips[tipCount] = {}
		tips[tipCount][0] = string.upper(text)
		tips[tipCount][1] = nil
	end
end

local function tipBox(x, y, cY, padding, width, height, lineSpacing, text, font)
	drawTextBox(x, y, padding, width, height, black(1), text, TEXT_ALIGN_LEFT, 1, font)
	drawText("↑", font, x + width - (padding / 2), cY - lineSpacing - 4, white(1), TEXT_ALIGN_RIGHT)
	drawText("↓", font, x + width - (padding / 2), cY, white(1), TEXT_ALIGN_RIGHT)
end

local function drawTips()
	tipModifier = getMsgModifier(tipModifier, novusNotificationsVisible)

	if tipCount > 0 && tips[tip][0] != nil && tipModifier != 0 then
		local font = "novusTips"
		local lineSpacing = draw.GetFontHeight(font)
		local arrowPadding = 10
		local width = math.Round((tipWidth * hudScale) + arrowPadding)
		local x = (ScrW() / 2) - (width / 2)
		local y = ScrH() - (tipPadding + 16 + ((72 * hudScale) + 2) + 8)
		local offset = (width - (width * tipModifier)) / 2

		tips = updateTextWrapping(tips, font, width, arrowPadding + tipPadding)

		if tips[tip][1] != nil then
			local length = table.getn(tips[tip][1])
			local height = (lineSpacing * length) + (tipPadding)
			local controlY = y - ((lineSpacing * length) / 2) + (lineSpacing / 2) + (tipPadding / 2)

			if tipModifier < 1 then
				render.SetScissorRect((x + offset), (y + 20), ((width * tipModifier) + (x + offset)), height, true)
					tipBox(x, y, controlY, tipPadding, width, height, lineSpacing, tips[tip][1], font)
				render.SetScissorRect(0, 0, 0, 0, false )
			else
				tipBox(x, y, controlY, tipPadding, width, height, lineSpacing, tips[tip][1], font)
			end

			if tipModifier == 0 && !novusNotificationsVisible then
				tipModifier = 0
			end

			if !timer.Exists("TipCycle") && tipModifier > 0 then
				timer.Create("TipCycle", 8, 0, function()
					if tip < tipCount then
						tip = tip + 1
					else
						tip = 1
					end
				end)
			end
		end
	end
end

hook.Add("PlayerBindPress", "cycletips", function(ply, bind, pressed)
	if pressed && tipCount > 0 && tipModifier != 0 then
		if timer.Exists("TipCycle") then
			timer.Remove("TipCycle")
		end

		if bind == "invprev" then
			tip = tip + 1

			if tip > tipCount then
				tip = 1
			end
		elseif bind == "invnext" then
			tip = tip - 1

			if tip < 1 then
				tip = tipCount
			end
		end
	end
end)

local hudScaleCache = nil
local textScaleCache = nil
local hudScaleLockCache = nil

function messageStack(hScale, tScale, sLock, roundNotification, tips, popups, events, eventMessageTime)
	hudScale = hScale
	textScale = sLock
	hudScaleLock = sLock

	if hudScale != hudScaleCache || textScale != textScaleCache || hudScaleLock != hudScaleLock then
		updateWrapping = true
	end
	
	if roundNotification then
		drawRoundEndNotification()
	end
	
	if tips then
		drawTips()
	end

	if popups then
		drawPopups()
	end

	if events then
		drawEventMessages()
		drawPermaMessage()
	end

	if eventMessageTime != nil then
		messageTime = eventMessageTime
	end
	
	if updateWrapping then
		scaleLockCache = hudScaleLock
		textScaleCache = textScale
		boxScaleCache = hudScale
		updateWrapping = false
	end
end