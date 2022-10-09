--[[function BlackMarketManager:WriteFile(Contents)
	local file, err = io.open(RaID._path.."/shotgunprint.txt", "r")
	if not file then
		file = io.open(RaID._path.."/shotgunprint.txt", "w")
		file:close()
	else
		file:close()
		file = io.open(RaID._path.."/shotgunprint.txt", "a")
		file:write(Contents.."\n")
		file:close()
	end
end

function BlackMarketManager:_setup_weapons()
	local weapons = {}
	Global.blackmarket_manager.weapons = weapons

    local count = 0
    local stringout = ""
	for weapon, data in pairs(tweak_data.weapon) do
        if tweak_data.weapon[weapon].categories and type(tweak_data.weapon[weapon].categories)=="table" and tweak_data.weapon[weapon].categories[1] == "shotgun" then
            if not string.find(weapon, "_crew") and not string.find(weapon, "_npc") then
                count = count + 1
                stringout = stringout .. "self." .. tostring(weapon) .. "\n"
                --log("weapon = "..tostring(weapon))
                for w, d in pairs(data) do
                    local w_text = tostring(w)
                    if w_text == "stats" or w_text == "rays" or w_text == "stats_modifiers" then
                        if type(d) == "table" then
                            --log(tostring(w))
                            stringout = stringout .. tostring(w) .. "\n"
                            for k, v in pairs(d) do
                                stringout = stringout .. tostring(k) .. " = " .. tostring(v) .. "\n"
                                --log(tostring(k).." = "..tostring(v))
                            end
                        else
                            stringout = stringout .. tostring(w) .. " = " .. tostring(d) .. "\n"
                            --log(tostring(w).." = "..tostring(d))
                        end
                    end
                end
            end
        end
		if data.autohit then
			local selection_index = data.use_data.selection_index
			local equipped = weapon == managers.player:weapon_in_slot(selection_index)
			local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon)
			weapons[weapon] = {
				owned = false,
				unlocked = false,
				factory_id = factory_id,
				selection_index = selection_index
			}
			local is_default, weapon_level, got_parent = managers.upgrades:get_value(weapon)
			weapons[weapon].level = weapon_level
			weapons[weapon].skill_based = got_parent or not is_default and weapon_level == 0 and not tweak_data.weapon[weapon].global_value
			weapons[weapon].func_based = tweak_data.weapon[weapon].unlock_func

			if _G.IS_VR then
				weapons[weapon].vr_locked = tweak_data.vr:is_locked("weapons", weapon)
			end
		end
	end
    self:WriteFile(stringout)
    log("Count = "..tostring(count))
end]]

function BlackMarketManager:modify_damage_falloff(damage_falloff, custom_stats)
	if damage_falloff and custom_stats then
        --log("ORIG : "..tostring(damage_falloff.optimal_distance))
		for part_id, stats in pairs(custom_stats) do
			if stats.falloff_override then
                --log("MOD : "..tostring(stats.falloff_override.optimal_distance))
				damage_falloff.optimal_distance = stats.falloff_override.optimal_distance or damage_falloff.optimal_distance
				damage_falloff.optimal_range = stats.falloff_override.optimal_range or damage_falloff.optimal_range
				damage_falloff.near_falloff = stats.falloff_override.near_falloff or damage_falloff.near_falloff
				damage_falloff.far_falloff = stats.falloff_override.far_falloff or damage_falloff.far_falloff
				damage_falloff.near_multiplier = stats.falloff_override.near_mul or damage_falloff.near_multiplier
				damage_falloff.far_multiplier = stats.falloff_override.far_mul or damage_falloff.far_multiplier
			end

			if stats.optimal_distance_mul ~= nil then
				damage_falloff.optimal_distance = damage_falloff.optimal_distance * stats.optimal_distance_mul
			end

			if stats.optimal_range_mul ~= nil then
				damage_falloff.optimal_range = damage_falloff.optimal_range * stats.optimal_range_mul
			end

			if stats.near_falloff_mul ~= nil then
				damage_falloff.near_falloff = damage_falloff.near_falloff * stats.near_falloff_mul
			end

			if stats.far_falloff_mul ~= nil then
				damage_falloff.far_falloff = damage_falloff.far_falloff * stats.far_falloff_mul
			end

			if stats.falloff_mul ~= nil then
				damage_falloff.optimal_distance = damage_falloff.optimal_distance * stats.falloff_mul
				damage_falloff.optimal_range = damage_falloff.optimal_range * stats.falloff_mul
				damage_falloff.near_falloff = damage_falloff.near_falloff * stats.falloff_mul
				damage_falloff.far_falloff = damage_falloff.far_falloff * stats.falloff_mul
			end

			if stats.near_damage_mul ~= nil then
				damage_falloff.near_multiplier = damage_falloff.near_multiplier * stats.near_damage_mul
			end

			if stats.far_damage_mul ~= nil then
				damage_falloff.far_multiplier = damage_falloff.far_multiplier * stats.far_damage_mul
			end

			if stats.falloff_damage_mul ~= nil then
				damage_falloff.near_multiplier = damage_falloff.near_multiplier * stats.falloff_damage_mul
				damage_falloff.far_multiplier = damage_falloff.far_multiplier * stats.falloff_damage_mul
			end

			if stats.damage_near_mul ~= nil then
				damage_falloff.optimal_range = damage_falloff.optimal_range * stats.damage_near_mul
			end

			if stats.damage_far_mul ~= nil then
				damage_falloff.far_falloff = damage_falloff.far_falloff * stats.damage_far_mul
			end
		end
	end
end