local HiddenLight = {}
local Utils = require("utility/utils")

function HiddenLight.FindEntitiePrototypeRadius(entityPrototype)
    local xRange = entityPrototype.collision_box.right_bottom.x - entityPrototype.collision_box.left_top.x
    local yRange = entityPrototype.collision_box.right_bottom.y - entityPrototype.collision_box.left_top.y
    return math.max(xRange, yRange) / 2
end

function HiddenLight.OnEntityBuilt(entity)
    if entity.force.ai_controllable == true then
        return
    end
    local entityLightName = global.Mod.EntityToLightName[entity.name]
    if entityLightName == nil then
        return
    end
    if entity.force == nil or not global.Mod.EnabledForForce[entity.force.name] then
        return
    end
    if entity.type ~= "electric-pole" then
        entity.surface.create_entity {
            name = "hiddenlightpole",
            position = entity.position,
            force = entity.force
        }
    end
    entity.surface.create_entity {
        name = entityLightName,
        position = entity.position,
        force = entity.force
    }
end

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
    local position = entity.position
    if positionToCheckOverride ~= nil then
        position = positionToCheckOverride
    end
    local hiddenLightEntity = entity.surface.find_entity(hiddenLightName, position)
    if hiddenLightEntity ~= nil then
        hiddenLightEntity.destroy()
    end
    local entityLightPole = entity.surface.find_entity("hiddenlightpole", position)
    if entityLightPole ~= nil then
        entityLightPole.destroy()
    end
end

function HiddenLight.UpdateHiddenLightsForEntityType(entityTypesTable)
    local entityTypesArray = Utils.TableKeyToArray(entityTypesTable)
    for _, surface in pairs(game.surfaces) do
        for _, mainEntity in pairs(surface.find_entities_filtered {type = entityTypesArray}) do
            if mainEntity.force.ai_controllable == false and mainEntity.name ~= "hiddenlightpole" then
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

function HiddenLight.UpdatedElectricPoleSetting()
    local powerPoleWireReachLightedMultiplier = tonumber(settings.global["power-pole-wire-reach-lighted-percent"].value) / 100
    local entityTypesTable = {["electric-pole"] = true}
    for power_pole_name, power_pole in pairs(game.entity_prototypes) do
        if entityTypesTable[power_pole.type] ~= nil and entityTypesTable[power_pole.type] == true then
            if powerPoleWireReachLightedMultiplier > 0 then
                local lightedDistance = math.ceil(power_pole.supply_area_distance * powerPoleWireReachLightedMultiplier)
                lightedDistance = math.min(lightedDistance, 75)
                global.Mod.EntityToLightName[power_pole_name] = "hiddenlight-" .. lightedDistance
            else
                global.Mod.EntityToLightName[power_pole_name] = nil
            end
        end
    end
    global.Mod.EntityToLightName["hiddenlightpole"] = nil
    HiddenLight.UpdateHiddenLightsForEntityType(entityTypesTable)
end

function HiddenLight.UpdatedTurretSetting()
    local edgeLitTiles = tonumber(settings.global["turrets-lighted-edge-tiles"].value)
    local entityTypesTable = {["turret"] = true, ["ammo-turret"] = true, ["electric-turret"] = true, ["fluid-turret"] = true, ["artillery-turret"] = true}
    for turret_name, turret in pairs(game.entity_prototypes) do
        if entityTypesTable[turret.type] ~= nil and entityTypesTable[turret.type] == true then
            if edgeLitTiles >= 0 then
                local lightedDistance
                if edgeLitTiles > 0 then
                    lightedDistance = math.ceil(HiddenLight.FindEntitiePrototypeRadius(turret) + (edgeLitTiles))
                else
                    lightedDistance = math.ceil(HiddenLight.FindEntitiePrototypeRadius(turret))
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

function HiddenLight.PickerDollyEntityMoved(event)
    HiddenLight.OnEntityRemoved(event.moved_entity, event.start_pos)
    HiddenLight.OnEntityBuilt(event.moved_entity)
end

function HiddenLight.RemoveAllModEntities()
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities()) do
            if entity.name == "hiddenlightpole" or string.find(entity.name, "hiddenlight-") == 1 then
                entity.destroy()
            end
        end
    end
end

function HiddenLight.OnResearchFinished(technology)
    if technology.name ~= "inbuilt-lighting" then
        return
    end
    global.Mod.EnabledForForce[technology.force.name] = true
end

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
