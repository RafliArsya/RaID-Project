if RequiredScript == "lib/units/beings/player/playermovement" then
local old_on_SPOOCed = PlayerMovement.on_SPOOCed
_increase_auto_counter = 0
function PlayerMovement:on_SPOOCed(enemy_unit)
	if managers.player:has_category_upgrade("player", "counter_strike_spooc") and self._current_state.in_melee and self._current_state:in_melee() then
		self._current_state:discharge_melee()
		return "countered"
	end
	if managers.player:has_category_upgrade("player", "auto_counter_spooc") then
		local roll = math.random()
		local auto = managers.player:upgrade_value("player", "auto_counter_spooc")
		auto = auto + (_increase_auto_counter / 100)
		if roll <= auto then
			_increase_auto_counter = 0
			return "countered"
		end
		_increase_auto_counter = _increase_auto_counter + math.random(10)
	end
	if self._unit:character_damage()._god_mode or self._unit:character_damage():get_mission_blocker("invulnerable") then
		return
	end
	if self._current_state_name == "standard" or self._current_state_name == "carry" or self._current_state_name == "bleed_out" or self._current_state_name == "tased" or self._current_state_name == "bipod" then
		local state = "incapacitated"
		state = managers.modifiers:modify_value("PlayerMovement:OnSpooked", state)

		managers.player:set_player_state(state)
		managers.achievment:award(tweak_data.achievement.finally.award)

		return true
	end
end

function PlayerMovement:_get_sus_rat()
	return self._suspicion_ratio
end

function PlayerMovement:_get_suspicion()
	return self._synced_suspicion
end

end

function PlayerMovement:_upd_underdog_skill(t)
	local data = self._underdog_skill_data
	
	if not self._attackers or not data.has_dmg_dampener and not data.has_dmg_mul or (t < data.chk_t and t < data.cq_chk_t) then
		return
	end
	
	local my_pos = self._m_pos
	local nr_guys = 0
	local activated = nil

	for u_key, attacker_unit in pairs(self._attackers) do
		if not alive(attacker_unit) then
			self._attackers[u_key] = nil

			return
		end

		local attacker_pos = attacker_unit:movement():m_pos()
		local dis_sq = mvector3.distance_sq(attacker_pos, my_pos)

		if dis_sq < data.max_dis_sq and math.abs(attacker_pos.z - my_pos.z) < data.max_vert_dis then
			nr_guys = nr_guys + 1

			if data.nr_enemies <= nr_guys then
			
				self:_upd_underdog_out_skill(t, data, nr_guys)

				break
			end
		end
	end

	if nr_guys >= 1 and data.has_cqc then
		self:_upd_underdog_cqc_skill(t, data, nr_guys)
	end
	
end

function PlayerMovement:_upd_underdog_out_skill(t, data, num_enemy)
	local data = data
	
	if t < data.chk_t then
		return
	end
	
	if num_enemy < data.nr_enemies  then
		return
	end
	
	local activated = false
	
	if data.has_dmg_mul and managers.player:has_inactivate_temporary_upgrade('temporary', 'dmg_multiplier_outnumbered') then
		managers.player:activate_temporary_upgrade("temporary", "dmg_multiplier_outnumbered")
		activated = true
	end
	
	if data.has_out and managers.player:has_inactivate_temporary_upgrade('temporary', 'dmg_dampener_outnumbered') then
		managers.player:activate_temporary_upgrade("temporary", "dmg_dampener_outnumbered")
		activated = true
	end
	
	if data.has_outstrong and managers.player:has_inactivate_temporary_upgrade('temporary', 'dmg_dampener_outnumbered_strong') then
		managers.player:activate_temporary_upgrade("temporary", "dmg_dampener_outnumbered_strong")
		activated = true
	end
	
	data.chk_t = t + (activated and data.chk_interval_active or data.chk_interval_inactive)
end

function PlayerMovement:_upd_underdog_cqc_skill(t, data, num_enemy)
	local data = data
	
	if t < data.cq_chk_t or managers.player:has_activate_temporary_upgrade('temporary', 'dmg_dampener_close_contact') then
		return
	end
	
	if num_enemy < 1 then
		return
	end
	
	local activated = false
	
	if managers.player:has_inactivate_temporary_upgrade('temporary', 'dmg_dampener_close_contact') then
		managers.player:activate_temporary_upgrade("temporary", "dmg_dampener_close_contact")
		activated = true
	end
	
	data.cq_chk_t = t + (activated and data.chk_interval_active or data.chk_interval_inactive)
end

Hooks:PostHook(PlayerMovement, 'init', 'RaID_PlayerMovement_Init', function(self, unit)
	self._underdog_skill_data = {
		max_dis_sq = tweak_data.upgrades.close_combat_distance * tweak_data.upgrades.close_combat_distance,
		chk_t = 6,
		cq_chk_t = 6,
		chk_interval_active = 6,
		nr_enemies = 3,
		max_vert_dis = 1000,
		chk_interval_inactive = 1,
		has_dmg_dampener = managers.player:has_category_upgrade("temporary", "dmg_dampener_outnumbered") or managers.player:has_category_upgrade("temporary", "dmg_dampener_outnumbered_strong") or managers.player:has_category_upgrade("temporary", "dmg_dampener_close_contact"),
		has_dmg_mul = managers.player:has_category_upgrade("temporary", "dmg_multiplier_outnumbered"),
		has_outstrong = managers.player:has_category_upgrade("temporary", "dmg_dampener_outnumbered_strong"),
		has_out = managers.player:has_category_upgrade("temporary", "dmg_dampener_outnumbered"),
		has_cqc = managers.player:has_category_upgrade("temporary", "dmg_dampener_close_contact")
	}
end)
