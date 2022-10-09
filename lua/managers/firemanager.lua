function FireManager:_damage_fire_dot(dot_info)
	if dot_info.user_unit and dot_info.user_unit == managers.player:player_unit() or not dot_info.user_unit and Network:is_server() then
		local attacker_unit = managers.player:player_unit()
		local col_ray = {
			unit = dot_info.enemy_unit
		}
		local damage = dot_info.dot_damage
		if dot_info.user_unit and dot_info.user_unit == managers.player:player_unit() then
			if dot_info.dot_mul_counter then
				damage = damage * dot_info.dot_mul_counter
			end
		end
		local ignite_character = false
		local variant = "fire"
		local weapon_unit = dot_info.weapon_unit
		local is_fire_dot_damage = true
		local is_molotov = dot_info.is_molotov
		--dot_info.dot_damage = damage
		dot_info.dot_mul_counter = math.min(dot_info.dot_mul_counter + 1, 10)

		FlameBulletBase:give_fire_damage_dot(col_ray, weapon_unit, attacker_unit, damage, is_fire_dot_damage, is_molotov)
	end
end

function FireManager:_add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
	local contains = false

	if self._doted_enemies then
		for _, dot_info in ipairs(self._doted_enemies) do
			if dot_info.enemy_unit == enemy_unit then
				dot_info.fire_damage_received_time = fire_damage_received_time
				contains = true
				if dot_info.user_unit == user_unit then
					local new_damage = tonumber(dot_info.dot_damage) < tonumber(dot_damage) and tonumber(dot_damage) or tonumber(dot_info.dot_damage)
					dot_info.dot_damage = new_damage
					if dot_info.dot_mul_counter then
						dot_info.dot_mul_counter = math.max(math.floor(dot_info.dot_mul_counter * 0.5), 1)
					end
				end
			end
		end

		if not contains then
			local dot_info = {
				fire_dot_counter = 0,
				enemy_unit = enemy_unit,
				fire_damage_received_time = fire_damage_received_time,
				weapon_unit = weapon_unit,
				dot_length = dot_length,
				dot_damage = dot_damage,
				user_unit = user_unit,
				is_molotov = is_molotov,
				dot_mul_counter = 1
			}

			table.insert(self._doted_enemies, dot_info)

			local has_delayed_info = false

			for index, delayed_dot in pairs(self.predicted_dot_info) do
				if enemy_unit == delayed_dot.enemy_unit then
					dot_info.sound_source = delayed_dot.sound_source
					dot_info.fire_effects = delayed_dot.fire_effects

					table.remove(self.predicted_dot_info, index)

					has_delayed_info = true
				end
			end

			if not has_delayed_info then
				self:_start_enemy_fire_effect(dot_info)
				self:start_burn_body_sound(dot_info)
			end
		end

		self:check_achievemnts(enemy_unit, fire_damage_received_time)
	end
end