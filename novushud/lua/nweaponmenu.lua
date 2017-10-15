// Copyright © 2016, Zachary Hembree, All Rights Reserved.
// Novus HUD for Garry's Mod
// 4/18/2017

local sortedWepTable = {}
local verticalAlignment = nil
local quickWepSelection = false
local updateWepTable = false
local updateWepSubTables = false
local weaponsList = false
local pickupNotifications = false
local executeOnPress = true
local hooksInitialized = false
local translate = false
	
local function weaponIndicator(bgAccent, textAccent, background, foreground, bgText, foreText, weapon, slotBind, ammoInfo, height, width, secondaryWidth, modifier, x, y)
	local yAlignModifier = 0
	
	if slotBind == 6 then  -- Compensating for some of the font's alignment quriks.
		yAlignModifier = 1
	elseif slotBind == 5 then
		yAlignModifier = -2
	else
		yAlignModifier = -1
	end
	
	surface.SetDrawColor(bgAccent)
	surface.DrawRect( x, y, secondaryWidth, height )
	drawText(slotBind, "novusInfo", x, y + yAlignModifier, textAccent, TEXT_ALIGN_CENTER, height, secondaryWidth)
	primaryIndicator(background, foreground, bgText, foreText, "novusInfo", weapon, ammoInfo, height, width - secondaryWidth, modifier, x + secondaryWidth, y, 1)
end

local function getWeaponInfo(ply, wep)
	if wep != nil then
		local weapon = ""
			
		if translate then
			weapon = string.upper(LANG.TryTranslation(wep:GetPrintName()))
		else
			weapon = string.upper(wep:GetPrintName())
		end
		
		local slotBind = wep:GetSlot() + 1
		local clipSize = wep:GetMaxClip1()
				
		local totalAmmo = ""
		local ammo = ""
		local ammoInfo = ""
		local modifier = 1
			
		if wep:Clip1() >= 0 && clipSize > 0 then
			ammo = wep:Clip1()
			totalAmmo = ply:GetAmmoCount( wep:GetPrimaryAmmoType() )
			ammoInfo = ammo .. " | " .. totalAmmo
					
			modifier = math.min( ammo / clipSize, 1 )
		end
			
		return weapon, slotBind, clipSize, ammoInfo, modifier
	end
end

local selectionCounter = 1
local scrollCounter = 0
local previousSlot = 1
local categoryTable = {}
local slotBind = {}

local function getSelection(ply, bind, wepTable, alignment)
	local isIncrimented = true
	local weaponSelection = nil
	local wepTableLength = table.getn(wepTable)
	local bindIncriment = ""
	local bindDecriment = ""
	
	if alignment == 1 then
		bindIncriment = "invnext"
		bindDecriment = "invprev"
	else
		bindIncriment = "invprev"
		bindDecriment = "invnext"
	end

	if bind == bindIncriment then	
		scrollCounter = scrollCounter + 1
		if scrollCounter > wepTableLength then
			scrollCounter = 1
		end
		
		weaponSelection = wepTable[scrollCounter]
	elseif bind == bindDecriment then
		scrollCounter = scrollCounter - 1
		if scrollCounter < 1 then
			scrollCounter = wepTableLength
		end
		
		weaponSelection = wepTable[scrollCounter]
	else
		scrollCounter = 0
		isIncrimented = false
		
		if updateWepSubTables then
			categoryTable = {}
			slotBind = {}
			
			for k, v in pairs(wepTable) do
				if IsValid(v) then
					local slot = (v:GetSlot() + 1)
						
					if IsValid(wepTable[k - 1]) then
						if slot != (wepTable[k - 1]:GetSlot() + 1) then
							categoryTable[slot] = {}
							slotBind[slot] = "slot" .. slot
						end
					else
						categoryTable[slot] = {}
						slotBind[slot] = "slot" .. slot
					end
					
					if (categoryTable[slot] != v) then
						table.insert(categoryTable[slot], v)
					end
				end
			end
			updateWepSubTables = false
		end
		
		for k, v in pairs(slotBind) do
			if bind == v then
				if (selectionCounter > table.getn(categoryTable[k])) || (k != previousSlot) then
					selectionCounter = 1
				end
				previousSlot = k
				weaponSelection = categoryTable[k][selectionCounter]
				selectionCounter = selectionCounter + 1
			end
		end

	end
	return weaponSelection, isIncrimented
end

local meta = FindMetaTable("Player")

function meta:SelectWeapon(class)
	if !self:HasWeapon(class) then return end
	self.DoWeaponSwitch = self:GetWeapon(class)
end

hook.Add( "CreateMove", "WeaponSwitch", function(cmd)
	local ply = LocalPlayer()
	
	if !IsValid(ply.DoWeaponSwitch) then return end
	cmd:SelectWeapon(ply.DoWeaponSwitch)
end)

local function drawWeaponsList(ply, bgAccent, textAccent, height, width, secondaryWidth, x, y, alignment, wep, wepTable)
	local yOffset = 0
	local yStart = 0
	local startOp = .6
	local opacity = startOp
	local weapon = ""
	local slotBind = 0
	local clipSize = 0
	local ammoInfo = ""
	local modifier = 0
	
	hook.Add("PlayerBindPress", "cycleWeaponsList", function(ply, bind, pressed)
		local execute = false
	
		if executeOnPress then
			if pressed then execute = true else execute = false end
		else
			if !pressed then execute = true else execute = false end
		end
		
		if execute then
			weaponSelection = getSelection(ply, bind, sortedWepTable, alignment)
		end
	end)	
	
	for k, v in pairs(wepTable) do
		if v == weaponSelection then 
			opacity = 1

			hook.Add( "PlayerBindPress", "confirmSelection", function(ply, bind, pressed)
				local execute = false
		
				if executeOnPress then
					if pressed then execute = true else execute = false end
				else
					if !pressed then execute = true else execute = false end
				end
					
				if execute then
					if bind == "+attack" && IsValid(v) then
						ply:SelectWeapon(v:GetClass())
						weaponsList = false
					end
				end
			end)
		end
					
		weapon, slotBind, clipSize, ammoInfo, modifier = getWeaponInfo(ply, v)
			
		if alignment == 1 then
			yStart = y + yOffset
		else
			yStart = y - yOffset
		end
		
		weaponIndicator(bgAccent, textAccent, black(opacity), white(opacity), white(1), black(1), weapon, slotBind, ammoInfo, height, width, secondaryWidth, modifier, x, yStart)
		
		opacity = startOp	
		yOffset = yOffset + height + 2
	end
	
	yOffset = 0
end

hook.Add("PlayerBindPress", "openWeaponsList", function(ply, bind, pressed)
	local binds = {"slot1", "slot2", "slot3", "slot4", "slot5", "slot6", "slot7", "slot8", "slot9", "invnext", "invprev"}
	local execute = false
	local weaponsListShouldDraw = true
	
	if executeOnPress then
		if pressed then execute = true else execute = false end
	else
		if !pressed then execute = true else execute = false end
	end
	
	if quickWepSelection && bind != "invnext" && bind != "invprev" then
		weaponsListShouldDraw = false
		
		local weaponSelection = getSelection(ply, bind, sortedWepTable, verticalAlignment)
		if IsValid(weaponSelection) then ply:SelectWeapon(weaponSelection:GetClass()) end
	end
	
	if execute then
		for k, v in pairs(binds) do
			if bind == v then
				weaponsList = weaponsListShouldDraw
				
				if timer.Exists("weaponListTimer") then timer.Remove("weaponListTimer") end
				timer.Create("weaponListTimer", 3, 1, function() 
					weaponsList = false
					selectionCounter = 1
					scrollCounter = 0
				end)
			end
		end
	end
end)

local items = {}
local itemCount = 0
local removeItem = false

function addPickupNotification(name, amount, duplicates)
	if itemCount == 0 then removeItem = false end
	
	items[itemCount + 1] = {}
	items[itemCount + 1][1] = string.upper(name)
	items[itemCount + 1][2] = amount
	items[itemCount + 1][3] = duplicates
	items[itemCount + 1][4] = -366
	items[itemCount + 1][5] = 0
	itemCount = itemCount + 1
	
	for a, b in pairs(items) do
		for c = a + 1, itemCount do
			if b[1] == items[c][1] then
				b[3] = b[3] + 1
				
				table.remove(items, c)
				itemCount = itemCount - 1 
			end
		end
	end
end

hook.Add("HUDWeaponPickedUp", "novusWeaponPickup", function(wep)
	local wepName = ""
	
	if translate then
		wepName = LANG.TryTranslation( wep:GetPrintName() or wep.PrintName or "" )
	else
		wepName = language.GetPhrase(wep:GetPrintName())
	end
		
	addPickupNotification(wepName, 0, 0)
end)

hook.Add("HUDAmmoPickedUp", "novusAmmoPickup", function(ammo, amount)
	local ammoName = ""

	if translate then
		ammoName = LANG.TryTranslation( string.lower( "ammo_" .. ammo ) or ammo )
	else
		ammoName = ammo
		if string.EndsWith(ammoName, "1") then ammoName = string.TrimRight(ammoName, "1") .. " AMMO" end
		if ammoName == "SMG1_Grenade" then ammoName = "SMG GRENADE" end
	end
			
	addPickupNotification(ammoName, amount, 1)
end)

hook.Add("HUDItemPickedUp", "novusItemPickup", function(itemName)
	addPickupNotification(itemName, 0, 1)
end)

local function drawPickupNotifications(bgAccent, textAccent, height, width, secondaryWidth, xOrigin, yOrigin, alignment)
	if itemCount > 0 then		
		for k, v in pairs(items) do 
			v[4] = nLerp(.15, v[4], 0)
			
			local itemText = ""
			local x = xOrigin - v[4]
			local y = yOrigin
			
			if v[2] == 0 && v[3] == 0 then
				itemText = ""
			elseif v[2] == 0 && v[3] > 0 then
				itemText = "+" .. v[3]
			else
				itemText = "+" .. v[2] * v[3]
			end
			
			if v[5] != nil then
				if !removeItem then
					v[5] = nLerp(.25, v[5], k * (height + 2))
				elseif k == 1 then
					v[5] = nLerp(.3, v[5], 0)
				end
			end
			
			if v[5] != nil then
				y = y - v[5]
			end
						
			weaponIndicator(bgAccent, textAccent, black(1), white(1), white(1), black(1), v[1], "", itemText, height, width, secondaryWidth, 1, x, y)
		end
		
		if !timer.Exists("novusPopupTimer") then
			local time = 2.5
			if itemCount > 1 then time = 1 end
			
			timer.Create("novusPopupTimer", time, 1, function()
				removeItem = true	
			end)
		end
		
		if items[1][5] <= 1 && removeItem then
			removeItem = false
			itemCount = itemCount - 1
			table.remove(items, 1)
		end
	end
end

local wepTableCache = {}
local wepSortDescending = nil

local function updateWeps() updateWepTable = true end
cvars.AddChangeCallback("novus_wepSort", updateWeps)

function drawWeaponInfo(ply, height, width, horizontalAlignment, _verticalAlignment, bgAccent, textAccent, lang, userInputMode)
	local xPos = 0
	local yPos = 0
	local wepTable = ply:GetWeapons()
	local wep = ply:GetActiveWeapon()
	local weapon = ""
	local slotBind = 0
	local clipSize = 0
	local ammoInfo = ""
	local modifier = 0
	verticalAlignment = _verticalAlignment
	translate = lang
	
	if userInputMode then
		executeOnPress = true
	else
		executeOnPress = false
	end
	
	for a, b in pairs(wepTable) do
		if (b != wepTableCache[a]) || table.Count(wepTable) != table.Count(wepTableCache) then
			wepTableCache = wepTable
			
			updateWepTable = true
			updateWepSubTables = true
		end
	end
	
	if cvars.Bool("novus_wepSelectMode") then
		quickWepSelection = true
	else
		quickWepSelection = false
	end
	
	if cvars.Bool("novus_wepSort") then
		wepSortDescending = true
	else
		wepSortDescending = false
	end
	
	if updateWepTable then
		sortedWepTable = wepTable
		sortedWepTable = table.ClearKeys(sortedWepTable)
		
		if wepSortDescending then
			table.sort( sortedWepTable, function(a, b) 
				if a != nil && b != nil then
					return a:GetSlot() > b:GetSlot() 
				end
			end)
		else
			table.sort( sortedWepTable, function(a, b) 
				if a != nil && b != nil then
					return a:GetSlot() < b:GetSlot() 
				end
			end)
		end
		
		updateWepTable = false
	end
	
	if horizontalAlignment == 1 then
		xPos = ScrW() - (width + novusBorder)
	elseif horizontalAlignment == 0 then
		xPos = (ScrW() / 2) - (width / 2)
	else
		xPos = novusBorder
	end
	
	if verticalAlignment == 1 then
		yPos = novusBorder
	elseif verticalAlignment == 0 then
		yPos = (ScrH() / 2) - (height / 2)
	else
		yPos = ScrH() - (height + novusBorder)
	end
	
	if IsValid(sortedWepTable[1]) then
		if IsValid(wep) then
			weapon, slotBind, clipSize, ammoInfo, modifier = getWeaponInfo( ply, wep )
		else
			weapon, slotBind, clipSize, ammoInfo, modifier = getWeaponInfo( ply, sortedWepTable[1])
		end
			
		if weaponsList then
			drawWeaponsList(ply, bgAccent, textAccent, height, width, width / 16, xPos, yPos, verticalAlignment, wep, sortedWepTable)
		else
			drawPickupNotifications(bgAccent, textAccent, height, width, width / 16, xPos, yPos, verticalAlignment)
			weaponIndicator(bgAccent, textAccent, black(1), white(1), white(1), black(1), weapon, slotBind, ammoInfo, height, width, width / 16, modifier, xPos, yPos)
		end
	end
end