local orig_npcrwb__fire_ray = NPCRaycastWeaponBase._fire_raycast
Hooks:PostHook(NPCRaycastWeaponBase, "init", "RaID_NPCRaycastWeaponBase_init", function(self)
	self._minion_damage_explode_t = self._minion_damage_explode_t or {}
end)

function NPCRaycastWeaponBase:_remove_dmg_explode(user_unit)
	if self._minion_damage_explode_t and self._minion_damage_explode_t[user_unit:key()] then
		self._minion_damage_explode_t[user_unit:key()] = nil
	end
end

function NPCRaycastWeaponBase:_add_dmg_explode(user_unit)
    local player = managers.player and managers.player:player_unit()
	if user_unit:in_slot(16) and user_unit:base()._minion_owner and user_unit:base()._minion_owner == player then
		if self._minion_damage_explode_t and not self._minion_damage_explode_t[user_unit:key()] then
			self._minion_damage_explode_t[user_unit:key()] = TimerManager:game():time() + 1
		end
	end
end

function NPCRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	local result = {}
	local hit_unit = nil
	local miss, extra_spread = self:_check_smoke_shot(user_unit, target_unit)

	if miss then
		result.guaranteed_miss = miss

		mvector3.spread(direction, math.rand(unpack(extra_spread)))
	end

	mvector3.set(mvec_to, direction)
	mvector3.multiply(mvec_to, 20000)
	mvector3.add(mvec_to, from_pos)

	local damage = self._damage * (dmg_mul or 1)
	local col_ray = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	local player_hit, player_ray_data = nil

	if shoot_player and self._hit_player then
		player_hit, player_ray_data = self:damage_player(col_ray, from_pos, direction, result)

		if player_hit then
			InstantBulletBase:on_hit_player(col_ray or player_ray_data, self._unit, user_unit, damage)
		end
	end

	local char_hit = nil

	if not player_hit and col_ray then
		char_hit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
	end

	if (not col_ray or col_ray.unit ~= target_unit) and target_unit and target_unit:character_damage() and target_unit:character_damage().build_suppression then
		target_unit:character_damage():build_suppression(tweak_data.weapon[self._name_id].suppression)
	end

	if not col_ray or col_ray.distance > 600 or result.guaranteed_miss then
		local num_rays = (tweak_data.weapon[self._name_id] or {}).rays or 1

		for i = 1, math.min(num_rays, 4) do
			mvector3.set(mvec_spread, direction)

			if i > 1 then
				mvector3.spread(mvec_spread, self:_get_spread(user_unit))
			end

			self:_spawn_trail_effect(mvec_spread, col_ray)
		end
	end

	result.hit_enemy = char_hit

	if self._alert_events then
		result.rays = {
			col_ray
		}
	end

	self:_cleanup_smoke_shot()

	return result
end

function NPCRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	if user_unit:in_slot(16) and managers.player and managers.player:player_unit() and target_unit and user_unit:base()._minion_owner and user_unit:base()._minion_owner == managers.player:player_unit() then
		local player = managers.player:player_unit() or managers.player:local_player()
		local _t = TimerManager:game():time()
		if not alive(player)then
			return orig_npc_fire_ray(self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
		end
		if self._minion_damage_explode_t and not self._minion_damage_explode_t[user_unit:key()] then
			self._minion_damage_explode_t[user_unit:key()] = _t + 1
		end
		if self._minion_damage_explode_t[user_unit:key()] and _t >= self._minion_damage_explode_t[user_unit:key()] then
			local e_pos = target_unit:position()
			local bodies = World:find_units_quick("sphere", e_pos, 300, managers.slot:get_mask("enemies"))
			local col_ray = { }
			col_ray.ray = Vector3(1, 0, 0)
			col_ray.position = e_pos

			local interval = math.randomFloat(1,12,1)

			self._minion_damage_explode_t[user_unit:key()] = _t + interval

			local action_data = {
				variant = "bullet" or "light",
				damage = 100,
				weapon_unit = user_unit:base()._minion_owner:inventory():equipped_unit(),
				attacker_unit = user_unit,
				col_ray = col_ray,
				armor_piercing = false,
				shield_knock = false,
				origin = user_unit:position(),
				knock_down = false,
				stagger = false
			}
			for _, hit_unit in ipairs(bodies) do
				if hit_unit:character_damage() then
					hit_unit:character_damage():damage_explosion(action_data)
				end
			end
		end
	end
    return orig_npcrwb__fire_ray(self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
end