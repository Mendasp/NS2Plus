Script.Load("lua/GUIInsight_PlayerHealthbars.lua")

ReplaceLocals(GUIInsight_PlayerHealthbars.UpdatePlayers, { kArmorColors = {Color(0.5, 1, 1, 1), Color(1,0.8,0,1)} })