# Factorio-Inbuilt-Lighting
Adds configurable free lighting to power poles. Intended for map/zoomed out view and streaming/youtube pre night vision



Adds a free inbuilt light to all power pole types that uses no power. Is a pure QOL mod designed for streamers, youtube or anyone who wants to be able to see their base early game when zoomed out. Its intended for use before night vision goggles, and then when its setting is turned off (0) it removes all of the inbuilt lighting so night vision looks natural.

The mod scales the light for each power pole based on its powering range. There is a global setting to increase/decrease this as a percentage from 0 to massive based on your desires. 0 turns off the inbuilt light entirely.

On loading a map the mod will check the light range percentage setting and either add hidden lights or remove them all as appropriate. They are fully removed from the map when set to 0 to save UPS and entity count.
The mod doesn't change or replace power poles in any way and so if the mod is removed the game will just remove the inbuilt lights and not affect existing power poles.

The mod should be compatible with all other mods as it searches the game for all "electric-pole" type entities during the data-updates phase. Allowing all other mods to add their new power pole types first. No changes to any base or other mod entities occur as hidden lamps are created for each power pole type and then added/removed from the map with power poles.
