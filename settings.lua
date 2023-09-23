data:extend(
    {
        {
            name = "light-power-usage-watts",
            type = "int-setting",
            default_value = 0,
            minimum_value = 0,
            setting_type = "startup",
            order = "1001"
        },
        {
            name = "research-unlock",
            type = "bool-setting",
            default_value = false,
            setting_type = "startup",
            order = "1001"
        },
        {
            name = "inbuilt_lighting-light_brightness",
            type = "double-setting",
            default_value = 0.6,
            minimum_value = 0,
            maximum_value = 1,
            setting_type = "startup",
            order = "1002"
        }
    }
)

data:extend(
    {
        {
            name = "power-pole-powered-area-lighted-percent",
            type = "int-setting",
            default_value = 100,
            minimum_value = 0,
            setting_type = "runtime-global",
            order = "1001"
        },
        {
            -- Don't name `power-pole-wire-reach-lighted-percent` as this was an old setting name and so might go odd from older migrations.
            name = "power-pole-connection-reach-lighted-percent",
            type = "int-setting",
            default_value = 0,
            minimum_value = 0,
            setting_type = "runtime-global",
            order = "1002"
        },
        {
            name = "turrets-lighted-edge-tiles",
            type = "int-setting",
            default_value = -1,
            minimum_value = -1,
            setting_type = "runtime-global",
            order = "1003"
        }
    }
)
