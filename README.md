# Factorio-Inbuilt-Lighting


- Options to add a free inbuilt light to power poles and optionally turrets that can use no power and run without a power connection, or can have a power cost set. 
- Is a pure QOL mod designed for streamers, youtube or anyone who wants to be able to see their base early game when zoomed out. 
- Its intended for use before night vision goggles, and then when the lighting settings are turned off it removes all of the inbuilt lighting so night vision looks natural.
- Blueprint friendly as they are regular power poles, so no modded entities in your exported Blueprint, just no lights either.



Options
---------

The mod scales the light for each power pole based on its powering range. There is a global setting to increase/decrease this as a percentage from 0 to massive based on your desires. 0 turns off the inbuilt light entirely and removes them from the map (save any UPS).

The mod can light up turrets. If the feature is enabled it will light up the building plus the set number of tiles around the edge from 0 upwards. Note, large quantities of turrets (500+) with this feature enabled can impact UPS and cause game slowdown. Turn this feature off later in the game when turrets have power and power pole lighting is suitable.

There is a setting to control how much power each inbuilt light requires. It defaults to 0 watts, which means these lights are on without any power network being required. Anything above 0 watts requires active electricity for them to work and thus an active power network. There will never be any low power or no electric connection icons shown for the inbuilt lights regardless of the power usage setting.



Limitations
-----------

The maxiumum lighted radius is limited to 75 due to the Factorio game engine.
Lights in Factorio illuminate the in-game picture you see and so tall building pictures may be half in light and half out, despite their footprint being fully within the lighted area.
If the lights have a power usage set then the Electric Network Info screen will have 1 listing for each radius of light present (1 entry per power pole type). This is unavoidable in the Factorio engine.



Mod Compatibility
-------------

The mod doesn't change or replace buildings or power poles in any way and so if the mod is removed the game will just remove the inbuilt lights and not affect existing power poles.
The mod should be compatible with all other mods that don't move entities around the map. It reacts when entities are placed in the game via standard actions. No changes to any base or other mod entities occur. Hidden lamps are created for all sizes between 1 and 75 tiles at game start.
Support for mods that place & move entities in the map:
	* Creative Mode mod - Instant Construction & Deconstruction
	* Picker Extended - Dollies feature

Should mod compatibility issues occur the command "inbuilt-lighting-reset" is included to tidy up any legacy issues that had occurred prior to support being added. It removes and then re-adds all inbuilt lighting entities on the map.
