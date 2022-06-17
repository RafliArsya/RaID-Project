function PoisonGasGrenade:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	if self._detonated then
		return
	end

	local pos = self._unit:position()
	local normal = math.UP
	local range = self._range
	local grenade_entry = self:projectile_entry()
	local tweak_entry = tweak_data.projectiles[grenade_entry]

	managers.player:spawn_poison_gas(pos, normal, tweak_entry, self._unit)
	self._unit:body("static_body"):set_fixed()
	self._unit:set_extension_update_enabled(Idstring("base"), false)

	self._timer = nil
	self._detonated = true

	self:remove_trail_effect()

	if Network:is_server() then
        local local_peer = managers.network:session():local_peer()
	    local peer_unit = local_peer and local_peer:unit()
	    local is_local = self._thrower_unit == peer_unit

		local slot_mask = managers.slot:get_mask("explosion_targets")
		local hit_units, splinters = managers.explosion:detect_and_give_dmg({
			player_damage = 0,
			hit_pos = pos,
			range = range,
			collision_slotmask = slot_mask,
			curve_pow = self._curve_pow,
			damage = self._damage,
			ignore_unit = self._unit,
			alert_radius = self._alert_radius,
			user = self:thrower_unit() or self._unit,
			owner = self._unit
		})

        if is_local then
			--[[local proj_ent = self:projectile_entry()
			local tweak_ent = tweak_data.projectiles[proj_ent]
			]]
			
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
			--[[local targets = World:find_units_quick("sphere", pos, range * 1.75, managers.slot:get_mask( "trip_mine_targets" ))
            local weapon_id = tweak_data.blackmarket.projectiles[self:projectile_entry()].weapon_id
            local action_data = {
        	    variant = "explosion",
       			damage = self._damage * 10,
				attacker_unit = self._unit,
				weapon_unit = self._unit,
         		col_ray = {}
        	}
			for _, unit in ipairs(targets) do
				if alive(unit) and not managers.enemy:is_civilian(unit) and not unit:character_damage()._invulnerable and not unit:character_damage().is_escort then	
                    action_data.col_ray = {
                        body = unit:body("body"),
                        position = unit:position() + math.UP * 100, 
                        ray = unit:body("body") and unit:center_of_mass() or alive(unit) and unit:position()
                    }
                    unit:character_damage():damage_explosion(action_data)
				end
			end]]
        end

		managers.explosion:give_local_player_dmg(pos, range, self._player_damage)
		managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)
		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)
	end
end

function PoisonGasGrenade:_detonate_on_client()
	if self._detonated then
		return
	end

	self:_detonate()

	local pos = self._unit:position()
	local range = self._range

    local local_peer = managers.network:session():local_peer()
    local peer_unit = local_peer and local_peer:unit()
    local is_local = self._thrower_unit == peer_unit

    if is_local then
		--[[local proj_ent = self:projectile_entry()
		local tweak_ent = tweak_data.projectiles[proj_ent]
		]]

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
        --[[local targets = World:find_units_quick("sphere", pos, range * 1.75, managers.slot:get_mask( "trip_mine_targets" ))
        local weapon_id = tweak_data.blackmarket.projectiles[self:projectile_entry()].weapon_id
        local action_data = {
            variant = "explosion",
            damage = self._damage * 10,
            attacker_unit = self._unit,
            weapon_unit = self._unit,
            col_ray = {}
        }
        for _, unit in ipairs(targets) do
            if alive(unit) and not managers.enemy:is_civilian(unit) and not unit:character_damage()._invulnerable and not unit:character_damage().is_escort then	
                action_data.col_ray = {
                    body = unit:body("body"),
                    position = unit:position() + math.UP * 100, 
                    ray = unit:body("body") and unit:center_of_mass() or alive(unit) and unit:position()
                }
                unit:character_damage():damage_explosion(action_data)
            end
        end]]
    end

	managers.explosion:give_local_player_dmg(pos, range, self._player_damage)
	managers.explosion:explode_on_client(pos, math.UP, nil, self._damage, range, self._curve_pow, self._custom_params)
end