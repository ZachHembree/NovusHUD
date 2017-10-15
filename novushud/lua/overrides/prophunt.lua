// Copyright © 2016, Zachary Hembree, All Rights Reserved.
// Novus HUD for Garry's Mod
// Gamemode Profile: Prop Hunt
// 10/14/2017

local cfg = {}
function setOverrideConfig(config) cfg = config end

if CLIENT then
	hook.Remove("HUDPaint", "PH_HUDPaint")
	function GAMEMODE:AddPlayerAction() end
	
	local textCache = nil
	function GAMEMODE:InRound() return GetGlobalBool( "InRound", false ) end
	
	function GAMEMODE:GetTeamAliveCounts()
		local TeamCounter = {}

		for k,v in pairs( player.GetAll() ) do
			if ( v:Alive() && v:Team() > 0 && v:Team() < 1000 ) then
				TeamCounter[ v:Team() ] = TeamCounter[ v:Team() ] or 0
				TeamCounter[ v:Team() ] = TeamCounter[ v:Team() ] + 1
			end
		end

		return TeamCounter
	end

	local blindlockMessageCache = nil
	local messageRemoved = false
	local teams = nil
	local text = 0
	
	function GAMEMODE:HUDPaint()
		if !GAMEMODE:InRound() then
			teams = GAMEMODE:GetTeamAliveCounts()

			if table.Count(teams) == 0 then				
				if textCache != text then
					text = "DRAW"
					
					addRoundEndNotification("DRAW", "EVERYONE DIED!", white(1))
					textCache = text
				end
			elseif table.Count(teams) == 1 then	
				if text != textCache then
					text = "HUNTERS WIN"
			
					addRoundEndNotification("HUNTERS WIN", "THE PROPS HAVE BEEN VANQUISHED!", white(1))
					textCache = text
				end
			elseif GetGlobalFloat("RoundEndTime", 0) - CurTime() < 1 then						
				if text != textCache then
					text = "PROPS WIN"
					
					addRoundEndNotification("PROPS WIN", "THE HUNTERS RAN OUT OF TIME!", white(1))
					textCache = text
				end
			end
		else
			removeRoundEndNotification()
			textCache = nil
		end
		
		if GetGlobalBool("InRound", false) then
			local blindlockTime = nil
			local blindlockMessage = nil

			// Yes, please change shit that's worked forever.
			if HUNTER_BLINDLOCK_TIME != nil then
				blindlockTime = (HUNTER_BLINDLOCK_TIME - (CurTime() - GetGlobalFloat("RoundStartTime", 0))) + 1
			else
				blindlockTime = (GetConVarNumber("ph_hunter_blindlock_time") - (CurTime() - GetGlobalFloat("RoundStartTime", 0))) + 1
			end
						
			if blindlockTime < 1 && blindlockTime > -6 then
				blindlockMessage = "Hunters have been released!"
			elseif blindlockTime > 0 then
				blindlockMessage = "Hunters will be unblinded and released in ".. string.ToMinutesSeconds(blindlockTime)
			else
				blindlockMessage = nil
			end
			
			if blindlockMessage then
				if blindlockMessage != blindlockMessageCache then
					addPermaMessage(blindlockMessage)
					blindlockMessageCache = blindlockMessage
					messageRemoved = false
				end
				
				if blindlockTime < -5 then
					if !messageRemoved then
						removePermaMessage()	
						messageRemoved = true
					end
				end
			end
		end
	end
	
	function GAMEMODE:AddDeathNotice(a, b, c, d, e) // via
		if a != "suicide" && a != "worldspawn" then
			b = language.GetPhrase(b)
			b = string.TrimRight(b, "1")
			b = string.TrimRight(b, "_ar2")
				
			if type(c) != "string" then					
				if c != nil then				
					local text = string.upper(c:Nick() .. " killed " .. a:Nick() .. " with a " .. b .. ".")
					local color = white(1)
									
					if c:Team() == 2 then
						color = cfg["propColor"]
					elseif c:Team() == 1 then
						color = cfg["hunterColor"]
					end
					
					addEventMessage(text, color)
				end
			else
				if a != nil && b != nil && c != nil then	
					
					local text = string.upper(a .. " killed " .. d .. " with a " .. c .. ".")
					local color = white(1)
						
					if b == 2 || b ~= "Props" then
						color = cfg["propColor"]
					elseif e == 1 || e ~= "Hunters" then
						color = cfg["hunterColor"]
					end
						
					addEventMessage(text, color)
				end
			end
		end
	end
	
	local victim = nil
	local attacker = nil
	
	net.Receive("novusDeathVictim", function() victim = net.ReadEntity() end)
	net.Receive("novusDeathAttacker", function() attacker = net.ReadEntity() end)
	
	net.Receive("novusDeathNotice", function()
		local color = white(1)
		
		if victim:Team() == TEAM_PROPS then
			color = cfg["propColor"]
		elseif victim:Team() == TEAM_HUNTERS then
			color = cfg["hunterColor"]
		end
	
		if victim == attacker then
			local text = string.upper(victim:Nick() .. " has commited suicide!")
			addEventMessage(text, color)
		elseif attacker:GetClass() == "worldspawn" then
			local text = string.upper(victim:Nick() .. " has died under mysterious circumstances!")
			addEventMessage(text, color)
		end
	end)
else
	util.AddNetworkString("novusDeathVictim")
	util.AddNetworkString("novusDeathAttacker")
	util.AddNetworkString("novusDeathNotice")
	
	hook.Add("PlayerDeath", "novusDeathNotification", function(victim, inflictor, attacker)
		if IsValid(victim) then		
			net.Start( "novusDeathVictim" )
				net.WriteEntity(victim)
			net.Broadcast()
			
			net.Start( "novusDeathAttacker" )
				net.WriteEntity(attacker)
			net.Broadcast()
			
			net.Start( "novusDeathNotice" )
			net.Broadcast()
		end
	end)
end