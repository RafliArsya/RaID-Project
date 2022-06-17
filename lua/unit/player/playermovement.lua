Hooks:PostHook(PlayerMovement, 'init', 'RaIDPost_PlayerMovement_Init', function(self, unit)
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

	self:update_stamina(t, dt)
	self:update_teleport(t, dt)
end

function PlayerMovement:_upd_close_fear_skill(t)
    local data = self._close_fear_skill_data
    local hostages = managers.groupai:state():all_hostages()
    local activated = nil

	if not self._attackers or not data.has_close_fear or t < self._close_fear_skill_data.chk_t or hostages <= 0 then
		return
	end

    if managers.player:close_hostage_fear_val() == true or not activated then
        managers.player:close_hostage_fear_val(false)
    end
   
	local my_pos = self._m_pos
	local max_guys_to_check = data.nr_enemies
	local nr_guys = 0
	
    for key, unit in pairs(managers.groupai:state():all_hostages()) do
        if alive(unit) and unit:character_damage() and not unit:character_damage():dead() then
            local is_converted = unit:brain() and unit:brain()._logic_data and unit:brain()._logic_data.is_converted
            
            local hostage_pos = unit:movement():m_pos()
            local dis_sq = mvector3.distance_sq(hostage_pos, my_pos)

            if dis_sq <= data.max_dis_sq and math.abs(hostage_pos.z - my_pos.z) <= data.max_vert_dis and not is_converted then
                activated = true
                nr_guys = nr_guys + 1
            end
        end    
    end

    if activated then
        managers.player:close_hostage_fear_val(true)
    end

	self._close_fear_skill_data.chk_t = t + (activated and data.chk_interval_active or data.chk_interval_inactive)
end