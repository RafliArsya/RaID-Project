function PlayerTased:give_shock_to_taser_no_damage()
	if not alive(self._taser_unit) then
		return
	end

	local action_data = {
		damage = 2,
		variant = "counter_tased",
		damage_effect = self._taser_unit:character_damage()._HEALTH_INIT * 2,
		attacker_unit = self._unit,
		--weapon_unit = self._unit:inventory():equipped_unit(),
		attack_dir = -self._taser_unit:movement()._action_common_data.fwd,
		col_ray = {
			position = mvector3.copy(self._taser_unit:movement():m_head_pos()),
			body = self._taser_unit:body("body")
		}
	}
	self._taser_unit:character_damage():damage_melee(action_data)
	
	managers.fire:add_doted_enemy(self._taser_unit, TimerManager:game():time(), self._unit or self._unit:inventory():equipped_unit(), math.random(3, 12), 2, self._unit, true)
	
	self._unit:sound():play("tase_counter_attack")
end

function PlayerTased:_on_malfunction_to_taser_event()
	if not alive(self._taser_unit) then
		return
	end

	World:effect_manager():spawn({
		effect = Idstring("effects/payday2/particles/character/taser_stop"),
		position = self._taser_unit:movement():m_head_pos(),
		normal = math.UP
	})

	local action_data = {
		damage = 1,
		variant = "melee",
		damage_effect = self._taser_unit:character_damage()._HEALTH_INIT * 10,
		attacker_unit = self._unit,
		--weapon_unit = self._unit:inventory():equipped_unit(),
		attack_dir = -self._taser_unit:movement()._action_common_data.fwd,
		col_ray = {
			position = mvector3.copy(self._taser_unit:movement():m_head_pos()),
			body = self._taser_unit:body("body")
		}
	}

	self._taser_unit:character_damage():damage_melee(action_data)
end