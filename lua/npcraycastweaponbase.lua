local mvec_to = Vector3()
local mvec_spread = Vector3()

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
		
		if RaID:get_data("toggle_caps_npc_weapon_rays") then
			local max_rays = RaID:get_data("value_caps_npc_weapon_rays")
			num_rays = num_rays <= max_rays and num_rays or max_rays
		end
		
		for i = 1, num_rays do
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

local orig_npc_fire_ray = NPCRaycastWeaponBase._fire_raycast
function NPCRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	if user_unit:in_slot(16) and managers.player:player_unit() and target_unit and user_unit:base()._minion_owner == managers.player:player_unit() then
		local player = managers.player:player_unit()
		local _t = TimerManager:game():time()
		if _t >= self._minion_damage_explode_t then
			local e_pos = target_unit:position()
			local bodies = World:find_units_quick("sphere", e_pos, 325, managers.slot:get_mask("enemies"))
			local col_ray = { }
			col_ray.ray = Vector3(1, 0, 0)
			col_ray.position = e_pos
			local interval = 10 * math.min((math.floor(math.random()*100)/100)+0.1,1)
			interval = math.max(interval, 1)
			self._minion_damage_explode_t = _t + interval
			local action_data = {
				variant = "explosion",
				damage = 100,
				attacker_unit = user_unit,
				weapon_unit = user_unit:base()._minion_owner:inventory():equipped_unit(),
				col_ray = col_ray
			}
			log("Minion Damage Explode = "..self._minion_damage_explode_t)
			for _, hit_unit in ipairs(bodies) do
				if hit_unit:character_damage() then
					hit_unit:character_damage():damage_explosion(action_data)
				end
			end
		end
	end
    return orig_npc_fire_ray(self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
end

Hooks:PostHook(NPCRaycastWeaponBase, "init", "RaID_NPCRaycastWeaponBase_init", function(self)
	self._minion_damage_explode_t = 0
end)