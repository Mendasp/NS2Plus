local oldCreateTimeLimitedDecal = Client.CreateTimeLimitedDecal
function Client.CreateTimeLimitedDecal(materialName, coords, scale, lifeTime)

	if not lifeTime then
		lifeTime = Client.GetOptionFloat("graphics/decallifetime", 0.2) * kDecalMaxLifetime * CHUDGetOption("maxdecallifetime")
	end
	
	oldCreateTimeLimitedDecal(materialName, coords, scale, lifeTime)

end