Script.Load("lua/GUIInsight_PlayerHealthbars.lua")
local kCompModAmmoColors = {
	["rifle"] = Color(0,0,1,1), // blue
	["pistol"] = Color(0,1,1,1), // teal
	["axe"] = Color(1,1,1,1), // white
	["welder"] = Color(1,1,1,1), // white
	["builder"] = Color(1,1,1,1), // white
	["mine"] = Color(1,1,1,1), // white
	["shotgun"] = Color(0,1,0,1), // green
	["flamethrower"] = Color(1,1,0,1), // yellow
	["grenadelauncher"] = Color(1,0,1,1), // magenta
	["minigun"] = Color(1,0,0,1), // red
	["railgun"] = Color(1,0.5,0,1), // orange
	["heavymachinegun"] = Color(1,0,0,1) // red
}

ReplaceLocals(GUIInsight_PlayerHealthbars.UpdatePlayers, { kArmorColors = {Color(0.5, 1, 1, 1), Color(1,0.8,0,1)}, kAmmoColors = kCompModAmmoColors })