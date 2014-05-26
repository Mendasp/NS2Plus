// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\TechTreeConstants.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================


kTechId = enum {
    
    'None', 'PingLocation',
    
    'VoteConcedeRound',
    
    'SpawnMarine', 'SpawnAlien', 'CollectResources', 'TransformResources', 'Research',
    
    // General orders and actions ("Default" is right-click)
    'Default', 'Move', 'Patrol', 'Attack', 'Build', 'Construct', 'AutoConstruct', 'Grow', 'Cancel', 'Recycle', 'Weld', 'AutoWeld', 'Stop', 'SetRally', 'SetTarget', 'Follow', 'HoldPosition', 'FollowAlien',
    // special mac order (follows the target, welds the target as priority and others in range)
    'FollowAndWeld',
    
    // Alien specific orders
    'AlienMove', 'AlienAttack', 'AlienConstruct', 'Heal', 'AutoHeal',
    
    // Commander menus for selected units
    'RootMenu', 'BuildMenu', 'AdvancedMenu', 'AssistMenu', 'MarkersMenu', 'UpgradesMenu', 'WeaponsMenu',
    
    // Robotics factory menus
    'RoboticsFactoryARCUpgradesMenu', 'RoboticsFactoryMACUpgradesMenu', 'UpgradeRoboticsFactory',

    'ReadyRoomPlayer', 
    
    // Doors
    'Door', 'DoorOpen', 'DoorClose', 'DoorLock', 'DoorUnlock',

    // Misc
    'ResourcePoint', 'TechPoint', 'SocketPowerNode', 'Mine',
    
    /////////////
    // Marines //
    /////////////
    
    // Marine classes + spectators
    'Marine', 'Exo', 'MarineCommander', 'JetpackMarine', 'Spectator', 'AlienSpectator',
    
    // Marine alerts (specified alert sound and text in techdata if any)
    'MarineAlertAcknowledge', 'MarineAlertNeedMedpack', 'MarineAlertNeedAmmo', 'MarineAlertNeedOrder', 'MarineAlertHostiles', 'MarineCommanderEjected', 'MACAlertConstructionComplete',    
    'MarineAlertSentryFiring', 'MarineAlertCommandStationUnderAttack',  'MarineAlertSoldierLost', 'MarineAlertCommandStationComplete',
    
    'MarineAlertInfantryPortalUnderAttack', 'MarineAlertSentryUnderAttack', 'MarineAlertStructureUnderAttack', 'MarineAlertExtractorUnderAttack', 'MarineAlertSoldierUnderAttack',
    
    'MarineAlertResearchComplete', 'MarineAlertManufactureComplete', 'MarineAlertUpgradeComplete', 'MarineAlertOrderComplete', 'MarineAlertWeldingBlocked', 'MarineAlertMACBlocked', 'MarineAlertNotEnoughResources', 'MarineAlertObjectiveCompleted', 'MarineAlertConstructionComplete',
    
    // Marine orders 
    'Defend',
    
    // Special tech
    'TwoCommandStations', 'ThreeCommandStations',

    // Marine tech 
    'CommandStation', 'MAC', 'Armory', 'InfantryPortal', 'Extractor', 'ExtractorArmor', 'Sentry', 'ARC',
    'PowerPoint', 'AdvancedArmoryUpgrade', 'Observatory', 'Detector', 'DistressBeacon', 'PhaseGate', 'RoboticsFactory', 'ARCRoboticsFactory', 'ArmsLab',
    'SentryBattery', 'PrototypeLab', 'AdvancedArmory',
    
    // Weapon tech
    'AdvancedWeaponry', 'ShotgunTech', 'HeavyRifleTech', 'DetonationTimeTech', 'FlamethrowerRangeTech', 'GrenadeLauncherTech', 'FlamethrowerTech', 'FlamethrowerAltTech', 'WelderTech', 'MinesTech',
    'GrenadeTech', 'ClusterGrenade', 'ClusterGrenadeProjectile', 'GasGrenade', 'GasGrenadeProjectile', 'PulseGrenade', 'PulseGrenadeProjectile',
    'DropWelder', 'DropMines', 'DropShotgun', 'DropGrenadeLauncher', 'DropFlamethrower',
    
    // Marine buys
    'FlamethrowerAlt',
    
    // Research 
    'PhaseTech', 'MACSpeedTech', 'MACEMPTech', 'ARCArmorTech', 'ARCSplashTech', 'JetpackTech', 'ExosuitTech',
    'DualMinigunTech', 'DualMinigunExosuit', 'UpgradeToDualMinigun',
    'ClawRailgunTech', 'ClawRailgunExosuit',
    'DualRailgunTech', 'DualRailgunExosuit', 'UpgradeToDualRailgun',
    'DropJetpack', 'DropExosuit',
    
    // MAC (build bot) abilities
    'MACEMP', 'Welding',
    
    // Weapons 
    'Rifle', 'Pistol', 'Shotgun', 'HeavyRifle', 'Claw', 'Minigun', 'Railgun', 'GrenadeLauncher', 'Flamethrower', 'Axe', 'LayMines', 'Welder',
    
    // Armor
    'Jetpack', 'JetpackFuelTech', 'JetpackArmorTech', 'Exosuit', 'ExosuitLockdownTech', 'ExosuitUpgradeTech',
    
    // Marine upgrades
    'Weapons1', 'Weapons2', 'Weapons3', 'CatPackTech',
    'Armor1', 'Armor2', 'Armor3', 'NanoArmor',
    
    // Activations
    'ARCDeploy', 'ARCUndeploy',
    
    // Marine Commander abilities
    'NanoShieldTech', 'NanoShield', 'PowerSurge', 'Scan', 'AmmoPack', 'MedPack', 'CatPack',
    
    ////////////
    // Aliens //
    ////////////
    
    // bio mass levels
    'Biomass', 'BioMassOne', 'BioMassTwo', 'BioMassThree', 'BioMassFour', 'BioMassFive', 'BioMassSix', 'BioMassSeven', 'BioMassEight', 'BioMassNine',
    // those are available at the hive
    'ResearchBioMassOne', 'ResearchBioMassTwo', 'ResearchBioMassThree', 'ResearchBioMassFour',

    'DrifterEgg', 'Drifter', 

    // Alien lifeforms 
    'Skulk', 'Gorge', 'Lerk', 'Fade', 'Onos', "AlienCommander", "AllAliens", "Hallucination", "DestroyHallucination",
    
    // Special tech
    'TwoHives', 'ThreeHives', 'UpgradeToCragHive', 'UpgradeToShadeHive', 'UpgradeToShiftHive',
    
    'HydraSpike',

    'LifeFormMenu', 'SkulkMenu', 'GorgeMenu', 'LerkMenu', 'FadeMenu', 'OnosMenu',

    // Alien structures 
    'Hive', 'HiveHeal', 'CragHive', 'ShadeHive', 'ShiftHive','Harvester', 'Egg', 'Embryo', 'Hydra', 'Cyst', 'Clog', 'GorgeTunnel',
    'GorgeEgg', 'LerkEgg', 'FadeEgg', 'OnosEgg',
    
    // Infestation upgrades
    'MucousMembrane',
    
    // personal upgrade levels
    'Shell', 'TwoShells', 'ThreeShells', 'SecondShell', 'ThirdShell', 'FullShell',
    'Veil', 'TwoVeils', 'ThreeVeils', 'SecondVeil', 'ThirdVeil', 'FullVeil',
    'Spur', 'TwoSpurs', 'ThreeSpurs', 'SecondSpur', 'ThirdSpur', 'FullSpur',

    // Upgrade buildings and abilities (structure, upgraded structure, passive, triggered, targeted)
    'Crag', 'TwoCrags', 'CragHeal',
    'Whip', 'TwoWhips', 'EvolveBombard', 'WhipBombard', 'WhipBombardCancel', 'WhipBomb', 'Slap',
    'Shift', 'TwoShifts', 'SelectShift', 'EvolveEcho', 'ShiftHatch', 'ShiftEcho', 'ShiftEnergize', 
    'Shade', 'TwoShades', 'EvolveHallucinations', 'ShadeDisorient', 'ShadeCloak', 'ShadePhantomMenu', 'ShadePhantomStructuresMenu',
    'UpgradeCeleritySpur', 'CeleritySpur', 'UpgradeAdrenalineSpur', 'AdrenalineSpur', 'UpgradeHyperMutationSpur', 'HyperMutationSpur',
    'UpgradeSilenceVeil', 'SilenceVeil', 'UpgradeCamouflageVeil', 'CamouflageVeil', 'UpgradeAuraVeil', 'AuraVeil', 'UpgradeFeintVeil', 'FeintVeil',
    'UpgradeRegenerationShell', 'RegenerationShell', 'UpgradeCarapaceShell', 'CarapaceShell',
    'DrifterCamouflage', 'DrifterCelerity', 'DrifterRegeneration',
    
    'DefensivePosture', 'OffensivePosture', 'AlienMuscles', 'AlienBrain',
    
    'UpgradeSkulk', 'UpgradeGorge', 'UpgradeLerk', 'UpgradeFade', 'UpgradeOnos',
    
    'ContaminationTech', 'RuptureTech', 'BoneWallTech',
    
    // Skulk abilities    
    'Bite', 'Sneak', 'Parasite', 'Leap', 'Xenocide',
    
    // gorge abilities
    'Spit', 'Spray', 'BellySlide', 'BabblerTech', 'BuildAbility', 'BabblerAbility', 'Babbler', 'BabblerEgg', 'GorgeTunnelTech', 'BileBomb',  'WebTech', 'Web', 'HydraTech',

    // lerk abilities
    'LerkBite', 'Cling', 'Spikes', 'Umbra', 'Spores',

    // fade abilities   
    'Swipe', 'Blink', 'ShadowStep', 'Vortex', 'Stab', 
    
    // onos abilities
    'Gore', 'Smash', 'Charge', 'BoneShield', 'Stomp', 'Shockwave', 
    
    // echo menu
    'TeleportHydra', 'TeleportWhip', 'TeleportTunnel', 'TeleportCrag', 'TeleportShade', 'TeleportShift', 'TeleportVeil', 'TeleportSpur', 'TeleportShell', 'TeleportHive', 'TeleportEgg', 'TeleportHarvester',
    
    // Whip movement
    'WhipRoot', 'WhipUnroot',
    
    // Alien abilities and upgrades
    'Carapace', 'Regeneration', 'Aura', 'Silence', 'Feint', 'Camouflage', 'Phantom', 'Celerity', 'Adrenaline', 'HyperMutation',  
    
    // Alien alerts
    'AlienAlertNeedHarvester', 'AlienAlertNeedMist', 'AlienAlertNeedDrifter', 'AlienAlertNeedHealing', 'AlienAlertStructureUnderAttack', 'AlienAlertHiveUnderAttack', 'AlienAlertHiveDying', 'AlienAlertHarvesterUnderAttack',
    'AlienAlertLifeformUnderAttack', 'AlienAlertGorgeBuiltHarvester', 'AlienCommanderEjected',
    'AlienAlertOrderComplete',
    'AlienAlertNotEnoughResources', 'AlienAlertResearchComplete', 'AlienAlertManufactureComplete', 'AlienAlertUpgradeComplete', 'AlienAlertHiveComplete',
    
    // Pheromones
    'ThreatMarker', 'LargeThreatMarker', 'NeedHealingMarker', 'WeakMarker', 'ExpandingMarker',
    
    // Infestation
    'Infestation',
    
    // Commander abilities
    'NutrientMist', 'Rupture', 'BoneWall', 'Contamination', 'SelectDrifter', 'HealWave', 'CragUmbra', 'ShadeInk', 'EnzymeCloud', 'Hallucinate', 'SelectHallucinations', 'Storm',
    
    // Alien Commander hallucinations
    'HallucinateDrifter', 'HallucinateSkulk', 'HallucinateGorge', 'HallucinateLerk', 'HallucinateFade', 'HallucinateOnos',
    'HallucinateHive', 'HallucinateWhip', 'HallucinateShade', 'HallucinateCrag', 'HallucinateShift', 'HallucinateHarvester', 'HallucinateHydra',
    
    // Voting commands
    'VoteDownCommander1', 'VoteDownCommander2', 'VoteDownCommander3',
    
    'GameStarted',
    
    'DeathTrigger',

    // Maximum index
    'Max'
    
    }
    
function StringToTechId(string)
    return rawget(kTechId, string) or kTechId.None
end     

// Increase techNode network precision if more needed
kTechIdMax  = math.pow( 2, math.ceil( math.log(kTechId.Max)/math.log(2) ) ) - 1 -- use all the bits
    
// Tech types
kTechType = enum({ 'Invalid', 'Order', 'Research', 'Upgrade', 'Action', 'Buy', 'Build', 'EnergyBuild', 'Manufacture', 'Activation', 'Menu', 'EnergyManufacture', 'PlasmaManufacture', 'Special', 'Passive' })

// Button indices
kRecycleCancelButtonIndex   = 12
kMarineUpgradeButtonIndex   = 5
kAlienBackButtonIndex       = 8

