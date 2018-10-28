UpdateSetting = function(settingName)
	if settingName == "power-pole-wire-reach-lighted-percent" or settingName == nil then
		UpdatedElectricPoleSetting()
	end
end

UpdatedElectricPoleSetting = function()
	Global.ModSettings.PowerPoleWireReachLightedMultiplier = tonumber(settings.global["power-pole-wire-reach-lighted-percent"].value) / 100
	for power_pole_name, power_pole in pairs(game.entity_prototypes) do
		if power_pole.type == "electric-pole" then
			local lightedDistance = math.min(math.ceil(power_pole.supply_area_distance * Global.ModSettings.PowerPoleWireReachLightedMultiplier), 75)
			if lightedDistance > 0 then
				Global.EntityToLightName[power_pole_name] = "hiddenlight-" .. lightedDistance
			else
				Global.EntityToLightName[power_pole_name] = nil
			end
		end
	end
	UpdateHiddenLightsForEntityType("electric-pole")
end

OnEntityBuilt = function(entity)
	if entity == nil then
		game.print("entity is nil")
		return
	elseif not entity.valid then
		game.print("entity not valid")
		return
	end
	local entityLightName = Global.EntityToLightName[entity.name]
    if entityLightName == nil then return end
	entity.surface.create_entity{
		name = entityLightName, 
		position = entity.position,
		force = entity.force
	}
end

OnEntityRemoved = function(entity)
	local entityLightName = Global.EntityToLightName[entity.name]
    if entityLightName == nil then return end
	local entityLight = entity.surface.find_entity(entityLightName, entity.position)
	if entityLight == nil then return end
	entityLight.destroy()
end

UpdateHiddenLightsForEntityType = function(entityType)
	for _, surface in pairs(game.surfaces) do
		for _, mainEntity in pairs(surface.find_entities_filtered{type=entityType}) do
			local expectedHiddenLightName = Global.EntityToLightName[mainEntity.name]
			local correctLightFound = false
			for _, lightEntity in pairs(surface.find_entities_filtered{
				position = mainEntity.position,
				type = "lamp"
			}) do
				if expectedHiddenLightName == nil or lightEntity.name ~= expectedHiddenLightName then
					lightEntity.destroy()
				else
					correctLightFound = true
				end
			end
			if not correctLightFound then
				OnEntityBuilt(mainEntity)
			end
		end
	end
end

WasCreativeModeInstantDeconstructionUsed = function(event)
	if event.instant_deconstruction ~= nil and event.instant_deconstruction == true then
		return true 
	else
		return false
	end
end


OnStartup = function()
	OnLoad()
	if Global.ModSettings == nil then Global.ModSettings = {} end
	if Global.EntityToLightName == nil then Global.EntityToLightName = {} end
	UpdateSetting(nil)
end

OnLoad = function()
	Global = global
end

OnBuiltEntity = function(event)
    OnEntityBuilt(event.created_entity)
end

OnRemovedEntity = function(event)
    OnEntityRemoved(event.entity)
end

OnSettingChanged = function(event)
	UpdateSetting(event.setting)
end

OnRobotPreMined = function(event)
	if WasCreativeModeInstantDeconstructionUsed(event) then
		OnEntityRemoved(event.entity)
	end 
end



script.on_init(function()
	OnStartup()
end)
script.on_load(function() 
	OnLoad()
end)
script.on_event(defines.events.on_built_entity, OnBuiltEntity)
script.on_event(defines.events.on_robot_built_entity, OnBuiltEntity)
script.on_event(defines.events.on_player_mined_entity, OnRemovedEntity)
script.on_event(defines.events.on_entity_died, OnRemovedEntity)
script.on_event(defines.events.on_robot_mined_entity, OnRemovedEntity)
script.on_event(defines.events.on_robot_pre_mined, OnRobotPreMined)
script.on_event(defines.events.on_runtime_mod_setting_changed, OnSettingChanged)
script.on_configuration_changed(function()
	OnStartup()
end)