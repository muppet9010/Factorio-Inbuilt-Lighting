UpdateSetting = function(settingName)
	if settingName == "power-pole-wire-reach-lighted-percent" or settingName == nil then
		UpdatedElectricPoleSetting()
	end
	if settingName == "turrets-lighted-edge-tiles" or settingName == nil then
		UpdatedTurretSetting()
	end
end

UpdatedElectricPoleSetting = function()
	local powerPoleWireReachLightedMultiplier = tonumber(settings.global["power-pole-wire-reach-lighted-percent"].value) / 100
	local entityTypesTable = {["electric-pole"] = true}
	for power_pole_name, power_pole in pairs(game.entity_prototypes) do
		if entityTypesTable[power_pole.type] ~= nil and entityTypesTable[power_pole.type] == true then
			if powerPoleWireReachLightedMultiplier > 0 then
				local lightedDistance = math.ceil(power_pole.supply_area_distance * powerPoleWireReachLightedMultiplier)
				lightedDistance = math.min(lightedDistance, 75)
				Global.EntityToLightName[power_pole_name] = "hiddenlight-" .. lightedDistance
			else
				Global.EntityToLightName[power_pole_name] = nil
			end
		end
	end
	Global.EntityToLightName["hiddenlightpole"] = nil
	UpdateHiddenLightsForEntityType(entityTypesTable)
end

UpdatedTurretSetting = function()
	local edgeLitTiles = tonumber(settings.global["turrets-lighted-edge-tiles"].value)
	local entityTypesTable = {["turret"] = true, ["ammo-turret"] = true, ["electric-turret"] = true, ["fluid-turret"] = true, ["artillery-turret"] = true}
	for turret_name, turret in pairs(game.entity_prototypes) do
		if entityTypesTable[turret.type] ~= nil and entityTypesTable[turret.type] == true then
			if edgeLitTiles >= 0 then
				local lightedDistance = nil
				if edgeLitTiles > 0 then
					lightedDistance = math.ceil(FindEntitiePrototypeRadius(turret) + (edgeLitTiles))
				else
					lightedDistance = math.ceil(FindEntitiePrototypeRadius(turret))
				end
				lightedDistance = math.min(lightedDistance, 75)
				Global.EntityToLightName[turret_name] = "hiddenlight-" .. lightedDistance
			else
				Global.EntityToLightName[turret_name] = nil
			end
		end
	end
	UpdateHiddenLightsForEntityType(entityTypesTable)
end

FindEntitiePrototypeRadius = function(entityPrototype)
	local xRange = entityPrototype.collision_box.right_bottom.x - entityPrototype.collision_box.left_top.x
	local yRange = entityPrototype.collision_box.right_bottom.y - entityPrototype.collision_box.left_top.y
	return math.max(xRange, yRange) / 2
end

OnEntityBuilt = function(entity)
	if entity.force.ai_controllable == true then return end
	local entityLightName = Global.EntityToLightName[entity.name]
    if entityLightName == nil then return end
	if entity.type ~= "electric-pole" then
		local hiddenPoleAdded = entity.surface.create_entity{
			name = "hiddenlightpole", 
			position = entity.position,
			force = entity.force
		}
	end
	local lightEntity = entity.surface.create_entity{
		name = entityLightName, 
		position = entity.position,
		force = entity.force
	}
end

OnEntityRemoved = function(entity)
	if entity.force.ai_controllable == true then return end
	local hiddenLightName = Global.EntityToLightName[entity.name]
    if hiddenLightName == nil then return end
	local hiddenLightEntity = entity.surface.find_entity(hiddenLightName, entity.position)
	if hiddenLightEntity ~= nil then
		local result = hiddenLightEntity.destroy()
	end
	local entityLightPole = entity.surface.find_entity("hiddenlightpole", entity.position)
	if entityLightPole ~= nil then
		local result = entityLightPole.destroy()
	end
end

UpdateHiddenLightsForEntityType = function(entityTypesTable)
	local entityTypesArray = MakeArrayFromTableKeys(entityTypesTable)
	for surfaceIndex, surface in pairs(game.surfaces) do
		for mainEntityIndex, mainEntity in pairs(surface.find_entities_filtered{type=entityTypesArray}) do
			if mainEntity.force.ai_controllable == false and mainEntity.name ~= "hiddenlightpole" then
				local expectedHiddenLightName = Global.EntityToLightName[mainEntity.name]
				local correctLightFound = false
				--Use an area search to work around Factorio position search bug: https://forums.factorio.com/viewtopic.php?f=7&t=63270
				for lightEntityIndex, lightEntity in pairs(surface.find_entities_filtered{
					area = {{mainEntity.position.x-0.0001, mainEntity.position.y-0.0001}, {mainEntity.position.x+0.0001, mainEntity.position.y+0.0001}},
					type = "lamp"
				}) do
					if expectedHiddenLightName == nil or lightEntity.name ~= expectedHiddenLightName then
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
					OnEntityBuilt(mainEntity)
				end
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

MakeArrayFromTableKeys = function(thisTable)
	local newArray = {}
	for key, value in pairs(thisTable) do
		table.insert(newArray, key)
	end
	return newArray
end




OnStartup = function()
	OnLoad()
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




Log = function(text)
	game.print(text)
	game.write_file("Inbuilt_Lighting_logOutput.txt", tostring(text) .. "\r\n", true)
end