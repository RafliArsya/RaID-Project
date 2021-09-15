SentryGunBase.DEPLOYEMENT_COST = {
	0.75,
	0.8,
	0.85
}

SentryGunBase.ROTATION_SPEED_MUL = {
	1.2,
	1.7
}

SentryGunBase.SPREAD_MUL = {
	1,
	0.4
}

function SentryGunBase:on_death()    
	if self._unit:base():is_owner() then
		if managers.player:has_category_upgrade("sentry_gun", "destroy_explosion") then
			local data = managers.player:upgrade_value("sentry_gun", "destroy_explosion")
			local function unit_stance(unit_key)
				if alive(unit_key) and unit_key:character_damage() and not unit_key:character_damage():dead() then
					local is_civ = CopDamage.is_civilian(unit_key:base()._tweak_table)
					local is_sentry = unit_key:base() and unit_key:base().sentry_gun and (unit_key:base():get_type() == "sentry_gun" or unit_key:base():get_type() == "sentry_gun_silent")
					local is_enemy = unit_key:base() and unit_key:base()._tweak_table and managers.enemy:is_enemy(unit_key)
					local is_converted = unit_key:brain() and unit_key:brain()._logic_data and unit_key:brain()._logic_data.is_converted
					local is_enggage = unit_key:brain() and unit_key:brain():is_hostile() 
					local is_human = (is_civ or is_enemy) and true or false
					local unit_mov = unit_key:movement()
					local unit_enggage = unit_mov and not is_sentry and is_human and not unit_mov:cool()
					local unit_hostile = unit_mov and not is_sentry and is_human and unit_mov:stance_name() == "hos"
					local unit_cbt = unit_mov and not is_sentry and is_human and unit_mov:stance_name() == "cbt"
					local unit_sentry_enemy = is_sentry and unit_mov and unit_mov:team().foes[tweak_data.levels:get_default_team_ID("player")]
					local unit_dmg = unit_key:character_damage()
					if is_civ and (unit_enggage or unit_hostile) then
						return true, false, false
					end
					if not is_civ and not is_converted and is_enggage and unit_enggage and (unit_hostile or unit_cbt) then
						return false, true, false
					end
					if unit_sentry and unit_sentry_enemy then
						if unit_dmg then
							return false, false, true
						end
					end
				end
				return false, false, false
			end	
		
        	local bodies = World:find_units_quick("sphere", self._unit:position(), data.radius, managers.slot:get_mask(data.slotmask))
        	local col_ray = { }
        	col_ray.ray = Vector3(1, 0, 0)
        	col_ray.position = self._unit:position()
        	local action_data = {
        	    variant = "explosion",
       			damage = data.damage,
         		attacker_unit = RaID:get_data("toggle_sentry_skill_is_player") and managers.player:player_unit() or self._unit,
				weapon_unit = self._unit,
         		col_ray = col_ray
        	}
        	for _, hit_unit in pairs(bodies) do
				local civs, enemies, sentries = unit_stance(hit_unit)
         		if hit_unit:character_damage() and (civs or enemies or sentries) then
         	       hit_unit:character_damage():damage_explosion(action_data)
        		end
        	end
    	end

	
		if managers.player:_has_sentry_lives() then
			if self._unit:interaction() then
				self._unit:interaction():interact()
				managers.player:_sentry_lives(1)
			end
        end
    end
	
	self._unit:set_extension_update_enabled(Idstring("base"), false)
	self:unregister()
end
