function FragGrenade:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	if self._detonated then
		return
	end

	self._detonated = true
	local pos = self._unit:position()
	local normal = math.UP
	local range = self._range
	local slot_mask = managers.slot:get_mask("explosion_targets")

	managers.explosion:give_local_player_dmg(pos, range, self._player_damage)
	managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)

	local local_peer = managers.network:session():local_peer()
	local peer_unit = local_peer and local_peer:unit()
	local is_local = self._thrower_unit == peer_unit

	local hit_units, splinters = managers.explosion:detect_and_give_dmg({
		player_damage = 0,
		hit_pos = pos,
		range = is_local and range * 1.75 or range,
		collision_slotmask = slot_mask,
		curve_pow = self._curve_pow,
		damage = is_local and self._damage * 6 or self._damage ,
		ignore_unit = self._unit,
		alert_radius = self._alert_radius,
		user = self:thrower_unit() or self._unit,
		owner = self._unit
	})

	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)
	self._unit:set_slot(0)
end

function FragGrenade:_detonate_on_client()
	if self._detonated then
		return
	end

    --[[log("thrower_unit = "..tostring(self._thrower_unit))
	local local_peer = managers.network:session():local_peer()
	local peer_unit = local_peer and local_peer:unit()
	log("peer unit = "..tostring(peer_unit))
	log("self._unit = "..tostring(peer_unit))]]
	
	self._detonated = true
	local pos = self._unit:position()
	local range = self._range

	local local_peer = managers.network:session():local_peer()
	local peer_unit = local_peer and local_peer:unit()
	local is_local = self._thrower_unit == peer_unit

	if is_local then
		local slot_mask = managers.slot:get_mask("explosion_targets")
		local hit_unitsb, splintersb = managers.explosion:detect_and_give_effect({
			player_damage = 0,
			hit_pos = self._unit:position(),
			range = self._range * 1.75,
			collision_slotmask = slot_mask,
			curve_pow = self._curve_pow,
			damage = self._damage * 5,
			ignore_unit = self._unit,
			alert_radius = self._alert_radius,
			user = self:thrower_unit() or self._unit,
			owner = self._unit,
			owner_peer_id = local_peer:id()
		})
	end

	managers.explosion:give_local_player_dmg(pos, range, self._player_damage)
	managers.explosion:explode_on_client(pos, math.UP, nil, self._damage, range, self._curve_pow, self._custom_params)
end