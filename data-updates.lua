GenerateHiddenLights = function()
	local poleLights = {}
	for supply_area_distance=1,75 do
		local lightRange = supply_area_distance * 5
		local hiddenLight = table.deepcopy(data.raw["lamp"]["small-lamp"])
		hiddenLight.name = "hiddenlight-" .. supply_area_distance
		hiddenLight.collision_mask = {"resource-layer"}
		hiddenLight.flags = {"not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map"}
		hiddenLight.selectable_in_game = false
		hiddenLight.picture_off = {
			filename = "__base__/graphics/entity/small-lamp/lamp.png",
			width = 0,
			height = 0
		}
		hiddenLight.picture_on = {
			filename = "__base__/graphics/entity/small-lamp/lamp.png",
			width = 0,
			height = 0
		}
		hiddenLight.light = {intensity = 0.6, size = lightRange, color = {r=1.0, g=1.0, b=1.0}}
		hiddenLight.energy_usage_per_tick = settings.startup["light-power-usage-watts"].value .. "W"
		hiddenLight.energy_source.render_no_network_icon = false
		hiddenLight.energy_source.render_no_power_icon = false
		table.insert(poleLights, hiddenLight)
	end
	data:extend(poleLights)
end



GenerateHiddenLights()