local HiddenLight = require("scripts/hidden-light")
local Utils = require("utility/utils")

---@param settingName string?
local function UpdateSetting(settingName)
    if settingName == "power-pole-powered-area-lighted-percent" or settingName == "power-pole-connection-reach-lighted-percent" or settingName == nil then
        HiddenLight.UpdatedElectricPoleSetting()
    end
    if settingName == "turrets-lighted-edge-tiles" or settingName == nil then
        HiddenLight.UpdatedTurretSetting()
    end
end

local function GetStartUpSettings()
    HiddenLight.HandleResearchEnabledSetting()
end

--- Update all of the lights on the map.
local function InbuiltLighting_Reset()
    HiddenLight.RemoveAllModEntities()
    UpdateSetting(nil)
end

local function RegisterEvents()
    --Picker Extended Mod - Dolly entity movement feature event
    if remote.interfaces["picker"] and remote.interfaces["picker"]["dolly_moved_entity_id"] then
        script.on_event(remote.call("picker", "dolly_moved_entity_id"), HiddenLight.PickerDollyEntityMoved)
    end
end

local function RegisterCommands()
    commands.remove_command("inbuilt-lighting-reset")
    commands.add_command("inbuilt-lighting-reset", { "api-description.inbuilt-lighting-reset" }, InbuiltLighting_Reset)
end

local function CreateGlobals()
    if global.Mod == nil then
        global.Mod = {} ---@type table
    end
    if global.Mod.EntityToLightName == nil then
        global.Mod.EntityToLightName = {} ---@type table<string, string> # In-game entity name to light entity name.
    end
    if global.Mod.EnabledForForce == nil then
        global.Mod.EnabledForForce = {} ---@type table<string, boolean> # Keyed as force name.
    end
end

local function OnStartup()
    CreateGlobals()
    GetStartUpSettings()
    UpdateSetting(nil)
    RegisterEvents()
    RegisterCommands()
end

local function OnLoad()
    RegisterEvents()
    RegisterCommands()
end

---@param event EventData.on_built_entity|EventData.on_robot_built_entity|EventData.script_raised_built|EventData.script_raised_revive
local function OnBuiltEntity(event)
    local entity ---@type LuaEntity
    if event.created_entity ~= nil then
        entity = event.created_entity
    elseif event.entity ~= nil then
        entity = event.entity
    else
        return
    end
    HiddenLight.OnEntityBuilt(entity)
end

---@param event EventData.on_player_mined_entity|EventData.on_entity_died|EventData.on_robot_mined_entity|EventData.script_raised_destroy
local function OnRemovedEntity(event)
    HiddenLight.OnEntityRemoved(event.entity, nil)
end

---@param event EventData.on_runtime_mod_setting_changed
local function OnSettingChanged(event)
    UpdateSetting(event.setting)
end

---@param event EventData.on_robot_pre_mined
local function OnRobotPreMined(event)
    if Utils.WasCreativeModeInstantDeconstructionUsed(event) then
        HiddenLight.OnEntityRemoved(event.entity, nil)
    end
end

---@param event EventData.on_research_finished
local function OnResearchFinished(event)
    local technology = event.research
    if technology.name ~= "inbuilt-lighting" then
        return
    end
    HiddenLight.OnInbuiltLightsResearchFinished(technology)
    UpdateSetting(nil)
end

script.on_init(OnStartup)
script.on_load(OnLoad)
script.on_configuration_changed(OnStartup)
script.on_event(defines.events.on_runtime_mod_setting_changed, OnSettingChanged)

-- Filter to all the entity types we might react too. Avoids dynamic changing.
local entityTypeFilter = { { filter = "type", type = "electric-pole" }, { filter = "turret" }, { filter = "type", type = "artillery-turret" } }
script.on_event(defines.events.on_built_entity, OnBuiltEntity, entityTypeFilter)
script.on_event(defines.events.on_robot_built_entity, OnBuiltEntity, entityTypeFilter)
script.on_event(defines.events.on_player_mined_entity, OnRemovedEntity, entityTypeFilter)
script.on_event(defines.events.on_entity_died, OnRemovedEntity, entityTypeFilter)
script.on_event(defines.events.on_robot_mined_entity, OnRemovedEntity, entityTypeFilter)
script.on_event(defines.events.on_robot_pre_mined, OnRobotPreMined, entityTypeFilter)
script.on_event(defines.events.script_raised_built, OnBuiltEntity, entityTypeFilter)
script.on_event(defines.events.script_raised_revive, OnBuiltEntity, entityTypeFilter)
script.on_event(defines.events.script_raised_destroy, OnRemovedEntity, entityTypeFilter)
script.on_event(defines.events.on_research_finished, OnResearchFinished)
