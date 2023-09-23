local HiddenLight = {}

local turretTypeList = { "turret", "ammo-turret", "electric-turret", "fluid-turret", "artillery-turret" }
local turretTypeDictionary = {} ---@type table<string, string> # Key and value both turret type name.
for _, turretType in pairs(turretTypeList) do
    turretTypeDictionary[turretType] = turretType
end


--- Work out how large a prototype is.
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
    local force = entity.force
    if not entity.valid or force == nil or force.ai_controllable == true then
        return
    end
    local entityLightName = global.Mod.EntityToLightName[entity.name]
    if entityLightName == nil then
        return
    end
    if not global.Mod.EnabledForForce[force.name] then
        return
    end

    local position, surface = entity.position, entity.surface

    -- Handle turrets specially.
    if turretTypeDictionary[entity.type] ~= nil then
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

    -- Create the light.
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
    local force = entity.force
    if force == nil or force.ai_controllable == true then
        return
    end
    local hiddenLightName = global.Mod.EntityToLightName[entity.name]
    if hiddenLightName == nil then
        return
    end
    if not global.Mod.EnabledForForce[force.name] then
        return
    end

    -- Handle if another mod moved the entity and so use the old position.
    local position, surface = entity.position, entity.surface
    if positionToCheckOverride ~= nil then
        position = positionToCheckOverride
    end

    -- Remove the light.
    local hiddenLightEntity = surface.find_entity(hiddenLightName, position)
    if hiddenLightEntity ~= nil then
        hiddenLightEntity.destroy()
    end

    -- Handle turrets specially.
    if turretTypeDictionary[entity.type] ~= nil then
        local entityLightPole = surface.find_entity("hiddenlightpole", position)
        if entityLightPole ~= nil then
            entityLightPole.destroy()
        end
    end
end

--- Replace all the lights on an entity type to the current light size.
---@param entityTypesList string|string[]
function HiddenLight.UpdateHiddenLightsForEntityType(entityTypesList)
    for _, surface in pairs(game.surfaces) do
        for _, mainEntity in pairs(surface.find_entities_filtered { type = entityTypesList }) do
            if mainEntity.force.ai_controllable == false then
                local expectedHiddenLightName = global.Mod.EntityToLightName[mainEntity.name]
                local correctLightFound = false
                local mainEntity_position = mainEntity.position
                for _, lightEntity in pairs(
                    surface.find_entities_filtered {
                        position = mainEntity_position,
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
                    local entityLightPole = surface.find_entity("hiddenlightpole", mainEntity_position)
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
    ---@diagnostic disable: missing-fields # get_filtered_entity_prototypes Factorio object definition expects too much.
    for powerPolePrototypeName, powerPolePrototype in pairs(game.get_filtered_entity_prototypes({ { filter = "type", type = "electric-pole" } })) do
        ---@diagnostic enable: missing-fields # get_filtered_entity_prototypes Factorio object definition expects too much.
        -- Certain special power poles we don't want to create lights for.
        if powerPolePrototypeName ~= "hiddenlightpole" then
            local lightedAreaDistance, lightedReachDistance = 0, 0
            local powerPole_supplyAreaDistance = powerPolePrototype.supply_area_distance
            if powerPolePoweredAreaLightedMultiplier > 0 and powerPole_supplyAreaDistance > 0 then
                -- The supply_area_distance is the diameter from the power pole.
                lightedAreaDistance = math.ceil(powerPole_supplyAreaDistance * powerPolePoweredAreaLightedMultiplier)
                lightedAreaDistance = math.min(lightedAreaDistance, 75) -- Max light size of 75.
            end
            local powerPole_maxWireDistance = powerPolePrototype.max_wire_distance
            if powerPoleConnectionReachLightedMultiplier > 0 and powerPole_maxWireDistance > 0 then
                -- The max_wire_distance is the distance between 2 power poles, so it's double the radius of any single power pole.
                lightedReachDistance = math.ceil((powerPole_maxWireDistance * 0.5) * powerPoleConnectionReachLightedMultiplier)
                lightedReachDistance = math.min(lightedReachDistance, 75) -- Max light size of 75.
            end
            -- The light size is the diameter, centered on the power pole.
            local lightedDistance = math.max(lightedAreaDistance, lightedReachDistance)
            if lightedDistance > 0 then
                global.Mod.EntityToLightName[powerPolePrototypeName] = "hiddenlight-" .. lightedDistance
            else
                global.Mod.EntityToLightName[powerPolePrototypeName] = nil
            end
        end
    end
    global.Mod.EntityToLightName["hiddenlightpole"] = nil
    HiddenLight.UpdateHiddenLightsForEntityType({ "electric-pole" })
end

--- Called when the turret lighting setting is changed.
function HiddenLight.UpdatedTurretSetting()
    local edgeLitTiles = tonumber(settings.global["turrets-lighted-edge-tiles"].value)
    ---@diagnostic disable: missing-fields # get_filtered_entity_prototypes Factorio object definition expects too much.
    for turretPrototypeName, turretPrototype in pairs(game.get_filtered_entity_prototypes({ { filter = "turret" }, { filter = "type", type = "artillery-turret" } })) do
        ---@diagnostic enable: missing-fields # get_filtered_entity_prototypes Factorio object definition expects too much.
        if edgeLitTiles >= 0 then
            local lightedDistance ---@type int
            if edgeLitTiles > 0 then
                lightedDistance = math.ceil(HiddenLight.FindEntityPrototypeRadius(turretPrototype) + edgeLitTiles)
            else
                lightedDistance = math.ceil(HiddenLight.FindEntityPrototypeRadius(turretPrototype))
            end
            lightedDistance = math.min(lightedDistance, 75)
            global.Mod.EntityToLightName[turretPrototypeName] = "hiddenlight-" .. lightedDistance
        else
            global.Mod.EntityToLightName[turretPrototypeName] = nil
        end
    end
    HiddenLight.UpdateHiddenLightsForEntityType(turretTypeList)
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
            local entity_name = entity.name
            if entity_name == "hiddenlightpole" or string.find(entity_name, "hiddenlight-") == 1 then
                entity.destroy()
            end
        end
    end
end

--- Called when the inbuilt lighting tech is researched.
---@param technology LuaTechnology
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
