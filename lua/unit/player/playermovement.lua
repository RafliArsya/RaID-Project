Hooks:PostHook(PlayerMovement, 'init', 'RaIDPost_PlayerMovement_Init', function(self, unit)
    self._underdog_skill_data = {
		nr_enemies = 2,
		chk_t = 6,
		chk_interval_active = 6,
		chk_interval_inactive = 1,
		max_dis_sq = 3240000,
		max_vert_dis = 1000,
		has_dmg_dampener = managers.player:has_category_upgrade("temporary", "dmg_dampener_outnumbered") or managers.player:has_category_upgrade("temporary", "dmg_dampener_outnumbered_strong"),
		has_dmg_dampener_close = managers.player:has_category_upgrade("temporary", "dmg_dampener_close_contact"),
		has_dmg_mul = managers.player:has_category_upgrade("temporary", "dmg_multiplier_outnumbered")
	}
	if self._rally_skill_data then
        local data = managers.player:upgrade_value("cooldown", "long_dis_revive", nil)
        self._rally_skill_data = {
            range_sq = 810000,
            morale_boost_delay_t = managers.player:has_category_upgrade("player", "morale_boost") and 0 or nil,
            long_dis_revive = managers.player:has_category_upgrade("cooldown", "long_dis_revive"),
            revive_chance = data and type(data) ~= "number" and data[1] or 0,
            morale_boost_cooldown_t = tweak_data.upgrades.morale_boost_base_cooldown * managers.player:upgrade_value("player", "morale_boost_cooldown_multiplier", 1),
            revive_chance_inc = 0
        }
    end
    self._close_fear_skill_data = {
		chk_t = 6,
		chk_interval_active = 6,
		chk_interval_inactive = 1,
		max_dis_sq = 90000,
		max_vert_dis = 1000,
		has_close_fear = managers.player:has_category_upgrade("player", "close_hostage_fear"),
        is_active = false
	}
	self._ninja_gone = {
		hud_t = nil,
		is_hud_on = false,
		is_pressed = false,
		active_t = nil,
		cooldown = nil
	}
end)

function PlayerMovement:update(unit, t, dt)
	if _G.IS_VR then
		self:_update_vr(unit, t, dt)
	end

	self:_calculate_m_pose()

	if self:_check_out_of_world(t) then
		return
	end

	self:_upd_underdog_skill(t)
    self:_upd_close_fear_skill(t)

	if self._current_state then
		self._current_state:update(t, dt)
	end

	if self._ninja_gone.active_t then
		if t > self._ninja_gone.active_t - 1.85 then
			local velocity = managers.player:player_unit():mover():velocity()

			if self:crouching() then
				self:current_state():_activate_mover(PlayerStandard.MOVER_DUCK, velocity)
			else
				self:current_state():_activate_mover(PlayerStandard.MOVER_STAND, velocity)
			end
		end
		if t > self._ninja_gone.active_t then
			self:current_state():_upd_attention()
			self._ninja_gone.active_t = nil
		end
	end

	if self._ninja_gone.cooldown and self._ninja_gone.cooldown < t then
		self._ninja_gone.is_pressed = false
		self._ninja_gone.cooldown = nil
	end

	self:update_stamina(t, dt)
	self:update_teleport(t, dt)
end

function PlayerMovement:_get_sus_rat()
	return self._suspicion_ratio
end

function PlayerMovement:_get_suspicion()
	return self._synced_suspicion
end

function PlayerMovement:ninja_escape_cd(val)
	if not val then
		return self._ninja_gone.cooldown
	end
	self._ninja_gone.cooldown = val
end

function PlayerMovement:ninja_escape_t(val)
	if not val then
		return self._ninja_gone.active_t
	end
	self._ninja_gone.active_t = val
end

function PlayerMovement:ninja_escape_hud()
	return self._ninja_gone.is_hud_on
end

function PlayerMovement:_upd_close_fear_skill(t)
	local data = self._close_fear_skill_data
	
	if not data.has_close_fear or t < self._close_fear_skill_data.chk_t then
		return
	end

    if managers.player:close_hostage_fear_val() and managers.player:close_hostage_fear_val() == true then
        managers.player:close_hostage_fear_val(false)
    end
	
	local my_pos = managers.player:player_unit():position()
	local nr_guys = 0
	local activated = nil
	
	local _hostages = World:find_units_quick("sphere", my_pos, 300, {16, 21, 22})
	for _, hit_unit in ipairs(_hostages) do
		if not alive(hit_unit) then
			return
		end
		local hostage_pos = hit_unit:movement():m_pos()
		if math.abs(hostage_pos.z - my_pos.z) < data.max_vert_dis then
			nr_guys = nr_guys + 1
		end
		if nr_guys > 0 then
			activated = true
		end
	end
	if activated then
		managers.player:close_hostage_fear_val(true)
	end

	data.chk_t = t + (activated and data.chk_interval_active or data.chk_interval_inactive)
end

Hooks:PostHook(PlayerMovement, '_feed_suspicion_to_hud', 'RaIDPost_PlayerMovement__feed_suspicion_to_hud', function(self, ...)
	local susp_ratio = self._suspicion_ratio
	--log(tostring(self._suspicion_ratio))
	if managers.player:has_category_upgrade("player", "ninja_escape_move") and susp_ratio and not managers.player:is_carrying() then
		local key_press = managers.player:player_unit():base():controller()
		local interact_pressed = key_press:get_input_bool("interact")
		local is_pressed = interact_pressed and true or false

		self._ninja_gone.is_pressed = is_pressed

		if not self._ninja_gone.cooldown and not self._ninja_gone.active_t then
			if not self._ninja_gone.is_pressed then
				self._ninja_gone.hud_t = Application:time() + 1.25
				if not managers.player._coroutine_mgr:is_running(PlayerAction.NinjaGone) then
					managers.player:add_coroutine("ninja_gone", PlayerAction.NinjaGone, managers.player, managers.hud, self)
				end
			else
				self._ninja_gone.cooldown = Application:time() + 0.25
			end
		end
	end
end)