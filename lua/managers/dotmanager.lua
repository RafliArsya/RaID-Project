function DOTManager:_add_doted_enemy(enemy_unit, dot_damage_received_time, weapon_unit, dot_length, dot_damage, hurt_animation, variant, weapon_id, apply_hurt_once)
	local contains = false

	for _, dot_info in ipairs(self._doted_enemies) do
		if dot_info.enemy_unit == enemy_unit then
			local dot_comma = dot_info.dot_times
			dot_info.dot_times = dot_info.dot_times + 1
			local old_length = dot_info.dot_damage_received_time + dot_info.dot_length
			local new_length = dot_damage_received_time + dot_length
            local old_damage = dot_info.dot_damage
			local new_damage = old_damage < dot_damage and dot_damage or old_damage
			new_damage = math.ceil(new_damage*(dot_info.dot_times*dot_comma))

            dot_info.dot_damage = new_damage

			if old_length < new_length then
				dot_info.dot_length = dot_info.dot_length + new_length - old_length
			end

			dot_info.hurt_animation = dot_info.hurt_animation or hurt_animation
			contains = true

			break
		end
	end

	if not contains then
		local dot_info = {
			dot_times = 1,
			dot_counter = 0,
			enemy_unit = enemy_unit,
			dot_damage_received_time = dot_damage_received_time,
			weapon_unit = weapon_unit,
			dot_length = dot_length,
			dot_damage = dot_damage,
			hurt_animation = hurt_animation,
			apply_hurt_once = apply_hurt_once,
			variant = variant,
			weapon_id = weapon_id
		}

		table.insert(self._doted_enemies, dot_info)
		self:check_achievemnts(enemy_unit, dot_damage_received_time)
	end
end