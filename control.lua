if ModSettings == nil then
	ModSettings = {}
end



StartUp = function()
	ModSettings.PowerPoleWireReachLightedMultiplier = tonumber(settings.startup["power-pole-wire-reach-lighted-percent"].value) / 100
end

PowerPoleToLightName = {}

LoadConstants = function()
	for power_pole_name, power_pole in pairs(game.entity_prototypes) do
		if power_pole.type == "electric-pole" then
			local supply_area_distance = math.ceil(power_pole.supply_area_distance)
			PowerPoleToLightName[power_pole_name] = "light-" .. supply_area_distance
		end
	end
end


OnPowerPoleBuilt = function(entity)
	local poleLightName = PowerPoleToLightName[entity.name]
	local poleLight = entity.surface.find_entity(poleLightName, entity.position)
	if poleLight ~= nil then return end
	entity.surface.create_entity{
		name = poleLightName, 
		position = entity.position,
		force = entity.force
	}
end

OnPowerPoleRemoved = function(entity)
	local poleLightName = PowerPoleToLightName[entity.name]
	local poleLight = entity.surface.find_entity(poleLightName, entity.position)
	if poleLight == nil then return end
	poleLight.destroy()
end

UpdateHiddenLightEntities = function()
	if ModSettings.PowerPoleWireReachLightedMultiplier > 0 then
		for _, surface in pairs(game.surfaces) do
			for _, pole in pairs(surface.find_entities_filtered{type="electric-pole"}) do
				OnPowerPoleBuilt(pole)
			end
		end
	else
		for _, surface in pairs(game.surfaces) do
			for _, pole in pairs(surface.find_entities_filtered{type="electric-pole"}) do
				OnPowerPoleRemoved(pole)
			end
		end
	end
end



OnBuiltEntity = function(event)
    local entity = event.created_entity
    if entity.type == "electric-pole" and ModSettings.PowerPoleWireReachLightedMultiplier > 0 then
        OnPowerPoleBuilt(entity)
    end
end

OnRemovedEntity = function(event)
    local entity = event.entity
    if entity.type == "electric-pole" and ModSettings.PowerPoleWireReachLightedMultiplier > 0 then
		OnPowerPoleRemoved(entity)
	end
end

OnFirstTick = function()
	script.on_event(defines.events.on_tick, nil)
	UpdateHiddenLightEntities()
end



script.on_init(function() 
	StartUp()
end)
script.on_load(function() 
	StartUp()
end)
script.on_event(defines.events.on_built_entity, OnBuiltEntity)
script.on_event(defines.events.on_robot_built_entity, OnBuiltEntity)
script.on_event(defines.events.on_player_mined_entity, OnRemovedEntity)
script.on_event(defines.events.on_entity_died, OnRemovedEntity)
script.on_event(defines.events.on_robot_mined_entity, OnRemovedEntity)
script.on_event(defines.events.on_tick, OnFirstTick)
