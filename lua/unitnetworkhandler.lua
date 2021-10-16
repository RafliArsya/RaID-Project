if HopLib then
	return
end

local mark_minion_original = UnitNetworkHandler.mark_minion
function UnitNetworkHandler:mark_minion(unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender, ...)
  if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
    return
  end
  
  local peer = managers.network:session():peer(minion_owner_peer_id)
  local player_unit = peer and peer:unit()
  if alive(player_unit) then
    unit:base()._minion_owner = player_unit
  end
  
  mark_minion_original(self, unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender, ...)
  
end

function UnitNetworkHandler:remove_minion(unit, sender)
	if not self._verify_sender(sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if unit then
		local u_key = unit:key()

		managers.groupai:state():_set_converted_police(u_key, nil)
	end
  NPCRaycastWeaponBase._remove_dmg_explode(unit)
end

--[[function UnitNetworkHandler:m79grenade_explode_on_client(position, normal, user, damage, range, curve_pow, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(user, sender) then
		return
	end
  log("m79 user = "..tostring(user))
	ProjectileBase._explode_on_client(position, normal, user, damage, range, curve_pow)
end]]