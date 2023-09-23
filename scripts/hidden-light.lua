local HiddenLight = {}
local Utils = require("utility/utils")

---@param entityPrototype LuaEntityPrototype
---@return double
function HiddenLight.FindEntityPrototypeRadius(entityPrototype)
    local xRange = entityPrototype.collision_box.right_bottom.x - entityPrototype.collision_box.left_top.x
    local yRange = entityPrototype.collision_box.right_bottom.y - entityPrototype.collision_box.left_top.y
    return math.max(xRange, yRange) / 2
end

--- When an entity is built on the map.
---@param entity LuaEntity
function HiddenLight.OnEntityBuilt(entity)
    if not entity.valid or entity.force.ai_controllable == true then
        return
    end
    local entityLightName = global.Mod.EntityToLightName[entity.name]
    if entityLightName == nil then
        return
    end
    if entity.force == nil or not global.Mod.EnabledForForce[entity.force.name] then
        return
    end
    local position, force, surface = entity.position, entity.force, entity.surface
    if entity.type ~= "electric-pole" then
        ---@diagnostic disable: missing-fields # create_entity Factorio object definition expects too much.
        local hiddenElectricPole = surface.create_entity({
            name = "hiddenlightpole",
            position = position,
            force = force
        })
        ---@diagnostic enable: missing-fields # create_entity Factorio object definition expects too much.
        if hiddenElectricPole ~= nil then
            hiddenElectricPole.destructible = false -- Needed so anything that does damage ignoring the collision mask (atomic bombs) doesn't kill it.
        else
            game.print("ERROR - Inbuilt lighting failed to place Hidden Electric Pole at: " .. position.x .. ", " .. position.y)
        end
    end
    ---@diagnostic disable: missing-fields # create_entity Factorio object definition expects too much.
    local hiddenLight = surface.create_entity({
        name = entityLightName,
        position = position,
        force = force
    })
    ---@diagnostic enable: missing-fields # create_entity Factorio object definition expects too much.
    if hiddenLight ~= nil then
        hiddenLight.destructible = false -- Needed so anything that does damage ignoring the collision mask (atomic bombs) doesn't kill it.
    else
        game.print("ERROR - Inbuilt lighting failed to place Hidden Light at: " .. position.x .. ", " .. position.y)
    end
end

--- When an entity is removed from the map.
---@param entity LuaEntity
---@param positionToCheckOverride MapPosition?
function HiddenLight.OnEntityRemoved(entity, positionToCheckOverride)
    if entity.force.ai_controllable == true then
        return
    end
    local hiddenLightName = global.Mod.EntityToLightName[entity.name]
    if hiddenLightName == nil then
        return
    end
    if entity.force == nil or not global.Mod.EnabledForForce[entity.force.name] then
        return
    end
    local position, surface = entity.position, entity.surface
    if positionToCheckOverride ~= nil then
        position = positionToCheckOverride
    end
    local hiddenLightEntity = surface.find_entity(hiddenLightName, position)
    if hiddenLightEntity ~= nil then
        hiddenLightEntity.destroy()
    end
    local entityLightPole = surface.find_entity("hiddenlightpole", position)
    if entityLightPole ~= nil then
        entityLightPole.destroy()
    end
end

--- Replace all the lights on an entity type to the current light size.
--- TODO: entityTypesTable should come in as an array as part of overhaul i think.
---@param entityTypesTable table<string, true>
function HiddenLight.UpdateHiddenLightsForEntityType(entityTypesTable)
    local entityTypesArray = Utils.TableKeyToArray(entityTypesTable)
    for _, surface in pairs(game.surfaces) do
        for _, mainEntity in pairs(surface.find_entities_filtered { type = entityTypesArray }) do
            if mainEntity.valid and mainEntity.force.ai_controllable == false and mainEntity.name ~= "hiddenlightpole" then
                local expectedHiddenLightName = global.Mod.EntityToLightName[mainEntity.name]
                local correctLightFound = false
                for _, lightEntity in pairs(
                    surface.find_entities_filtered {
                        position = mainEntity.position,
                        type = "lamp"
                    }
                ) do
                    if expectedHiddenLightName == nil or lightEntity.name ~= expectedHiddenLightName or not global.Mod.EnabledForForce[lightEntity.force.name] then
                        lightEntity.destroy()
                    else
                        correctLightFound = true
                    end
                end
                if not correctLightFound then
                    local entityLightPole = surface.find_entity("hiddenlightpole", mainEntity.position)
                    if entityLightPole ~= nil then
                        entityLightPole.destroy()
                    end
                    HiddenLight.OnEntityBuilt(mainEntity)
                end
            end
        end
    end
end

--- Called when the light size has been changed and needs to be calculated and applied to the map.
function HiddenLight.UpdatedElectricPoleSetting()
    local powerPolePoweredAreaLightedMultiplier = tonumber(settings.global["power-pole-powered-area-lighted-percent"].value) / 100
    local powerPoleConnectionReachLightedMultiplier = tonumber(settings.global["power-pole-connection-reach-lighted-percent"].value) / 100
    local entityTypesTable = { ["electric-pole"] = true }
    --TODO: why don't we use a filtered list here from Factorio?
    for power_pole_name, power_pole in pairs(game.entity_prototypes) do
        if entityTypesTable[power_pole.type] ~= nil and entityTypesTable[power_pole.type] == true then
            local lightedAreaDistance, lightedReachDistance = 0, 0
            if powerPolePoweredAreaLightedMultiplier > 0 and power_pole.supply_area_distance > 0 then
                -- The supply_area_distance is the diameter from the power pole.
                lightedAreaDistance = math.ceil(power_pole.supply_area_distance * powerPolePoweredAreaLightedMultiplier)
                lightedAreaDistance = math.min(lightedAreaDistance, 75) -- Max light size of 75.
            end
            if powerPoleConnectionReachLightedMultiplier > 0 and power_pole.max_wire_distance > 0 then
                -- The max_wire_distance is the distance between 2 power poles, so it's double the radius of any single power pole.
                lightedReachDistance = math.ceil((power_pole.max_wire_distance * 0.5) * powerPoleConnectionReachLightedMultiplier)
                lightedReachDistance = math.min(lightedReachDistance, 75) -- Max light size of 75.
            end
            -- The light size is the diameter, centered on the power pole.
            local lightedDistance = math.max(lightedAreaDistance, lightedReachDistance)
            if lightedDistance > 0 then
                global.Mod.EntityToLightName[power_pole_name] = "hiddenlight-" .. lightedDistance
            else
                global.Mod.EntityToLightName[power_pole_name] = nil
            end
        end
    end
    global.Mod.EntityToLightName["hiddenlightpole"] = nil
    HiddenLight.UpdateHiddenLightsForEntityType(entityTypesTable)
end

--- Called when the turret lighting setting is changed.
function HiddenLight.UpdatedTurretSetting()
    local edgeLitTiles = tonumber(settings.global["turrets-lighted-edge-tiles"].value)
    local entityTypesTable = { ["turret"] = true, ["ammo-turret"] = true, ["electric-turret"] = true, ["fluid-turret"] = true, ["artillery-turret"] = true }
    for turret_name, turret in pairs(game.entity_prototypes) do
        if entityTypesTable[turret.type] ~= nil and entityTypesTable[turret.type] == true then
            if edgeLitTiles >= 0 then
                local lightedDistance ---@type int
                if edgeLitTiles > 0 then
                    lightedDistance = math.ceil(HiddenLight.FindEntityPrototypeRadius(turret) + (edgeLitTiles))
                else
                    lightedDistance = math.ceil(HiddenLight.FindEntityPrototypeRadius(turret))
                end
                lightedDistance = math.min(lightedDistance, 75)
                global.Mod.EntityToLightName[turret_name] = "hiddenlight-" .. lightedDistance
            else
                global.Mod.EntityToLightName[turret_name] = nil
            end
        end
    end
    HiddenLight.UpdateHiddenLightsForEntityType(entityTypesTable)
end

--- Called when Picker Dollies moves an entity.
---@param event any -- Not typed as outside our mod.
function HiddenLight.PickerDollyEntityMoved(event)
    HiddenLight.OnEntityRemoved(event.moved_entity, event.start_pos)
    HiddenLight.OnEntityBuilt(event.moved_entity)
end

--- Removes all modded lights from the map.
function HiddenLight.RemoveAllModEntities()
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities()) do
            if entity.name == "hiddenlightpole" or string.find(entity.name, "hiddenlight-") == 1 then
                entity.destroy()
            end
        end
    end
end

--- Called when the inbuilt lighting tech is researched.
function HiddenLight.OnInbuiltLightsResearchFinished(technology)
    global.Mod.EnabledForForce[technology.force.name] = true
end

--- Update each forces enablement of inbuilt lighting based on the mod setting for if research is required and of the force has researched the tech.
function HiddenLight.HandleResearchEnabledSetting()
    if settings.startup["research-unlock"].value then
        for _, force in pairs(game.forces) do
            if force.technologies["inbuilt-lighting"].researched then
                global.Mod.EnabledForForce[force.name] = true
            else
                global.Mod.EnabledForForce[force.name] = false
            end
        end
    else
        for _, force in pairs(game.forces) do
            global.Mod.EnabledForForce[force.name] = true
        end
    end
end

return HiddenLight
