function PlayerTurret:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	self:_determine_move_direction()
	self:_update_interaction_timers(t)
	self:_update_throw_projectile_timers(t, input)
	self:_update_reload_timers(t, dt, input)
	self:_update_melee_timers(t, input)
	self:_update_equip_weapon_timers(t, input)
	self:_update_running_timers(t)
	self:_update_zipline_timers(t, dt)

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	local new_action = false
	new_action = new_action or self:_check_action_unmount_turret(t, input)
	new_action = new_action or self:_check_action_reload(t, input)
	new_action = new_action or self:_check_action_primary_attack(t, input)
    new_action = new_action or self:_check_action_throw_projectile_turret(t, input)

	self:_check_action_steelsight(t, input)
	self:_check_action_night_vision(t, input)
	self:_find_pickups(t)
end

function PlayerTurret:_check_action_unmount_turret(t, input)
	local move = self._controller:get_input_axis("move")
	local action_wanted = input.btn_interact_press or input.btn_jump_press or input.btn_run_state and move.y > 0.1 or input.btn_switch_weapon_press or input.btn_primary_choice or input.btn_use_item_press

	if action_wanted then
		local action_forbidden = self:_turret_unmount_action_forbidden()

		if not action_forbidden then
			self:unmount_turret()

			self._running_wanted = input.btn_run_state

			return true
		end
	end

	return false
end

function PlayerBipod:_check_action_throw_projectile_turret(t, input)
	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.blackmarket.projectiles[projectile_entry].ability then
		return self:_check_action_use_ability_turret(t, input)
	end

	return false
end

function PlayerDriving:_check_action_use_ability_turret(t, input)
	local action_wanted = input.btn_throw_grenade_press

	if not action_wanted then
		return action_wanted
	end

	local equipped_ability = managers.blackmarket:equipped_grenade()

	if not managers.player:attempt_ability(equipped_ability) then
		return false
	end

	return action_wanted
end