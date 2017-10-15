// Copyright © 2016, Zachary Hembree, All Rights Reserved.
// Novus HUD for Garry's Mod
// 9/24/2016

function white(opacity) return Color( 250, 250, 255, 255 * opacity) end
function black(opacity) return Color( 40, 40, 40, 255 * opacity) end

local animations = nil
local animationSpeed = nil
local frameTime = 1/60

local function updateAnimationSpeed()
	animationSpeed = cvars.Number("novus_hudAnimationSpeed")
end

local function toggleAnimations()
	animations = cvars.Bool("novus_hudAnimations")
end

cvars.AddChangeCallback("novus_hudAnimationSpeed", updateAnimationSpeed)
cvars.AddChangeCallback("novus_hudAnimations", toggleAnimations)
hook.Add("HUDPaint", "novusFrameTime", function() frameTime = RealFrameTime() end)

function nLerp(rate, start, endPoint, precision)
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

function formatTime(time, fmt) -- A slightly modified version of util.SimpleTime() found in Terrortown
	if !seconds then seconds = 0 end

	local ms = (time - math.floor(time)) * 100
	time = math.floor(time)
	local s = time % 60
	time = (time - s) / 60
	local m = time

    return string.format(fmt, m, s, ms)
end

function drawText(text, font, x, y, color, xAlign, height, width)
	if height == nil then height = 0 end
	if width == nil then width = 0 end

	surface.SetFont(font)
	local textWidth, textHeight = surface.GetTextSize(text)
	
	y = y + (height / 2) - (textHeight / 2)
	
	if xAlign == TEXT_ALIGN_LEFT then 
		x = x
	elseif xAlign == TEXT_ALIGN_CENTER then
		x = x + (width / 2) - (textWidth / 2)
	elseif xAlign == TEXT_ALIGN_RIGHT then
		x = x + width - (textWidth)
	end
	
	surface.SetFont( font )
	surface.SetTextColor( color )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
end

function wrapText(text, font, fieldWidth, lineBreaks)
	surface.SetFont(font)
	local textWidth, textHeight = surface.GetTextSize(text)
	local wrappedText = {}
	local line = 1
	
	if textWidth > fieldWidth then
		local words = string.Explode(" ", text)
		local concatString = words[1]
		
		for k, v in pairs(words) do
			if k != 1 then
				local concatWidth, concatHeight = surface.GetTextSize(concatString .. " " .. v)
				local skipLine = false
				
				if lineBreaks != nil then
					for a, b in pairs(lineBreaks) do
						if v == b then
							skipLine = true
							table.insert(wrappedText, line, concatString)
							concatString = ""
							line = line + 1
						end
					end
				end
				
				if concatWidth < fieldWidth && !skipLine then
					concatString = concatString .. " " .. v
				else
					table.insert(wrappedText, line, concatString)
					concatString = v
					line = line + 1
				end
			end
		end
		if (text[line - 1] != concatString) && (concatString != nil) then
			table.insert(wrappedText, line, concatString)
		end
	else
		table.insert(wrappedText, line, text)
	end

	return wrappedText
end

function drawTextBox(x, y, padding, width, height, color, text, textAlignment, wrapResize, font)
	local length = table.getn(text)
	local lineSpacing = draw.GetFontHeight(font)
	
	if wrapResize == 0 then
		surface.SetDrawColor(color)
		surface.DrawRect( x - (width / 2), y, width, height )
	else
		surface.SetDrawColor(color)
		surface.DrawRect( x, y - (lineSpacing * length), width, height )
	end
	
	for line = 1, length do
	local lineY = 0
		if wrapResize == 0 then
			lineY = y + lineSpacing * (line - .5) + 4
		else
			lineY = y + lineSpacing * (line - length - .5)
		end
		drawText(text[line], font, x + (padding / 2), lineY + (padding / 2), white(1), textAlignment)
	end
end

function primaryBase(background, textColor, font, textPrimary, textSecondary, height, width, x, y)
	surface.SetDrawColor(background)
	surface.DrawRect(x, y, width, height)
	drawText(textPrimary, font, x + 4, y, textColor, TEXT_ALIGN_LEFT, height, width)
	drawText(textSecondary, font, x - 4, y, textColor, TEXT_ALIGN_RIGHT, height, width)
end

function secondaryBase(background, textColor, font, text, textAlignment, height, width, x, y)
	surface.SetDrawColor(background)
	surface.DrawRect(x, y, width, height)
	drawText(text, font, x, y, textColor, textAlignment, height, width)
end

function primaryIndicator(background, foreground, bgText, foreText, font, textPrimary, textSecondary, height, width, modifier, x, y, alignment)
	local offset = nil
	
	if alignment == 1 then 
		offset = width - (width * modifier) -- Right
	else 
		offset = 0 -- Left
	end
	
	if modifier < 1 then
		primaryBase(background, bgText, font, textPrimary, textSecondary, height, width, x, y)
		
		render.SetScissorRect((x + offset), ScrH() - novusBorder, (width * modifier) + (x + offset), y, true)
			primaryBase(foreground, foreText, font, textPrimary, textSecondary, height, width, x, y)
		render.SetScissorRect(0, 0, 0, 0, false )
	elseif modifier == 0 then
		primaryBase(background, bgText, font, textPrimary, textSecondary, height, width, x, y)
	else
		primaryBase(foreground, foreText, font, textPrimary, textSecondary, height, width, x, y)
	end	
end

function secondaryIndicator(text, height, width, padding, modifier, x, y)	
	local offset = 0
	local y = y - (height + padding)
	
	if modifier < 1 then
		secondaryBase(black(1), white(1), "novusInfoSmallerT", text, TEXT_ALIGN_CENTER, height, width, x, y)
		
		render.SetScissorRect((x + offset), ScrH() - novusBorder, (width * modifier) + (x + offset), y, true)
			secondaryBase(white(1), black(1), "novusInfoSmallerB", text, TEXT_ALIGN_CENTER, height, width, x, y)
		render.SetScissorRect(0, 0, 0, 0, false )
	elseif modifier == 0 then
		secondaryBase(black(1), white(1), "novusInfoSmallerT", text, TEXT_ALIGN_CENTER, height, width, x, y)
	else
		secondaryBase(white(1), black(1), "novusInfoSmallerB", text, TEXT_ALIGN_CENTER, height, width, x, y)
	end	
end

local tertiaryModifier = {}
local tertiarySecondaryY = {}
local tertiarySecondaryText = {}

function tertiaryIndicator(x, y, height, width, tertiaryCount, drawSecondary, primaryText, secondaryText, secondaryBG, secondaryTextColor)
	if tertiaryModifier[tertiaryCount] == nil then tertiaryModifier[tertiaryCount] = 0 end
	if tertiarySecondaryY[tertiaryCount] == nil then tertiarySecondaryY[tertiaryCount] = 0 end
	if tertiarySecondaryText[tertiaryCount] == nil then tertiarySecondaryText[tertiaryCount] = "" end
	
	tertiaryModifier[tertiaryCount] = nLerp(.05, tertiaryModifier[tertiaryCount], 1)
	
	local secondaryY = y - ((height / 2) + 2)
	local offset = (width - (width * tertiaryModifier[tertiaryCount])) / 2
	
	if secondaryText != nil then
		tertiarySecondaryText[tertiaryCount] = secondaryText
	end
	
	if tertiarySecondaryY[tertiaryCount] == 0 then tertiarySecondaryY[tertiaryCount] = y end
	
	if drawSecondary && tertiaryModifier[tertiaryCount] == 1 then
		tertiarySecondaryY[tertiaryCount] = nLerp(.05, tertiarySecondaryY[tertiaryCount], secondaryY)
	else
		tertiarySecondaryY[tertiaryCount] = nLerp(.05, tertiarySecondaryY[tertiaryCount], y)
	end
	
	if tertiarySecondaryY[tertiaryCount] != y && tertiarySecondaryText[tertiaryCount] != nil && drawSecondary then
		secondaryBase(secondaryBG, secondaryTextColor, "novusInfoSmallerB", tertiarySecondaryText[tertiaryCount], TEXT_ALIGN_CENTER, height / 2, width, x, tertiarySecondaryY[tertiaryCount])
	end
	
	if tertiaryModifier[tertiaryCount] < 1 && tertiaryModifier[tertiaryCount] != 0 then
		render.SetScissorRect((x + offset), ScrH() - novusBorder, (width * tertiaryModifier[tertiaryCount]) + (x + offset) + 1, y, true)
			secondaryBase(black(1), white(1), "novusInfo", primaryText, TEXT_ALIGN_CENTER, height, width, x, y)
		render.SetScissorRect(0, 0, 0, 0, false )
	else
		secondaryBase(black(1), white(1), "novusInfo", primaryText, TEXT_ALIGN_CENTER, height, width, x, y)
	end	
end