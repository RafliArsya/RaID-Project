SniperGrazeDamage = SniperGrazeDamage or {}

function SniperGrazeDamage:on_weapon_fired(weapon_unit, result)
	if not alive(weapon_unit) then
		return
	end

	if not weapon_unit:base():is_category("snp", "assault_rifle") then
		return
	end

	local is_assault = weapon_unit:base():is_category("assault_rifle") and true or false

	if is_assault then
		if weapon_unit:base():fire_mode() == ("auto" or "burst") then
			return
		end
	end

	if weapon_unit ~= managers.player:equipped_weapon_unit() then
		return
	end

	if not result.hit_enemy then
		return
	end

	if not result.rays then
		return
	end

	local furthest_hit = result.rays[#result.rays]
	local upgrade_value = managers.player:upgrade_value("snp", "graze_damage")
	--local enemies_hit = {}
	local best_damage = 0
	local sentry_mask = managers.slot:get_mask("sentry_gun")
	local ally_mask = managers.slot:get_mask("all_criminals")

	local target_hit = {}

	for i, hit in ipairs(result.rays) do
		local is_turret = hit.unit:in_slot(sentry_mask)
		local is_ally = hit.unit:in_slot(ally_mask)
		local is_valid_hit = hit.damage_result and hit.damage_result.attack_data and true or false

		if not is_turret and not is_ally and is_valid_hit then
			local result = hit.damage_result
			local attack_data = result.attack_data
			local headshot_kill = attack_data.headshot --and (result.type == "death" or result.type == "healed")
			local damage_mul = headshot_kill and upgrade_value.damage_factor_headshot or upgrade_value.damage_factor
			damage_mul = is_assault and damage_mul * 0.5 or damage_mul
			local damage = attack_data.damage * damage_mul

			if best_damage < damage then
				best_damage = damage
			end

			--enemies_hit[hit.unit:key()] = true
			table.insert(target_hit, hit.unit)
		end
	end

	if best_damage == 0 then
		return
	end

	local radius = upgrade_value.radius
	local from = mvector3.copy(furthest_hit.position)
	local stopped_by_geometry = furthest_hit.unit:in_slot(managers.slot:get_mask("world_geometry"))
	local distance = stopped_by_geometry and furthest_hit.distance - radius * 2 or weapon_unit:base():weapon_range() - radius

	mvector3.add_scaled(from, furthest_hit.ray, -furthest_hit.distance)
	mvector3.add_scaled(from, furthest_hit.ray, radius)

	local to = mvector3.copy(from)

	mvector3.add_scaled(to, furthest_hit.ray, distance)

	local targets = {}
	
	local hits = World:raycast_all("ray", from, to, "sphere_cast_radius", radius, "disable_inner_ray", "slot_mask", managers.slot:get_mask("enemies"))

	for i, hit in ipairs(hits) do
		if not table.contains(target_hit, hit.unit) and not table.contains(targets, hit.unit) then
			table.insert(targets, hit.unit)
		end
	end

	local hits_round = World:find_units_quick("sphere", from, radius, managers.slot:get_mask("enemies"))

	for i, hit in ipairs(hits) do
		if not table.contains(target_hit, hit.unit) and not table.contains(targets, hit.unit) then
			table.insert(targets, hit.unit)
		end
	end

	for _, hit in pairs(targets) do
		local hit_pos = Vector3()
		mvector3.set(hit_pos, hit:movement():m_head_pos())
		if hit:character_damage() and not hit:character_damage():dead() then
			hit:character_damage():damage_simple({
				variant = "graze",
				damage = best_damage,
				attacker_unit = managers.player:player_unit(),
				pos = hit:position(),
				attack_dir = from - hit_pos
			})
		end
	end

end
