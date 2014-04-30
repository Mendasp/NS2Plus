local oldMarineTeamInitTechTree = MarineTeam.InitTechTree
function MarineTeam:InitTechTree()

	oldMarineTeamInitTechTree( self )

	self.techTree:GetTechNode( kTechId.Sentry ).prereq2 = kTechId.None

end
