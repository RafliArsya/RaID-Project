local orig_ps_start_action_intimidate = PlayerStandard._start_action_intimidate

Hooks:PostHook(PlayerStandard, "init", "RaID_PlayerStandard_Init", function(self, unit)
	self._heavy_drop_damage = {
		_count = 0,
		_reset_t = nil
	}
	self._heavy_drop_damage_max = {
		easy = 100,
		normal = 200,
		hard = 200,
		overkill = 300,
		overkill_145 = 400,
		easy_wish = 600,
		overkill_290 = 600,
		sm_wish = 1200
	}
	self._has_iryf = managers.player:has_category_upgrade("player", "revived_up_enemy_fall")
	if self._has_iryf then
		self._iryf = {
			_data = managers.player:upgrade_value("player", "revived_up_enemy_fall"),
			_tick = nil,
			_active = nil
		}
	else
		self._iryf = {
			_data = managers.player:upgrade_value("player", "revived_up_enemy_fall", 0),
			_tick = nil,
			_active = nil
		}
	end
end)

Hooks:PostHook(PlayerStandard, "update", "RaID_PlayerStandard_Update", function(self, t, dt, ...)
	if managers.player:has_category_upgrade("player", "ninja_escape_move") then
		self:_get_update_attention(t)
		
		if self._ninja_escape_t and self._ninja_escape_t < t then
			self._ninja_escape_t = nil
		end
		if self._ninja_gone_t and self._ninja_gone_t < t then
			self._ninja_gone_t = nil
		end
	end
	
	if self._heavy_drop_damage._reset_t then
		if self._heavy_drop_damage._reset_t <= t or managers.player:local_player():character_damage():need_revive() or managers.player:local_player():character_damage():is_downed() or managers.player:local_player():character_damage():incapacitated() or managers.player:local_player():character_damage():dead() then
			self._heavy_drop_damage._reset_t = nil
			self._heavy_drop_damage._count = 0
		end
	end
	
	if self._iryf._tick then
		if self._iryf._tick <= t or not self._iryf._active or managers.player:local_player():character_damage():need_revive() or managers.player:local_player():character_damage():is_downed() or managers.player:local_player():character_damage():incapacitated() or managers.player:local_player():character_damage():dead() then
			self._iryf._tick = nil
		end
	end
	
	if self._iryf._active then
		if not self._iryf._tick then
			self:_on_iryf_active()
		end
		if self._iryf._active <= t or managers.player:local_player():character_damage():need_revive() or managers.player:local_player():character_damage():is_downed() or managers.player:local_player():character_damage():incapacitated() or managers.player:local_player():character_damage():dead() then
			self._iryf._active = nil
		end
	end
	
end)

function PlayerStandard:_start_action_intimidate(t, secondary)
	if not self._intimidate_t or tweak_data.player.movement_state.interaction_delay < t - self._intimidate_t then
		local skip_alert = managers.groupai:state():whisper_mode()
		local voice_type, plural, prime_target = self:_get_unit_intimidation_action(not secondary, not secondary, true, false, true, nil, nil, nil, secondary)

		if prime_target and prime_target.unit and prime_target.unit.base and (prime_target.unit:base().unintimidateable or prime_target.unit:anim_data() and prime_target.unit:anim_data().unintimidateable) then
			return
		end

		local interact_type, sound_name = nil
		local sound_suffix = plural and "plu" or "sin"
		if voice_type == "revive" then
			interact_type = "cmd_get_up"
			local static_data = managers.criminals:character_static_data_by_unit(prime_target.unit)

			if not static_data then
				return
			end

			local character_code = static_data.ssuffix
			sound_name = "f36x_any"

			if math.random() < self._ext_movement:rally_skill_data().revive_chance then
				prime_target.unit:interaction():interact(self._unit)
			end
			
			local pos = prime_target.unit:position()
			
			local _inspire_AOE_check = function(_c_data, _pos)
				if _c_data and _c_data.unit and alive(_c_data.unit) and mvector3.distance(_pos, _c_data.unit:position()) <= 675 then
					return true
				end
				return false
			end
			local revive_units = {}
			for c_key, c_data in pairs(managers.groupai:state():all_player_criminals()) do
				if _inspire_AOE_check(c_data, pos) then
					revive_units[c_data.unit:key()] = c_data.unit
					
					c_data.unit:network():send_to_unit({
						"long_dis_interaction",
						c_data.unit,
						0,
						self._unit,
						false
					})
				end
			end
			for c_key, c_data in pairs(managers.groupai:state():all_AI_criminals()) do
				if _inspire_AOE_check(c_data, pos) then
					revive_units[c_data.unit:key()] = c_data.unit			
				end
			end
			for _, r_unit in pairs(revive_units) do
				if r_unit:interaction() then
					if r_unit:interaction():active() then
						r_unit:interaction():interact(self._unit)
					end
				end
			end
			self._ext_movement:rally_skill_data().morale_boost_delay_t = managers.player:player_timer():time() + (self._ext_movement:rally_skill_data().morale_boost_cooldown_t or 3.5)
		else
			return orig_ps_start_action_intimidate(self, t, secondary)
		end
		self:_do_action_intimidate(t, interact_type, sound_name, skip_alert)
	end
end

function PlayerStandard:_check_action_primary_attack(t, input)
	local new_action = nil
	local action_wanted = input.btn_primary_attack_state or input.btn_primary_attack_release

	if action_wanted then
		local action_forbidden = self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self._use_item_expire_t or self:_interacting() or self:_is_throwing_projectile() or self:_is_deploying_bipod() or self._menu_closed_fire_cooldown > 0 or self:is_switching_stances()

		if not action_forbidden then
			self._queue_reload_interupt = nil
			local start_shooting = false

			self._ext_inventory:equip_selected_primary(false)

			if self._equipped_unit then
				local weap_base = self._equipped_unit:base()
				local fire_mode = weap_base:fire_mode()
				local fire_on_release = weap_base:fire_on_release()

				if weap_base:out_of_ammo() then
					if input.btn_primary_attack_press then
						weap_base:dryfire()
					end
				elseif weap_base.clip_empty and weap_base:clip_empty() then
					if self:_is_using_bipod() then
						if input.btn_primary_attack_press then
							weap_base:dryfire()
						end

						self._equipped_unit:base():tweak_data_anim_stop("fire")
					elseif fire_mode == "single" then
						if input.btn_primary_attack_press or self._equipped_unit:base().should_reload_immediately and self._equipped_unit:base():should_reload_immediately() then
							self:_start_action_reload_enter(t)
						end
					else
						new_action = true

						self:_start_action_reload_enter(t)
					end
				elseif self._running and not self._equipped_unit:base():run_and_shoot_allowed() then
					self:_interupt_action_running(t)
				else
					if not self._shooting then
						if weap_base:start_shooting_allowed() then
							local start = fire_mode == "single" and input.btn_primary_attack_press
							start = start or fire_mode ~= "single" and input.btn_primary_attack_state
							start = start and not fire_on_release
							start = start or fire_on_release and input.btn_primary_attack_release

							if start then
								weap_base:start_shooting()
								self._camera_unit:base():start_shooting()

								self._shooting = true
								self._shooting_t = t
								start_shooting = true

								if fire_mode == "auto" then
									self._unit:camera():play_redirect(self:get_animation("recoil_enter"))

									if (not weap_base.akimbo or weap_base:weapon_tweak_data().allow_akimbo_autofire) and (not weap_base.third_person_important or weap_base.third_person_important and not weap_base:third_person_important()) then
										self._ext_network:send("sync_start_auto_fire_sound", 0)
									end
								end
							end
						else
							self:_check_stop_shooting()

							return false
						end
					end

					local suppression_ratio = self._unit:character_damage():effective_suppression_ratio()
					local spread_mul = math.lerp(1, tweak_data.player.suppression.spread_mul, suppression_ratio)
					local autohit_mul = math.lerp(1, tweak_data.player.suppression.autohit_chance_mul, suppression_ratio)
					local suppression_mul = managers.blackmarket:threat_multiplier()
					local dmg_mul = 1
					dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "dmg_multiplier_outnumbered", 1)

					if managers.player:has_category_upgrade("player", "overkill_all_weapons") or weap_base:is_category("shotgun", "saw") then
						dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "overkill_damage_multiplier", 1)
					end

					if managers.player:has_category_upgrade("temporary", "damage_boost_multiplier") then
						dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "damage_boost_multiplier", 1)
						log("damage_boost_second_wind activated")
					end

					local health_ratio = self._ext_damage:health_ratio()
					local primary_category = weap_base:weapon_tweak_data().categories[1]
					local damage_health_ratio = managers.player:get_damage_health_ratio(health_ratio, primary_category)

					if damage_health_ratio > 0 then
						local upgrade_name = weap_base:is_category("saw") and "melee_damage_health_ratio_multiplier" or "damage_health_ratio_multiplier"
						local damage_ratio = damage_health_ratio
						dmg_mul = dmg_mul * (1 + managers.player:upgrade_value("player", upgrade_name, 0) * damage_ratio)
					end

					dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "berserker_damage_multiplier", 1)
					dmg_mul = dmg_mul * managers.player:get_property("trigger_happy", 1)
					local fired = nil

					if fire_mode == "single" then
						if input.btn_primary_attack_press and start_shooting then
							fired = weap_base:trigger_pressed(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
						elseif fire_on_release then
							if input.btn_primary_attack_release then
								fired = weap_base:trigger_released(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
							elseif input.btn_primary_attack_state then
								weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
							end
						end
					elseif input.btn_primary_attack_state then
						fired = weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
					end

					if weap_base.manages_steelsight and weap_base:manages_steelsight() then
						if weap_base:wants_steelsight() and not self._state_data.in_steelsight then
							self:_start_action_steelsight(t)
						elseif not weap_base:wants_steelsight() and self._state_data.in_steelsight then
							self:_end_action_steelsight(t)
						end
					end

					local charging_weapon = fire_on_release and weap_base:charging()

					if not self._state_data.charging_weapon and charging_weapon then
						self:_start_action_charging_weapon(t)
					elseif self._state_data.charging_weapon and not charging_weapon then
						self:_end_action_charging_weapon(t)
					end

					new_action = true

					if fired then
						managers.rumble:play("weapon_fire")

						local weap_tweak_data = tweak_data.weapon[weap_base:get_name_id()]
						local shake_multiplier = weap_tweak_data.shake[self._state_data.in_steelsight and "fire_steelsight_multiplier" or "fire_multiplier"]

						self._ext_camera:play_shaker("fire_weapon_rot", 1 * shake_multiplier)
						self._ext_camera:play_shaker("fire_weapon_kick", 1 * shake_multiplier, 1, 0.15)
						self._equipped_unit:base():tweak_data_anim_stop("unequip")
						self._equipped_unit:base():tweak_data_anim_stop("equip")

						if not self._state_data.in_steelsight or not weap_base:tweak_data_anim_play("fire_steelsight", weap_base:fire_rate_multiplier()) then
							weap_base:tweak_data_anim_play("fire", weap_base:fire_rate_multiplier())
						end

						if fire_mode == "single" and weap_base:get_name_id() ~= "saw" then
							if not self._state_data.in_steelsight then
								self._ext_camera:play_redirect(self:get_animation("recoil"), weap_base:fire_rate_multiplier())
							elseif weap_tweak_data.animations.recoil_steelsight then
								self._ext_camera:play_redirect(weap_base:is_second_sight_on() and self:get_animation("recoil") or self:get_animation("recoil_steelsight"), 1)
							end
						end

						local recoil_multiplier = (weap_base:recoil() + weap_base:recoil_addend()) * weap_base:recoil_multiplier()

						cat_print("jansve", "[PlayerStandard] Weapon Recoil Multiplier: " .. tostring(recoil_multiplier))

						local up, down, left, right = unpack(weap_tweak_data.kick[self._state_data.in_steelsight and "steelsight" or self._state_data.ducking and "crouching" or "standing"])

						self._camera_unit:base():recoil_kick(up * recoil_multiplier, down * recoil_multiplier, left * recoil_multiplier, right * recoil_multiplier)

						if self._shooting_t then
							local time_shooting = t - self._shooting_t
							local achievement_data = tweak_data.achievement.never_let_you_go

							if achievement_data and weap_base:get_name_id() == achievement_data.weapon_id and achievement_data.timer <= time_shooting then
								managers.achievment:award(achievement_data.award)

								self._shooting_t = nil
							end
						end

						if managers.player:has_category_upgrade(primary_category, "stacking_hit_damage_multiplier") then
							self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
							self._state_data.stacking_dmg_mul[primary_category] = self._state_data.stacking_dmg_mul[primary_category] or {
								nil,
								0
							}
							local stack = self._state_data.stacking_dmg_mul[primary_category]

							if fired.hit_enemy then
								stack[1] = t + managers.player:upgrade_value(primary_category, "stacking_hit_expire_t", 1)
								stack[2] = math.min(stack[2] + 1, tweak_data.upgrades.max_weapon_dmg_mul_stacks or 5)
							else
								stack[1] = nil
								stack[2] = 0
							end
						end

						if weap_base.set_recharge_clbk then
							weap_base:set_recharge_clbk(callback(self, self, "weapon_recharge_clbk_listener"))
						end

						managers.hud:set_ammo_amount(weap_base:selection_index(), weap_base:ammo_info())

						local impact = not fired.hit_enemy

						if weap_base.third_person_important and weap_base:third_person_important() then
							self._ext_network:send("shot_blank_reliable", impact, 0)
						elseif weap_base.akimbo and not weap_base:weapon_tweak_data().allow_akimbo_autofire or fire_mode == "single" then
							self._ext_network:send("shot_blank", impact, 0)
						end
					elseif fire_mode == "single" then
						new_action = false
					end
				end
			end
		elseif self:_is_reloading() and self._equipped_unit:base():reload_interuptable() and input.btn_primary_attack_press then
			self._queue_reload_interupt = true
		end
	end

	if not new_action then
		self:_check_stop_shooting()
	end

	return new_action
end

local wallslide_values = {60} -- minimum of 50-51?
wallslide_values[2] = wallslide_values[1] * 0.707 -- sin 45
wallslide_values[3] = wallslide_values[1] * 0.924 -- cos 22.5/sin 67.5
wallslide_values[4] = wallslide_values[1] * 0.383 -- sin 22.5/cos 67.5

function PlayerStandard:_get_nearest_wall_ray_dir(ray_length_mult, raytarget, only_frontal_rays, z_offset)

	local length_mult = ray_length_mult or 1
	local playerpos = managers.player:player_unit():position()
	local result = nil or false
	if z_offset then
		mvector3.add(playerpos, Vector3(0, 0, z_offset))
	end
	-- only get one axis of rotation so facing up doesn't end the wallrun via not detecting a wall to run on
	local rotation = self._ext_camera:rotation():z()
	mvector3.set_x(rotation, 0)
	mvector3.set_y(rotation, 0)
	local shortest_ray_dist = 10000
	local shortest_ray_dir = nil
	local shortest_ray = nil
	local first_ray_dist = 10000
	local first_ray_dir = nil
	local first_ray = nil

	-- alternate table to check more than cardinal and intercardinal directions
	local ray_adjust_table = nil
	if not self._nearest_wall_ray_dir_state then
		self._nearest_wall_ray_dir_state = true
		ray_adjust_table = {
			{-1 * wallslide_values[2], wallslide_values[2]}, -- 315, forward-left
			{0, wallslide_values[1]}, -- 360/0, forward
			{wallslide_values[2], wallslide_values[2]}, -- 45, forward-right
			{wallslide_values[1], 0}, -- 90, right
			{wallslide_values[2], -1 * wallslide_values[2]}, -- 135, back-right
			{0, -1 * wallslide_values[1]}, -- 180, back
			{-1 * wallslide_values[2], -1 * wallslide_values[2]}, -- 225, back-left
			{-1 * wallslide_values[1], 0} -- 270, left
		}
		if only_frontal_rays then
			ray_adjust_table[4] = nil
			ray_adjust_table[5] = nil
			ray_adjust_table[6] = nil
			ray_adjust_table[7] = nil
			ray_adjust_table[8] = nil
		end
	else
		self._nearest_wall_ray_dir_state = nil
		ray_adjust_table = {
			{-1 * wallslide_values[4], wallslide_values[3]}, -- 292.5
			{-1 * wallslide_values[3], wallslide_values[4]}, -- 337.5
			{wallslide_values[3], wallslide_values[4]}, -- 22.5
			{wallslide_values[4], wallslide_values[3]}, -- 67.5
			{wallslide_values[4], -1 * wallslide_values[3]}, -- 112.5
			{wallslide_values[3], -1 * wallslide_values[4]}, -- 157.5
			{-1 * wallslide_values[3], -1 * wallslide_values[4]}, -- 202.5
			{-1 * wallslide_values[4], -1 * wallslide_values[3]} -- 247.5
		}
		if only_frontal_rays then
			--ray_adjust_table[4] = nil
			ray_adjust_table[5] = nil
			ray_adjust_table[6] = nil
			ray_adjust_table[7] = nil
			ray_adjust_table[8] = nil
		end
	end

	for i = 1, #ray_adjust_table do
		local ray = Vector3()
		mvector3.set(ray, playerpos)
		local ray_adjust = Vector3(ray_adjust_table[i][1] * length_mult, ray_adjust_table[i][2] * length_mult, 0)
		mvector3.rotate_with(ray_adjust, rotation)
		mvector3.add(ray, ray_adjust)
		local ray_check = Utils:GetCrosshairRay(playerpos, ray)
		if ray_check and (shortest_ray_dist > ray_check.distance) then
			-- husks use different data reee
			local is_enemy = managers.enemy:is_enemy(ray_check.unit) and ray_check.unit:brain():is_hostile() -- exclude sentries
			local is_shield = ray_check.unit:in_slot(8) and alive(ray_check.unit:parent())
			local enemy_not_surrendered = is_enemy and ray_check.unit:brain() and not (ray_check.unit:brain()._surrendered or ray_check.unit:brain():surrendered())
			local enemy_not_joker = is_enemy and ray_check.unit:brain() and not (ray_check.unit:brain()._converted or (ray_check.unit:brain()._logic_data and ray_check.unit:brain()._logic_data.is_converted))
			local enemy_not_trading = is_enemy and ray_check.unit:brain() and not (ray_check.unit:brain()._logic_data and ray_check.unit:brain()._logic_data.name == "trade") -- i don't know how to check for trading on husk
			if raytarget == "enemy" and ((is_enemy and enemy_not_surrendered and enemy_not_joker and enemy_not_trading) or is_shield) then
				shortest_ray_dist = ray_check.distance
				shortest_ray_dir = ray_adjust
				shortest_ray = ray_check
				result = true
			elseif raytarget == "breakable" and ray_check.unit:damage() and not ray_check.unit:character_damage() then
				shortest_ray_dist = ray_check.distance
				shortest_ray_dir = ray_adjust
				shortest_ray = ray_check
				result = true
			elseif not raytarget then
				shortest_ray_dist = ray_check.distance
				shortest_ray_dir = ray_adjust
				shortest_ray = ray_check
				result = true
			end
		end
	end

	
	return result
end

local _f_PlayerStandard_check_action_jump = PlayerStandard._check_action_jump
local _f_PlayerStandard_perform_jump = PlayerStandard._perform_jump
local _PlayerStandard_start_action_ducking = PlayerStandard._start_action_ducking
local _PlayerStandard_end_action_ducking = PlayerStandard._end_action_ducking

PlayerStandard._jump_max = 2
PlayerStandard._double_jump = false
PlayerStandard._jump_count = 0
PlayerStandard._jump_t = nil

function PlayerStandard:_check_action_jump(t, input)
	local nearest_wall = nil or false
	if input and input.btn_jump_press and self._state_data and not self._state_data.in_air then
		self._jump_count = 1
	end
	if self._state_data.in_air then
		nearest_wall = self:_get_nearest_wall_ray_dir(1, nil, nil, nil)
	end
	if input and input.btn_jump_press and self._jump_t and self._jump_count < self._jump_max and nearest_wall then	
		self._jump_count = self._jump_count + 1
		self._double_jump = true
		local _tmp_t = self._jump_t
		local _tmp_bool = self._state_data.in_air
		self._jump_t = 0
		self._state_data.in_air = false
		local _result = _f_PlayerStandard_check_action_jump(self, t, input)
		self._jump_t = _tmp_t
		self._state_data.in_air = _tmp_bool
		return _result
	end
	return _f_PlayerStandard_check_action_jump(self, t, input)
end

function PlayerStandard:_perform_jump(jump_vec)
	local height = jump_vec
	if self._double_jump then
		self._double_jump = false
		height = height * 1.4
	end
	return _f_PlayerStandard_perform_jump(self, height)
end

function PlayerStandard:_update_omniscience(t, dt)
	local action_forbidden = not managers.player:has_category_upgrade("player", "standstill_omniscience") or self:_interacting() or self._ext_movement:has_carry_restriction() or self:is_deploying() or self:_changing_weapon() or self:_is_throwing_projectile() or self:_is_meleeing() or self:_on_zipline() or self._moving or self:running() or self:_is_reloading() or self:in_air() or self:in_steelsight() or self:is_equipping() or self:shooting() or not managers.groupai:state():whisper_mode() or not tweak_data.player.omniscience

	if action_forbidden then
		if self._state_data.omniscience_t then
			self._state_data.omniscience_t = nil
		end

		return
	end

	self._state_data.omniscience_t = self._state_data.omniscience_t or t + tweak_data.player.omniscience.start_t

	if self._state_data.omniscience_t <= t then
		local sensed_targets = World:find_units_quick("sphere", self._unit:movement():m_pos(), tweak_data.player.omniscience.sense_radius, managers.slot:get_mask("trip_mine_targets"))

		for _, unit in ipairs(sensed_targets) do
			if alive(unit) and not unit:base():char_tweak().is_escort then
				self._state_data.omniscience_units_detected = self._state_data.omniscience_units_detected or {}

				if not self._state_data.omniscience_units_detected[unit:key()] or self._state_data.omniscience_units_detected[unit:key()] <= t then
					self._state_data.omniscience_units_detected[unit:key()] = t + tweak_data.player.omniscience.target_resense_t

					managers.game_play_central:auto_highlight_enemy(unit, true)

					break
				end
			end
		end

		self._state_data.omniscience_t = t + tweak_data.player.omniscience.interval_t
	end
end

PlayerStandard._ninja_escape_t = nil
PlayerStandard._ninja_gone_t = nil
PlayerStandard._has_update_att = false
function PlayerStandard:_get_update_attention(t, force_run)
	if self._state_data.in_air and (self._running or force_run) and managers.groupai:state():whisper_mode() and not self._ext_movement:has_carry_restriction() and (Network:is_server() and self._ext_movement:_get_suspicion() ~= nil or self._ext_movement:_get_sus_rat() ~= nil) then
		if not self._ninja_escape_t then
			self._ext_movement:set_attention_settings({
				"pl_civilian"
			})
			self._ninja_escape_t = t + 3.5
			self._ninja_gone_t = t + 2
			self._has_update_att = false
		end
	else
		if not self._ninja_gone_t and not self._has_update_att then
			self:_upd_attention()
			self._has_update_att = true
		end
	end
end

function PlayerStandard:_get_max_walk_speed(t, force_run)
	local speed_tweak = self._tweak_data.movement.speed
	local movement_speed = speed_tweak.STANDARD_MAX
	local speed_state = "walk"

	--[[if self._state_data.in_steelsight and not managers.player:has_category_upgrade("player", "steelsight_normal_movement_speed") and not _G.IS_VR then
		movement_speed = speed_tweak.STEELSIGHT_MAX
		speed_state = "steelsight"
	elseif self:on_ladder() then
		movement_speed = speed_tweak.CLIMBING_MAX
		speed_state = "climb"
	elseif self._state_data.ducking then
		movement_speed = speed_tweak.CROUCHING_MAX
		speed_state = "crouch"
	elseif self._state_data.in_air and not managers.player:has_category_upgrade("player", "ninja_escape_move") and (self._running or force_run) then
		movement_speed = speed_tweak.INAIR_MAX * 3.5
		speed_state = nil
	elseif self._state_data.in_air and managers.player:has_category_upgrade("player", "ninja_escape_move") and (self._running or force_run) then
		movement_speed = speed_tweak.INAIR_MAX * 4.2
		speed_state = nil
		self:_get_update_attention(t, force_run)
	elseif self._state_data.in_air and not (self._running or force_run) then
		movement_speed = speed_tweak.INAIR_MAX
		speed_state = nil
	elseif self._running or force_run then
		movement_speed = speed_tweak.RUNNING_MAX
		speed_state = "run"
	end]]

	if self._state_data.in_steelsight and not managers.player:has_category_upgrade("player", "steelsight_normal_movement_speed") and not _G.IS_VR then
		movement_speed = speed_tweak.STEELSIGHT_MAX
		speed_state = "steelsight"
	elseif self:on_ladder() then
		movement_speed = speed_tweak.CLIMBING_MAX
		speed_state = "climb"
	elseif self._state_data.ducking then
		movement_speed = speed_tweak.CROUCHING_MAX
		speed_state = "crouch"
	elseif self._state_data.in_air and managers.player:has_category_upgrade("player", "ninja_escape_move") and (self._running or force_run) then
		movement_speed = speed_tweak.INAIR_MAX * 5
		speed_state = nil
		self:_get_update_attention(t, force_run)
	elseif self._state_data.in_air then
		movement_speed = speed_tweak.INAIR_MAX
		speed_state = nil
	elseif self._running or force_run then
		movement_speed = speed_tweak.RUNNING_MAX
		speed_state = "run"
	end

	movement_speed = managers.modifiers:modify_value("PlayerStandard:GetMaxWalkSpeed", movement_speed, self._state_data, speed_tweak)
	local morale_boost_bonus = self._ext_movement:morale_boost()
	local multiplier = managers.player:movement_speed_multiplier(speed_state, speed_state and morale_boost_bonus and morale_boost_bonus.move_speed_bonus, nil, self._ext_damage:health_ratio())
	multiplier = multiplier * (self._tweak_data.movement.multiplier[speed_state] or 1)
	local apply_weapon_penalty = true

	if self:_is_meleeing() then
		local melee_entry = managers.blackmarket:equipped_melee_weapon()
		apply_weapon_penalty = not tweak_data.blackmarket.melee_weapons[melee_entry].stats.remove_weapon_movement_penalty
	end

	if alive(self._equipped_unit) and apply_weapon_penalty then
		multiplier = multiplier * self._equipped_unit:base():movement_penalty()
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "increased_movement_speed") then
		multiplier = multiplier * managers.player:temporary_upgrade_value("temporary", "increased_movement_speed", 1)
	end

	local final_speed = movement_speed * multiplier
	self._cached_final_speed = self._cached_final_speed or 0

	if final_speed ~= self._cached_final_speed then
		self._cached_final_speed = final_speed

		self._ext_network:send("action_change_speed", final_speed)
	end
	
	return final_speed
end

function PlayerStandard:_interupt_action_reload(t)
	if alive(self._equipped_unit) then
		self._equipped_unit:base():check_bullet_objects()
	end

	if self:_is_reloading() then
		self._equipped_unit:base():tweak_data_anim_stop("reload_enter")
		self._equipped_unit:base():tweak_data_anim_stop("reload")
		self._equipped_unit:base():tweak_data_anim_stop("reload_not_empty")
		self._equipped_unit:base():tweak_data_anim_stop("reload_exit")
	end

	self._state_data.reload_enter_expire_t = nil
	self._state_data.reload_expire_t = nil
	self._state_data.reload_exit_expire_t = nil
	
	self._queue_reload_interupt = nil

	managers.player:remove_property("shock_and_awe_reload_multiplier")
	self:send_reload_interupt()
end 

function PlayerStandard:_update_foley(t, input)
	if self._state_data.on_zipline then
		return
	end

	local player_armor_eq = managers.blackmarket:equipped_armor(true, true)
	local heavy_armor = player_armor_eq == "level_7"

	if not self._gnd_ray and not self._state_data.on_ladder then
		if not self._state_data.in_air then
			self._state_data.in_air = true
			self._state_data.enter_air_pos_z = self._pos.z

			self:_interupt_action_running(t)
			self._unit:set_driving("orientation_object")
		end
	elseif self._state_data.in_air then
		self._unit:set_driving("script")

		self._state_data.in_air = false
		local from = self._pos + math.UP * 10
		local to = self._pos - math.UP * 60
		local material_name, pos, norm = World:pick_decal_material(from, to, self._slotmask_bullet_impact_targets)

		self._unit:sound():play_land(material_name)

		if self._unit:character_damage():damage_fall({
			height = self._state_data.enter_air_pos_z - self._pos.z
		}) then
			self._running_wanted = false

			managers.rumble:play("hard_land")
			if heavy_armor then
				self._ext_camera:play_shaker( "player_fall_damage" , 7 )
				self:_do_drop_dmg()
			else
				self._ext_camera:play_shaker("player_fall_damage")
				self:_start_action_ducking(t)
			end
		elseif input.btn_run_state then
			self._running_wanted = true
		end

		self._jump_t = nil
		self._jump_vel_xy = nil

		self._ext_camera:play_shaker("player_land", 0.5)
		managers.rumble:play("land")
	elseif self._jump_vel_xy and t - self._jump_t > 0.3 then
		self._jump_vel_xy = nil

		if input.btn_run_state then
			self._running_wanted = true
		end
	end

	self:_check_step(t)
end

function PlayerStandard:_do_drop_dmg()
	local data = self._heavy_drop_damage
	local reset_time = data._reset_t
	local counter = data._count
	local triggered = false
	local pm = managers.player
	local player = pm:local_player() or self._unit
	local t = pm:player_timer():time()
	local targets = World:find_units_quick( "sphere" , self._unit:movement():m_pos() , 1000 , managers.slot:get_mask( "trip_mine_targets" ) )
	for _ , unit in ipairs( targets ) do
		if alive( unit ) and not managers.enemy:is_civilian( unit ) and not unit:character_damage()._invulnerable then
			local action_data
			local hit_dir = player:position() - unit:position()
			local unit_dmg = unit:character_damage()
			local unit_max_health = unit_dmg._HEALTH_INIT
			local distance = mvector3.normalize(hit_dir)
			local dmg_reduc = 1 - ((distance/1000)- 0.1) 
			dmg_reduc = math.max(0.05, dmg_reduc - (0.1 * counter))
			if managers.groupai:state():whisper_mode() then
				if distance < 601 then
					action_data = {
						variant 		= "counter_spooc",
						damage 			= unit_max_health,
						damage_effect 	= 1,
						attacker_unit 	= player,
						col_ray 		= {
							body 		= unit:body( "body" ),
							position 	= unit:position() + math.UP * 100
						},
						attack_dir 		= self._unit:movement():m_head_rot():y()
					}
				else
					action_data = {
						variant 		= "counter_spooc",
						damage 			= 0,
						damage_effect 	= 1,
						attacker_unit 	= player,
						col_ray 		= {
							body 		= unit:body( "body" ),
							position 	= unit:position() + math.UP * 100
						},
						attack_dir 		= self._unit:movement():m_head_rot():y()
					}
				end
			else
				local dmg_unit = math.min(unit_max_health * dmg_reduc, self._heavy_drop_damage_max[Global.game_settings.difficulty])
				action_data = {
					variant 		= "counter_spooc",
					damage 			= dmg_unit,
					damage_effect 	= 2,
					attacker_unit 	= player,
					col_ray 		= {
						body 		= unit:body( "body" ),
						position 	= unit:position() + math.UP * 100
					},
					attack_dir 		= self._unit:movement():m_head_rot():y()
				}
			end
			if unit_dmg then
				unit:character_damage():damage_melee( action_data )
				triggered = true
			end
		end
	end
	if triggered then
		counter = math.min(counter + 1 , 5)
		reset_time = t + 7
	end
end

function PlayerStandard:_activate_iryf(user)
	if user ~= self:local_player() or self._unit then
		return
	end
	if not alive(user) then
		return
	end
	if self._iryf._active then
		return
	end
	local t = pm:player_timer():time()
	self._iryf._active = t + self._iryf._data.active_t
end

function PlayerStandard:_on_iryf_active()
	local data = self._iryf._data
	local is_active = self._iryf._active
	if not is_active then
		return
	end
	local pm = managers.player
	local player = pm:local_player() or self._unit
	local weapon = pm:equipped_weapon_unit()
	if not alive(player) then
		return
	end
	local t = pm:player_timer():time()
	local slotmask = managers.slot:get_mask(data.slotmask)
	local targets = World:find_units_quick( "sphere" , self._unit:movement():m_pos() or player:movement():m_pos() , data.aoe , slotmask )
	for _ , unit in ipairs( targets ) do
		if alive( unit ) and not unit:character_damage()._invulnerable then
			local action_data
			if not managers.groupai:state():whisper_mode() then
				local dmg_unit = unit_max_health * dmg_reduc
				action_data = {
					variant 		= 0,
					damage 			= math.random(data.damage),
					damage_effect 	= 2,
					attacker_unit 	= player,
					weapon_unit		= weapon,
					col_ray 		= {
						body 		= unit:body( "body" ),
						position 	= unit:position() + math.UP * 100
					},
					attack_dir 		= self._unit:movement():m_head_rot():y()
				}
			end
			if unit_dmg then
				unit:character_damage():damage_explosion( action_data )
			end
		end
	end
	self._iryf._tick = t + data.tick_t
end