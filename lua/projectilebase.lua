function ProjectileBase:set_weapon_unit(weapon_unit)
	self._weapon_unit = weapon_unit
	self._weapon_id = weapon_unit and weapon_unit:base():get_name_id()
	self._weapon_damage_mult = weapon_unit and weapon_unit:base().projectile_damage_multiplier and weapon_unit:base():projectile_damage_multiplier() or 1
	self._shield_knock = managers.player:has_category_upgrade("player", "shield_knock") and true or false
	self._knock_down = managers.player:upgrade_value("weapon", "knock_down", nil)
end

function ProjectileBase.throw_projectile(projectile_type, pos, dir, owner_peer_id)
	if not ProjectileBase.check_time_cheat(projectile_type, owner_peer_id) then
		return
	end

	log("Projectile")

	local tweak_entry = tweak_data.blackmarket.projectiles[projectile_type]
	local unit_name = Idstring(not Network:is_server() and tweak_entry.local_unit or tweak_entry.unit)
	local unit = World:spawn_unit(unit_name, pos, Rotation(dir, math.UP))

	if owner_peer_id and managers.network:session() then
		local peer = managers.network:session():peer(owner_peer_id)
		local thrower_unit = peer and peer:unit()

		if alive(thrower_unit) then
			unit:base():set_thrower_unit(thrower_unit)

			if not tweak_entry.throwable and thrower_unit:movement() and thrower_unit:movement():current_state() then
				unit:base():set_weapon_unit(thrower_unit:movement():current_state()._equipped_unit)
			end
		end
	end

	unit:base():throw({
		dir = dir,
		projectile_entry = projectile_type
	})

	if unit:base().set_owner_peer_id then
		unit:base():set_owner_peer_id(owner_peer_id)
	end

	local projectile_type_index = tweak_data.blackmarket:get_index_from_projectile_id(projectile_type)

	managers.network:session():send_to_peers_synched("sync_throw_projectile", unit:id() ~= -1 and unit or nil, pos, dir, projectile_type_index, owner_peer_id or 0)

	if tweak_data.blackmarket.projectiles[projectile_type].impact_detonation then
		unit:damage():add_body_collision_callback(callback(unit:base(), unit:base(), "clbk_impact"))
		unit:base():create_sweep_data()
	end

	return unit
end

--[[function ProjectileBase:_fire_large()
	local params = {
		sound_event = "molotov_impact",
		range = 75,
		curve_pow = 3,
		damage = 1,
		fire_alert_radius = 1500,
		hexes = 6,
		sound_event_burning = "burn_loop_gen",
		is_molotov = true,
		player_damage = 2,
		sound_event_impact_duration = 4,
		burn_tick_period = 0.5,
		burn_duration = 15,
		alert_radius = 1500,
		effect_name = "effects/payday2/particles/explosions/molotov_grenade",
		fire_dot_data = {
			dot_trigger_chance = 35,
			dot_damage = 15,
			dot_length = 6,
			dot_trigger_max_distance = 3000,
			dot_tick_period = 0.5
		}
	}

	return params
end]]

