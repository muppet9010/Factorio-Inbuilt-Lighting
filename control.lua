local HiddenLight = require("scripts/hidden-light")
local Utils = require("utility/utils")

local function UpdateSetting(settingName)
    if settingName == "power-pole-wire-reach-lighted-percent" or settingName == nil then
        HiddenLight.UpdatedElectricPoleSetting()
    end
    if settingName == "turrets-lighted-edge-tiles" or settingName == nil then
        HiddenLight.UpdatedTurretSetting()
    end
end

local function GetStartUpSettings()
    HiddenLight.HandleResearchEnabledSetting()
end

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
    commands.add_command("inbuilt-lighting-reset", {"api-description.inbuilt-lighting-reset"}, InbuiltLighting_Reset)
end

local function CreateGlobals()
    if global.Mod == nil then
        global.Mod = {}
    end
    if global.Mod.EntityToLightName == nil then
        global.Mod.EntityToLightName = {}
    end
    if global.Mod.EnabledForForce == nil then
        global.Mod.EnabledForForce = {}
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

local function OnBuiltEntity(event)
    local entity
    if event.created_entity ~= nil then
        entity = event.created_entity
    elseif event.entity ~= nil then
        entity = event.entity
    else
        return
    end
    HiddenLight.OnEntityBuilt(entity)
end

local function OnRemovedEntity(event)
    HiddenLight.OnEntityRemoved(event.entity)
end

local function OnSettingChanged(event)
    UpdateSetting(event.setting)
end

local function OnRobotPreMined(event)
    if Utils.WasCreativeModeInstantDeconstructionUsed(event) then
        HiddenLight.OnEntityRemoved(event.entity)
    end
end

local function OnResearchFinished(event)
    HiddenLight.OnResearchFinished(event.research)
    UpdateSetting(nil)
end

script.on_init(OnStartup)
script.on_load(OnLoad)
script.on_configuration_changed(OnStartup)
script.on_event(defines.events.on_runtime_mod_setting_changed, OnSettingChanged)

script.on_event(defines.events.on_built_entity, OnBuiltEntity)
script.on_event(defines.events.on_robot_built_entity, OnBuiltEntity)
script.on_event(defines.events.on_player_mined_entity, OnRemovedEntity)
script.on_event(defines.events.on_entity_died, OnRemovedEntity)
script.on_event(defines.events.on_robot_mined_entity, OnRemovedEntity)
script.on_event(defines.events.on_robot_pre_mined, OnRobotPreMined)
script.on_event(defines.events.script_raised_built, OnBuiltEntity)
script.on_event(defines.events.script_raised_revive, OnBuiltEntity)
script.on_event(defines.events.script_raised_destroy, OnRemovedEntity)
script.on_event(defines.events.on_research_finished, OnResearchFinished)
