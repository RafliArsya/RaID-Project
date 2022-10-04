local mvec_temp = Vector3()
local mvec_to = Vector3()
local mvec_direction = Vector3()
local mvec_spread_direction = Vector3()

function tdump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. tdump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
end 

function DeepPrint(e)
    -- if e is a table, we should iterate over its elements
    if type(e) == "table" then
        for k,v in pairs(e) do -- for every element in the table
            log(tostring(k))
            DeepPrint(v)       -- recursively repeat the same procedure
        end
    else -- if not, we can just print it
        log(tostring(e))
    end
end


function ShotgunBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data, sg_ray)
	local result = nil
	local hit_enemies = {}
    --local hit_enemies_t = {}
    local hit_enemies_c = {}
	local hit_objects = {}
	local hit_something, col_rays = nil

	if self._alert_events then
		col_rays = {}
	end

	local damage = self:_get_current_damage(dmg_mul)
	local autoaim, dodge_enemies = self:check_autoaim(from_pos, direction, self._range)
	local weight = 0.1
	local enemy_died = false

	local function hit_enemy(col_ray)
		if col_ray.unit:character_damage() then
			--log("HIT HERE")
			local enemy_key = col_ray.unit:key()

            --table.insert(hit_enemies_t, col_ray)

            hit_enemies_c[enemy_key] = hit_enemies_c[enemy_key] or {}
			hit_enemies_c[enemy_key]["body"] = hit_enemies_c[enemy_key]["body"] or {}
			hit_enemies_c[enemy_key]["headshot"] = hit_enemies_c[enemy_key]["headshot"] or {}
            if col_ray.unit:character_damage().is_head and col_ray.unit:character_damage():is_head(col_ray.body) then
                hit_enemies_c[enemy_key]["headshot"].count = hit_enemies_c[enemy_key]["headshot"].count or 0
                hit_enemies_c[enemy_key]["headshot"].count = hit_enemies_c[enemy_key]["headshot"].count + 1
				hit_enemies_c[enemy_key]["headshot"].ray = col_ray
            else
                hit_enemies_c[enemy_key]["body"].count = hit_enemies_c[enemy_key].body.count or 0
                hit_enemies_c[enemy_key]["body"].count = hit_enemies_c[enemy_key].body.count + 1
				hit_enemies_c[enemy_key]["body"].ray = col_ray
            end

            --log("Body = "..tostring(hit_enemies_c[enemy_key].body))
            --log("Head = "..tostring(hit_enemies_c[enemy_key].headshot))

			if not hit_enemies[enemy_key] or col_ray.unit:character_damage().is_head and col_ray.unit:character_damage():is_head(col_ray.body) then
				hit_enemies[enemy_key] = col_ray
			end

			if not col_ray.unit:character_damage().is_head then
				self._bullet_class:on_collision_effects(col_ray, self._unit, user_unit, damage)
			end
		else
			local add_shoot_through_bullet = self._can_shoot_through_shield or self._can_shoot_through_wall

			if add_shoot_through_bullet then
				hit_objects[col_ray.unit:key()] = hit_objects[col_ray.unit:key()] or {}

				table.insert(hit_objects[col_ray.unit:key()], col_ray)
				--log("HEREEEE")
			else
				self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
			end
		end
	end

	local spread_x, spread_y = self:_get_spread(user_unit)
	local right = direction:cross(Vector3(0, 0, 1)):normalized()
	local up = direction:cross(right):normalized()

	mvector3.set(mvec_direction, direction)

	for i = 1, shoot_through_data and 1 or self._rays do
		local theta = math.random() * 360
		local ax = math.sin(theta) * math.random() * spread_x * (spread_mul or 1)
		local ay = math.cos(theta) * math.random() * spread_y * (spread_mul or 1)

		mvector3.set(mvec_spread_direction, mvec_direction)
		mvector3.add(mvec_spread_direction, right * math.rad(ax))
		mvector3.add(mvec_spread_direction, up * math.rad(ay))
		mvector3.set(mvec_to, mvec_spread_direction)
		mvector3.multiply(mvec_to, 20000)
		mvector3.add(mvec_to, from_pos)

		local ray_from_unit = shoot_through_data and alive(shoot_through_data.ray_from_unit) and shoot_through_data.ray_from_unit or nil
		local col_ray = (ray_from_unit or World):raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)

		if col_rays then
			if col_ray then
				table.insert(col_rays, col_ray)
			else
				local ray_to = mvector3.copy(mvec_to)
				local spread_direction = mvector3.copy(mvec_spread_direction)

				table.insert(col_rays, {
					position = ray_to,
					ray = spread_direction
				})
			end
		end

		if self._autoaim and autoaim then
			if col_ray and col_ray.unit:in_slot(managers.slot:get_mask("enemies")) then
				self._autohit_current = (self._autohit_current + weight) / (1 + weight)

				hit_enemy(col_ray)

				autoaim = false
			else
				autoaim = false
				local autohit = self:check_autoaim(from_pos, direction, self._range)

				if autohit then
					local autohit_chance = 1 - math.clamp((self._autohit_current - self._autohit_data.MIN_RATIO) / (self._autohit_data.MAX_RATIO - self._autohit_data.MIN_RATIO), 0, 1)

					if math.random() < autohit_chance then
						self._autohit_current = (self._autohit_current + weight) / (1 + weight)
						hit_something = true

						hit_enemy(autohit)
					else
						self._autohit_current = self._autohit_current / (1 + weight)
					end
				elseif col_ray then
					hit_something = true

					hit_enemy(col_ray)
				end
			end
		elseif col_ray then
			hit_something = true

			hit_enemy(col_ray)
		end
	end

	--DeepPrint(hit_objects)
	for _, col_rays in pairs(hit_objects) do
		--log(tdump(col_rays))
		local center_ray = col_rays[1]

		if #col_rays > 1 then
			mvector3.set_static(mvec_temp, center_ray)

			for _, col_ray in ipairs(col_rays) do
				mvector3.add(mvec_temp, col_ray.position)
			end

			mvector3.divide(mvec_temp, #col_rays)

			local closest_dist_sq = mvector3.distance_sq(mvec_temp, center_ray.position)
			local dist_sq = nil

			for _, col_ray in ipairs(col_rays) do
				dist_sq = mvector3.distance_sq(mvec_temp, col_ray.position)

				if dist_sq < closest_dist_sq then
					closest_dist_sq = dist_sq
					center_ray = col_ray
				end
			end
		end

		log("LOL")
		ShotgunBase.super._fire_raycast(self, user_unit, from_pos, center_ray.ray, dmg_mul, shoot_player, 0, autohit_mul, suppr_mul, shoot_through_data, sg_ray)
	end

	local kill_data = {
		kills = 0,
		headshots = 0,
		civilian_kills = 0
	}

	for _, enemy in pairs(hit_enemies_c) do
		local headshot = false
		local dont_count = false
		local sg_ray = {
			current_hit = 0,
			hit_total = 0,
			headshot = false,
			dont_count = false
		}
		--local save_damage = 0
		if enemy.headshot.ray ~= nil then
			headshot = true
		end
		sg_ray.hit_total = enemy.body.count or 0 + enemy.headshot.count or 0
		log("whatt")
		for i, v in pairs(enemy) do
			sg_ray.headshot = headshot
			sg_ray.dont_count = dont_count
			local col_ray = v.ray ~= nil and v.ray or nil
			if col_ray and col_ray.unit:character_damage() and not col_ray.unit:character_damage():dead() then
				log("aaa "..tostring(sg_ray.hit_total))
				sg_ray.current_hit = v.count and v.count or 0
				local damage = self:get_damage_falloff(damage, col_ray, user_unit)
	
				if damage > 0 then
					local my_result = nil
					local add_shoot_through_bullet = self._can_shoot_through_shield or self._can_shoot_through_enemy or self._can_shoot_through_wall
					local collection = sg_ray.current_hit

					damage = damage * collection
					
					if add_shoot_through_bullet then
						log("GO HERE")
						my_result = ShotgunBase.super._fire_raycast(self, user_unit, from_pos, col_ray.ray, dmg_mul, shoot_player, 0, autohit_mul, suppr_mul, shoot_through_data, sg_ray)
					else
						my_result = self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage, sg_ray)
					end
		
					my_result = managers.mutators:modify_value("ShotgunBase:_fire_raycast", my_result)
		
					if my_result and my_result.type == "death" then
						kill_data.kills = kill_data.kills + 1
		
						if col_ray.body and col_ray.body:name() == Idstring("head") or sg_ray.headshot==true then
							kill_data.headshots = kill_data.headshots + 1
						end
		
						if col_ray.unit and col_ray.unit:base() and (col_ray.unit:base()._tweak_table == "civilian" or col_ray.unit:base()._tweak_table == "civilian_female") then
							kill_data.civilian_kills = kill_data.civilian_kills + 1
						end
					end
				end
			end
			sg_ray.dont_count = sg_ray.dont_count==true and sg_ray.dont_count or true
		end
		--log("Head = "..tostring(enemy.headshot.ray))
		--[[for i, v in pairs(enemy) do
			local col_ray = v.ray ~= nil and v.ray or nil
			if col_ray and col_ray.unit:character_damage() and not col_ray.unit:character_damage():dead() then
				local damage = self:get_damage_falloff(damage, col_ray, user_unit)
	
				if damage > 0 then
					local my_result = nil
					local add_shoot_through_bullet = self._can_shoot_through_shield or self._can_shoot_through_enemy or self._can_shoot_through_wall
					local collection = v.count and v.count or 0

					damage = damage * collection
					if headshot and i ~= "headshot" then
						save_damage = damage
					end
					if headshot and i == "headshot" or not headshot and i == "body" then
						damage = damage + save_damage
						if add_shoot_through_bullet then
							my_result = ShotgunBase.super._fire_raycast(self, user_unit, from_pos, col_ray.ray, dmg_mul, shoot_player, 0, autohit_mul, suppr_mul, shoot_through_data)
						else
							my_result = self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
						end
		
						my_result = managers.mutators:modify_value("ShotgunBase:_fire_raycast", my_result)
		
						if my_result and my_result.type == "death" then
							kill_data.kills = kill_data.kills + 1
		
							if col_ray.body and col_ray.body:name() == Idstring("head") then
								kill_data.headshots = kill_data.headshots + 1
							end
		
							if col_ray.unit and col_ray.unit:base() and (col_ray.unit:base()._tweak_table == "civilian" or col_ray.unit:base()._tweak_table == "civilian_female") then
								kill_data.civilian_kills = kill_data.civilian_kills + 1
							end
						end
					end
				end
			end
		end]]
	end
	--[[for _, enemy in pairs(hit_enemies_c) do
		for _, v in pairs(enemy) do
			local col_ray = v.ray ~= nil and v.ray or nil
			if col_ray and col_ray.unit:character_damage() and not col_ray.unit:character_damage():dead() then
				local damage = self:get_damage_falloff(damage, col_ray, user_unit)
	
				if damage > 0 then
					local my_result = nil
					local add_shoot_through_bullet = self._can_shoot_through_shield or self._can_shoot_through_enemy or self._can_shoot_through_wall
					local collection = v.count and v.count or 0

					damage = damage * collection

					if add_shoot_through_bullet then
						my_result = ShotgunBase.super._fire_raycast(self, user_unit, from_pos, col_ray.ray, dmg_mul, shoot_player, 0, autohit_mul, suppr_mul, shoot_through_data)
					else
						my_result = self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
					end
	
					my_result = managers.mutators:modify_value("ShotgunBase:_fire_raycast", my_result)
	
					if my_result and my_result.type == "death" then
						kill_data.kills = kill_data.kills + 1
	
						if col_ray.body and col_ray.body:name() == Idstring("head") then
							kill_data.headshots = kill_data.headshots + 1
						end
	
						if col_ray.unit and col_ray.unit:base() and (col_ray.unit:base()._tweak_table == "civilian" or col_ray.unit:base()._tweak_table == "civilian_female") then
							kill_data.civilian_kills = kill_data.civilian_kills + 1
						end
					end
				end
			end
		end
        --log(tostring(col_ray.unit))
	end]]

	--[[for _, col_ray in pairs(hit_enemies_t) do
        --log(tostring(col_ray.unit))
        if col_ray.unit:character_damage() and not col_ray.unit:character_damage():dead() then
		    local damage = self:get_damage_falloff(damage, col_ray, user_unit)

		    if damage > 0 then
			    local my_result = nil
			    local add_shoot_through_bullet = self._can_shoot_through_shield or self._can_shoot_through_enemy or self._can_shoot_through_wall

			    if add_shoot_through_bullet then
			    	my_result = ShotgunBase.super._fire_raycast(self, user_unit, from_pos, col_ray.ray, dmg_mul, shoot_player, 0, autohit_mul, suppr_mul, shoot_through_data)
			    else
			    	my_result = self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
			    end

			    my_result = managers.mutators:modify_value("ShotgunBase:_fire_raycast", my_result)

			    if my_result and my_result.type == "death" then
			    	kill_data.kills = kill_data.kills + 1

			    	if col_ray.body and col_ray.body:name() == Idstring("head") then
			    		kill_data.headshots = kill_data.headshots + 1
			    	end

			    	if col_ray.unit and col_ray.unit:base() and (col_ray.unit:base()._tweak_table == "civilian" or col_ray.unit:base()._tweak_table == "civilian_female") then
			    		kill_data.civilian_kills = kill_data.civilian_kills + 1
			    	end
			    end
		    end
        end
	end]]

	if dodge_enemies and self._suppression then
		for enemy_data, dis_error in pairs(dodge_enemies) do
			enemy_data.unit:character_damage():build_suppression(suppr_mul * dis_error * self._suppression, self._panic_suppression_chance)
		end
	end

	if not result then
		result = {
			hit_enemy = next(hit_enemies) and true or false
		}

		if self._alert_events then
			result.rays = #col_rays > 0 and col_rays
		end
	end

	if not shoot_through_data then
		managers.statistics:shot_fired({
			hit = false,
			weapon_unit = self._unit
		})
	end

	for _, d in pairs(hit_enemies) do
		managers.statistics:shot_fired({
			skip_bullet_count = true,
			hit = true,
			weapon_unit = self._unit
		})
	end

	for key, data in pairs(tweak_data.achievement.shotgun_single_shot_kills) do
		if data.headshot and data.count <= kill_data.headshots - kill_data.civilian_kills or data.count <= kill_data.kills - kill_data.civilian_kills then
			local should_award = true

			if data.blueprint then
				local missing_parts = false

				for _, part_or_parts in ipairs(data.blueprint) do
					if type(part_or_parts) == "string" then
						if not table.contains(self._blueprint or {}, part_or_parts) then
							missing_parts = true

							break
						end
					else
						local found_part = false

						for _, part in ipairs(part_or_parts) do
							if table.contains(self._blueprint or {}, part) then
								found_part = true

								break
							end
						end

						if not found_part then
							missing_parts = true

							break
						end
					end
				end

				if missing_parts then
					should_award = false
				end
			end

			if should_award then
				managers.achievment:_award_achievement(data, key)
			end
		end
	end

	return result
end

local MIN_KNOCK_BACK = 200
local KNOCK_BACK_CHANCE = 0.8

function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, sg_ray, blank, no_sound)
	local hit_unit = col_ray.unit
	local shield_knock = false
	local is_shield = hit_unit:in_slot(8) and alive(hit_unit:parent())

	if sg_ray then
		log("SG: CALL IT")
	else
		log("ANY: CALL IT")
	end

	if is_shield and not hit_unit:parent():character_damage():is_immune_to_shield_knockback() and weapon_unit then
		shield_knock = weapon_unit:base()._shield_knock
		local dmg_ratio = math.min(damage, MIN_KNOCK_BACK)
		dmg_ratio = dmg_ratio / MIN_KNOCK_BACK + 1
		local rand = math.random() * dmg_ratio

		if KNOCK_BACK_CHANCE < rand then
			local enemy_unit = hit_unit:parent()

			if shield_knock and enemy_unit:character_damage() then
				local damage_info = {
					damage = 0,
					type = "shield_knock",
					variant = "melee",
					col_ray = col_ray,
					result = {
						variant = "melee",
						type = "shield_knock"
					}
				}

				enemy_unit:character_damage():_call_listeners(damage_info)
			end
		end
	end

	local play_impact_flesh = not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood

	if hit_unit:damage() and managers.network:session() and col_ray.body:extension() and col_ray.body:extension().damage then
		local sync_damage = not blank and hit_unit:id() ~= -1
		local network_damage = math.ceil(damage * 163.84)
		damage = network_damage / 163.84

		if sync_damage then
			local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
			local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

			managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.unit:id() ~= -1 and col_ray.body or nil, user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
		end

		local local_damage = not blank or hit_unit:id() == -1

		if local_damage then
			col_ray.body:extension().damage:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
			col_ray.body:extension().damage:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, damage)

			if alive(weapon_unit) and weapon_unit:base().categories and weapon_unit:base():categories() then
				for _, category in ipairs(weapon_unit:base():categories()) do
					col_ray.body:extension().damage:damage_bullet_type(category, user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
				end
			end
		end
	end

	local result = nil

	if alive(weapon_unit) and hit_unit:character_damage() and hit_unit:character_damage().damage_bullet then
		local is_alive = not hit_unit:character_damage():dead()
		local knock_down = weapon_unit:base()._knock_down and weapon_unit:base()._knock_down > 0 and math.random() < weapon_unit:base()._knock_down
		result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, weapon_unit:base()._use_armor_piercing, false, knock_down, weapon_unit:base()._stagger, weapon_unit:base()._variant, sg_ray)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()
			local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

			managers.game_play_central:physics_push(col_ray, push_multiplier)

			if result and result.type == "death" and weapon_unit:base()._do_shotgun_push then
				managers.game_play_central:do_shotgun_push(col_ray.unit, col_ray.position, col_ray.ray, col_ray.distance, user_unit)
			end
		else
			play_impact_flesh = false
		end
	else
		managers.game_play_central:physics_push(col_ray)
	end

	if play_impact_flesh then
		managers.game_play_central:play_impact_flesh({
			col_ray = col_ray,
			no_sound = no_sound
		})
		self:play_impact_sound_and_effects(weapon_unit, col_ray, no_sound)
	end

	return result
end

function InstantBulletBase:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, shield_knock, knock_down, stagger, variant, sg_ray)
	local action_data = {
		variant = variant or "bullet",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		shield_knock = shield_knock,
		origin = user_unit:position(),
		knock_down = knock_down,
		stagger = stagger,
		sg_ray = sg_ray
	}
	local defense_data = col_ray.unit:character_damage():damage_bullet(action_data)

	return defense_data
end

function FlameBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, sg_ray, blank)
	local hit_unit = col_ray.unit
	local play_impact_flesh = false
	local armor_piercing = false

	if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
		local sync_damage = not blank and hit_unit:id() ~= -1
		local network_damage = math.ceil(damage * 163.84)
		damage = network_damage / 163.84

		if sync_damage then
			local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
			local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

			managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.unit:id() ~= -1 and col_ray.body or nil, user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
		end

		local local_damage = not blank or hit_unit:id() == -1

		if local_damage then
			col_ray.body:extension().damage:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
			col_ray.body:extension().damage:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, damage)

			if alive(weapon_unit) and weapon_unit:base().categories and weapon_unit:base():categories() then
				for _, category in ipairs(weapon_unit:base():categories()) do
					col_ray.body:extension().damage:damage_bullet_type(category, user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
				end
			end
		end
	end

	local result = nil

	if hit_unit:character_damage() and hit_unit:character_damage().damage_fire then
		local is_alive = not hit_unit:character_damage():dead()

		result = self:give_fire_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, sg_ray)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()

			if weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.push_units then
				local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

				managers.game_play_central:physics_push(col_ray, push_multiplier)
			end
		else
			play_impact_flesh = false
		end
	elseif weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.push_units then
		managers.game_play_central:physics_push(col_ray)
	end

	if play_impact_flesh then
		managers.game_play_central:play_impact_flesh({
			no_sound = true,
			col_ray = col_ray
		})
	end

	self:play_impact_sound_and_effects(weapon_unit, col_ray)

	return result
end

function FlameBulletBase:give_fire_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, sg_ray)
	local fire_dot_data = nil

	if weapon_unit.base and weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.bullet_class == "FlameBulletBase" then
		fire_dot_data = weapon_unit:base()._ammo_data.fire_dot_data
	elseif weapon_unit.base and weapon_unit:base()._name_id then
		local weapon_name_id = weapon_unit:base()._name_id

		if tweak_data.weapon[weapon_name_id] and tweak_data.weapon[weapon_name_id].fire_dot_data then
			fire_dot_data = tweak_data.weapon[weapon_name_id].fire_dot_data
		end
	end

	if sg_ray then
		log("HEHEHE")
	end

	local action_data = {
		variant = "fire",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		fire_dot_data = fire_dot_data,
		sg_ray = sg_ray
	}
	local defense_data = col_ray.unit:character_damage():damage_fire(action_data)

	return defense_data
end

function FlameBulletBase:give_fire_damage_dot(col_ray, weapon_unit, attacker_unit, damage, is_fire_dot_damage, is_molotov, sg_ray)
	local action_data = {
		variant = "fire",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = attacker_unit,
		col_ray = col_ray,
		is_fire_dot_damage = is_fire_dot_damage,
		is_molotov = is_molotov,
		sg_ray = sg_ray
	}
	local defense_data = {}

	if col_ray and col_ray.unit and alive(col_ray.unit) and col_ray.unit:character_damage() then
		defense_data = col_ray.unit:character_damage():damage_fire(action_data)
	end

	return defense_data
end
