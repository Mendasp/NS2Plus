Changelog
============
- 27/3/2017
    - Fixed a script error that caused the end stats GUI to fail initializing causing the client's UI to become unresponsive.
    - Made sure that the end stats GUI initializes completely even if it fails to load the LastRoundStats.json due to a script error.
    - Improved how the hiveskillgraph records players joining teams to fix issues with failed team join attempts and players moving to the spectator team
    - Improved the y axis scaling of the hive skill graph to not start at negative values and use a more useful grid resolution.

- 26/3/2017
    - Added an indicator icon for being on fire for everybody using the hidden viewmodel option
    - Added an option to configurate the color of marines when using Cr4zy's Alienvision
    - Added a graph displaying each team's avg. hive skill over the time of the round to the end round stats view.
    - Added an option to display the current time below the minimap
    - Added an option to display the probability of victory for each team at the scoreboard (needs to be enabled by the server admin)
    - Fixed a comaptibility issue with some mods caused by a missing argument in GetEnergyCost
    - Fixed that the custom alien minimap color was not applied to embyros (evolving players)
    - Fixed that the current round time was not displayed for the commander when the given option is enabled
    - Fixed a rare script error occurring while spectating a dying enemy.
    - Fixed that the information (e.g. hp percentage) of the custom nameplates did not update instantly.
    - Fixed that the research progress tooltip started fading out at creation of the tooltip. This caused the tooltip often to not even show up.
    - Fixed that the exo's left minigun's cinematics did not get hidden with minimal particles or hidden viewmodel options enabled.

- 26/12/2017
	- Fixed compatibility problem with b320 emissive-toggle change (power-state changes)
	- Fixed that the custom nameplate style options did not work. Please note that the displayed information of the custom nameplate styles may only update every 200 ms.
	
- 6/12/2017
    - Fixed that the end stats hover menu consumed the player's input after initialization without being visible.
    
- 4/12/2017
    - Added Observatory (https://observatory.morrolan.ch) profile links to the scoreboard and end stats
    - Fixed that the player entry hover menu of the end stats was hidden instantly
    - Fixed that the overhead research tooltips displayed a negative research time after completion
    
- 27/10/2017
    - Fixed compatibility issues with ns2 build 319
    - Added per-lifeform sensitivity for aliens
    - Added some screen-occluding effects of gorge tunnels and embryos to be disabled when minimal particles is enabled

- 6/10/2017
    - Fixed that you couldn't pickup weapons with autopickup disabled with build 318
        

- 30/08/2017
    - Fixed that the hivestatus UI was hidden by default.
    - Fixed that the hide friends at the minimap option still had no effect.
    - Fixed that the minimap location name alpha option did not work and caused script errors.
    - Fixed a script error occurring for commanders caused by the research time tool tips trying to update before the Commander has been fully initialized
    
- 28/08/2017
    - Fixed that the research time tooltips did not work for Commanders
    - Fixed that the mingui option did not effect some minimap and gorge build menu backgrounds
    - Fixed that the custom minimap color options (including hidding friends) had no effect.
    - Fixed a script error occurring while spectating a marine reloading their shotgun.
    - Fixed a script error occurring while spectating a gorge placing structures.
    - Changed the hivestatus option entry to behave like the other option toogles.

- 24/08/2017
	- Refactored the way GUI modifications are loaded to fix and avoid load order issues with new ns2 updates.
	- Fixed the critical performance issues caused by various GUI modifications.
	- Removed the death message icon scaling option because it wasn't working in all situations.
	- Removed the remote config trolling system.
	- Removed the remote config badge system.
	- Updated or removed all outdated web references.
	- Added reload indicators around the crosshair. Also displays ability cool downs for aliens.
	- Made exo overheat UI display proper values to show when we are able to fire again.
	- Added a new option to completely disable the hive status UI.
    - The existing minimal GUI option now removes some background elements from the hive status UI.
    - Added research times to overhead view tech tool tips
      
- 26/05/2017
    - Fixed compatibility issues with the new ns2 help screen	

- 05/03/2017
    - Removed the wc badges as those are part of vanilla ns2 now
    - Refactored the way the gamemode is set in the serverbrowser to avoid conflicts with future ns2 updates
	
- 09/02/2017
    - Improved the stats tracking to work better with recent ns2 changes.

- 28/09/2016
	- Fixed Server Browser ranked filter not working correctly
	- Fix End game stats issue with warmup mode
    
- 15/07/2016
	- Fix enemy health bars showing up while spawning in
    
- 22/06/2016
	- Fixed compatibility issue between feedback GUI and NS2+ end stats
    
- 10/06/2016
	- Take warmup mode into account when checking for game start
    
- 03/06/2016
	- Fixed server browser tabs not showing correct player counts
    
- 31/05/32016
	- Reset options that have been integreated to vanilla
	- Fixed resetting non-slider options in NS2+

- 20/05/2015
	- Autopickup integrated into vanilla
	- Colored wrench integrated to vanilla
	- Khamm range circles integrated to vanilla
	- AV state default to ON integrated to vanilla

    
- 30/04/2016
	- Added High Visibility Gorge spit option, available in Graphics tab (Thanks turtsmcgurts!).

- 23/03/2016
	- Fixed End Stats UI not resizing properly on resolution change sometimes.
	- Fixed options menu displaying reset option button for hidden options in certain circumstances.

- 22/02/2016
	- Added doerLocation and doerPosition to certain kills in the KillFeed table for exported stats to support proper positions for turrets, whips, hydras, etc.

- 10/02/2016
	- Excluded bots from the average skill calculation.
	- Fixed hallucinations not using their own color if the player was using a custom alien minimap color.
	
- 30/01/2011
	- Added shown/total server count to server browser.
	- Added NSL info to scoreboard hover menu for NSL servers.
	- Adjusted server tagging for NSL servers.

- 29/01/2016
	- Added Cr4zy's configurable Alien Vision (Thanks Cr4zy!).
	- Added checkbox in the Server Browser to hide Rookie Only servers.
	- Added button to filter for Hive Whitelisted servers in the Server Browser. The button will only display if the client is able to successfully download the list of whitelisted servers.
	- Moved all weapon pickup options out of "HUD" and into "MISC".
	- Moved weapon tracers from "HUD" into "GRAPHICS".

- 26/01/2016
	- Changed rookieFriendly to rookieOnly for the exported stats as the rookieFriendly tag is now deprecated in Build 282.

- 25/01/2016
	- Added NSL server highlighting, they will show up in blue and will append "NSL" to the gamemode for easy filtering.
	- Excluded team specific FOV and sensitivities from caster mode.
	- Fixed missing percentage sign for exo weapons on classic ammo.
	- Added NSL lights json files to consistency check.
	- Fixed exos not showing proper outline color in overhead spectator.
	
- 13/01/2016
	- Fixed unbuilt RT deaths showing up in the RT graph (allowed for negative RT counts).
	- Stats format changes:
		- Renamed pdmg and sdmg fields to playerDamage and structureDamage.
		- Removed "last" table from player stats which was only meant for internal use.
		- Renamed KillGraph to KillFeed.
		- Renamed ClientStats to PlayerStats.
		- Renamed "weapon" field to "killerWeapon" and "teamNumber" to "killerTeamNumber" in the KillFeed table.
		- Changed "gameMinute" field in KillFeed table to "gameTime", which now returns the time in seconds.
		- Renamed "roundTime" field in RoundInfo table to "roundLength".
		- Fixed kills not showing the killer weapon in the KillFeed table if the player had left the server.

- 12/01/2016
	- Updated exported stats data format.
	- Fixed bug with Marine Commander Medpack accuracy being calculated wrong.

- 10/01/2016
	- RT graph table now contains if the node was recycled.
	- Tech table now contains if (in case of buildings) it was finished and if it was recycled.

- 09/01/2016
	- Fixed bug that wouldn't ignore maxPlayers for each team while the game wasn't live.
	- Removed server option for disabling Hive HTTP connections.
	- New data points for the exported stats:
		- Minimap extents for mapping coordinates to the overview graphic.
		- Destroyed tech in Tech Log, also shows Biomass level on Hive death. If the last Hive was killed it will show as Biomass 1 being "destroyed".
		- Killer/victim class in the kills table.
	- End game stats now shows the loss of important buildings in the Tech Log and Biomass level on Hive death.

- 06/01/2016
	- Added "savestats" option to the server settings (default off). This option allows servers to save the round stats info in a json file located at (CONFIGFOLDER)\NS2Plus\Stats\. Each round will generate a separate file. Mods can also access this info directly by calling CHUDGetLastRoundStats().