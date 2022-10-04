function PlayerBase:sync_unit_upgrades()
	local sus_multiplier = 1
	local det_multiplier = 1

	if managers.player:has_category_upgrade("player", "suspicion_multiplier") then
		local mul = managers.player:upgrade_value("player", "suspicion_multiplier", 1)

		self:set_suspicion_multiplier("suspicion_multiplier", mul)
	end

	managers.environment_controller:set_flashbang_multiplier(managers.player:upgrade_value("player", "flashbang_multiplier"))
    managers.environment_controller:set_concussion_multiplier(managers.player:upgrade_value("player", "flashbang_multiplier"))

	local pm = managers.player
	local net_sesh = managers.network:session()

	for category, upgrades in pairs(pm._global.upgrades) do
		for upgrade, level in pairs(upgrades) do
			if pm:is_upgrade_synced(category, upgrade) then
				if category == "temporary" then
					net_sesh:send_to_peers_synched("sync_temporary_upgrade_owned", category, upgrade, level, pm:temporary_upgrade_index(category, upgrade))
				else
					net_sesh:send_to_peers_synched("sync_upgrade", category, upgrade, level)
				end
			end
		end
	end
end