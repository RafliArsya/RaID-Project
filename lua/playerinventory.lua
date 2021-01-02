Hooks:PostHook(PlayerInventory, "_start_jammer_effect", "RAID_PlayerInventory__start_jammer_effect", function(self, end_time)
	local is_player = managers.player:player_unit() or self._unit
	local has_skill = managers.player:has_category_upgrade("player", "pocket_crewd")
	local crewd = managers.player:_jammer_crewd()
	if is_player and has_skill then
		if not crewd then
			managers.player:_jammer_crewd(true)
		end
	end
end)

Hooks:PostHook(PlayerInventory, "_stop_jammer_effect", "RAID_PlayerInventory__stop_jammer_effect", function(self)
	local is_player = managers.player:player_unit() or self._unit
	local crewd = managers.player:_jammer_crewd()
	if is_player then
		if crewd then
			managers.player:_jammer_crewd(false)
		end
	end
end)

Hooks:PostHook(PlayerInventory, "_start_feedback_effect", "RAID_PlayerInventory__start_feedback_effect", function(self, end_time, interval, range)
	local is_player = managers.player:player_unit() or self._unit
	local crewd = managers.player:_jammer_crewd()
	if is_player then
		if crewd then
			managers.player:_jammer_crewd(false)
		end
	end
end)