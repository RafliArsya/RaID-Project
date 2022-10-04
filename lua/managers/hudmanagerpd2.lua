
local HUDManager_sync_end_assault = HUDManager.sync_end_assault
function HUDManager:sync_end_assault(result)
	local mplayer = managers.player
	local player = mplayer and mplayer:player_unit()
	if alive(player) and mplayer:has_category_upgrade("player", "super_syndrome") and mplayer:has_category_upgrade("player", "replenish_super_syndrome_chance") then
		mplayer:_on_recharge_super_syndrome_event()
	end
	
	HUDManager_sync_end_assault(self, result)
end