if HopLib then
	return
end

local convert_hostage_to_criminal_original = GroupAIStateBase.convert_hostage_to_criminal
function GroupAIStateBase:convert_hostage_to_criminal(unit, peer_unit)

  if not alive(unit) then
    return
  end

  local player_unit = peer_unit or managers.player:player_unit()
  if alive(player_unit) then
    local max_minions = peer_unit and (peer_unit:base():upgrade_value("player", "convert_enemies_max_minions") or 0) or managers.player:upgrade_value("player", "convert_enemies_max_minions", 0)
    local criminal_data = self._criminals[player_unit:key()]
    if table.size(criminal_data and criminal_data.minions or {}) < max_minions then
      unit:base()._minion_owner = player_unit
    end
  end
  
  convert_hostage_to_criminal_original(self, unit, peer_unit)

end

function GroupAIStateBase:on_hostage_state(state, key, police, skip_announcement)
	local d = state and 1 or -1

	if state then
		for i, h_key in ipairs(self._hostage_keys) do
			if key == h_key then
				debug_pause("double-registered hostage")

				return
			end
		end

		table.insert(self._hostage_keys, key)
	else
		local found = false

		for i, h_key in ipairs(self._hostage_keys) do
			if key == h_key then
				table.remove(self._hostage_keys, i)

				found = true

				break
			end
		end

		if not found then
			return
		end
	end

	self._hostage_headcount = self._hostage_headcount + d

	self:sync_hostage_headcount()
	managers.modifiers:run_func("OnHostageCountChanged")
	managers.player:on_hostages_count_changed()

	if Network:is_server() and state then
		managers.player:captured_hostage()
	end

	if state and not skip_announcement and self._hostage_headcount == 1 and self._task_data.assault.disabled then
		managers.dialog:queue_narrator_dialog("h01a", {})
	end

	if police then
		self._police_hostage_headcount = self._police_hostage_headcount + d
	end

	if state and self._hstg_hint_clbk then
		if managers.enemy:is_clbk_registered("_hostage_hint_clbk") then
			managers.enemy:remove_delayed_clbk("_hostage_hint_clbk")
		end

		self._hstg_hint_clbk = nil
	end

	if self._hostage_headcount ~= #self._hostage_keys then
		debug_pause("[GroupAIStateBase:on_hostage_state] Headcount mismatch", self._hostage_headcount, #self._hostage_keys, key, inspect(self._hostage_keys))
	end
end

function GroupAIStateBase:sync_hostage_headcount(nr_hostages)
	if nr_hostages and self._hostage_headcount < nr_hostages then
		managers.player:captured_hostage()
	end

	if nr_hostages then
		self._hostage_headcount = nr_hostages
	elseif Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_hostage_headcount", math.min(self._hostage_headcount, 63))
	end

	if managers.player:has_team_category_upgrade("damage", "hostage_absorption") then
		local hostages_c = self:hostage_count() + self:get_amount_enemies_converted_to_criminals() --buff hostage include civ police and joker?
		--log("Hostage = "..tostring(self:hostage_count()).."\nPolice hostage = "..tostring(self:police_hostage_count()).."\nJoker = "..tostring(self:get_amount_enemies_converted_to_criminals()))
		local hostage_count = math.min(hostages_c, tweak_data.upgrades.values.team.damage.hostage_absorption_limit) --self._hostage_headcount only count civ?
		local absorption = managers.player:team_upgrade_value("damage", "hostage_absorption", 0) * hostage_count
    	if hostage_count >= 7 then
      		absorption = managers.player:team_upgrade_value("damage", "hostage_absorption", 0) * (hostage_count + 2)
   		end

		managers.player:set_damage_absorption("hostage_absorption", absorption)
	end

	managers.hud:set_control_info({
		nr_hostages = self._hostage_headcount
	})
	self:check_gameover_conditions()
end