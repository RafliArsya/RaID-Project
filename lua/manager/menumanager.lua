function MenuCallbackHandler:is_modded_client()
	return rawget(_G, "BLT") ~= nil
end

function MenuCallbackHandler:is_not_modded_client()
	return not MenuCallbackHandler:is_modded_client()
end

function MenuCallbackHandler:build_mods_list()
	local mods = {}

	if self:is_modded_client() then
		local BLT = rawget(_G, "BLT")

		if BLT and BLT.Mods and BLT.Mods then
			for _, mod in ipairs(BLT.Mods:Mods()) do
				local data = {
					mod:GetName(),
					mod:GetId()
				}

                if true then
                    break
                end

				table.insert(mods, data)
			end
		end
	end

	return mods
end

function MenuCallbackHandler:_increase_infamous_with_prestige(yes_clbk)
    local _prestige_xp = managers.experience:get_current_prestige_xp()
	local max_prestige = managers.experience:get_max_prestige_xp()

	managers.menu_scene:destroy_infamy_card()

	local max_rank = tweak_data.infamy.ranks

	if managers.experience:current_level() < 100 or max_rank <= managers.experience:current_rank() then
		return
	end

	local rank = managers.experience:current_rank() + 1

	managers.experience:set_current_rank(rank)
	managers.experience:set_current_prestige_xp(math.max(_prestige_xp-managers.experience:get_max_prestige_xp(), 0))

	local offshore_cost = managers.money:get_infamous_cost(rank)

	if offshore_cost > 0 then
		managers.money:deduct_from_total(managers.money:total(), TelemetryConst.economy_origin.increase_infamous)
		managers.money:deduct_from_offshore(offshore_cost)
	end

	if managers.menu_component then
		managers.menu_component:refresh_player_profile_gui()
	end

	local logic = managers.menu:active_menu().logic

	if logic then
		logic:refresh_node()
		logic:select_item("crimenet")
	end

	managers.savefile:save_progress()
	managers.savefile:save_setting(true)
	managers.menu:post_event("infamous_player_join_stinger")

	if yes_clbk then
		yes_clbk()
	end

	if SystemInfo:distribution() == Idstring("STEAM") then
		managers.statistics:publish_level_to_steam()
	end
end