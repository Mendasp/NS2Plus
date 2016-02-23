NS2+
==========
This Natural Selection 2 mod aims to improve, fix and expand the game in order to bring players a better experience. It contains extra customization options and quality of life improvements. This mod needs to be installed on the server.

Latest changes
==============
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

Server settings
===============
Server operators can adjust some features for NS2+ through the console (typing "sv_plus" in console), or change them in the NS2PlusServerSettings.json file located in the server config folder.
- Enable/Disable client features
	- **allow_ambient:** Enables or disables the ability to disable map ambient sounds for clients.
	- **allow_mapparticles:** Enables or disables the ability to disable the map particles for clients.
	- **allow_nsllights:** Enables or disables the ability to use the NSL lights for clients.
	- **allow_deathstats:** Enables or disables the display of stats when players die.
	- **allow_drawviewmodel:** Enables or disables the ability to hide player models. Disabled by default.
	
- Server features
	- **autodisplayendstats:** Enables or disables the end game stats displaying automatically upon game end.
	- **endstatsteambreakdown:** Enables or disables the end game stats displaying the full team breakdown. This is the table with kills, deaths, accuracy, etc.
	- **modupdater:** Enables or disables the mod update checker. This will notify players that mods running on the server have been updated during the round and that new players cannot join until the map is changed. If the server is using a mod backup server it will display a different notification.
	- **modupdatercheckinterval:** Sets the update check interval for the mod updater (in minutes).
	- **modupdaterreminderinterval:** Sets the time between reminders when an update has been found. Set to 0 to disable (only shows once).
	- **showavgteamskill:** Shows the average team skill at the top of the scoreboard for clients.
	- **showplayerskill:** Shows each player's Hive skill on the scoreboard before the game starts.
	- **savestats:** Saves the last round stats in the NS2Plus\\Stats\\ folder in your config path in json format. Each round played will be saved in a separate file. The file name for each round is the epoch time at round end. Disabled by default.

Stats format
============
For the modders or people interested in making use of the stats gathered by NS2+, they can either call CHUDGetLastRoundStats() after the round has ended (it updates the data on NS2Gamerules:EndGame()), or use the "savestats" server option, which will give them access to the tables that NS2+ uses to store the info during the round that gets sent to the players at the end of the game.

**Locations**

This table will store an array with the location names, the index of each entry will be used in the other tables to refer to each location in order to save some space.

For example in "Locations":["North Tech","South Tech"], North Tech would be referred as 1, and South Tech as 2.

**ServerInfo**

| Field          | Description                                                                        |
|----------------|------------------------------------------------------------------------------------|
| slots          | Number of slots for this server.                                                   |
| mods           | Table that contains the modId and name for each of the mods active in this server. |
| buildNumber    | NS2 build number for this round.                                                   |
| rookieOnly     | Shows if the server is rookie only or not.                                         |
| ip             | Server IP.                                                                         |
| port           | Server port.                                                                       |
| name           | Server name.                                                                       |

**RoundInfo**

| Field             | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| roundDate         | Epoch time for the round.                                                   |
| winningTeam       | Team that won the game (0 = Draw, 1 = Marines, 2 = Aliens).                 |
| roundLength       | Round length, in seconds.                                                   |
| tournamentMode    | Will show if the game had tournament mode enabled (true/false).             |
| mapName           | Name of the map played.                                                     |
| startingLocations | Table with the starting locations for each team, (1 = Marines, 2 = Aliens). It uses the location name index from the Locations table. |
| maxPlayers1       | The maximum amount of players the marine team had during the round.         |
| maxPlayers2       | The maximum amount of players the alien team had during the round.          |
| minimapExtents    | Table with the minimap extents to map coordinates to the overview. Contains "origin" and "scale". |

**Research**

This table contains all the researches done during the game.

| Field      | Description                                     |
|------------|-------------------------------------------------|
| teamNumber | Team that owns the research.                    |
| gameTime   | Time when this research completed (in seconds). |
| researchId | Name of the tech researched.                    |

**Buildings**

Here we can find building completions, deaths and recycles during the games. If built = true and destroyed = false, it means the building finished construction. When a building is recycled, the destroyed field will also be true.

| Field      | Description                                              |
|------------|----------------------------------------------------------|
| teamNumber | Team that owns the building.                             |
| gameTime   | Time when this building action completed (in seconds).   |
| built      | If the building was completely built when this happened. |
| recycled   | The building was recycled.                               |
| destroyed  | The building was destroyed.                              |
| techId     | Name of the building.                                    |
| biomass    | **(Optional)** This will only show up when a Hive dies to be able to track how much biomass was lost. |

**PlayerStats**

The first field in this table is the SteamID for each recorded player in the game. Inside each table, you will find tables for each team that the player played in (1 = Marines, 2 = Aliens), each of these team tables has these fields:

| Field           | Description                                                           |
|-----------------|-----------------------------------------------------------------------|
| kills           | Number of kills.                                                      |
| deaths          | Number of deaths.                                                     |
| assists         | Number of assists.                                                    |
| score           | Player score for the round.                                           |
| timeBuilding    | Time that the player has spent building during the round, in seconds. |
| hits            | Number of attacks that hit (this includes Onos hits).                 |
| onosHits        | Number of attacks that hit an Onos.                                   |
| misses          | Number of attacks that missed.                                        |
| killstreak      | Best killstreak during the round.                                     |
| isRookie        | Shows if this player is a rookie (true/false).                        |
| timePlayed      | Time that the player was on this team for the round, in seconds.      |
| commanderTime   | Time that the player spent as commander for this team, in seconds.    |
| playerDamage    | Player damage.                                                        |
| structureDamage | Structure damage.                                                     |

It also has a table ("weapons") for the weapons used by the player, which contains the following:

| Field           | Description                                           |
|-----------------|-------------------------------------------------------|
| teamNumber      | The player's team (1 = Marines, 2 = Aliens).          |
| hits            | Number of attacks that hit (this includes Onos hits). |
| onosHits        | Number of attacks that hit an Onos.                   |
| misses          | Number of attacks that missed.                        |
| kills           | Number of kills with this weapon.                     |
| playerDamage    | Player damage with this weapon.                       |
| structureDamage | Structure damage with this weapon.                    |

Also contains a status table ("status"), which shows the breakdown of classes for the player during the round:

| Field     | Description                     |
|-----------|---------------------------------|
| statusId  | Name of the class.              |
| classTime | Time as this class, in seconds. |

These are the rest of the fields inside each SteamID entry:

| Field      | Description                               |
|------------|-------------------------------------------|
| playerName | The player nickname ingame.               |
| lastTeam   | Last team the player belonged to.         |
| hiveSkill  | Hive Skill for the player for this round. |
| isRookie   | Shows if the player is a rookie.          |

**MarineCommStats**

The first field in this table is the SteamID for each recorded marine Commander in the game. Inside each table, you will find a table for each type of drop, as follows:

medpack

| Field      | Description                                                                    |
|------------|--------------------------------------------------------------------------------|
| hitsAcc    | Number of medpacks dropped directly on players. Used for the medpack accuracy. |
| picks      | Number of medpacks picked up by players at any point.                          |
| misses     | Number of medpacks that are never picked up.                                   |
| refilled   | Amount of health given to players through medpacks.                            |

ammopack

| Field      | Description                                           |
|------------|-------------------------------------------------------|
| picks      | Number of ammopacks picked up by players.             |
| misses     | Number of ammopacks that are never picked up.         |
| refilled   | Amount of bullets given to players through ammopacks. |

catpack

| Field  | Description                                  |
|--------|----------------------------------------------|
| picks  | Number of catpacks picked up by players.     |
| misses | Number of catpacks that are never picked up. |

**KillFeed**

Some fields will be null sometimes like in Suicides or death by Natural Causes or killing bots (they don't have SteamIDs).

| Field            | Description                                                                        |
|------------------|------------------------------------------------------------------------------------|
| killerTeamNumber | Team that got awarded this kill (1 = Marines, 2 = Aliens).                         |
| killerWeapon     | Weapon used for the kill. Will be "None" for Natural Causes/Suicide.               |
| killerClass      | The killer's class.                                                                |
| killerPosition   | Map coordinates for the killer's position.                                         |
| killerLocation   | Location name index for the killer's position.                                     |
| doerPosition     | Map coordinates for the killer entity position (grenades/turrets/hydras, etc).     |
| doerLocation     | Location name index for the killer entity position (grenades/turrets/hydras, etc). |
| victimClass      | The victim's class.                                                                |
| victimPosition   | Map coordinates for the victim's position.                                         |
| victimLocation   | Location name index for the victim's position.                                     |
| gameTime         | Game time when this happened (in seconds).                                         |

Credits/Thanks to
=================
- Regular contributors
	- [**remi.D**](https://github.com/sclark39)
	- **rantology**

- Also thanks to
	- [**Unknown Worlds Entertainment**](http://unknownworlds.com)
	- [**Dragon**](https://github.com/xToken)
	- [**bawNg**](https://github.com/bawNg)
	- **lwf** - [(Better NS2)](http://steamcommunity.com/sharedfiles/filedetails/?id=113116595)
	- [**Ghoul**](https://github.com/BrightPaul)
	- **Sewlek**
	- [**Person8880**](https://github.com/Person8880)

Past NS2+ features now included in vanilla NS2:
=================
- [286] The server browser highlights ranked servers.
- [286] The server browser shows the total number of servers available as well as the total number that pass your filter settings.
- [286] Resource nodes and Tech Points are highlighted on the minimap.
- [276] Added extra bindings for voiceover options: "Weld me", "Follow me", etc.
- [276] Dropped weapon expire times now are displayed for the commander.
- [273] You can click on the scoreboard to check a player's Steam/NS2 profile.
- [273] Scoreboard displays if someone is your steam friend.
- [273] You can mute voice/text independently and it's persistent across map changes up to 6 hours.
- [273] The scoreboard now truncates player names if they overlap with the rest of the elements.
- [272] Modified vanilla scoreboard to make it usable at low resolutions. It will automatically scroll to your position if you are in RR or in a team. You can use the mousewheel, home/end/pgup/pgdn or click and drag to scroll.
- [272] Scoreboard shows the Commander background in yellow instead of the name, so you can identify rookie players that are commanding.
- [272] Medpacks, ammo, and catpacks can be picked up from any height difference.
- [270] Scoreboard displays the number of connecting players.
- [270] In the voice request menu you can now select items by moving the mouse past them (similar to NS1).
- [270] Building range circles now use decals instead of models.
- [270] Added an option in the sound tab to continue recording after the microphone button has been released for a fraction of a second to help ensure your last word isn't cut off (defaults to 150ms).
- [268] Marine weapons now reload automatically upon firing the last bullet.
- [268] Commanders can marquee select enemy units when there's no friendly units in the marquee.
- [268] Grenade collision radius is more representative of the visual model (proximity detonation radius is unchanged).
- [268] You can click on the player frames on the sides to autofollow a player. Click again to stop following.
- [268] Shotgun lights in the model reflect ammo count.
- [268] Weapon displays flash red when low on ammo.
- [268] Added unsocketed and blueprint states for Power Nodes in the minimap. You can now see all Power Node states.
- [268] Alien Commanders can see the energy for their teammates.
- [268] High contrast colors for health/armor in Insight spectator.
- [267] Marine players and the Marine Commander can see the time until the weapon disappears when it's been dropped.
- [267] Make the outline color yellow for parasited players and purple when they have received a catpack in overhead.
- [267] Added bonewall icon to map.
- [267] Items that disappear after some time on the ground now display an expiration bar for all Marine players (including the Marine Commander).
- [267] Server-confirmed hitsounds.
- [267] The armory and infantry portal arms don’t block bullets anymore.
- [267] Lerks can see damage numbers for the poison bite's damage over time.
- [267] When a structure bleeds out the killfeed will show the killer as whoever hit it last.
- [267] You can see the class of your evolving teammates.
- [267] The kill feed highlights your player kills. Icons in the killfeed are properly scaled too.
- [267] Dropped weapons outlines are color coded for improved readability.
- [267] Infantry Portals will show the name and progress of the player that is about to spawn.
- [267] Evolving alien players will show their evolution progress for their teammates.
- [267] Scoreboard keeps the time of the previous round until the next one starts.
- [267] Dropped marine weapons are outlined for the marine commander and spectators.
- [267] Spectators can see deployed mines highlighted with a blue outline, and the outline will turn yellow if the mine has been parasited.
- [267] Added slight impulse to dropped weapons.
- [267] Enabled weapon specific ammo models for dropped weapons.
- [266] Marine commanders can see the marine ammo bar with the color that's used in the overview spectator mode to easily identify the weapon the marine is carrying.
- [266] Commanders can see building ranges before dropping them.
- [266] Adds player upgrades to the Insight player frames.
- [266] Adds Lerk deaths to Insight alerts.
- [266] Alltalk displays the correct team color/background for voice chat.
- [266] Mods list is sorted automatically as Active > Subscribed > Alphabetically. You can also sort by column.
- [266] Connections between Phase Gates or Gorge Tunnels are now colored depending on the team. If there’s more than 2 PGs it will switch to lines with animated arrows.
- [265] Parasited players display their name yellow for teammates and spectators.

Past NS2+ fixes now included in vanilla NS2:
=================
- [274] Fixed scoreboard hiding the GUIHoverMenu every frame as long as the scoreboard wasn't up.
- [274] Fixed jetpacks left behind by dead marines not dissolving with the body on death.
- [274] Fixed Medpacks/Ammo/Catpacks not showing the pickup icons.
- [272] Fixed server crash related to picking up a jetpack and a weapon at the same time.
- [272] Fixed kill feed being obscured by the death screen fade to black.
- [270] Fixed players having voice communication cut off while entering or exiting commander mode.
- [270] Fixed occasional error when attempting to enter the Mods menu.
- [268] Fixed bug that made trigger volumes bigger than their representation in the editor. This affected some map locations (power node issues).
- [268] Fixed bug where the Commander would log out attacking.
- [267] Made location text for marines left aligned so long location names can fit in the UI
- [267] Fixed Bonewall not having pre-drop range.
- [267] Fixed bug where Shotguns and Exo Minigun didn't shoot through soft targets.
- [267] Fixed drifters trying to build structures they can't and fake-building them forever.
- [266] Fixed sentries not being able to be dropped until the first sentry battery is finished.
- [266] Fixed scoreboard not showing Spectators to players on teams.
- [266] Fixed commander selection bug that made buildings selected with hotgroups not respond properly sometimes.
- [266] Fixed lights staying red if the power node was under attack (infestation).
- [266] Fixed bug where damage numbers wouldn't show the damage done in the killing blow.
- [265] Fixed skulk jump sound loudness (50% reduced). 
- [265] Fixed skulk growl sound when walking.
- [265] Fixed inactive/unbuilt structures not blinking red when under attack.
- [265] Fixed alien structures not blinking red when uncysted.

Copyright 2016 - [Mendasp](http://steamcommunity.com/profiles/76561197960305571/). All rights reserved.
