function CopDamage:WriteFile(Contents)
	local file, err = io.open(RaID._path.."/printcopdamage.txt", "r")
	if not file then
		file = io.open(RaID._path.."/printcopdamage.txt", "w")
		file:close()
	else
		file:close()
		file = io.open(RaID._path.."/printcopdamage.txt", "a")
		file:write(Contents.."\n")
		file:close()
	end
end

function CopDamage:damage_bullet(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if self:is_friendly_fire(attack_data.attacker_unit) then
		return "friendly_fire"
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)

	if self._has_plate and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_plate_name and not attack_data.armor_piercing then
		local armor_pierce_roll = math.random()
		local armor_damage_reduction = 1
		local armor_pierce_value = 0
		local piercing_val = nil

		local function round(x, n)
			n = math.pow(10, n or 0)
			x = x * n
			if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
			return x / n
		end
		

		if attack_data.attacker_unit == managers.player:player_unit() and not attack_data.weapon_unit:base().thrower_unit then
			armor_pierce_value = armor_pierce_value + attack_data.weapon_unit:base():armor_piercing_chance()
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("player", "armor_piercing_chance", 0)
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance", 0)
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance_2", 0)

			if attack_data.weapon_unit:base():got_silencer() then
				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance_silencer", 0)
			end

			if attack_data.weapon_unit:base():is_category("saw") then
				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("saw", "armor_piercing_chance", 0)
			end
		elseif attack_data.attacker_unit:base() and attack_data.attacker_unit:base().sentry_gun then
			local owner = attack_data.attacker_unit:base():get_owner()

			if alive(owner) then
				if owner == managers.player:player_unit() then
					armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("sentry_gun", "armor_piercing_chance", 0)
					armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("sentry_gun", "armor_piercing_chance_2", 0)
				else
					armor_pierce_value = armor_pierce_value + (owner:base():upgrade_value("sentry_gun", "armor_piercing_chance") or 0)
					armor_pierce_value = armor_pierce_value + (owner:base():upgrade_value("sentry_gun", "armor_piercing_chance_2") or 0)
				end
			end
		end
		
		armor_pierce_value = round(armor_pierce_value, 2)

		if armor_pierce_value == 0 then
			return
		end

		piercing_val = 1 - math.clamp(armor_damage_reduction - armor_pierce_value, 0, 1)
		attack_data.damage = attack_data.damage * piercing_val
	end

	local result = nil
	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local damage = attack_data.damage

	if self._unit:base():char_tweak().DAMAGE_CLAMP_BULLET then
		damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_BULLET)
	end

	damage = damage * (self._marked_dmg_mul or 1)

	if self._marked_dmg_mul and self._marked_dmg_dist_mul then
		local dst = mvector3.distance(attack_data.origin, self._unit:position())
		local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

		if spott_dst[1] < dst then
			damage = damage * spott_dst[2]
		end
	end

	if self._unit:movement():cool() then
		damage = self._HEALTH_INIT
	end

	local headshot = false
	local headshot_multiplier = 1

	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)

		if critical_hit then
			managers.hud:on_crit_confirmed()

			damage = crit_damage
			attack_data.critical_hit = true
		else
			managers.hud:on_hit_confirmed()
		end

		headshot_multiplier = managers.player:upgrade_value("weapon", "passive_headshot_damage_multiplier", 1)

		if tweak_data.character[self._unit:base()._tweak_table].priority_shout then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end

		if head then
			managers.player:on_headshot_dealt()

			headshot = true
		end
	end

	if not self._char_tweak.ignore_headshot and not self._damage_reduction_multiplier and head then
		if self._char_tweak.headshot_dmg_mul then
			damage = damage * self._char_tweak.headshot_dmg_mul * headshot_multiplier
		else
			damage = self._health * 10
		end
	end

	if attack_data.weapon_unit:base().get_add_head_shot_mul then
		local add_head_shot_mul = attack_data.weapon_unit:base():get_add_head_shot_mul()

		if not head and add_head_shot_mul and self._char_tweak and self._char_tweak.access ~= "tank" then
			local tweak_headshot_mul = math.max(0, self._char_tweak.headshot_dmg_mul - 1)
			local mul = tweak_headshot_mul * add_head_shot_mul + 1
			damage = damage * mul
		end
	end

	damage = self:_apply_damage_reduction(damage)
	attack_data.raw_damage = damage
	attack_data.headshot = head
	local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, self._HEALTH_GRANULARITY))
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			if head then
				managers.player:on_lethal_headshot_dealt(attack_data.attacker_unit, attack_data)

				if math.random(10) < damage then
					self:_spawn_head_gadget({
						position = attack_data.col_ray.body:position(),
						rotation = attack_data.col_ray.body:rotation(),
						dir = attack_data.col_ray.ray
					})
				end
			end

			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "bullet", headshot)
		end
	else
		attack_data.damage = damage
		local result_type = not self._char_tweak.immune_to_knock_down and (attack_data.knock_down and "knock_down" or attack_data.stagger and not self._has_been_staggered and "stagger") or self:get_damage_type(damage_percent, "bullet")
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			head_shot = head,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant
		}

		if managers.groupai:state():all_criminals()[attack_data.attacker_unit:key()] then
			managers.statistics:killed_by_anyone(data)
		end

		if attack_data.attacker_unit == managers.player:player_unit() then
			local special_comment = self:_check_special_death_conditions(attack_data.variant, attack_data.col_ray.body, attack_data.attacker_unit, attack_data.weapon_unit)

			self:_comment_death(attack_data.attacker_unit, self._unit, special_comment)
			self:_show_death_hint(self._unit:base()._tweak_table)

			local attacker_state = managers.player:current_state()
			data.attacker_state = attacker_state
			
			--data.weapon_unit = data.weapon_unit ~= nil and data.weapon_unit or attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
			if not data.weapon_unit or data.weapon_unit == nil then
				self:WriteFile("[data weapon_unit][attack weapon_unit][attack attacker_unit] :"..tostring(data.weapon_unit)..", "..tostring(attack_data.weapon_unit)..", "..tostring(attack_data.attacker_unit))
			else
				managers.statistics:killed(data)
			end
			self:_check_damage_achievements(attack_data, head)

			if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
				managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
			end

			if is_civilian then
				managers.money:civilian_killed()
			end
		elseif attack_data.attacker_unit:in_slot(managers.slot:get_mask("criminals_no_deployables")) then
			self:_AI_comment_death(attack_data.attacker_unit, self._unit)
		elseif attack_data.attacker_unit:base().sentry_gun then
			if Network:is_server() then
				local server_info = attack_data.weapon_unit:base():server_information()

				if server_info and server_info.owner_peer_id ~= managers.network:session():local_peer():id() then
					local owner_peer = managers.network:session():peer(server_info.owner_peer_id)

					if owner_peer then
						owner_peer:send_queued_sync("sync_player_kill_statistic", data.name, data.head_shot and true or false, data.weapon_unit, data.variant, data.stats_name)
					end
				else
					data.attacker_state = managers.player:current_state()

					managers.statistics:killed(data)
				end
			end

			local sentry_attack_data = deep_clone(attack_data)
			sentry_attack_data.attacker_unit = attack_data.attacker_unit:base():get_owner()
			--log("sentry_attack_data.weapon_unit = "..tostring(sentry_attack_data.weapon_unit))

			if sentry_attack_data.attacker_unit == managers.player:player_unit() then
				self:_check_damage_achievements(sentry_attack_data, head)
			else
				self._unit:network():send("sync_damage_achievements", sentry_attack_data.weapon_unit, sentry_attack_data.attacker_unit, sentry_attack_data.damage, sentry_attack_data.col_ray and sentry_attack_data.col_ray.distance, head)
			end
		end
	end

	local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
	local attacker = attack_data.attacker_unit

	if attacker:id() == -1 then
		attacker = self._unit
	end

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", attacker, damage_percent)
	end

	local variant = nil

	local function do_dot_damage(self)
		local pm = managers.player
		if not pm then
			return
		end
		local player = pm:local_player()
		if not player then
			return
		end
		local t = pm:player_timer():time()
		
		if alive(self._unit) and self._unit:character_damage() and not self._unit:character_damage():dead() then
			local is_converted = self._unit:brain() and self._unit:brain()._logic_data and self._unit:brain()._logic_data.is_converted
			local is_enggage = self._unit:brain() and self._unit:brain():is_hostile()
			local unit_dmg = self._unit:character_damage()
			local unit_mov = self._unit:movement()
			local unit_enggage = unit_mov and not unit_mov:cool()
			local unit_hostile = unit_mov and unit_mov:stance_name() == "hos"
			local unit_cbt = unit_mov and unit_mov:stance_name() == "cbt"
			if not is_converted and is_enggage and unit_enggage and (unit_hostile or unit_cbt) then
				--[[local action_data = {
					variant = "light",
					damage = 70,
					attacker_unit = player,
					col_ray = { body = self._unit:body("body"), position = self._unit:position() + math.UP * 100, ray = self._unit:body("body") and self._unit:center_of_mass() or alive(self._unit) and self._unit:position()},
				}]]
				--[[local action_data = {
					variant = "light",
					damage = 2,
					weapon_unit = attack_data.weapon_unit,
					attacker_unit = player or attack_data.attacker_unit,
					col_ray = { 
						body = self._unit:body("body"), 
						position = self._unit:position() + math.UP * 100, 
						ray = self._unit:body("body") and self._unit:center_of_mass() or alive(self._unit) and self._unit:position()
					},
					hurt_animation = true,
					weapon_id = attack_data.weapon_unit and attack_data.weapon_unit:base():get_name_id() or nil
				}]]
				local dot_data = {
					type = "poison",
					custom_data = {
						dot_length = 7,
						dot_damage = 5,
						hurt_animation_chance = 0
					}
				}
				local action_data = managers.dot:create_dot_data(dot_data.type, dot_data.custom_data)
				if unit_dmg then	
					local damage_class = CoreSerialize.string_to_classtable(action_data.damage_class)
					action_data.dot_damage = dot_data.custom_data.dot_damage
					--log(tostring(damage_class))
					damage_class:start_dot_damage({unit = self._unit}, nil, action_data, attack_data.weapon_unit)
					--unit_dmg:damage_tase(action_data)
					--managers.fire:add_doted_enemy( self._unit , t , attack_data.weapon_unit , 7 , 5 , player , true )
				end
			end
		end
	end

	if result.type == "knock_down" then
		variant = 1
		do_dot_damage(self)
	elseif result.type == "stagger" then
		variant = 2
		do_dot_damage(self)
		self._has_been_staggered = true
	elseif result.type == "healed" then
		variant = 3
	else
		variant = 0
	end

	self:_send_bullet_attack_result(attack_data, attacker, damage_percent, body_index, hit_offset_height, variant)
	self:_on_damage_received(attack_data)

	if not is_civilian then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	result.attack_data = attack_data

	return result
end

function CopDamage:damage_explosion(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local result = nil
	local damage = attack_data.damage
	damage = managers.modifiers:modify_value("CopDamage:DamageExplosion", damage, self._unit:base()._tweak_table)

	if self._unit:base():char_tweak().DAMAGE_CLAMP_EXPLOSION then
		damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_EXPLOSION)
	end

	damage = damage * (self._char_tweak.damage.explosion_damage_mul or 1)
	damage = damage * (self._marked_dmg_mul or 1)

	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)
		damage = crit_damage

		if attack_data.weapon_unit and attack_data.variant ~= "stun" then
			if critical_hit then
				managers.hud:on_crit_confirmed()
			else
				managers.hud:on_hit_confirmed()
			end
		end
	end

	damage = self:_apply_damage_reduction(damage)
	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			attack_data.variant = "healed"
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
		end
	else
		attack_data.damage = damage
		local result_type = attack_data.variant == "stun" and "hurt_sick" or self:get_damage_type(damage_percent, "explosion")
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local head = nil

	if self._head_body_name and attack_data.variant ~= "stun" then
		head = attack_data.col_ray.body and self._head_body_key and attack_data.col_ray.body:key() == self._head_body_key
		local body = self._unit:body(self._head_body_name)

		self:_spawn_head_gadget({
			position = body:position(),
			rotation = body:rotation(),
			dir = -attack_data.col_ray.ray
		})
	end

	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	result.ignite_character = attack_data.ignite_character

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant,
			head_shot = head
		}

		managers.statistics:killed_by_anyone(data)

		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attacker_unit == managers.player:player_unit() and attack_data.weapon_unit and attack_data.weapon_unit:base().weapon_tweak_data and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
			managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
		end

		self:chk_killshot(attacker_unit, "explosion")

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if is_civilian then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		end
	end

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", attacker, damage_percent)
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(attack_data.pos, attack_data.col_ray.ray)
	end

	if attacker == managers.player:player_unit() then
		if result.type ~= "death" and not self._dead and managers.player:has_category_upgrade("player", "explosion_dmg_mul") then
			if attack_data.variant == "explosion" then
				if (table.contains({
					"frag",
					"dada_com",
					"frag_com",
					"dynamite"
				}, weapon_unit:base():get_name_id()) or weapon_unit:base():is_category("bow", "crossbow", "grenade_launcher", "projectile")) then
					local action_data = {}
					local mycol_ray = { 
						body = self._unit:body("body"), 
						position = self._unit:position() + math.UP * 100, 
						ray = self._unit:body("body") and self._unit:center_of_mass() or alive(self._unit) and self._unit:position()
					}
					local level = managers.player:upgrade_value_by_level("player", "explosion_dmg_mul", 1)
					action_data = {
						variant = "explosion" or "projectile",
						damage = level > 1 and 900 or 2000,
						weapon_unit = nil,
						--weapon_unit = attacker == managers.player:player_unit() and weapon_unit~=nil and weapon_unit or managers.player:player_unit() and managers.player:player_unit():inventory() and managers.player:player_unit():inventory():equipped_unit(),
						attacker_unit = attacker == managers.player:local_player() and managers.player:local_player() or managers.player:player_unit(),
						col_ray = mycol_ray,
						armor_piercing = false,
						shield_knock = false,
						origin = attacker:position(),
						knock_down = false,
						stagger = false
					}
					if attacker == managers.player:local_player() and weapon_unit~=nil and weapon_unit then
						action_data.weapon_unit = weapon_unit
						self:WriteFile(tostring(weapon_unit:base():get_name_id()))
					elseif managers.player:player_unit() and managers.player:player_unit():inventory() and managers.player:player_unit():inventory():equipped_unit() then
						action_data.weapon_unit = managers.player:player_unit():inventory():equipped_unit()
						self:WriteFile("WEAPON UNIT NOT FOUND RETURNING PLAYER INVENTORY"..tostring(managers.player:player_unit():inventory():equipped_unit():base():get_name_id()))
					else
						self:WriteFile("WEAPON UNIT AND PLAYER INVENTORY NOT FOUND!")
					end

					self:damage_bullet(action_data)
				end
			end
		end
	end

	self:_send_explosion_attack_result(attack_data, attacker, damage_percent, self:_get_attack_variant_index(attack_data.result.variant), attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)

	if not is_civilian and attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	return result
end

function CopDamage:sync_damage_explosion(attacker_unit, damage_percent, i_attack_variant, death, direction, weapon_unit)
	if self._dead then
		return
	end

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit
	}
	local result = nil

	if death then
		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data)

		local data = {
			variant = "explosion",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = weapon_unit or attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
		}

		managers.statistics:killed_by_anyone(data)
	else
		local result_type = variant == "stun" and "hurt_sick" or self:get_damage_type(damage_percent, "explosion")
		result = {
			type = result_type,
			variant = variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true
	local attack_dir = nil

	if direction then
		attack_dir = direction
	elseif attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	if self._head_body_name then
		local body = self._unit:body(self._head_body_name)

		self:_spawn_head_gadget({
			skip_push = true,
			position = body:position(),
			rotation = body:rotation(),
			dir = Vector3()
		})
	end
	
	if attack_data.attacker_unit and attack_data.attacker_unit == managers.player:player_unit() then
		managers.hud:on_hit_confirmed()
		managers.statistics:shot_fired({
			hit = true,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
		})
	end

	if result.type == "death" then
		local data = {
			variant = "explosion",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
		}
		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		self:chk_killshot(attacker_unit, "explosion")

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if CopDamage.is_civilian(self._unit:base()._tweak_table) then
				managers.money:civilian_killed()
			end
		end
	end

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", damage_percent)
	end

	if not self._no_blood then
		local hit_pos = mvector3.copy(self._unit:movement():m_pos())

		mvector3.set_z(hit_pos, hit_pos.z + 100)
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	attack_data.pos = self._unit:position()

	if attack_data.attacker_unit and attack_data.attacker_unit == managers.player:player_unit() then
		local attacker = attack_data.attacker_unit
		--log("ATTACKER")
		if result.type ~= "death" and not self._dead and managers.player:has_category_upgrade("player", "explosion_dmg_mul") then
			--log("NOT DEAD")
			if result.variant == "explosion" then
				--log("VARIANT")
				if (table.contains({
					"frag",
					"dada_com",
					"frag_com",
					"dynamite"
				}, weapon_unit:base():get_name_id()) or weapon_unit:base():is_category("bow", "crossbow", "grenade_launcher", "projectile")) then
					--log("succeedd")
					local action_data = {}
					local mycol_ray = { 
						body = self._unit:body("body"), 
						position = self._unit:position() + math.UP * 100, 
						ray = self._unit:body("body") and self._unit:center_of_mass() or alive(self._unit) and self._unit:position()
					}
					local level = managers.player:upgrade_value_by_level("player", "explosion_dmg_mul", 1)
					action_data = {
						variant = "explosion" or "projectile",
						damage = level > 1 and 900 or 2000,
						weapon_unit = nil,
						--weapon_unit = attacker == managers.player:player_unit() and weapon_unit~=nil and weapon_unit or managers.player:player_unit() and managers.player:player_unit():inventory() and managers.player:player_unit():inventory():equipped_unit(),
						attacker_unit = attacker == managers.player:local_player() and managers.player:local_player() or managers.player:player_unit(),
						col_ray = mycol_ray,
						armor_piercing = false,
						shield_knock = false,
						origin = attacker:position(),
						knock_down = false,
						stagger = false
					}
					if attacker == managers.player:local_player() and weapon_unit~=nil and weapon_unit then
						action_data.weapon_unit = weapon_unit
						self:WriteFile(tostring(weapon_unit:base():get_name_id()))
					elseif managers.player:player_unit() and managers.player:player_unit():inventory() and managers.player:player_unit():inventory():equipped_unit() then
						action_data.weapon_unit = managers.player:player_unit():inventory():equipped_unit()
						self:WriteFile("WEAPON UNIT NOT FOUND RETURNING PLAYER INVENTORY"..tostring(managers.player:player_unit():inventory():equipped_unit():base():get_name_id()))
					else
						self:WriteFile("WEAPON UNIT AND PLAYER INVENTORY NOT FOUND!")
					end

					self:damage_bullet(action_data)
				end
			end
		end
	end

	mvector3.set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)
	self:_send_sync_explosion_attack_result(attack_data)
	self:_on_damage_received(attack_data)
end

function CopDamage:_on_damage_received(damage_info)
	self:build_suppression("max", nil)
	self:_call_listeners(damage_info)
	CopDamage._notify_listeners("on_damage", damage_info, self._unit)
	
	local pm = managers.player
	--local sentry_kill = pm:has_category_upgrade("sentry_gun", "kill_restore_ammo")
	local sentry_kill_chance = pm:has_category_upgrade("sentry_gun", "kill_restore_ammo_chance")
	
	if damage_info.result.type == "death" then
		managers.enemy:on_enemy_died(self._unit, damage_info)

		for c_key, c_data in pairs(managers.groupai:state():all_char_criminals()) do
			if c_data.engaged[self._unit:key()] then
				debug_pause_unit(self._unit:key(), "dead AI engaging player", self._unit, c_data.unit)
			end
		end
	end

	if self._dead and self._unit:movement():attention() then
		debug_pause_unit(self._unit, "[CopDamage:_on_damage_received] dead AI", self._unit, inspect(self._unit:movement():attention()))
	end

	local attacker_unit = damage_info and damage_info.attacker_unit

	if alive(attacker_unit) and attacker_unit:base() then
		if attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
		elseif attacker_unit:base().sentry_gun then
			attacker_unit = attacker_unit:base():get_owner()
		end
	end

	if attacker_unit == managers.player:player_unit() and damage_info then
		managers.player:on_damage_dealt(self._unit, damage_info)
	end

	--modd
	local function randomFloat(min, max, precision)
		local range = max - min
		local offset = range * math.random()
		local unrounded = min + offset
	
		if not precision then
			return unrounded
		end
	
		local powerOfTen = 10 ^ precision
		return math.floor(unrounded * powerOfTen + 0.5) / powerOfTen
	end

	
	if (attacker_unit == managers.player:player_unit() or alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit) and damage_info then
		if damage_info.result.type == "death" and self._dead then
			if damage_info.variant == "fire" then
				if managers.player:has_category_upgrade("player", "flame_trap") and 0.65 >= randomFloat(0,1,2) or 0.15 >= randomFloat(0,1,2) then
					local position = self._unit:position()
					local rotation = self._unit:rotation()
					local attacker = self._unit or nil
					local params = {
						sound_event = nil,
						range = 75,
						curve_pow = 3,
						damage = 1,
						fire_alert_radius = 100,
						hexes = 6,
						sound_event_burning = "burn_loop_gen",
						is_molotov = true,
						player_damage = 2,
						sound_event_impact_duration = 4,
						burn_tick_period = 0.4,
						burn_duration = 4, --16,
						alert_radius = 50,
						effect_name = "effects/payday2/particles/explosions/molotov_grenade",
						fire_dot_data = {
							dot_trigger_chance = 30,
							dot_damage = 15,
							dot_length = 7,
							dot_trigger_max_distance = 3000,
							dot_tick_period = 0.5
						}
					}
					EnvironmentFire.spawn(position, rotation, params, math.UP, attacker, 0, 1)
				end
			end
		elseif damage_info.result.type ~= "death" and not self._dead then
			if damage_info.variant == "explosion" then
				if managers.player:has_category_upgrade("player", "expanded_n_enhanced") and 0.6 >= randomFloat(0,1,2) or 0.15 >= randomFloat(0,1,2) then
					local fire_dot_data = {
						dot_damage = 12,
						dot_trigger_max_distance = 3000,
						dot_trigger_chance = 100,
						dot_length = 3,
						dot_tick_period = 0.5
					}
					local mycol_ray = { 
						body = self._unit:body("body"), 
						position = self._unit:position() + math.UP * 100, 
						ray = self._unit:body("body") and self._unit:center_of_mass() or alive(self._unit) and self._unit:position()
					}
					local action_data = {
						variant = "fire",
						damage = damage_info.damage and damage_info.damage > 50 and damage_info.damage or 50,
						attacker_unit = attacker_unit,
						weapon_unit = attacker_unit == managers.player:player_unit() and managers.player:player_unit():inventory():equipped_unit() or damage_info.weapon_unit or nil,
						ignite_character = true,
						col_ray = damage_info.col_ray and damage_info.col_ray or mycol_ray,
						is_fire_dot_damage = false,
						fire_dot_data = fire_dot_data,
						is_molotov = false
					}
					self:damage_fire(action_data)
				end
			end
		end
	end
	--endmodd


	--modd
	--[[if attacker_unit == managers.player:player_unit() and damage_info then
		if damage_info.result.type ~= "death" and not self._dead then
			if damage_info.variant == "explosion" then
				log("attacker "..tostring(damage_info.attacker_unit:inventory():equipped_unit():base():get_name_id()))
				--log("attacker2 "..tostring(attacker_unit:base():thrower_unit()))
				local weap_check = nil
				if damage_info.weapon_unit then
					weap_check = damage_info.weapon_unit
				else
					weap_check = damage_info.attacker_unit:equipped_unit()
				end
				--(table.contains({
				--	"frag",
				--	"dada_com",
				--	"frag_com",
				--	"dynamite"
				--}, weap_check:base():get_name_id()) or weap_check:base():is_category("bow", "crossbow", "grenade_launcher", "projectile")) or
				if true then
					
				local mycol_ray = { 
					body = self._unit:body("body"), 
					position = self._unit:position() + math.UP * 100, 
					ray = self._unit:body("body") and self._unit:center_of_mass() or alive(self._unit) and self._unit:position()
				}
				local action_data = {
					variant = "bullet" or "heavy_hurt",
					damage = math.ceil(damage_info.damage) + math.ceil(damage_info.damage)*randomFloat(1,6,0),
					weapon_unit = attacker_unit == managers.player:player_unit() and managers.player:player_unit():inventory():equipped_unit() or damage_info.weapon_unit or nil,
					attacker_unit = attacker_unit == managers.player:player_unit() and managers.player:player_unit() or damage_info.attacker_unit or nil,
					col_ray = mycol_ray,
					armor_piercing = false,
					shield_knock = false,
					origin = attacker_unit:position(),
					knock_down = false,
					stagger = false
				}
				
				self:damage_bullet(action_data)
				end
			end
		end
	end]]
	--endamodd

	if damage_info.variant == "melee" then
		managers.statistics:register_melee_hit()
	end
	--modd
	--local cd = sentry_kill and sentry_kill_chance and pm:_s_kill_restore_chance_is_cd() or true
	--log(tostring(pm:_s_kill_restore_chance_is_cd()))

	if damage_info.result.type == "death" and sentry_kill_chance and not pm:_s_kill_restore_chance_is_cd() then
		--log(tostring(damage_info.attacker_unit))
		local player = pm:player_unit()
		local attacker = damage_info and damage_info.attacker_unit
		local is_sentry = alive(attacker) and attacker:base() and attacker:base().sentry_gun
		local sentry_owner = is_sentry and attacker:base():get_owner() == player
		if sentry_owner then
			if pm:_s_roll_restore_chance() then
				--log("SENTRY KILL RESTORE AMMO!!!")
				for id, weapon in pairs(player:inventory():available_selections()) do
					if alive(weapon.unit) then
						local ammo = weapon.unit:base():get_ammo_max_per_clip()
						--log(tostring(ammo))
						local not_full = not weapon.unit:base():ammo_full()
						local special = weapon.unit:base()._ammo_pickup[2] == 0
						local saw = table.contains(tweak_data.weapon[weapon.unit:base()._name_id].categories, "saw")
						if not_full and (not saw or not special) then
							local add = ammo * randomFloat(0,0.5,2)--((math.random(20)*100)*0.0001)
							add = add - math.floor(add) >= 0.5 and math.floor(add) > 0 and math.ceil(add) or math.floor(add) > 0 and math.floor(add) or 1
							weapon.unit:base():add_ammo_to_pool(add, id)
							--managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
						end
					end
				end
				pm:_s_kill_restore_chance_cd()
			end
		end

		--[[local is_sentry_mine = is_sentry and attacker:base():get_owner() == player or is_sentry and attacker:base():is_owner()
		local is_player = alive(attacker) and attacker == managers.player:player_unit()
		local is_player_sentry = is_player and damage_info.weapon_unit
		local is_player_sentry2 = is_player_sentry and is_player_sentry:base().sentry_gun
		local has_condition = is_sentry_mine or is_player_sentry2
		--log("is sentry "..tostring(is_sentry_mine).."\n is player sentry "..tostring(is_player_sentry))
		if has_condition then
			if pm:_s_roll_restore_chance() then
				log("SENTRY KILL RESTORE AMMO!!!")
				for id, weapon in pairs(player:inventory():available_selections()) do
					if alive(weapon.unit) then
						local ammo = weapon.unit:base():get_ammo_max_per_clip()
						log(tostring(ammo))
						local not_full = not weapon.unit:base():ammo_full()
						local special = weapon.unit:base()._ammo_pickup[2] == 0
						local saw = table.contains(tweak_data.weapon[weapon.unit:base()._name_id].categories, "saw")
						if not_full and (not saw or not special) then
							local add = ammo * randomFloat(0,0.5,2)--((math.random(20)*100)*0.0001)
							add = add - math.floor(add) >= 0.5 and math.floor(add) > 0 and math.ceil(add) or math.floor(add) > 0 and math.floor(add) or 1
							weapon.unit:base():add_ammo_to_pool(add, id)
							--managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
						end
					end
				end
				pm:_s_kill_restore_chance_cd()
			end
			
			local equipped_unit = pm:get_current_state()._equipped_unit:base()
			local ammo = equipped_unit:get_ammo_max_per_clip()
			local not_full = equipped_unit and not equipped_unit:ammo_full()
			local special = equipped_unit._ammo_pickup[2] == 0
			local saw = table.contains(tweak_data.weapon[equipped_unit._name_id].categories, "saw")
			local index = pm:equipped_weapon_index()
			if not_full and (not saw or not special) then
				if pm:_s_roll_restore_chance() == true then
					local add = ammo * ((math.random(20)*100)*0.0001)
					add = add - math.floor(add) >= 0.5 and math.floor(add) > 0 and math.ceil(add) or math.floor(add) > 0 and math.floor(add) or 1
					equipped_unit:add_ammo_to_pool(add, index)
					pm:_s_kill_restore_chance_cd()
				end
			end
		end]]
	end
	--endmodd
	
	self:_update_debug_ws(damage_info)
end

function CopDamage:_send_fire_attack_result(attack_data, attacker, damage_percent, is_fire_dot_damage, direction, healed)
	local weapon_type, weapon_unit = nil

	if attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit:base()._grenade_entry == "molotov" or attack_data.is_molotov then
		weapon_type = CopDamage.WEAPON_TYPE_GRANADE
		weapon_unit = "molotov"
	elseif alive(attack_data.weapon_unit) and attack_data.weapon_unit:base()._name_id ~= nil and tweak_data.weapon[attack_data.weapon_unit:base()._name_id] ~= nil and tweak_data.weapon[attack_data.weapon_unit:base()._name_id].fire_dot_data ~= nil then
		weapon_type = CopDamage.WEAPON_TYPE_FLAMER
		weapon_unit = attack_data.weapon_unit:base()._name_id
		--fix custom flamer weapon crash?
		if tweak_data.weapon[weapon_unit] then
			if tweak_data.weapon[weapon_unit].custom then
				if tweak_data.weapon[weapon_unit].based_on then
					weapon_unit = tweak_data.weapon[weapon_unit].based_on
				elseif tweak_data.weapon[weapon_unit]:base()._selection_index then
					weapon_unit = tweak_data.weapon[weapon_unit]:base()._selection_index % 2 == 0 and "wpn_fps_ass_amcar" or "wpn_fps_pis_g17"
				else
					weapon_unit = "wpn_fps_ass_amcar"
				end
			end
		end
	elseif alive(attack_data.weapon_unit) and attack_data.weapon_unit:base()._parts then
		for part_id, part in pairs(attack_data.weapon_unit:base()._parts) do
			if tweak_data.weapon.factory.parts[part_id].custom_stats and tweak_data.weapon.factory.parts[part_id].custom_stats.fire_dot_data then
				weapon_type = CopDamage.WEAPON_TYPE_BULLET
				weapon_unit = part_id
			end
		end
		--fix dragon breath mod crash?
		if tweak_data.weapon.factory.parts[weapon_unit] then
			if tweak_data.weapon.factory.parts[weapon_unit].custom then
				if tweak_data.weapon.factory.parts[weapon_unit].based_on then
					weapon_unit = tweak_data.weapon.factory.parts[weapon_unit].based_on
				else
					weapon_unit = "wpn_fps_upg_a_dragons_breath"
				end
			end
		end
	end

	--[[
		if tweak_data.weapon[weapon_unit] and tweak_data.weapon[weapon_unit].based_on and tweak_data.weapon[weapon_unit].custom == true then
			weapon_unit = tweak_data.weapon[weapon_unit].based_on
		end
	]]

	local start_dot_dance_antimation = attack_data.fire_dot_data and attack_data.fire_dot_data.start_dot_dance_antimation
	damage_percent = math.clamp(damage_percent, 0, 512)

	self._unit:network():send("damage_fire", attacker, damage_percent, start_dot_dance_antimation, self._dead and true or false, direction, weapon_type, weapon_unit, healed)
end