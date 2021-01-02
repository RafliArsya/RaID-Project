function RaycastWeaponBase:KNOCKBACK_CHANCE()
	local rand = math.random()
	return rand
end

local MIN_KNOCK_BACK = 200

function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound)
	local hit_unit = col_ray.unit
	local shield_knock = weapon_unit and weapon_unit:base()._shield_knock
	local is_shield = hit_unit:in_slot(8) and alive(hit_unit:parent())
	
	if is_shield and not hit_unit:parent():character_damage():is_immune_to_shield_knockback() and weapon_unit and shield_knock then
		local dmg_ratio = math.clamp(damage, 0.001, MIN_KNOCK_BACK)
		dmg_ratio = dmg_ratio / MIN_KNOCK_BACK
		local rand = dmg_ratio
		rand = rand + weapon_unit:base():KNOCK_BACK_CHANCE()
		if RaycastWeaponBase:KNOCKBACK_CHANCE() < rand then
			local enemy_unit = hit_unit:parent()

			if enemy_unit:character_damage() then
				local damage_info = {
					damage = 0.5,
					type = "shield_knock",
					variant = "melee",
					col_ray = col_ray,
					result = {
						variant = "melee",
						type = "shield_knock"
					}
				}

				enemy_unit:character_damage():_call_listeners(damage_info)
			end
			weapon_unit:base():KNOCK_BACK_CHANCE(0)
		else
			weapon_unit:base():KNOCK_BACK_CHANCE(math.clamp(dmg_ratio * math.random(), 0.005, 0.16))
		end
	end

	local play_impact_flesh = not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood

	if hit_unit:damage() and managers.network:session() and col_ray.body:extension() and col_ray.body:extension().damage then
		local sync_damage = not blank and hit_unit:id() ~= -1
		local network_damage = math.ceil(damage * 163.84)
		damage = network_damage / 163.84

		if sync_damage then
			local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
			local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

			managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.unit:id() ~= -1 and col_ray.body or nil, user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
		end

		local local_damage = not blank or hit_unit:id() == -1

		if local_damage then
			col_ray.body:extension().damage:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
			col_ray.body:extension().damage:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, damage)

			if alive(weapon_unit) and weapon_unit:base().categories and weapon_unit:base():categories() then
				for _, category in ipairs(weapon_unit:base():categories()) do
					col_ray.body:extension().damage:damage_bullet_type(category, user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
				end
			end
		end
	end

	local result = nil

	if alive(weapon_unit) and hit_unit:character_damage() and hit_unit:character_damage().damage_bullet then
		local is_alive = not hit_unit:character_damage():dead()
		local knock_down = weapon_unit:base()._knock_down and type(weapon_unit:base()._knock_down) == "number" and weapon_unit:base()._knock_down > 0
		local is_knocked_down = false
		if knock_down then
			--log("KNOCK_DOWN = "..tostring(weapon_unit:base()._knock_down))
			local val = weapon_unit:base()._knock_down 
			val = val + weapon_unit:base():KNOCK_DOWN_CHANCE()
			if val > math.random() then
				is_knocked_down = true
				weapon_unit:base():KNOCK_DOWN_CHANCE(0)
				--log("reset knock_down")
			else
				weapon_unit:base():KNOCK_DOWN_CHANCE(0.03)
				--log("increase knock_down = "..tostring(weapon_unit:base():KNOCK_DOWN_CHANCE()))
			end
		end
		
		result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, weapon_unit:base()._use_armor_piercing, false, is_knocked_down, weapon_unit:base()._stagger, weapon_unit:base()._variant)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()
			local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

			managers.game_play_central:physics_push(col_ray, push_multiplier)
		else
			play_impact_flesh = false
		end
	else
		managers.game_play_central:physics_push(col_ray)
	end

	if play_impact_flesh then
		managers.game_play_central:play_impact_flesh({
			col_ray = col_ray,
			no_sound = no_sound
		})
		self:play_impact_sound_and_effects(weapon_unit, col_ray, no_sound)
	end

	return result
end