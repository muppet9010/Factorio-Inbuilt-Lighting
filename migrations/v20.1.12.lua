-- Apply the deconstruction change to all of our power poles and lights.
for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({ type = { "lamp", "electric-pole" } })) do
        if entity.name == "hiddenlightpole" or string.find(entity.name, "hiddenlight-") == 1 then
            entity.destructible = false
        end
    end
end
