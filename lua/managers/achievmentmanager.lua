
function AchievmentManager:award(id)
	if not self:exists(id) then
		Application:error("[AchievmentManager:award] Awarding non-existing achievement", "id", id)

		return
	end

	managers.challenge:on_achievement_awarded(id)
	managers.custom_safehouse:on_achievement_awarded(id)
	managers.generic_side_jobs:award(id)
	managers.event_jobs:award(id)

	if managers.mutators:are_achievements_disabled() then
		--return
	end

	local info = self:get_info(id)

	if info.awarded then
		return
	end

	if managers.hud and not info.showed_awarded then
		managers.hud:achievement_popup(id)

		info.showed_awarded = true
	end

	if id == "christmas_present" then
		managers.network.account._masks.santa = true
	elseif id == "golden_boy" then
		managers.network.account._masks.gold = true
	end

	self:do_award(id)
	managers.mission:call_global_event(Message.OnAchievement, id)
end

function AchievmentManager:award_progress(stat, value)
	if Application:editor() then
		return
	end

	managers.challenge:on_achievement_progressed(stat)
	managers.custom_safehouse:on_achievement_progressed(stat, value)
	managers.generic_side_jobs:award(stat)
	managers.event_jobs:award(stat)

	if managers.mutators:are_mutators_active() and game_state_machine:current_state_name() ~= "menu_main" then
		--return
	end

	print("[AchievmentManager] award_progress: ", stat .. " increased by " .. tostring(value or 1))

	if SystemInfo:platform() == Idstring("WIN32") then
		self.handler:achievement_store_callback(AchievmentManager.steam_unlock_result)
	end

	local unlocks = tweak_data.achievement.persistent_stat_unlocks[stat] or {}
	local old_value = managers.network.account:get_stat(stat)
	local unlock_check = table.filter_list(unlocks, function (v)
		local info = self:get_info(v.award)

		if info and info.awarded then
			return false
		end

		if v.check_func_name and not callback(self, self, v.check_func_name)(stat) then
			return false
		end

		return old_value <= v.at
	end)
	local stats = {
		[stat] = {
			type = "int",
			value = value or 1
		}
	}

	managers.network.account:publish_statistics(stats, true)

	local new_value = managers.network.account:get_stat(stat)

	print("[AchievmentManager]", inspect(unlock_check))

	for _, d in pairs(unlock_check) do
		if d.at <= new_value then
			self:award(d.award)
		end
	end
end