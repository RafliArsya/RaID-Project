function ExplosionManager:detect_and_give_effect(params)
    local eff_var = params.variant
	local user_unit = params.user
	local owner = params.owner
	local damage = params.damage
	local player_damage = params.player_damage or damage
	local range = params.range
	local hit_pos = params.hit_pos
	local alert_radius = params.alert_radius or 1000
	local alert_filter = params.alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies")
	local alert_unit = user_unit

	if alive(alert_unit) and alert_unit:base() and alert_unit:base().thrower_unit then
		alert_unit = alert_unit:base():thrower_unit()
	end

	local push_units = false

	if params.push_units ~= nil then
		push_units = params.push_units
	end

	local player = managers.player:player_unit()

	if alive(player) and player_damage ~= 0 then
		player:character_damage():damage_explosion({
			variant = "explosion",
			position = hit_pos,
			range = range,
			damage = player_damage,
			ignite_character = params.ignite_character
		})
	end

    if alert_radius and alert_radius > 0 then
        managers.groupai:state():propagate_alert({
            "explosion",
            hit_pos,
            alert_radius,
            alert_filter,
            alert_unit
        })
    end
	
	local detect_results = self:_detect_hits(params)

	self:_damage_body_ext(detect_results, params)

	local damage_results = self:_damage_characters(detect_results, params)
	local results = {}

	if owner then
		results.count_cops = damage_results.count_cops
		results.count_gangsters = damage_results.count_gangsters
		results.count_civilians = damage_results.count_civilians
		results.count_cop_kills = damage_results.count_cop_kills
		results.count_gangster_kills = damage_results.count_gangster_kills
		results.count_civilian_kills = damage_results.count_civilian_kills
	end

	if push_units and push_units == true then
		self:units_to_push(detect_results.units_detected, hit_pos, range)
	end

	return detect_results.units_hit, detect_results.splinters, results
end

function ExplosionManager:_damage_body_ext(detect_results, params)
	local user_unit = params.user
	local hit_pos = params.hit_pos
	local damage = params.damage
	local range = params.range
	local curve_pow = params.curve_pow

	for _, bodies in pairs(detect_results.bodies_hit) do
		for _, hit_body in ipairs(bodies) do
			local apply_dmg = alive(hit_body) and hit_body:extension() and hit_body:extension().damage

			if apply_dmg then
				local dir = hit_body:center_of_mass()
				local len = mvector3.direction(dir, hit_pos, dir)
				local prop_damage = damage * math.pow(math.clamp(1 - len / range, 0, 1), curve_pow)
				prop_damage = math.max(prop_damage, math.min(damage, 1))
				prop_damage = math.ceil(prop_damage * 5)

				self:_apply_body_damage(true, hit_body, user_unit, dir, prop_damage)
			end
		end
	end
end

function ExplosionManager:_apply_body_damage(is_server, hit_body, user_unit, dir, damage)
	local hit_unit = hit_body:unit()
	local local_damage = is_server or hit_unit:id() == -1
	local sync_damage = is_server and hit_unit:id() ~= -1

	if not local_damage and not sync_damage then
		--print("_apply_body_damage skipped")
		return
	end

	local normal = dir
	local prop_damage = damage

	if prop_damage < 0.25 then
		prop_damage = math.round(prop_damage, 0.25)
	end

	if prop_damage > 0 then
		local local_damage = is_server or hit_unit:id() == -1
		local sync_damage = is_server and hit_unit:id() ~= -1
		local network_damage = math.ceil(prop_damage * 163.84)
		prop_damage = network_damage / 163.84


		if local_damage then
			hit_body:extension().damage:damage_explosion(user_unit, normal, hit_body:position(), dir, prop_damage)
			hit_body:extension().damage:damage_damage(user_unit, normal, hit_body:position(), dir, prop_damage)
		end

		if sync_damage and managers.network:session() then
			if alive(user_unit) then
				managers.network:session():send_to_peers_synched("sync_body_damage_explosion", hit_body, user_unit, normal, hit_body:position(), dir, math.min(32768, network_damage))
			else
				managers.network:session():send_to_peers_synched("sync_body_damage_explosion_no_attacker", hit_body, normal, hit_body:position(), dir, math.min(32768, network_damage))
			end
		end
	end
end
