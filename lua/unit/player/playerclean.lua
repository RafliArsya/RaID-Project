local old__update_check_actions = PlayerClean._update_check_actions

function PlayerClean:_check_action_duck(t, input, ...)
	local pass = managers.player:has_category_upgrade("player", "suspicious_movement")
	if pass then
		return self:__check_action_duck(t, input)
	end
	if input.btn_duck_press then
		managers.hint:show_hint("clean_block_interact")
	end
end

function PlayerClean:_check_action_jump(t, input, ...)
	local pass = managers.player:has_category_upgrade("player", "suspicious_movement")
	if pass then
		return self:__check_action_jump(t, input)
	end
	if input.btn_jump_press then
		managers.hint:show_hint("clean_block_interact")
	end
end

function PlayerClean:__check_action_jump(t, input, ...)
	if input.btn_jump_press then
		PlayerStandard._check_action_jump(self, t, input)
	end
end

function PlayerClean:__check_action_duck(t, input, ...)
	if managers.user:get_setting("hold_to_duck") and input.btn_duck_release then
		if self._state_data.ducking then
			self:_end_action_ducking(self, t)
		end
	elseif input.btn_duck_press and not self._unit:base():stats_screen_visible() then
		if not self._state_data.ducking then
			self:_start_action_ducking(self, t)
		elseif self._state_data.ducking then
			self:_end_action_ducking(self, t)
		end
	end
end

function PlayerClean:_start_action_ducking(t)
	if self:_interacting() or self:_on_zipline() then
		return
	end

	self:_interupt_action_running(t)

	self._state_data.ducking = true

	self:_stance_entered()
	self:_update_crosshair_offset()

	local velocity = self._unit:mover():velocity()

	self._unit:kill_mover()
	self:_activate_mover(PlayerStandard.MOVER_DUCK, velocity)
	self._ext_network:send("action_change_pose", 2, self._unit:position())

	self._ext_movement:set_attention_settings({
		"pl_mask_off_friend_combatant",
		"pl_mask_off_friend_non_combatant",
		"pl_mask_off_foe_combatant",
		"pl_mask_off_foe_non_combatant"
	})
end

function PlayerClean:_end_action_ducking(t, skip_can_stand_check)
	if not skip_can_stand_check and not self:_can_stand() then
		return
	end

	self._state_data.ducking = false

	self:_stance_entered()
	self:_update_crosshair_offset()

	local velocity = self._unit:mover():velocity()

	self._unit:kill_mover()
	self:_activate_mover(PlayerStandard.MOVER_STAND, velocity)
	self._ext_network:send("action_change_pose", 1, self._unit:position())

	self._ext_movement:set_attention_settings({
		"pl_mask_off_friend_combatant",
		"pl_mask_off_friend_non_combatant",
		"pl_mask_off_foe_combatant",
		"pl_mask_off_foe_non_combatant"
	})
end

function PlayerClean:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)
	self._stick_move = self._controller:get_input_axis("move")

	if mvector3.length(self._stick_move) < 0.1 then
		self._move_dir = nil
	else
		self._move_dir = mvector3.copy(self._stick_move)
		local cam_flat_rot = Rotation(self._cam_fwd_flat, math.UP)

		mvector3.rotate_with(self._move_dir, cam_flat_rot)
	end

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_update_foley(t, input)

	local new_action = nil

	self:_check_action_jump(t, input)
	self:_check_action_duck(t, input)

	if not new_action then
		-- Nothing
	end

	if not new_action and self._state_data.ducking and not managers.player:has_category_upgrade("player", "suspicious_movement") then
		self:_end_action_ducking(t)
	end

end

Hooks:PostHook(PlayerClean, "_enter", "RaID_PlayerClean__enter", function(self, enter_data)
	log("CLEAN _ENTER")
end)

Hooks:PostHook(PlayerClean, "enter", "RaID_PlayerClean_enter", function(self, state_data, enter_data)
	--self:_upd_attention()
	log("CLEAN ENTER")
end)