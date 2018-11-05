data:extend({
	{
		name = "light-power-usage-watts",
		type = "int-setting",
		default_value = 0,
		minimum_value = 0,
		setting_type = "startup",
		order = "1001"
	},
	

	{
		name = "power-pole-wire-reach-lighted-percent",
		type = "int-setting",
		default_value = 100,
		minimum_value = 0,
		setting_type = "runtime-global",
		order = "1001"
	},
	{
		name = "turrets-lighted-edge-tiles",
		type = "int-setting",
		default_value = -1,
		minimum_value = -1,
		setting_type = "runtime-global",
		order = "1002"
	}
})