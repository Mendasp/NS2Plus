local kLineTextureCoord = {0, 0, 64, 16}
local kLineTexture = "ui/mapconnector_line.dds"
local kDashedLineTexture = PrecacheAsset("ui/chud_mapconnector_dashed.dds")

function GUIMinimapConnection:UpdateAnimation(teamNumber, modeIsMini)
	local pglines = CHUDGetOption("pglines")

	local animatedArrows = not modeIsMini and teamNumber == kTeam1Index and #GetEntitiesForTeam("MapConnector", kTeam1Index) > 2

	local animation = ConditionalValue(animatedArrows and pglines > 1, (Shared.GetTime() % 1) / 1, 0)

	local x1Coord = kLineTextureCoord[1] - animation * (kLineTextureCoord[3] - kLineTextureCoord[1])
	local x2Coord = x1Coord + (self.length or 0)

	self.line:SetTexture(ConditionalValue(pglines == 2, kDashedLineTexture, kLineTexture))

	-- Don't draw arrows for just 2 PGs, the direction is clear here
	-- Gorge tunnels also don't need this since it is limited to entrance/exit
	local textureIndex = ConditionalValue(animatedArrows and pglines > 0, 16, 0)

	self.line:SetTexturePixelCoordinates(x1Coord, textureIndex, x2Coord, textureIndex + 16)
	self.line:SetColor(ConditionalValue(teamNumber == kTeam1Index, kMarineFontColor, kAlienFontColor))
	self.line:SetSize(Vector(self.length, GUIScale(ConditionalValue(modeIsMini, 6, 10)), 0))
end