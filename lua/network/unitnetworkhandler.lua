function UnitNetworkHandler:sync_end_assault(result)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local mplayer = managers.player
	local player = mplayer and mplayer:player_unit()
	if alive(player) and mplayer:has_category_upgrade("player", "super_syndrome") and mplayer:has_category_upgrade("player", "replenish_super_syndrome_chance") then
		mplayer:_on_recharge_super_syndrome_event()
	end

	managers.hud:sync_end_assault(result)
end

function UnitNetworkHandler:mark_minion(unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
		return
	end

	local health_multiplier = 1

	if convert_enemies_health_multiplier_level > 0 then
		health_multiplier = health_multiplier * tweak_data.upgrades.values.player.convert_enemies_health_multiplier[convert_enemies_health_multiplier_level]
	end

	if passive_convert_enemies_health_multiplier_level > 0 then
		health_multiplier = health_multiplier * tweak_data.upgrades.values.player.passive_convert_enemies_health_multiplier[passive_convert_enemies_health_multiplier_level]
	end

	local is_local_owner = minion_owner_peer_id == managers.network:session():local_peer():id()

	--mod
	local peer = managers.network:session():peer(minion_owner_peer_id)
	local player_unit = peer and peer:unit()
	if alive(player_unit) and is_local_owner then
		unit:base()._minion_owner = player_unit
	end
  
	NPCRaycastWeaponBase:_add_dmg_explode(unit, unit:base()._minion_owner)
	--end mod

	unit:character_damage():convert_to_criminal(health_multiplier)
	unit:contour():add("friendly", false, nil, is_local_owner and tweak_data.contour.character.friendly_minion_color)
	managers.groupai:state():sync_converted_enemy(unit, minion_owner_peer_id)

	if is_local_owner then
		managers.player:count_up_player_minions()
	end
end

function UnitNetworkHandler:remove_minion(unit, sender)
	if not self._verify_sender(sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if unit then
		local u_key = unit:key()

		managers.groupai:state():_set_converted_police(u_key, nil)
	end
	NPCRaycastWeaponBase:_remove_dmg_explode(unit)
end