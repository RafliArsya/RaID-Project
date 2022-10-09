function PlayerDriving:_update_check_actions_driver(t, dt, input)
	self:_update_equip_weapon_timers(t, input)

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end


	self:_check_action_throw_projectile_driving(t, input)
	self:_check_action_night_vision(t, input)
end

function PlayerDriving:_update_check_actions_passenger_no_shoot(t, dt, input)
	self:_update_equip_weapon_timers(t, input)

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_check_action_throw_projectile_driving(t, input)
	self:_check_action_deploy_underbarrel(t, input)
	self:_check_action_night_vision(t, input)
end

function PlayerDriving:_check_action_throw_projectile_driving(t, input)
	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.blackmarket.projectiles[projectile_entry].ability then
		return self:_check_action_use_ability_driving(t, input)
	end

	return false
end

function PlayerDriving:_check_action_use_ability_driving(t, input)
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