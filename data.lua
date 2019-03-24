local Constants = require("constants")

if settings.startup["research-unlock"].value then
    data:extend(
        {
            {
                type = "technology",
                name = "inbuilt-lighting",
                icon_size = 144,
                icon = Constants.AssetModName .. "/graphics/research-icon.png",
                unit = {
                    count = 50,
                    ingredients = {{"automation-science-pack", 1}},
                    time = 30
                },
                enabled = true,
                prerequisites = {"optics"},
                order = "a-h-b" --after optics
            }
        }
    )
end
