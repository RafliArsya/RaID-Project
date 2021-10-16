local orig_ps_start_action_intimidate = PlayerStandard._start_action_intimidate
local _f_PlayerStandard_check_action_jump = PlayerStandard._check_action_jump
local _f_PlayerStandard_perform_jump = PlayerStandard._perform_jump
local _PlayerStandard_start_action_ducking = PlayerStandard._start_action_ducking
local _PlayerStandard_end_action_ducking = PlayerStandard._end_action_ducking
local wallslide_values = {60} -- minimum of 50-51?
wallslide_values[2] = wallslide_values[1] * 0.707 -- sin 45
wallslide_values[3] = wallslide_values[1] * 0.924 -- cos 22.5/sin 67.5
wallslide_values[4] = wallslide_values[1] * 0.383 -- sin 22.5/cos 67.5
local melee_vars = {
	"player_melee",
	"player_melee_var2"
}

function PlayerStandard:init(unit)
	PlayerMovementState.init(self, unit)

	self._tweak_data = tweak_data.player.movement_state.standard
	self._obj_com = self._unit:get_object(Idstring("rp_mover"))
	local slot_manager = managers.slot
	self._slotmask_gnd_ray = slot_manager:get_mask("player_ground_check")
	self._slotmask_fwd_ray = slot_manager:get_mask("bullet_impact_targets")
	self._slotmask_bullet_impact_targets = slot_manager:get_mask("bullet_impact_targets")
	self._slotmask_pickups = slot_manager:get_mask("pickups")
	self._slotmask_AI_visibility = slot_manager:get_mask("AI_visibility")
	self._slotmask_long_distance_interaction = slot_manager:get_mask("long_distance_interaction")
	self._ext_camera = unit:camera()
	self._ext_movement = unit:movement()
	self._ext_damage = unit:character_damage()
	self._ext_inventory = unit:inventory()
	self._ext_anim = unit:anim_data()
	self._ext_network = unit:network()
	self._ext_event_listener = unit:event_listener()
	self._camera_unit = self._ext_camera._camera_unit
	self._camera_unit_anim_data = self._camera_unit:anim_data()
	self._machine = unit:anim_state_machine()
	self._m_pos = self._ext_movement:m_pos()
	self._pos = Vector3()
	self._stick_move = Vector3()
	self._stick_look = Vector3()
	self._cam_fwd_flat = Vector3()
	self._walk_release_t = -100
	self._last_sent_pos = unit:position()
	self._last_sent_pos_t = 0
	self._state_data = unit:movement()._state_data
	local pm = managers.player
	self.RUN_AND_RELOAD = pm:has_category_upgrade("player", "run_and_reload")
	self._pickup_area = 200 * pm:upgrade_value("player", "increased_pickup_area", 1)

	self:set_animation_state("standard")

	self._jump_max = 2
	self._double_jump = false
	self._jump_count = 0
	self._jump_t = nil

	self._ninja_escape_t = nil
	self._ninja_gone_t = nil
	self._need_updt_att = false
	self._interact_shaped_charged = {
		"open_from_inside",
		"pick_lock_30",
		"pick_lock_easy",
		"pick_lock_easy_no_skill",
		"pick_lock_hard",
		"pick_lock_hard_no_skill",
		"pex_pick_lock_easy_no_skill",
		"fex_pick_lock_easy_no_skill"
	}
	self._interact_c4 = {
		"shaped_sharge",
		"shaped_sharge_single"
	}
	--self._save_interaction = nil
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

	self._interaction = managers.interaction
	self._on_melee_restart_drill = pm:has_category_upgrade("player", "drill_melee_hit_restart_chance")
	local controller = unit:base():controller()

	if controller:get_type() ~= "pc" and controller:get_type() ~= "vr" then
		self._input = {}

		table.insert(self._input, BipodDeployControllerInput:new())

		if pm:has_category_upgrade("player", "second_deployable") then
			table.insert(self._input, SecondDeployableControllerInput:new())
		end
	end

	self._input = self._input or {}

	table.insert(self._input, HoldButtonMetaInput:new("night_vision", "weapon_firemode", nil, 0.5))

	self._menu_closed_fire_cooldown = 0

	managers.menu:add_active_changed_callback(callback(self, self, "_on_menu_active_changed"))
end

Hooks:PostHook(PlayerStandard, "_start_action_unequip_weapon", "RaID_PlayerStandard__start_action_unequip_weapon", function(self, data, ...)
	if managers.groupai then
		preset = nil
		if managers.groupai:state():whisper_mode() then
			if self._ext_movement:crouching() then
				log("C W")
				preset = {
					"pl_mask_on_friend_combatant_whisper_mode",
					"pl_mask_on_friend_non_combatant_whisper_mode",
					"pl_mask_on_foe_combatant_whisper_mode_crouch",
					"pl_mask_on_foe_non_combatant_whisper_mode_crouch"
				}
			else
				log("S W")
				preset = {
					"pl_mask_on_friend_combatant_whisper_mode",
					"pl_mask_on_friend_non_combatant_whisper_mode",
					"pl_mask_on_foe_combatant_whisper_mode_stand",
					"pl_mask_on_foe_non_combatant_whisper_mode_stand"
				}
			end
		elseif self._ext_movement:crouching() then
			log("C")
			preset = {
				"pl_mask_on_friend_combatant_whisper_mode",
				"pl_mask_on_friend_non_combatant_whisper_mode",
				"pl_mask_on_foe_combatant_whisper_mode_crouch",
				"pl_mask_on_foe_non_combatant_whisper_mode_crouch"
			}
		else
			log("S")
			preset = {
				"pl_mask_on_friend_combatant_whisper_mode",
				"pl_mask_on_friend_non_combatant_whisper_mode",
				"pl_mask_on_foe_combatant_whisper_mode_stand",
				"pl_mask_on_foe_non_combatant_whisper_mode_stand"
			}
		end
		
		self._ext_movement:set_attention_settings(preset)
	end
end)

function PlayerStandard:update(t, dt)
	PlayerMovementState.update(self, t, dt)
	self:_calculate_standard_variables(t, dt)
	self:_update_ground_ray()
	self:_update_fwd_ray()
	self:_update_check_actions(t, dt)

	if self._menu_closed_fire_cooldown > 0 then
		self._menu_closed_fire_cooldown = self._menu_closed_fire_cooldown - dt
	end

	self:_update_movement(t, dt)
	self:_upd_nav_data()
	managers.hud:_update_crosshair_offset(t, dt)
	self:_update_omniscience(t, dt)
	self:_upd_stance_switch_delay(t, dt)

	if self._last_equipped then
		if self._last_equipped ~= self._equipped_unit then
			self._equipped_visibility_timer = t + 0.1
		end

		if self._equipped_visibility_timer and self._equipped_visibility_timer < t and alive(self._equipped_unit) then
			self._equipped_unit:base():set_visibility_state(true)
		end
	end

	if managers.player:has_category_upgrade("player", "ninja_escape_move") and managers.groupai then
		if managers.groupai:state():whisper_mode() and self:in_air() and (self._running or force_run) then
			self:_get_update_attention(t)
		end
		--[[if self._need_updt_att and managers.groupai:state():enemy_weapons_hot() then
			self:_upd_attention()
			self._need_updt_att = false
		end]]
		
		if (self._ninja_escape_t and self._ninja_escape_t < t) or (self._ninja_escape_t and not managers.groupai:state():whisper_mode()) then
			self._ninja_escape_t = nil
		end
		if (self._ninja_gone_t and self._ninja_gone_t < t) or (self._ninja_gone_t and not managers.groupai:state():whisper_mode()) then
			self._ninja_gone_t = nil
			if not self._ninja_gone_t and self._need_updt_att then
				self:_upd_attention()
				self._need_updt_att = false
			end
		end

		if self._ninja_gone_t and t >= self._ninja_gone_t - 1.9 and (self:in_air() or not self._state_data.on_ladder or self._ext_movement:current_state_name() ~= "jerry1" or self._ext_movement:current_state_name() ~= "jerry2")  then
			self._unit:mover():set_gravity(Vector3(0, 0, -982))
		end
	end
	
	if self._heavy_drop_damage._reset_t then
		if self._heavy_drop_damage._reset_t <= t or managers.player:local_player():character_damage():need_revive() or managers.player:local_player():character_damage():is_downed() or managers.player:local_player():character_damage():incapacitated() or managers.player:local_player():character_damage():dead() then
			self._heavy_drop_damage._reset_t = nil
			self._heavy_drop_damage._count = 0
		end
	end
	
	--[[if self._iryf._tick then
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
	end]]

	self._last_equipped = self._equipped_unit
end

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
			
			local _inspire_AOE_check = function(_c_data, _pos, prime_target)
				if _c_data and _c_data.unit and alive(_c_data.unit) and mvector3.distance(_pos, _c_data.unit:position()) <= 600 and prime_target.unit ~= _c_data.unit then
					return true
				end
				return false
			end
			local revive_units = {}
			for c_key, c_data in pairs(managers.groupai:state():all_player_criminals()) do
				if _inspire_AOE_check(c_data, pos, prime_target) then
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
				if _inspire_AOE_check(c_data, pos, prime_target) then
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
		elseif voice_type == "stop" or voice_type == "down" or voice_type == "down_stay" or voice_type == "stop_cop" or voice_type == "down_cop" then
			if managers.player:has_category_upgrade("player", "AOE_intimidate") then
				managers.player:AOE_intimidate(prime_target)
			end
			return orig_ps_start_action_intimidate(self, t, secondary)
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

					dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "damage_boost_revenge", 1)

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

function PlayerStandard:_do_melee_damage(t, bayonet_melee, melee_hit_ray, melee_entry, hand_id)
	melee_entry = melee_entry or managers.blackmarket:equipped_melee_weapon()
	local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant
	local melee_damage_delay = tweak_data.blackmarket.melee_weapons[melee_entry].melee_damage_delay or 0
	local charge_lerp_value = instant_hit and 0 or self:_get_melee_charge_lerp_value(t, melee_damage_delay)

	self._ext_camera:play_shaker(melee_vars[math.random(#melee_vars)], math.max(0.3, charge_lerp_value))

	local sphere_cast_radius = 20
	local col_ray = nil

	if melee_hit_ray then
		col_ray = melee_hit_ray ~= true and melee_hit_ray or nil
	else
		col_ray = self:_calc_melee_hit_ray(t, sphere_cast_radius)
	end

	if col_ray and alive(col_ray.unit) then
		local damage, damage_effect = managers.blackmarket:equipped_melee_weapon_damage_info(charge_lerp_value)
		local damage_effect_mul = math.max(managers.player:upgrade_value("player", "melee_knockdown_mul", 1), managers.player:upgrade_value(self._equipped_unit:base():weapon_tweak_data().categories and self._equipped_unit:base():weapon_tweak_data().categories[1], "melee_knockdown_mul", 1))
		damage = damage * managers.player:get_melee_dmg_multiplier()
		damage_effect = damage_effect * damage_effect_mul
		col_ray.sphere_cast_radius = sphere_cast_radius
		local hit_unit = col_ray.unit

		if hit_unit:character_damage() then
			if bayonet_melee then
				self._unit:sound():play("fairbairn_hit_body", nil, false)
			else
				local hit_sfx = "hit_body"

				if hit_unit:character_damage() and hit_unit:character_damage().melee_hit_sfx then
					hit_sfx = hit_unit:character_damage():melee_hit_sfx()
				end

				self:_play_melee_sound(melee_entry, hit_sfx, self._melee_attack_var)
			end

			if not hit_unit:character_damage()._no_blood then
				managers.game_play_central:play_impact_flesh({
					col_ray = col_ray
				})
				managers.game_play_central:play_impact_sound_and_effects({
					no_decal = true,
					no_sound = true,
					col_ray = col_ray
				})
			end

			self._camera_unit:base():play_anim_melee_item("hit_body")
		elseif self._on_melee_restart_drill and hit_unit:base() and (hit_unit:base().is_drill or hit_unit:base().is_saw) then
			hit_unit:base():on_melee_hit(managers.network:session():local_peer():id())
		else
			if bayonet_melee then
				self._unit:sound():play("knife_hit_gen", nil, false)
			else
				self:_play_melee_sound(melee_entry, "hit_gen", self._melee_attack_var)
			end

			self._camera_unit:base():play_anim_melee_item("hit_gen")
			managers.game_play_central:play_impact_sound_and_effects({
				no_decal = true,
				no_sound = true,
				col_ray = col_ray,
				effect = Idstring("effects/payday2/particles/impacts/fallback_impact_pd2")
			})
		end

		local custom_data = nil

		if _G.IS_VR and hand_id then
			custom_data = {
				engine = hand_id == 1 and "right" or "left"
			}
		end

		managers.rumble:play("melee_hit", nil, nil, custom_data)
		managers.game_play_central:physics_push(col_ray)

		local character_unit, shield_knock = nil
		local can_shield_knock = managers.player:has_category_upgrade("player", "shield_knock")

		if can_shield_knock and hit_unit:in_slot(8) and alive(hit_unit:parent()) and not hit_unit:parent():character_damage():is_immune_to_shield_knockback() then
			shield_knock = true
			character_unit = hit_unit:parent()
		end

		character_unit = character_unit or hit_unit

		if character_unit:character_damage() and character_unit:character_damage().damage_melee then
			local dmg_multiplier = 1

			if not managers.enemy:is_civilian(character_unit) and not managers.groupai:state():is_enemy_special(character_unit) then
				dmg_multiplier = dmg_multiplier * managers.player:upgrade_value("player", "non_special_melee_multiplier", 1)
			else
				dmg_multiplier = dmg_multiplier * managers.player:upgrade_value("player", "melee_damage_multiplier", 1)
			end

			dmg_multiplier = dmg_multiplier * managers.player:upgrade_value("player", "melee_" .. tostring(tweak_data.blackmarket.melee_weapons[melee_entry].stats.weapon_type) .. "_damage_multiplier", 1)

			dmg_multiplier = dmg_multiplier * managers.player:temporary_upgrade_value("temporary", "damage_boost_revenge", 1)

			if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
				self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
				self._state_data.stacking_dmg_mul.melee = self._state_data.stacking_dmg_mul.melee or {
					nil,
					0
				}
				local stack = self._state_data.stacking_dmg_mul.melee

				if stack[1] and t < stack[1] then
					dmg_multiplier = dmg_multiplier * (1 + managers.player:upgrade_value("melee", "stacking_hit_damage_multiplier", 0) * stack[2])
				else
					stack[2] = 0
				end
			end

			local health_ratio = self._ext_damage:health_ratio()
			local damage_health_ratio = managers.player:get_damage_health_ratio(health_ratio, "melee")

			if damage_health_ratio > 0 then
				local damage_ratio = damage_health_ratio
				dmg_multiplier = dmg_multiplier * (1 + managers.player:upgrade_value("player", "melee_damage_health_ratio_multiplier", 0) * damage_ratio)
			end

			dmg_multiplier = dmg_multiplier * managers.player:temporary_upgrade_value("temporary", "berserker_damage_multiplier", 1)
			local target_dead = character_unit:character_damage().dead and not character_unit:character_damage():dead()
			local target_hostile = managers.enemy:is_enemy(character_unit) and not tweak_data.character[character_unit:base()._tweak_table].is_escort and character_unit:brain():is_hostile()
			local life_leach_available = managers.player:has_category_upgrade("temporary", "melee_life_leech") and not managers.player:has_activate_temporary_upgrade("temporary", "melee_life_leech")

			if target_dead and target_hostile and life_leach_available then
				managers.player:activate_temporary_upgrade("temporary", "melee_life_leech")
				self._unit:character_damage():restore_health(managers.player:temporary_upgrade_value("temporary", "melee_life_leech", 1))
			end

			local action_data = {
				variant = "melee"
			}

			if _G.IS_VR and melee_entry == "weapon" and not bayonet_melee then
				dmg_multiplier = 0.1
			end

			action_data.damage = shield_knock and 0 or damage * dmg_multiplier
			action_data.damage_effect = damage_effect
			action_data.attacker_unit = self._unit
			action_data.col_ray = col_ray

			if shield_knock then
				action_data.shield_knock = can_shield_knock
			end

			action_data.name_id = melee_entry
			action_data.charge_lerp_value = charge_lerp_value

			if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
				self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
				self._state_data.stacking_dmg_mul.melee = self._state_data.stacking_dmg_mul.melee or {
					nil,
					0
				}
				local stack = self._state_data.stacking_dmg_mul.melee

				if character_unit:character_damage().dead and not character_unit:character_damage():dead() then
					stack[1] = t + managers.player:upgrade_value("melee", "stacking_hit_expire_t", 1.5)
					stack[2] = math.min(stack[2] + 1, tweak_data.upgrades.max_melee_weapon_dmg_mul_stacks or 5)
				else
					stack[1] = nil
					stack[2] = 0
				end
			end

			local defense_data = character_unit:character_damage():damage_melee(action_data)

			self:_check_melee_dot_damage(col_ray, defense_data, melee_entry)
			self:_perform_sync_melee_damage(hit_unit, col_ray, action_data.damage)

			if tweak_data.blackmarket.melee_weapons[melee_entry].tase_data and character_unit:character_damage().damage_tase then
				local action_data = {
					variant = tweak_data.blackmarket.melee_weapons[melee_entry].tase_data.tase_strength,
					damage = 0,
					attacker_unit = self._unit,
					col_ray = col_ray
				}

				character_unit:character_damage():damage_tase(action_data)
			end

			if tweak_data.blackmarket.melee_weapons[melee_entry].fire_dot_data and character_unit:character_damage().damage_fire then
				local action_data = {
					variant = "fire",
					damage = 0,
					attacker_unit = self._unit,
					col_ray = col_ray,
					fire_dot_data = tweak_data.blackmarket.melee_weapons[melee_entry].fire_dot_data
				}

				character_unit:character_damage():damage_fire(action_data)
			end

			return defense_data
		else
			self:_perform_sync_melee_damage(hit_unit, col_ray, damage)
		end
	end

	if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
		self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
		self._state_data.stacking_dmg_mul.melee = self._state_data.stacking_dmg_mul.melee or {
			nil,
			0
		}
		local stack = self._state_data.stacking_dmg_mul.melee
		stack[1] = nil
		stack[2] = 0
	end

	return col_ray
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

function PlayerStandard:_get_update_attention(t, force_run)
	local stealth = managers.groupai and managers.groupai:state():whisper_mode()
	local suspicion = self._ext_movement:_get_sus_rat()
	local sus_type_b = type(suspicion) == "boolean"
	local sus_type_n = type(suspicion) == "number"
	if not stealth then
		return
	end
	if sus_type_n and suspicion > 0 then
		if not self._ninja_escape_t then
			log("JUMP NINJA".."| Sus Rat = "..tostring(self._ext_movement:_get_sus_rat()))
			self._ext_movement:set_attention_settings({
				"pl_civilian"
			})
			self._ninja_escape_t = t + 25
			self._ninja_gone_t = t + 2
			self._need_updt_att = true
			self._unit:mover():set_velocity(self._last_velocity_xy*0.8)
			self._unit:mover():set_gravity(Vector3(0, 0, 0))
		end
	end
	--[[if self._state_data.in_air and (self._running or force_run) and managers.groupai:state():whisper_mode() and not self._ext_movement:has_carry_restriction() and self._ext_movement:_get_sus_rat() then
		if not self._ninja_escape_t then
			log("JUMP NINJA".."| Sus Rat = "..tostring(self._ext_movement:_get_sus_rat()))
			self._ext_movement:set_attention_settings({
				"pl_civilian"
			})
			self._ninja_escape_t = t + 15
			self._ninja_gone_t = t + 2
			self._need_updt_att = false
			self._unit:mover():set_velocity(self._last_velocity_xy)
			
		end
	else
		if not self._ninja_gone_t and not self._need_updt_att then
			self:_upd_attention()
			self._need_updt_att = true
		end
	end]]
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
	local heavy_armor = player_armor_eq == "level_7" and RaID:get_data("toggle_heavy_armor_drop") == true

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

--[[function PlayerStandard:_activate_iryf(user)
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

function PlayerStandard:_start_action_interact(t, input, timer, interact_object)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	local final_timer = timer
	final_timer = managers.modifiers:modify_value("PlayerStandard:OnStartInteraction", final_timer, interact_object)
	self._interact_expire_t = final_timer
	local start_timer = 0
	self._interact_params = {
		object = interact_object,
		timer = final_timer,
		tweak_data = interact_object:interaction().tweak_data
	}
	self._save_interaction = nil
	if interact_object and interact_object == self._interaction:active_unit() and table.contains(self._interact_c4, interact_object:interaction().tweak_data) then
		local units = World:find_units("sphere", interact_object:position(), 200, managers.slot:get_mask("bullet_impact_targets"))
		local result = false
		local interact_count = 0
		local do_open = false
		for id, unit in pairs(units) do
			if unit and unit:interaction() and unit:interaction().tweak_data and table.contains(self._interact_c4, unit:interaction().tweak_data) then
				if unit:interaction():active() then
					interact_count = interact_count + 1
					log("interact c4 = "..tostring(interact_count))
				end
			end
		end
		do_open = interact_count <= 1 and true or false
		if do_open then
			for id, unit in pairs(units) do
				if unit and unit:interaction() and unit:interaction().tweak_data and table.contains(self._interact_shaped_charged, unit:interaction().tweak_data) then
					self._save_interaction = self._save_interaction or {}
					table.insert(self._save_interaction, unit)
					break
				end
			end
		end
	end
	self:_play_unequip_animation()
	managers.hud:show_interaction_bar(start_timer, final_timer)
	managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, true, self._interact_params.tweak_data, final_timer, false)
	self._unit:network():send("sync_interaction_anim", true, self._interact_params.tweak_data)
end

function PlayerStandard:_update_interaction_timers(t)
	if self._interact_expire_t then
		local dt = self:_get_interaction_speed()
		self._interact_expire_t = self._interact_expire_t - dt

		local get_interact_params = self._interact_params

		if not alive(self._interact_params.object) or self._interact_params.object ~= self._interaction:active_unit() or self._interact_params.tweak_data ~= self._interact_params.object:interaction().tweak_data or self._interact_params.object:interaction():check_interupt() then
			self._save_interaction = nil
			self:_interupt_action_interact(t)
		else
			local current = self._interact_params.timer - self._interact_expire_t
			local total = self._interact_params.timer

			managers.hud:set_interaction_bar_width(current, total)

			if self._interact_expire_t <= 0 then
				
				if managers.player:has_category_upgrade("trip_mine", "breach_mk2") and self._save_interaction then
					for id, unit in ipairs(self._save_interaction) do
						if unit:interaction() and unit:interaction().tweak_data and table.contains(self._interact_shaped_charged, unit:interaction().tweak_data) then
							unit:interaction():interact(self._unit)
							
							World:effect_manager():spawn({
								effect = Idstring("effects/particles/explosions/explosion_grenade"),
								position = unit:position(),
								normal = unit:rotation():y()
							})
						
							local sound_source = SoundDevice:create_source("TripMineBase")
						
							sound_source:set_position(unit:position())
							sound_source:post_event("molotov_impact")
							managers.enemy:add_delayed_clbk("TrMiexpl", callback(TripMineBase, TripMineBase, "_dispose_of_sound", {
								sound_source = sound_source
							}), TimerManager:game():time() + 1)

							local alert_size = tweak_data.weapon.trip_mines.alert_radius
							alert_size = managers.player:has_category_upgrade("trip_mine", "alert_size_multiplier") and alert_size * managers.player:upgrade_value("trip_mine", "alert_size_multiplier") or alert_size

							local alert_event = {
								"aggression",
								unit:position(),
								alert_size,
								managers.groupai:state():get_unit_type_filter("civilians_enemies"),
								self._unit
							}
							managers.groupai:state():propagate_alert(alert_event)
							table.remove(self._save_interaction, id)
						end
					end
				end
				
				self:_end_action_interact(t)

				self._interact_expire_t = nil
				self._save_interaction = nil
			end
		end
	end
end]]