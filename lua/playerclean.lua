if RequiredScript == "lib/units/beings/player/states/playerclean" then

local old__update_check_actions = PlayerClean._update_check_actions
local old__check_action_jump = PlayerClean._check_action_jump
local old__check_action_duck = PlayerClean._check_action_duck

function PlayerClean:_check_action_duck(t, input, ...)
	local pass = managers.player:has_category_upgrade("player", "suspicious_movement")
	if pass then
		return self:__check_action_duck(t, input)
	end
	return old__check_action_duck(self, t, input, ...)
end


function PlayerClean:_check_action_jump(t, input, ...)
	local pass = managers.player:has_category_upgrade("player", "suspicious_movement")
	if pass then
		return self:__check_action_jump(t, input)
	end
	return old__check_action_jump(self, t, input, ...)
end

function PlayerClean:__check_action_jump(t, input, ...)
	if input.btn_jump_press then
		PlayerStandard._check_action_jump(self, t, input)
	end
end

function PlayerClean:__check_action_duck(t, input, ...)
	if PlayerStandard._setting_hold_to_duck and input.btn_duck_release then
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
	--self:_upd_attention()
end

function PlayerClean:_update_check_actions(t, dt, ...)
	--[[self._ext_movement:set_attention_settings({
		"pl_mask_off_friend_combatant",
		"pl_mask_off_friend_non_combatant",
		"pl_mask_off_foe_combatant",
		"pl_mask_off_foe_non_combatant"
	})]]
	if not managers.player:has_category_upgrade("player", "suspicious_movement") then
		old__update_check_actions(self, t, dt)
	else
	local input = self:_get_input(t, dt)
	self._stick_move = self._controller:get_input_axis("move")

	if mvector3.length(self._stick_move) < 0.1 or self:_interacting() then
		self._move_dir = nil
	else
		self._move_dir = mvector3.copy(self._stick_move)
		local cam_flat_rot = Rotation(self._cam_fwd_flat, math.UP)
		mvector3.rotate_with(self._move_dir, cam_flat_rot)
	end

	self:_update_interaction_timers(t)
	self:_update_start_standard_timers(t)

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_update_foley(t, input)

	local new_action = nil
	new_action = new_action or self:_check_use_item(t, input)
	new_action = new_action or self:_check_action_interact(t, input)

	self:_check_action_jump(t, input)
	self:_check_action_duck(t, input)
	self:_check_action_run(t, input)
	self:_check_action_change_equipment(t, input)
	end
end

end