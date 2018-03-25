local marinePlayers = set {
	kMinimapBlipType.Marine, kMinimapBlipType.JetpackMarine, kMinimapBlipType.Exo
}
local alienPlayers = set {
	kMinimapBlipType.Skulk, kMinimapBlipType.Gorge, kMinimapBlipType.Lerk, kMinimapBlipType.Fade, kMinimapBlipType.Onos,
	kMinimapBlipType.Embryo
}

local mapElements = set {
	kMinimapBlipType.TechPoint, kMinimapBlipType.ResourcePoint
}

local originalMapBlipGetMapBlipColor = MapBlip.GetMapBlipColor
function MapBlip:GetMapBlipColor(minimap, item)

	local returnColor = originalMapBlipGetMapBlipColor(self, minimap, item)

	local player = Client.GetLocalPlayer()
	local highlight = CHUDGetOption("commhighlight")
	local highlightColor = ColorIntToColor(CHUDGetOption("commhighlightcolor"))
	local blipTeam = self:GetMapBlipTeam(minimap)
	local teamVisible = self.OnSameMinimapBlipTeam(minimap.playerTeam, blipTeam) or minimap.spectating
	local isHighlighted = false

	if marinePlayers[self.mapBlipType] then
		returnColor = ColorIntToColor(CHUDGetOption("playercolor_m"))
	elseif alienPlayers[self.mapBlipType] and not (teamVisible and self.isHallucination) then
		returnColor = ColorIntToColor(CHUDGetOption("playercolor_a"))
	elseif mapElements[self.mapBlipType] then
		returnColor = ColorIntToColor(CHUDGetOption("mapelementscolor"))
	elseif player and player:GetIsCommander() and highlight and EnumToString(kTechId, player:GetGhostModelTechId()) == EnumToString(kMinimapBlipType, self.mapBlipType) then
		returnColor = highlightColor
		isHighlighted = true
	end

	if not self.isHallucination then
		if teamVisible then
			if self.isInCombat then
				if self.MinimapBlipTeamIsActive(blipTeam) then
					if isHighlighted then
						local percentage = (math.cos(Shared.GetTime() * 10) + 1) * 0.5
						returnColor = LerpColor(kRed, highlightColor, percentage)
					else
						returnColor = self.PulseRed(1.0)
					end
				else
					returnColor = self.PulseDarkRed(returnColor)
				end
			end
		end
	end

	return returnColor
end
PlayerMapBlip.GetMapBlipColor = MapBlip.GetMapBlipColor

local friendTeams =
{
	[kMinimapBlipTeam.FriendMarine] = kMinimapBlipTeam.Marine,
	[kMinimapBlipTeam.FriendAlien] = kMinimapBlipTeam.Alien
}

local oldGetMapBlipTeam = MapBlip.GetMapBlipTeam
function MapBlip:GetMapBlipTeam(minimap)
	local blipTeam = oldGetMapBlipTeam(self, minimap)

	if not CHUDGetOption("friends") and friendTeams[blipTeam] then
		blipTeam = friendTeams[blipTeam]
	end

	return blipTeam
end
PlayerMapBlip.GetMapBlipTeam = MapBlip.GetMapBlipTeam