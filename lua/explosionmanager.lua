Hooks:PostHook(ExplosionManager, "init", "RaID_ExplosionManager_init", function(self)
	self._door_health_mul_diff = {
		easy = 1,
		normal = 1,
		hard = 1,
		overkill = 1,
		overkill_145 = 1,
		easy_wish = 1,
		overkill_290 = 1,
		sm_wish = 1
	}
	--[[self._door_health_mul_diff = {
		easy = 100,
		normal = 150,
		hard = 170,
		overkill = 175,
		overkill_145 = 200,
		easy_wish = 225,
		overkill_290 = 250,
		sm_wish = 325
	}]]
end)

function ExplosionManager:_damage_characters(detect_results, params, variant, damage_func_name)
	local user_unit = params.user
	local owner = params.owner
	local damage = params.damage
	local hit_pos = params.hit_pos
	local col_ray = params.col_ray
	local range = params.range
	local curve_pow = params.curve_pow
	local verify_callback = params.verify_callback
	local ignite_character = params.ignite_character
	damage_func_name = damage_func_name or "damage_explosion"
	local counts = {
		cops = {
			kills = 0,
			hits = 0
		},
		gangsters = {
			kills = 0,
			hits = 0
		},
		civilians = {
			kills = 0,
			hits = 0
		},
		criminals = {
			kills = 0,
			hits = 0
		}
	}
	local criminal_names = CriminalsManager.character_names()

	local function get_first_body_hit(bodies_hit)
		for _, hit_body in ipairs(bodies_hit or {}) do
			if alive(hit_body) then
				return hit_body
			end
		end
	end

	local dir, len, type, count_table, hit_body = nil

	for key, unit in pairs(detect_results.characters_hit) do
		hit_body = get_first_body_hit(detect_results.bodies_hit[key])
		dir = hit_body and hit_body:center_of_mass() or alive(unit) and unit:position()
		len = mvector3.direction(dir, hit_pos, dir)
		local can_damage = not verify_callback

		if verify_callback then
			can_damage = verify_callback(unit)
		end

		if alive(unit) and can_damage then
			if unit:character_damage()[damage_func_name] then
				local action_data = {
					variant = variant or "explosion"
				}

				if damage > 0 then
					action_data.damage = math.max(damage * math.pow(math.clamp(1 - len / range, 0, 1), curve_pow), 1)
				else
					action_data.damage = 0
				end

				action_data.attacker_unit = user_unit
				action_data.weapon_unit = owner
				action_data.col_ray = col_ray or {
					position = unit:position(),
					ray = dir
				}
				action_data.ignite_character = ignite_character

				unit:character_damage()[damage_func_name](unit:character_damage(), action_data)
			else
				debug_pause("unit: ", unit, " is missing " .. tostring(damage_func_name) .. " implementation")
			end
		end

		if alive(unit) and unit:base() and unit:base()._tweak_table then
			type = unit:base()._tweak_table

			if table.contains(criminal_names, CriminalsManager.convert_new_to_old_character_workname(type)) then
				count_table = counts.criminals
			elseif CopDamage.is_civilian(type) then
				count_table = counts.civilians
			elseif CopDamage.is_gangster(type) then
				count_table = counts.gangsters
			else
				count_table = counts.cops
			end

			count_table.hits = count_table.hits + 1

			if unit:character_damage():dead() then
				count_table.kills = count_table.kills + 1
			end
		end
	end

	local results = {
		count_cops = counts.cops.hits,
		count_gangsters = counts.gangsters.hits,
		count_civilians = counts.civilians.hits,
		count_criminals = counts.criminals.hits,
		count_cop_kills = counts.cops.kills,
		count_gangster_kills = counts.gangsters.kills,
		count_civilian_kills = counts.civilians.kills,
		count_criminal_kills = counts.criminals.kills
	}

	return results
end

--[[Hooks:PostHook(ExplosionManager, "detect_and_give_dmg", "RaID_ExplosionManager_detect_and_give_dmg", function(self, params, detect_results)
	log("Executed")
	local user_unit = params.user
	local owner = params.owner
	local ignore_unit = params.ignore_unit
	log("weapon = "..tostring(user_unit))
	log("owner = "..tostring(owner))
	log("ignore = "..tostring(ignore_unit))
	local hit_pos = type(params) == "table" and params.hit_pos or nil
	local slotmask = params.collision_slotmask
	local dmg = params.damage or nil
	if hit_pos and dmg then
		local units = World:find_units("sphere", hit_pos, 300, slotmask or managers.slot:get_mask("bullet_impact_targets"))
		if type(units) == "table" and units[1] then
			for id, hit_unit in pairs(units) do
				if hit_unit:base() and type(hit_unit:base()._devices) == "table" and type(hit_unit:base()._devices.c4) == "table" and type(hit_unit:base()._devices.c4.amount) == "number" then
					if not hit_unit:base()._devices.c4.max_health then
						hit_unit:base()._devices.c4.max_health = 1
					end
					if hit_unit:base()._devices.c4.max_health then
						hit_unit:base()._devices.c4.max_health = hit_unit:base()._devices.c4.max_health - dmg
					end
					if hit_unit:base()._devices.c4.max_health <= 0 then
						local sequence_name = "explode_door"
						if managers.network:session() then
							managers.network:session():send_to_peers_synched("run_mission_door_sequence", hit_unit:base(), sequence_name)
						end
				
						hit_unit:base():run_sequence_simple(sequence_name)
					end
					break
				end
			end
		end
	end
	local position = params.owner:position()
	local rotation = params.owner:rotation()
	local params2 = {
		sound_event = "molotov_impact",
		range = 75,
		curve_pow = 3,
		damage = 1,
		fire_alert_radius = 1500,
		hexes = 6,
		sound_event_burning = "burn_loop_gen",
		is_molotov = true,
		player_damage = 2,
		sound_event_impact_duration = 4,
		burn_tick_period = 0.5,
		burn_duration = 15,
		alert_radius = 1500,
		effect_name = "effects/payday2/particles/explosions/molotov_grenade",
		fire_dot_data = {
			dot_trigger_chance = 35,
			dot_damage = 15,
			dot_length = 6,
			dot_trigger_max_distance = 3000,
			dot_tick_period = 0.5
		}
	}
	EnvironmentFire.spawn(position, rotation, params2, math.UP, unit, 0, 1)
end)]]
--[[
function ExplosionManager:_damage_bodies2(detect_results, params)
	local user_unit = params.user
	local hit_pos = params.hit_pos
	local damage = params.damage
	local range = params.range
	local curve_pow = params.curve_pow

	local fire_dot_data = {
		dot_damage = 5,
		dot_trigger_max_distance = 9000,
		dot_trigger_chance = 100,
		dot_length = 6.1,
		dot_tick_period = 0.5
	}
	local action_data = {}
	action_data.variant = "fire" -- fire taser_tased
	action_data.damage = 1
	action_data.attacker_unit = nil -- managers.player:player_unit() -- or nil
	action_data.col_ray = col_ray
	action_data.fire_dot_data = fire_dot_data
	--[[for _, bodies in pairs(detect_results.bodies_hit) do
		bodies:character_damage():damage_fire(action_data)
	end
end



Hooks:PostHook(ExplosionManager, "client_damage_and_push", "RaID_ExplosionManager_client_damage_and_push", function(self, position, normal, user_unit, dmg, range, curve_pow)
	local hit_pos = position or nil
	local slotmask = managers.slot:get_mask("bullet_impact_targets")
	local dmg = dmg or nil
	if hit_pos and dmg then
		local units = World:find_units("sphere", hit_pos, 300, slotmask or managers.slot:get_mask("bullet_impact_targets"))
		if type(units) == "table" and units[1] then
			for id, hit_unit in pairs(units) do
				if hit_unit:base() and type(hit_unit:base()._devices) == "table" and type(hit_unit:base()._devices.c4) == "table" and type(hit_unit:base()._devices.c4.amount) == "number" then
					if not hit_unit:base()._devices.c4.max_health then
						hit_unit:base()._devices.c4.max_health = 1
					end
					if hit_unit:base()._devices.c4.max_health then
						hit_unit:base()._devices.c4.max_health = hit_unit:base()._devices.c4.max_health - dmg
					end
					if hit_unit:base()._devices.c4.max_health <= 0 then
						local sequence_name = "explode_door"
						if managers.network:session() then
							managers.network:session():send_to_peers_synched("run_mission_door_sequence", hit_unit:base(), sequence_name)
						end
				
						hit_unit:base():run_sequence_simple(sequence_name)
					end
					break
				end
			end
		end
	end
end)

function ExplosionManager:client_damage_and_push(position, normal, user_unit, dmg, range, curve_pow)
	local bodies = World:find_bodies("intersect", "sphere", position, range, managers.slot:get_mask("bullet_impact_targets"))
	local units_to_push = {}

	for _, hit_body in ipairs(bodies) do
		local hit_unit = hit_body:unit()
		units_to_push[hit_body:unit():key()] = hit_unit
		local apply_dmg = hit_body:extension() and hit_body:extension().damage and hit_unit:id() == -1
		local dir, len, damage = nil

		if apply_dmg then
			dir = hit_body:center_of_mass()
			len = mvector3.direction(dir, position, dir)
			damage = dmg * math.pow(math.clamp(1 - len / range, 0, 1), curve_pow)

			self:_apply_body_damage(false, hit_body, user_unit, dir, damage)
		end
	end

	self:units_to_push(units_to_push, position, range)
end]]