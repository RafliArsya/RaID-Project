local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_len = mvector3.length
local math_clamp = math.clamp
local math_lerp = math.lerp
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_rot1 = Rotation()

function RaycastWeaponBase:KNOCKBACK_CHANCE()
	local rand = math.random()
	return rand
end

local MIN_KNOCK_BACK = 200

function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound)
	local hit_unit = col_ray.unit
	local shield_knock = weapon_unit and weapon_unit:base()._shield_knock
	local is_shield = hit_unit:in_slot(8) and alive(hit_unit:parent())
	
	if is_shield and not hit_unit:parent():character_damage():is_immune_to_shield_knockback() and weapon_unit and shield_knock then
		local dmg_ratio = math.clamp(damage, 0.001, MIN_KNOCK_BACK)
		dmg_ratio = dmg_ratio / MIN_KNOCK_BACK
		local rand = dmg_ratio
		rand = rand + weapon_unit:base():KNOCK_BACK_CHANCE()
		if RaycastWeaponBase:KNOCKBACK_CHANCE() < rand then
			local enemy_unit = hit_unit:parent()

			if enemy_unit:character_damage() then
				local damage_info = {
					damage = 0.5,
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
			weapon_unit:base():KNOCK_BACK_CHANCE(0)
		else
			weapon_unit:base():KNOCK_BACK_CHANCE(math.clamp(dmg_ratio * math.random(), 0.005, 0.16))
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
		local knock_down = weapon_unit:base()._knock_down and type(weapon_unit:base()._knock_down) == "number" and weapon_unit:base()._knock_down > 0
		local is_knocked_down = false
		if knock_down then
			--log("KNOCK_DOWN = "..tostring(weapon_unit:base()._knock_down))
			local val = weapon_unit:base()._knock_down 
			val = val + weapon_unit:base():KNOCK_DOWN_CHANCE()
			if val > math.random() then
				is_knocked_down = true
				weapon_unit:base():KNOCK_DOWN_CHANCE(0)
				--log("reset knock_down")
			else
				weapon_unit:base():KNOCK_DOWN_CHANCE(0.03)
				--log("increase knock_down = "..tostring(weapon_unit:base():KNOCK_DOWN_CHANCE()))
			end
		end
		
		result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, weapon_unit:base()._use_armor_piercing, false, is_knocked_down, weapon_unit:base()._stagger, weapon_unit:base()._variant)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()
			local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

			managers.game_play_central:physics_push(col_ray, push_multiplier)
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

function InstantExplosiveBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank)
	local hit_unit = col_ray.unit

	if not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood and managers.player:has_category_upgrade("player", "explosive_breacher") then
		self:play_impact_sound_and_effects(weapon_unit, col_ray)
		local hit_pos = col_ray.position or nil
		local slotmask = managers.slot:get_mask("bullet_impact_targets")
		local dmg = damage or nil
		if hit_pos and dmg then
			local units = World:find_units("sphere", hit_pos, 300, slotmask or managers.slot:get_mask("bullet_impact_targets"))
			if type(units) == "table" and units[1] then
				for id, hit_unit in pairs(units) do
					if hit_unit:base() and type(hit_unit:base()._devices) == "table" and type(hit_unit:base()._devices.c4) == "table" and type(hit_unit:base()._devices.c4.amount) == "number" then
						if not hit_unit:base()._devices.c4.max_health then
							hit_unit:base()._devices.c4.max_health = 1000
						end
						if hit_unit:base()._devices.c4.max_health then
							hit_unit:base()._devices.c4.max_health = hit_unit:base()._devices.c4.max_health - dmg
						end
						if hit_unit:base()._devices.c4.max_health <= 0 then
							---hit_unit:base():trigger_sequence("door_opened")
							hit_unit:base():trigger_sequence("c4_completed")
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
	end

	if not blank then
		mvec3_set(tmp_vec1, col_ray.position)
		mvec3_set(tmp_vec2, col_ray.ray)
		mvec3_norm(tmp_vec2)
		mvec3_mul(tmp_vec2, 20)
		mvec3_sub(tmp_vec1, tmp_vec2)

		local network_damage = math.ceil(damage * 163.84)
		damage = network_damage / 163.84

		if Network:is_server() then
			self:on_collision_server(tmp_vec1, col_ray.normal, damage, user_unit, weapon_unit, managers.network:session():local_peer():id())
		else
			self:on_collision_server(tmp_vec1, col_ray.normal, damage, user_unit, weapon_unit, managers.network:session():local_peer():id())
		end

		if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
			local sync_damage = not blank and hit_unit:id() ~= -1

			if sync_damage then
				local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
				local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

				managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.body, user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
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

		return {
			variant = "explosion",
			col_ray = col_ray
		}
	end

	return nil
end

function RaycastWeaponBase:add_ammo(ratio, add_amount_override)
	local function _add_ammo(ammo_base, ratio, add_amount_override)
		if ammo_base:get_ammo_max() == ammo_base:get_ammo_total() then
			return false, 0
		end

		local multiplier_min = 1
		local multiplier_max = 1

		local base_ammo_pickup_min = ammo_base._ammo_pickup[1]
		local base_ammo_pickup_max = ammo_base._ammo_pickup[2]

		if ammo_base._ammo_data and ammo_base._ammo_data.ammo_pickup_min_mul then
			base_ammo_pickup_min = ammo_base._ammo_data.ammo_pickup_min_mul
		end

		if ammo_base._ammo_data and ammo_base._ammo_data.ammo_pickup_max_mul then
			base_ammo_pickup_max = ammo_base._ammo_data.ammo_pickup_max_mul
		end

		if ammo_base._ammo_data then
			if ammo_base._ammo_data.ammo_pickup_min_mul_override then
				multiplier_min = ammo_base._ammo_data.ammo_pickup_min_mul_override
			else
				multiplier_min = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
				multiplier_min = multiplier_min + managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
				multiplier_min = multiplier_min + managers.player:crew_ability_upgrade_value("crew_scavenge", 0)
			end

			if ammo_base._ammo_data.ammo_pickup_max_mul_override then
				multiplier_max = ammo_base._ammo_data.ammo_pickup_max_mul_override
			else
				multiplier_max = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
				multiplier_max = multiplier_max + managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
				multiplier_max = multiplier_max + managers.player:crew_ability_upgrade_value("crew_scavenge", 0)
			end
		end

		--[[if ammo_base._ammo_data and ammo_base._ammo_data.ammo_pickup_min_mul_override then
			multiplier_min = ammo_base._ammo_data.ammo_pickup_min_mul_override
		else
			multiplier_min = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
			multiplier_min = multiplier_min + managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
			multiplier_min = multiplier_min + managers.player:crew_ability_upgrade_value("crew_scavenge", 0)
		end

		if ammo_base._ammo_data and ammo_base._ammo_data.ammo_pickup_max_mul_override then
			multiplier_max = ammo_base._ammo_data.ammo_pickup_max_mul_override
		else
			multiplier_max = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
			multiplier_max = multiplier_max + managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
			multiplier_max = multiplier_max + managers.player:crew_ability_upgrade_value("crew_scavenge", 0)
		end]]

		local add_amount = add_amount_override
		local picked_up = true

		if not add_amount then
			local rng_ammo = math.lerp(base_ammo_pickup_min * multiplier_min, base_ammo_pickup_max * multiplier_max, math.random())
			rng_ammo = rng_ammo * 1.5
			picked_up = rng_ammo > 0
			add_amount = math.max(0, math.round(rng_ammo))
		end

		add_amount = math.floor(add_amount * (ratio or 1))

		ammo_base:set_ammo_total(math.clamp(ammo_base:get_ammo_total() + add_amount, 0, ammo_base:get_ammo_max()))

		return picked_up, add_amount
	end

	local picked_up, add_amount = nil
	picked_up, add_amount = _add_ammo(self, ratio, add_amount_override)

	if self.AKIMBO then
		local akimbo_rounding = self:get_ammo_total() % 2 + #self._fire_callbacks

		if akimbo_rounding > 0 then
			_add_ammo(self, nil, akimbo_rounding)
		end
	end

	for _, gadget in ipairs(self:get_all_override_weapon_gadgets()) do
		if gadget and gadget.ammo_base then
			local p, a = _add_ammo(gadget:ammo_base(), ratio, add_amount_override)
			picked_up = p or picked_up
			add_amount = add_amount + a
		end
	end

	return picked_up, add_amount
end

function RaycastWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	if managers.player:has_activate_temporary_upgrade("temporary", "no_ammo_cost_buff") then
		managers.player:deactivate_temporary_upgrade("temporary", "no_ammo_cost_buff")

		if managers.player:has_category_upgrade("temporary", "no_ammo_cost") then
			managers.player:activate_temporary_upgrade("temporary", "no_ammo_cost")
		end
	end

	if self._bullets_fired then
		if self._bullets_fired == 1 and self:weapon_tweak_data().sounds.fire_single then
			self:play_tweak_data_sound("stop_fire")
			self:play_tweak_data_sound("fire_auto", "fire")
		end

		self._bullets_fired = self._bullets_fired + 1
	end

	local is_player = self._setup.user_unit == managers.player:player_unit()
	local consume_ammo = not managers.player:has_active_temporary_property("bullet_storm") and (not managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier") or not managers.player:has_category_upgrade("player", "berserker_no_ammo_cost")) and not managers.player:has_activate_temporary_upgrade("temporary", "no_ammo_revenge") or not is_player

	if consume_ammo and (is_player or Network:is_server()) then
		local base = self:ammo_base()

		if base:get_ammo_remaining_in_clip() == 0 then
			return
		end

		local ammo_usage = 1

		if is_player then
			for _, category in ipairs(self:weapon_tweak_data().categories) do
				if managers.player:has_category_upgrade(category, "consume_no_ammo_chance") then
					local roll = math.rand(1)
					local chance = managers.player:upgrade_value(category, "consume_no_ammo_chance", 0)

					if roll < chance then
						ammo_usage = 0

						--print("NO AMMO COST")
					end
				end
			end
		end

		local mag = base:get_ammo_remaining_in_clip()
		local remaining_ammo = mag - ammo_usage

		if mag > 0 and remaining_ammo <= (self.AKIMBO and 1 or 0) then
			local w_td = self:weapon_tweak_data()

			if w_td.animations and w_td.animations.magazine_empty then
				self:tweak_data_anim_play("magazine_empty")
			end

			if w_td.sounds and w_td.sounds.magazine_empty then
				self:play_tweak_data_sound("magazine_empty")
			end

			if w_td.effects and w_td.effects.magazine_empty then
				self:_spawn_tweak_data_effect("magazine_empty")
			end

			self:set_magazine_empty(true)
		end

		base:set_ammo_remaining_in_clip(base:get_ammo_remaining_in_clip() - ammo_usage)
		self:use_ammo(base, ammo_usage)
	end

	local user_unit = self._setup.user_unit

	self:_check_ammo_total(user_unit)

	if alive(self._obj_fire) then
		self:_spawn_muzzle_effect(from_pos, direction)
	end

	self:_spawn_shell_eject_effect()

	local ray_res = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	if self._alert_events and ray_res.rays then
		self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
	end

	self:_build_suppression(ray_res.enemies_in_cone, suppr_mul)
	managers.player:send_message(Message.OnWeaponFired, nil, self._unit, ray_res)

	return ray_res
end