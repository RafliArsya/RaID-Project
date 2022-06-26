function RaycastWeaponBase:_collect_hits(from, to)
    local has_heat_to_overkill = managers.player:has_category_upgrade("temporary", "heat_to_overkill") and managers.player:has_activate_temporary_upgrade("temporary", "heat_to_overkill")
	local can_shoot_through_wall = self._can_shoot_through_wall or has_heat_to_overkill
    local can_shoot_through_shield = self._can_shoot_through_shield or has_heat_to_overkill
    local can_shoot_through_enemy = self._can_shoot_through_enemy or has_heat_to_overkill
	local ray_hits = nil
	local hit_enemy = false
	local enemy_mask = managers.slot:get_mask("enemies")
	local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
	local shield_mask = managers.slot:get_mask("enemy_shield_check")
	local ai_vision_ids = Idstring("ai_vision")
	local bulletproof_ids = Idstring("bulletproof")

	if self._can_shoot_through_wall then
		ray_hits = World:raycast_wall("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask)
	else
		ray_hits = World:raycast_all("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	end

	local units_hit = {}
	local unique_hits = {}

	for i, hit in ipairs(ray_hits) do
		if not units_hit[hit.unit:key()] then
			units_hit[hit.unit:key()] = true
			unique_hits[#unique_hits + 1] = hit
			hit.hit_position = hit.position
			hit_enemy = hit_enemy or hit.unit:in_slot(enemy_mask)
			local weak_body = hit.body:has_ray_type(ai_vision_ids)
			weak_body = weak_body or hit.body:has_ray_type(bulletproof_ids)

			if not can_shoot_through_enemy and hit_enemy then
				break
			elseif not can_shoot_through_wall and hit.unit:in_slot(wall_mask) and weak_body then
				break
			elseif not can_shoot_through_shield and hit.unit:in_slot(shield_mask) then
				break
			end
		end
	end

	return unique_hits, hit_enemy
end