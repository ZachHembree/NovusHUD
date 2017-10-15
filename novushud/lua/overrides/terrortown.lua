// Copyright © 2016, Zachary Hembree, All Rights Reserved.
// Novus HUD for Garry's Mod
// 9/14/2016
// This file primarily consists of modified, overriden TTT functions.

local cfg = {}
function setOverrideConfig(config) cfg = config end

if CLIENT then
	// Fonts for overridden target displays
	surface.CreateFont("novusTargetOverrideS", {font = "Raleway", size = 22, weight = 400})
	surface.CreateFont("novusTargetOverrideS2", {font = "Raleway", size = 18, weight = 400})

	// Hide TTT UI 
	local function hideTerrorUI()
		function GAMEMODE:HUDPaint() 
			local client = LocalPlayer()
			if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTTargetID" ) then
				hook.Call( "HUDDrawTargetID", GAMEMODE )
			end
			if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTRadar" ) then
				RADAR:Draw(client)
			end	   
			if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTTButton" ) then
				TBHUD:Draw(client)
			end
		end
	end

	local tttOverrideInit = false

	hook.Add( "HUDShouldDraw", "HideHUD", function( name )	
		if !tttOverrideInit then
			if GAMEMODE_NAME == "terrortown" then
				hideTerrorUI()
				tttOverrideInit = true
			end
		end
	end)

	// Config menu for TTT
	hook.Add("TTTSettingsTabs", "novusHUD_Settings", function(dtabs)
		local padding = dtabs:GetPadding()
		padding = padding * 2

		local dsettings = vgui.Create("DPanelList", dtabs)
		dsettings:StretchToParent(0, 0, padding, 0)
		dsettings:EnableVerticalScrollbar(true)
		
		local dgui = vgui.Create("DForm", dsettings)
		dgui:SetName("HUD Settings")
		dgui:Button( "Open HUD Configuration Menu", "novusConfig")
		dsettings:AddItem(dgui)
		
		dtabs:AddSheet("Novus HUD Settings", dsettings, "icon16/layout.png", false, false, "HUD Customization Settings")
	end)

	// Override Default RADAR
	local function DrawTarget(tgt, size, offset, no_shrink)
	   local scrpos = tgt.pos:ToScreen() -- sweet
	   local sz = (IsOffScreen(scrpos) and (not no_shrink)) and size/2 or size

	   scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
	   scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)
	   
	   if IsOffScreen(scrpos) then return end

	   surface.DrawTexturedRect(scrpos.x - sz, scrpos.y - sz, sz * 2, sz * 2)

	   -- Drawing full size?
	   if sz == size then
		  local text = math.ceil(LocalPlayer():GetPos():Distance(tgt.pos))
		  local w, h = surface.GetTextSize(text)

		  -- Show range to target
		  surface.SetTextPos(scrpos.x - w/2, scrpos.y + (offset * sz) - h/2)
		  surface.DrawText(text)

		  if tgt.t then
			 -- Show time
			 text = util.SimpleTime(tgt.t - CurTime(), "%02i:%02i")
			 w, h = surface.GetTextSize(text)

			 surface.SetTextPos(scrpos.x - w / 2, scrpos.y + sz / 2)
			 surface.DrawText(text)
		  elseif tgt.nick then
			 -- Show nickname
			 text = tgt.nick
			 w, h = surface.GetTextSize(text)

			 surface.SetTextPos(scrpos.x - w / 2, scrpos.y + sz / 2)
			 surface.DrawText(text)
		  end
	   end
	end

	local indicator   = surface.GetTextureID("effects/select_ring")
	local c4warn      = surface.GetTextureID("vgui/ttt/icon_c4warn")
	local sample_scan = surface.GetTextureID("vgui/ttt/sample_scan")
	local det_beacon  = surface.GetTextureID("vgui/ttt/det_beacon")

	function RADAR:Draw(client)
	   if not client then return end

	   surface.SetFont("novusInfoSmallerB")

	   -- C4 warnings
	   if self.bombs_count != 0 and client:IsActiveTraitor() then
		  surface.SetTexture(c4warn)
		  surface.SetTextColor(200, 55, 55, 220)
		  surface.SetDrawColor(255, 255, 255, 200)

		  for k, bomb in pairs(self.bombs) do
			 DrawTarget(bomb, 24, 0, true)
		  end
	   end

	   -- Corpse calls
	   if client:IsActiveDetective() and #self.called_corpses then
		  surface.SetTexture(det_beacon)
		  surface.SetTextColor(255, 255, 255, 240)
		  surface.SetDrawColor(255, 255, 255, 230)

		  for k, corpse in pairs(self.called_corpses) do
			 DrawTarget(corpse, 16, 0.5)
		  end
	   end

	   -- Samples
	   if self.samples_count != 0 then
		  surface.SetTexture(sample_scan)
		  surface.SetTextColor(200, 50, 50, 255)
		  surface.SetDrawColor(255, 255, 255, 240)

		  for k, sample in pairs(self.samples) do
			 DrawTarget(sample, 16, 0.5, true)
		  end
	   end

	   -- Player radar
	   if (not self.enable) or (not client:IsActiveSpecial()) then return end

	   surface.SetTexture(indicator)

	   local remaining = math.max(0, RADAR.endtime - CurTime())
	   local alpha_base = 50 + 180 * (remaining / RADAR.duration)

	   local mpos = Vector(ScrW() / 2, ScrH() / 2, 0)

	   local role, alpha, scrpos, md
	   for k, tgt in pairs(RADAR.targets) do
		  alpha = alpha_base

		  scrpos = tgt.pos:ToScreen()
		  if not scrpos.visible then
			 continue
		  end
		  md = mpos:Distance(Vector(scrpos.x, scrpos.y, 0))
		  if md < 180 then
			 alpha = math.Clamp(alpha * (md / 180), 40, 230)
		  end

		  role = tgt.role or ROLE_INNOCENT
		  if role == ROLE_TRAITOR then
			 surface.SetDrawColor(210, 60, 60, alpha)
			 surface.SetTextColor(210, 60, 60, alpha)

		  elseif role == ROLE_DETECTIVE then
			 surface.SetDrawColor(65, 130, 255, alpha)
			 surface.SetTextColor(65, 130, 255, alpha)

		  elseif role == 3 then -- decoys
			 surface.SetDrawColor(150, 150, 150, alpha)
			 surface.SetTextColor(150, 150, 150, alpha)

		  else
			 surface.SetDrawColor(50, 180, 80, alpha)
			 surface.SetTextColor(50, 180, 80, alpha)
		  end

		  DrawTarget(tgt, 24, 0)
	   end
	end

	// TTT Message Stack Data
	local GetTranslation = LANG.GetTranslation
	local GetPTranslation = LANG.GetParamTranslation
	local GetRaw = LANG.GetRawTranslation

	// Round start popup
	local function GetTextForRole(role)
		local menukey = Key("+menu_context", "C")

		if role == ROLE_INNOCENT then
			return GetTranslation("info_popup_innocent")
		elseif role == ROLE_DETECTIVE then
			return GetPTranslation("info_popup_detective", {menukey = Key("+menu_context", "C")})
		else
			local traitors = {}
			for _, ply in pairs(player.GetAll()) do
			if ply:IsTraitor() then
				table.insert(traitors, ply)
			end
		end

		local text
		if #traitors > 1 then
			local traitorlist = ""

			for k, ply in pairs(traitors) do
				local len = table.getn(traitors)
				
				if ply != LocalPlayer() then
					if k != len then
						traitorlist = traitorlist .. ply:Nick() .. ", "
					else
						traitorlist = traitorlist .. ply:Nick() .. ". "
					end
				end
			end
			text = GetPTranslation("info_popup_traitor",
									{menukey = menukey, traitorlist = traitorlist})
		else
			text = GetPTranslation("info_popup_traitor_alone", {menukey = menukey})
		end
		return text
		end
	end

	local function tttStartPopup()
		local text = string.Split(GetTextForRole(LocalPlayer():GetRole()), "\n")
		text = string.Implode(" ", text)
		
		local lineBreaks = {"PRESS", "THESE", "son:", "¡Pulsa", "Kollegen:", "Drücke"}
		
		addPopup(text, lineBreaks)
	end

	concommand.Add("ttt_cl_startpopup", tttStartPopup)

	// Event Messages
	function MSTACK:AddMessage(text, color) addEventMessage(text, color) end
	function MSTACK:AddColoredMessage(text, color) addEventMessage(text, color) end
	function MSTACK:AddColoredBgMessage(text, color) addEventMessage(text, color) end

	// Tips
	local function tips()
		local tipArguments = {}
		tipArguments[1] = {walkkey = Key("+walk", "WALK"), usekey = Key("+use", "USE")}
		tipArguments[24] = {helpkey = Key("+gm_showhelp", "F1")}
		tipArguments[28] = {mutekey = Key("+gm_showteam", "F2")}
		tipArguments[30] = {zoomkey = Key("+zoom", "the 'Suit Zoom' key")}
		tipArguments[31] = {duckkey = Key("+duck", "DUCK")}
		tipArguments[36] = {helpkey = Key("+gm_showhelp", "F1")}

		for tip = 1, 40 do
			if tipArguments[tip] != nil then
				addTip("Tip: " .. GetPTranslation("tip" .. tip, tipArguments[tip]))
			else
				addTip("Tip: " .. GetTranslation("tip" .. tip))
			end
		end
	end

	local tipsInitialized = false
	local tipsAdded = false

	hook.Add( "HUDShouldDraw", "tttTipInit", function()	
		TIPS.Hide()
		
		if !tipsInitialized then
			local function enableTips(cv, prev, new)
				if tobool(new) then
					if LocalPlayer():IsSpec() then
						if !tipsAdded then
							tips()
							tipsAdded = true
						end	
						novusNotificationsVisible = true
					end
				else
					novusNotificationsVisible = false
				end
			end
			cvars.AddChangeCallback("ttt_tips_enable", enableTips)
		end
		
		if cvars.Bool("ttt_tips_enable") then
			if LocalPlayer():IsSpec() then
				if !tipsAdded then
					tips()
					tipsAdded = true
				end	
				novusNotificationsVisible = true
			else
				novusNotificationsVisible = false
			end
		end
		
		tipsInitialized = true
	end)

	// Target ID Override
	local key_params = {usekey = Key("+use", "USE"), walkkey = Key("+walk", "WALK")}
	local ClassHint = {
	   prop_ragdoll = {
		  name= "corpse",
		  hint= "corpse_hint",

		  fmt = function(ent, txt) return GetPTranslation(txt, key_params) end
	   }
	};

	-- Basic access for servers to add/modify hints. They override hints stored on
	-- the entities themselves.
	function GAMEMODE:AddClassHint(cls, hint)
	   ClassHint[cls] = table.Copy(hint)
	end

	local minimalist = CreateConVar("ttt_minimal_targetid", "0", FCVAR_ARCHIVE)
	local magnifier_mat = Material("icon16/magnifier.png")
	local ring_tex = surface.GetTextureID("effects/select_ring")
	local rag_color = Color(200,200,200,255)

	function GAMEMODE:HUDDrawTargetID()
	   local client = LocalPlayer()

	   local L = LANG.GetUnsafeLanguageTable()

	   local trace = client:GetEyeTrace(MASK_SHOT)
	   local ent = trace.Entity
	   if (not IsValid(ent)) or ent.NoTarget then return end

	   -- some bools for caching what kind of ent we are looking at
	   local target_traitor = false
	   local target_detective = false
	   local target_corpse = false

	   local text = nil
	   local color = COLOR_WHITE

	   -- if a vehicle, we identify the driver instead
	   if IsValid(ent:GetNWEntity("ttt_driver", nil)) then
		  ent = ent:GetNWEntity("ttt_driver", nil)

		  if ent == client then return end
	   end

	   local cls = ent:GetClass()
	   local minimal = minimalist:GetBool()
	   local hint = (not minimal) and (ent.TargetIDHint or ClassHint[cls])

	   if ent:IsPlayer() then
		  if ent:GetNWBool("disguised", false) then
			 client.last_id = nil

			 if client:IsTraitor() or client:IsSpec() then
				text = ent:Nick() .. L.target_disg
			 else
				-- Do not show anything
				return
			 end

			 color = COLOR_RED
		  else
			 text = ent:Nick()
			 client.last_id = ent
		  end

		  local _ -- Stop global clutter
		  -- in minimalist targetID, colour nick with health level
		  if minimal then
			 _, color = util.HealthToString(ent:Health())
		  end

		  if client:IsTraitor() and GAMEMODE.round_state == ROUND_ACTIVE then
			 target_traitor = ent:IsTraitor()
		  end

		  target_detective = ent:IsDetective()

	   elseif cls == "prop_ragdoll" then
		  -- only show this if the ragdoll has a nick, else it could be a mattress
		  if CORPSE.GetPlayerNick(ent, false) == false then return end

		  target_corpse = true

		  if CORPSE.GetFound(ent, false) or not DetectiveMode() then
			 text = CORPSE.GetPlayerNick(ent, "A Terrorist")
		  else
			 text  = L.target_unid
			 color = COLOR_YELLOW
		  end
	   elseif not hint then
		  -- Not something to ID and not something to hint about
		  return
	   end

	   local x_orig = ScrW() / 2.0
	   local x = x_orig
	   local y = ScrH() / 2.0

	   local w, h = 0,0 -- text width/height, reused several times

	   if target_traitor or target_detective then
		  surface.SetTexture(ring_tex)

		  if target_traitor then
			 surface.SetDrawColor(255, 0, 0, 200)
		  else
			 surface.SetDrawColor(0, 0, 255, 220)
		  end
		  surface.DrawTexturedRect(x-32, y-32, 64, 64)
	   end

	   y = y + 30
	   local font = "novusTargetOverrideS"
	   surface.SetFont( font )

	   -- Draw main title, ie. nickname
	   if text then
		  w, h = surface.GetTextSize( text )

		  x = x - w / 2

		  draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
		  draw.SimpleText( text, font, x, y, color )

		  -- for ragdolls searched by detectives, add icon
		  if ent.search_result and client:IsDetective() then
			 -- if I am detective and I know a search result for this corpse, then I
			 -- have searched it or another detective has
			 surface.SetMaterial(magnifier_mat)
			 surface.SetDrawColor(200, 200, 255, 255)
			 surface.DrawTexturedRect(x + w + 5, y, 16, 16)
		  end

		  y = y + h + 4
	   end

	   -- Minimalist target ID only draws a health-coloured nickname, no hints, no
	   -- karma, no tag
	   if minimal then return end

	   -- Draw subtitle: health or type
	   local clr = rag_color
	   if ent:IsPlayer() then
		  text, clr = util.HealthToString(ent:Health())

		  -- HealthToString returns a string id, need to look it up
		  text = L[text]
	   elseif hint then
		  text = GetRaw(hint.name) or hint.name
	   else
		  return
	   end
	   font = "novusTargetOverrideS2"

	   surface.SetFont( font )
	   w, h = surface.GetTextSize( text )
	   x = x_orig - w / 2

	   draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
	   draw.SimpleText( text, font, x, y, clr )

	   font = "novusTargetOverrideS2"
	   surface.SetFont( font )

	   -- Draw second subtitle: karma
	   if ent:IsPlayer() and KARMA.IsEnabled() then
		  text, clr = util.KarmaToString(ent:GetBaseKarma())

		  text = L[text]

		  w, h = surface.GetTextSize( text )
		  y = y + h + 5
		  x = x_orig - w / 2

		  draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
		  draw.SimpleText( text, font, x, y, clr )
	   end

	   -- Draw key hint
	   if hint and hint.hint then
		  if not hint.fmt then
			 text = GetRaw(hint.hint) or hint.hint
		  else
			 text = hint.fmt(ent, hint.hint)
		  end

		  w, h = surface.GetTextSize(text)
		  x = x_orig - w / 2
		  y = y + h + 5
		  draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
		  draw.SimpleText( text, font, x, y, COLOR_LGRAY )
	   end

	   text = nil

	   if target_traitor then
		  text = L.target_traitor
		  clr = COLOR_RED
	   elseif target_detective then
		  text = L.target_detective
		  clr = COLOR_BLUE
	   elseif ent.sb_tag and ent.sb_tag.txt != nil then
		  text = L[ ent.sb_tag.txt ]
		  clr = ent.sb_tag.color
	   elseif target_corpse and client:IsActiveTraitor() and CORPSE.GetCredits(ent, 0) > 0 then
		  text = L.target_credits
		  clr = COLOR_YELLOW
	   end

	   if text then
		  w, h = surface.GetTextSize( text )
		  x = x_orig - w / 2
		  y = y + h + 5

		  draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
		  draw.SimpleText( text, font, x, y, clr )
	   end
	end
end