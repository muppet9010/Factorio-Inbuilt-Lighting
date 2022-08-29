--[[
	Done as a data-update to allow other mods to manipulate the base lamp before we clone it. ie: change turn on/off times.
]]
local Constants = require("constants")

local light_brightness = settings.startup["inbuilt_lighting-light_brightness"].value

local function GenerateHiddenLight(tile, name)
    if name == nil then
        name = tile
    end
    local lightRange = tile * 5
    local hiddenLight = table.deepcopy(data.raw["lamp"]["small-lamp"])
    hiddenLight.name = "hiddenlight-" .. name
    hiddenLight.collision_mask = {} -- So nothing can collide with it and do damage.
    hiddenLight.flags = { "not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map", "not-upgradable", "not-in-kill-statistics" } -- So if it should die somehow (script?) it still won't appear in any kills/losses list.
    hiddenLight.selection_box = nil --makes a nice cross on the powered area rather than a default sized box
    hiddenLight.selectable_in_game = false
    hiddenLight.picture_off = {
        filename = Constants.AssetModName .. "/graphics/transparent.png",
        priority = "very-low",
        width = 1,
        height = 1
    }
    hiddenLight.picture_on = {
        filename = Constants.AssetModName .. "/graphics/transparent.png",
        priority = "very-low",
        width = 1,
        height = 1
    }
    hiddenLight.light = { intensity = light_brightness, size = lightRange, color = { r = 1.0, g = 1.0, b = 1.0 } }
    if settings.startup["light-power-usage-watts"].value > 0 then
        hiddenLight.energy_usage_per_tick = settings.startup["light-power-usage-watts"].value .. "W"
    else
        hiddenLight.energy_source.type = "void"
        hiddenLight.energy_usage_per_tick = "1W"
    end
    hiddenLight.energy_source.render_no_network_icon = false
    hiddenLight.energy_source.render_no_power_icon = false
    hiddenLight.next_upgrade = nil -- Added to be compatible with Xander Mod
    return hiddenLight
end

local function GenerateHiddenLights()
    local poleLights = {}
    for tile = 1, 75 do
        table.insert(poleLights, GenerateHiddenLight(tile, tile))
    end
    data:extend(poleLights)
end

--Used to connect the hidden lights when there is no electric network there and no power usage set (work around engine feature)
local function GenerateHiddenLightElectricPole()
    local hiddenLightPole = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"])
    hiddenLightPole.name = "hiddenlightpole"
    hiddenLightPole.collision_mask = {} -- So nothing can collide with it and do damage.
    hiddenLightPole.flags = { "not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map", "not-upgradable", "not-in-kill-statistics" } -- So if it should die somehow (script?) it still won't appear in any kills/losses list.
    hiddenLightPole.selectable_in_game = false
    hiddenLightPole.maximum_wire_distance = 0
    hiddenLightPole.supply_area_distance = 0.1
    hiddenLightPole.pictures = {
        filename = Constants.AssetModName .. "/graphics/transparent.png",
        priority = "very-low",
        width = 1,
        height = 1,
        direction_count = 4
    }
    hiddenLightPole.next_upgrade = nil -- Added to be compatible with Xander Mod.
    data:extend({ hiddenLightPole })
end

GenerateHiddenLights()
GenerateHiddenLightElectricPole()
