function IncendiaryBurstGrenade:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	if self._detonated then
		return
	end

	self._detonated = true
	local pos = self._unit:position()
	local normal = math.UP
	local range = self._range
	local slot_mask = managers.slot:get_mask("explosion_targets")

	managers.fire:give_local_player_dmg(pos, range, self._player_damage)
	managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)
	managers.explosion:client_damage_and_push(pos, normal, nil, self._damage, range, self._curve_pow)

	local params = {
		player_damage = 0,
		is_molotov = "fir_com",
		hit_pos = pos,
		range = range,
		collision_slotmask = slot_mask,
		curve_pow = self._curve_pow,
		damage = self._damage,
		ignore_unit = self._unit,
		alert_radius = self._alert_radius,
		user = self:thrower_unit() or self._unit,
		owner = self._unit,
		fire_dot_data = self._fire_dot_data
	}
	local hit_units, splinters = managers.fire:detect_and_give_dmg(params)

	local local_peer = managers.network:session():local_peer()
	local peer_unit = local_peer and local_peer:unit()
	local is_local = self._thrower_unit == peer_unit
	
	if is_local then
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
	
	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)

	self.burn_stop_time = TimerManager:game():time() + self._fire_dot_data.dot_length + 1

	self._unit:set_visible(false)
end

function IncendiaryBurstGrenade:_detonate_on_client()
	if self._detonated then
		return
	end

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
            curve_pow = self._curve_pow or 3,
            damage = self._damage * 5,
            ignore_unit = self._unit,
            alert_radius = self._alert_radius or 1000,
            user = self:thrower_unit() or self._unit,
            owner = self._unit
        })
	end

	managers.fire:give_local_player_dmg(pos, range, self._player_damage)
	managers.explosion:explode_on_client(pos, math.UP, nil, self._damage, range, self._curve_pow, self._custom_params)
end