GeneratePowerPoleLights = function()
	local poleLights = {}
	local powerPoleWireReachLightedMultiplier = tonumber(settings.startup["power-pole-wire-reach-lighted-percent"].value) / 100
	for supply_area_distance=1,64 do
		local poleLightRange = powerPoleWireReachLightedMultiplier * supply_area_distance * 5
		local poleLight = table.deepcopy(data.raw["lamp"]["small-lamp"])
		poleLight.name = "light-" .. supply_area_distance
		poleLight.collision_mask = {"resource-layer"}
		poleLight.flags = {"not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map"}
		poleLight.selectable_in_game = false
		poleLight.picture_off = {
			filename = "__base__/graphics/entity/small-lamp/lamp.png",
			width = 0,
			height = 0
		}
		poleLight.picture_on = {
			filename = "__base__/graphics/entity/small-lamp/lamp.png",
			width = 0,
			height = 0
		}
		poleLight.light = {intensity = 0.6, size = poleLightRange, color = {r=1.0, g=1.0, b=1.0}}
		poleLight.energy_usage_per_tick = "0W"
		poleLight.energy_source.render_no_network_icon = false
		poleLight.energy_source.render_no_power_icon = false
		table.insert(poleLights, poleLight)
	end
	data:extend(poleLights)
end



GeneratePowerPoleLights()
