PlayerAction.TagTeam = {
	Priority = 1,
	Function = function (tagged, owner)
		local base_values = managers.player:upgrade_value("player", "tag_team_base")
		local cooldown_drain = managers.player:upgrade_value("player", "tag_team_cooldown_drain")
		local absorption_bonus = managers.player:has_category_upgrade("player", "tag_team_damage_absorption") and managers.player:upgrade_value("player", "tag_team_damage_absorption")
		local timer = TimerManager:game()
		local end_time = timer:time() + base_values.duration
		local absorption = 0
		local absorption_key = {}
		local on_damage_key = {}
		local on_damage_cooldown_key = {}

		local function update_ability_radial()
			local time_left = end_time - timer:time()

			managers.hud:activate_teammate_ability_radial(HUDManager.PLAYER_PANEL, time_left, base_values.duration)
		end

        local function on_damage(damage_info, unit)
            if CopDamage.is_civilian(unit:base()._tweak_table) then
                return
            end
            local hp = unit:character_damage()._HEALTH_INIT --tweak_data.character[unit:base()._tweak_table].HEALTH_INIT
			local was_killed = damage_info.result.type == "death"
			local valid_player = damage_info.attacker_unit == owner or damage_info.attacker_unit == tagged

            if was_killed and valid_player then
				local add_time = math.min(math.round(hp/60, 0.1), 5) --math.clamp(hp / 60, 0.3, 5)
				local add_health = math.clamp(hp * 0.01, 0.01, 3)
				add_time = add_time < 0.3 and 0.3 or add_time 
				
				end_time = math.min(end_time + base_values.kill_extension + add_time, timer:time() + base_values.duration)

				update_ability_radial()
				owner:character_damage():restore_health(base_values.kill_health_gain + add_health, true)

				if absorption_bonus then
					local absorp_max = math.max(absorption_bonus.max, owner:character_damage():_max_health()*0.5)
					local absorp_gain
					if owner:character_damage():_max_health() * 0.2 > absorption_bonus.kill_gain then
						absorp_gain = math.clamp(unit:character_damage()._HEALTH_INIT*0.01, absorption_bonus.kill_gain, owner:character_damage():_max_health()*0.2)
					else
						absorp_gain = math.clamp(unit:character_damage()._HEALTH_INIT*0.01, absorption_bonus.kill_gain, 1)
					end
					absorption = absorption + absorp_gain
					absorption = math.min(absorption, absorp_max)

					managers.player:set_damage_absorption(absorption_key, absorption)
				end
			end
		end

        local function on_damage_cooldown(damage_info, unit)
            if CopDamage.is_civilian(unit:base()._tweak_table) then
                return
            end
			local was_killed = damage_info.result.type == "death"
            local valid_player = damage_info.attacker_unit == owner or damage_info.attacker_unit == tagged
            local hp = unit:character_damage()._HEALTH_INIT --tweak_data.character[unit:base()._tweak_table].HEALTH_INIT 

            if was_killed and valid_player then
				local add_time = math.min(math.round(hp/60, 0.1), 4) --math.clamp(hp / 60, 0.5, 4)
                --add_time = add_time >= 1 and add_time or 0
				managers.player:speed_up_grenade_cooldown(damage_info.attacker_unit == owner and cooldown_drain.owner + add_time or cooldown_drain.tagged + add_time)
			end
		end

		CopDamage.register_listener(on_damage_key, {
			"on_damage"
		}, on_damage)
		CopDamage.register_listener(on_damage_cooldown_key, {
			"on_damage"
		}, on_damage_cooldown)
		managers.network:session():send_to_peers("sync_tag_team", tagged, owner)
		update_ability_radial()

		if alive(owner) then
			while alive(owner) and timer:time() < end_time do
				coroutine.yield()
			end
		end

		CopDamage.unregister_listener(on_damage_key)
		managers.network:session():send_to_peers("end_tag_team", tagged, owner)

		tagged = nil

		while not managers.player:got_max_grenades() do
			coroutine.yield()
		end

		CopDamage.unregister_listener(on_damage_cooldown_key)
		managers.player:set_damage_absorption(absorption_key, nil)
	end
}
PlayerAction.TagTeamTagged = {
	Priority = 1,
	Function = function (tagged, owner)
		if tagged ~= managers.player:local_player() then
			return
		end
		local tagged_has_upg = tagged:base():has_category_upgrade("player", "tag_team_base")
		local base_values_t = tagged_has_upg and tagged:base():upgrade_value("player", "tag_team_base")
		local base_values = owner:base():upgrade_value("player", "tag_team_base")
		local kill_health_gain
		if tagged_has_upg then
			if base_values.kill_health_gain * base_values.tagged_health_gain_ratio > base_values_t.kill_health_gain * base_values_t.tagged_health_gain_ratio then
				kill_health_gain = base_values_t.kill_health_gain * base_values_t.tagged_health_gain_ratio
			else
				kill_health_gain = base_values.kill_health_gain * base_values.tagged_health_gain_ratio
			end
		else
			kill_health_gain = base_values.kill_health_gain * base_values.tagged_health_gain_ratio
		end

		--local kill_health_gain = base_values.kill_health_gain * base_values.tagged_health_gain_ratio

		local timer = TimerManager:game()
		local end_time = timer:time() + base_values.duration
		local on_damage_key = {}

        local function on_damage(damage_info, unit)
            if CopDamage.is_civilian(unit:base()._tweak_table) then
                return
            end
            local hp = unit:character_damage()._HEALTH_INIT --tweak_data.character[unit:base()._tweak_table].HEALTH_INIT
			local was_killed = damage_info.result.type == "death"
			local valid_player = damage_info.attacker_unit == owner or damage_info.attacker_unit == tagged

            if was_killed and valid_player then
				--local add_health = math.clamp(hp / 60, 0.3, 5)
				local add_health = math.clamp(hp * 0.01, 0.01, 3)
				--end_time = math.min(end_time + base_values.kill_extension+add_time, timer:time() + base_values.duration)
				--end_time = math.min(end_time + base_values.kill_extension, timer:time() + base_values.duration)

				tagged:character_damage():restore_health(kill_health_gain + add_health, true)
			end
		end

		CopDamage.register_listener(on_damage_key, {
			"on_damage"
		}, on_damage)

		local ended_by_owner = false
		local on_end_key = {}

		local function on_action_end(end_tagged, end_owner)
			local tagged_match = tagged == end_tagged
			local owner_match = owner == end_owner
			ended_by_owner = tagged_match and owner_match
		end

		managers.player:add_listener(on_end_key, {
			"tag_team_end"
		}, on_action_end)

		local timer = TimerManager:game()

		if not ended_by_owner and alive(tagged) then
			while not ended_by_owner and alive(tagged) and (alive(owner) or timer:time() < end_time) do
				coroutine.yield()
			end
		end

		CopDamage.unregister_listener(on_damage_key)
		managers.player:remove_listener(on_end_key)
	end
}
