StartUp = function()
	settings.powerPoleWireReachLightedMultiplier = tonumber(settings.startup["power-pole-wire-reach-lighted-percent"].value) / 100
end

OnPowerPoleBuilt = function(entity)
	local poleLightName = entity.name .. "-light"
	entity.surface.create_entity{
		name = poleLightName, 
		position = entity.position,
		force = entity.force
	}
end

OnPowerPoleRemoved = function(entity)
	local poleLightName = entity.name .. "-light"
	if game.entity_prototypes[poleLightName] == nil then return end
	local poleLight = entity.surface.find_entity(poleLightName, entity.position)
	if poleLight == nil then return end
	poleLight.destroy()
end



OnBuiltEntity = function(event)
    local entity = event.created_entity
    if entity.type == "electric-pole" and settings.powerPoleWireReachLightedMultiplier > 0 then
        OnPowerPoleBuilt(entity)
    end
end

OnRemovedEntity = function(event)
    local entity = event.entity
    if entity.type == "electric-pole" and settings.powerPoleWireReachLightedMultiplier > 0 then
		OnPowerPoleRemoved(entity)
	end
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