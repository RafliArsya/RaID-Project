local mto = Vector3()
local mfrom = Vector3()
local mspread = Vector3()

function NewNPCRaycastWeaponBase:auto_fire_blank(direction, impact, sub_ids, override_direction)
	local user_unit = self._setup.user_unit

	self._unit:m_position(mfrom)

	if override_direction then
		direction = self:fire_object():rotation():y()
	end

	local rays = {}
	local right = direction:cross(math.UP):normalized()
	local up = direction:cross(right):normalized()

	if impact and (self._use_trails == nil or self._use_trails == true) then
		local num_rays = (tweak_data.weapon[self:non_npc_name_id()] or {}).rays or 1

		if self._ammo_data and self._ammo_data.rays then
			num_rays = self._ammo_data.rays
		end
		
		if RaID:get_data("toggle_caps_npc_weapon_rays") then
			local max_rays = RaID:get_data("value_caps_npc_weapon_rays")
			num_rays = num_rays <= max_rays and num_rays or max_rays
		end
		
		for i = 1, num_rays do
			local spread_x, spread_y = self:_get_spread(user_unit)
			local theta = math.random() * 360
			local ax = math.sin(theta) * math.random() * spread_x
			local ay = math.cos(theta) * math.random() * (spread_y or spread_x)

			mvector3.set(mspread, direction)
			mvector3.add(mspread, right * math.rad(ax))
			mvector3.add(mspread, up * math.rad(ay))
			mvector3.set(mto, mspread)
			mvector3.multiply(mto, 20000)
			mvector3.add(mto, mfrom)

			local col_ray = World:raycast("ray", mfrom, mto, "slot_mask", self._blank_slotmask, "ignore_unit", self._setup.ignore_units)

			if alive(self._obj_fire) then
				self._obj_fire:m_position(self._trail_effect_table.position)
				mvector3.set(self._trail_effect_table.normal, mspread)
			end

			local trail = nil

			if not self:weapon_tweak_data().no_trail then
				trail = alive(self._obj_fire) and (not col_ray or col_ray.distance > 650) and World:effect_manager():spawn(self._trail_effect_table) or nil
			end

			if col_ray then
				InstantBulletBase:on_collision(col_ray, self._unit, user_unit, self._damage, true)

				if trail then
					World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
				end

				table.insert(rays, col_ray)
			end
		end
	end

	if alive(self._obj_fire) then
		self:_spawn_muzzle_effect(mfrom, direction)
	end

	if self._use_shell_ejection_effect then
		World:effect_manager():spawn(self._shell_ejection_effect_table)
	end

	if self:weapon_tweak_data().has_fire_animation then
		self:tweak_data_anim_play("fire")
	end

	if user_unit:movement() then
		local anim_data = user_unit:anim_data()

		if not anim_data or not anim_data.reload then
			user_unit:movement():play_redirect("recoil_single")
		end
	end

	return true
end

function NewNPCRaycastWeaponBase:fire_blank(direction, impact, sub_id, override_direction)
	local user_unit = self._setup.user_unit

	self._unit:m_position(mfrom)

	if override_direction then
		direction = self:fire_object():rotation():y()
	end

	local rays = {}
	local right = direction:cross(math.UP):normalized()
	local up = direction:cross(right):normalized()

	if impact and (self._use_trails == nil or self._use_trails == true) then
		local num_rays = (tweak_data.weapon[self:non_npc_name_id()] or {}).rays or 1

		if self._ammo_data and self._ammo_data.rays then
			num_rays = self._ammo_data.rays
		end
		
		if RaID:get_data("toggle_caps_npc_weapon_rays") then
			num_rays = num_rays < RaID:get_data("value_caps_npc_weapon_rays") and num_rays or RaID:get_data("value_caps_npc_weapon_rays")
		end

		for i = 1, num_rays do
			local spread_x, spread_y = self:_get_spread(user_unit)
			local theta = math.random() * 360
			local ax = math.sin(theta) * math.random() * spread_x
			local ay = math.cos(theta) * math.random() * (spread_y or spread_x)

			mvector3.set(mspread, direction)
			mvector3.add(mspread, right * math.rad(ax))
			mvector3.add(mspread, up * math.rad(ay))
			mvector3.set(mto, mspread)
			mvector3.multiply(mto, 20000)
			mvector3.add(mto, mfrom)

			local col_ray = World:raycast("ray", mfrom, mto, "slot_mask", self._blank_slotmask, "ignore_unit", self._setup.ignore_units)

			if alive(self._obj_fire) then
				self._obj_fire:m_position(self._trail_effect_table.position)
				mvector3.set(self._trail_effect_table.normal, mspread)
			end

			local trail = nil

			if not self:weapon_tweak_data().no_trail then
				trail = alive(self._obj_fire) and (not col_ray or col_ray.distance > 650) and World:effect_manager():spawn(self._trail_effect_table) or nil
			end

			if col_ray then
				InstantBulletBase:on_collision(col_ray, self._unit, user_unit, self._damage, true)

				if trail then
					World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
				end

				table.insert(rays, col_ray)
			end
		end
	end

	if alive(self._obj_fire) then
		self:_spawn_muzzle_effect(mfrom, direction)
	end

	if self._use_shell_ejection_effect then
		World:effect_manager():spawn(self._shell_ejection_effect_table)
	end

	if self:weapon_tweak_data().has_fire_animation then
		self:tweak_data_anim_play("fire")
	end

	self:_sound_singleshot()
end
