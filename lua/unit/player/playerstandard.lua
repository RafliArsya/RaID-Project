function PlayerStandard:_update_omniscience(t, dt)
	local action_forbidden = not managers.player:has_category_upgrade("player", "standstill_omniscience") or self:_interacting() or self._ext_movement:has_carry_restriction() or self:is_deploying() or self:_is_throwing_projectile() or self:_is_meleeing() or self:_on_zipline() or self._moving or self:running() or self:_is_reloading() or self:in_air() or self:in_steelsight() or self:is_equipping() or self:shooting() or not managers.groupai:state():whisper_mode() or not tweak_data.player.omniscience

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

				end
			end
		end

		self._state_data.omniscience_t = t + tweak_data.player.omniscience.interval_t
	end
end

function PlayerStandard:_get_intimidation_action(prime_target, char_table, amount, primary_only, detect_only, secondary)
	local voice_type, new_action, plural = nil
	local unit_type_enemy = 0
	local unit_type_civilian = 1
	local unit_type_teammate = 2
	local unit_type_camera = 3
	local unit_type_turret = 4
	local is_whisper_mode = managers.groupai:state():whisper_mode()

	if self._ext_movement:ninja_escape_hud() == true then
		return voice_type, plural, prime_target
	end

	if prime_target then
		if prime_target.unit_type == unit_type_teammate then
			local is_human_player, record = nil

			if not detect_only then
				record = managers.groupai:state():all_criminals()[prime_target.unit:key()]

				if record.ai then
					if not prime_target.unit:brain():player_ignore() then
						prime_target.unit:movement():set_cool(false)
						prime_target.unit:brain():on_long_dis_interacted(0, self._unit, secondary)
					end
				else
					is_human_player = true
				end
			end

			local amount = 0
			local current_state_name = self._unit:movement():current_state_name()

			if current_state_name ~= "arrested" and current_state_name ~= "bleed_out" and current_state_name ~= "fatal" and current_state_name ~= "incapacitated" then
				local rally_skill_data = self._ext_movement:rally_skill_data()

				if rally_skill_data and mvector3.distance_sq(self._pos, record.m_pos) < rally_skill_data.range_sq then
					local needs_revive, is_arrested, action_stop = nil

					if not secondary then
						if prime_target.unit:base().is_husk_player then
							is_arrested = prime_target.unit:movement():current_state_name() == "arrested"
							needs_revive = prime_target.unit:interaction():active() and prime_target.unit:movement():need_revive() and not is_arrested
						else
							is_arrested = prime_target.unit:character_damage():arrested()
							needs_revive = prime_target.unit:character_damage():need_revive()
						end

						if needs_revive and rally_skill_data.long_dis_revive and managers.player:has_enabled_cooldown_upgrade("cooldown", "long_dis_revive") then
							voice_type = "revive"

							--managers.player:disable_cooldown_upgrade("cooldown", "long_dis_revive")
						elseif not is_arrested and not needs_revive and rally_skill_data.morale_boost_delay_t and rally_skill_data.morale_boost_delay_t < managers.player:player_timer():time() then
							voice_type = "boost"
							amount = 1
						end
					end
				end
			end

			if is_human_player then
				prime_target.unit:network():send_to_unit({
					"long_dis_interaction",
					prime_target.unit,
					amount,
					self._unit,
					secondary or false
				})
			end

			voice_type = voice_type or secondary and "ai_stay" or "come"
			plural = false
		else
			local prime_target_key = prime_target.unit:key()

			if prime_target.unit_type == unit_type_enemy then
				plural = false

				if prime_target.unit:anim_data().hands_back then
					voice_type = "cuff_cop"
				elseif prime_target.unit:anim_data().surrender then
					voice_type = "down_cop"
				elseif is_whisper_mode and prime_target.unit:movement():cool() and prime_target.unit:base():char_tweak().silent_priority_shout then
					voice_type = "mark_cop_quiet"
				elseif prime_target.unit:base():char_tweak().priority_shout then
					voice_type = "mark_cop"
				else
					voice_type = "stop_cop"
				end
			elseif prime_target.unit_type == unit_type_camera then
				if not prime_target.unit or not prime_target.unit:base() or not prime_target.unit:base().is_friendly then
					plural = false
					voice_type = "mark_camera"
				end
			elseif prime_target.unit_type == unit_type_turret then
				plural = false
				voice_type = "mark_turret"
			elseif prime_target.unit:base():char_tweak().is_escort then
				plural = false
				local e_guy = prime_target.unit

				if e_guy:anim_data().move then
					voice_type = "escort_keep"
				elseif e_guy:anim_data().panic then
					voice_type = "escort_go"
				else
					voice_type = prime_target.unit:base():char_tweak().speech_escort or "escort"
				end
			else
				if prime_target.unit:movement():stance_name() == "cbt" and prime_target.unit:anim_data().stand then
					voice_type = "come"
				elseif prime_target.unit:anim_data().move then
					voice_type = "stop"
				elseif prime_target.unit:anim_data().drop then
					voice_type = "down_stay"
				else
					voice_type = "down"
				end

				local num_affected = 0

				for _, char in pairs(char_table) do
					if char.unit_type == unit_type_civilian then
						if voice_type == "stop" and char.unit:anim_data().move then
							num_affected = num_affected + 1
						elseif voice_type == "down_stay" and char.unit:anim_data().drop then
							num_affected = num_affected + 1
						elseif voice_type == "down" and not char.unit:anim_data().move and not char.unit:anim_data().drop then
							num_affected = num_affected + 1
						end
					end
				end

				if num_affected > 1 then
					plural = true
				else
					plural = false
				end
			end

			local max_inv_wgt = 0

			for _, char in pairs(char_table) do
				if max_inv_wgt < char.inv_wgt then
					max_inv_wgt = char.inv_wgt
				end
			end

			if max_inv_wgt < 1 then
				max_inv_wgt = 1
			end

			if detect_only then
				voice_type = "come"
			else
				for _, char in pairs(char_table) do
					if char.unit_type ~= unit_type_camera and char.unit_type ~= unit_type_teammate and (not is_whisper_mode or not char.unit:movement():cool()) then
						if char.unit_type == unit_type_civilian then
							amount = (amount or tweak_data.player.long_dis_interaction.intimidate_strength) * managers.player:upgrade_value("player", "civ_intimidation_mul", 1) * managers.player:team_upgrade_value("player", "civ_intimidation_mul", 1)
						end

						if prime_target_key == char.unit:key() then
							voice_type = char.unit:brain():on_intimidated(amount or tweak_data.player.long_dis_interaction.intimidate_strength, self._unit) or voice_type
						elseif not primary_only and char.unit_type ~= unit_type_enemy then
							char.unit:brain():on_intimidated((amount or tweak_data.player.long_dis_interaction.intimidate_strength) * char.inv_wgt / max_inv_wgt, self._unit)
						end
					end
				end
			end
		end
	end

	return voice_type, plural, prime_target
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

		if voice_type == "stop" then
			interact_type = "cmd_stop"
			sound_name = "f02x_" .. sound_suffix
		elseif voice_type == "stop_cop" then
			interact_type = "cmd_stop"
			sound_name = "l01x_" .. sound_suffix
		elseif voice_type == "mark_cop" or voice_type == "mark_cop_quiet" then
			interact_type = "cmd_point"

			if voice_type == "mark_cop_quiet" then
				sound_name = tweak_data.character[prime_target.unit:base()._tweak_table].silent_priority_shout .. "_any"
			else
				sound_name = tweak_data.character[prime_target.unit:base()._tweak_table].priority_shout .. "x_any"
				sound_name = managers.modifiers:modify_value("PlayerStandart:_start_action_intimidate", sound_name, prime_target.unit)
			end

			if managers.player:has_category_upgrade("player", "special_enemy_highlight") then
				prime_target.unit:contour():add(managers.player:get_contour_for_marked_enemy(), true, managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1))
				managers.network:session():send_to_peers_synched("spot_enemy", prime_target.unit)
			end
		elseif voice_type == "down" then
			interact_type = "cmd_down"
			sound_name = "f02x_" .. sound_suffix
			self._shout_down_t = t
		elseif voice_type == "down_cop" then
			interact_type = "cmd_down"
			sound_name = "l02x_" .. sound_suffix
		elseif voice_type == "cuff_cop" then
			interact_type = "cmd_down"
			sound_name = "l03x_" .. sound_suffix
		elseif voice_type == "down_stay" then
			interact_type = "cmd_down"

			if self._shout_down_t and t < self._shout_down_t + 2 then
				sound_name = "f03b_any"
			else
				sound_name = "f03a_" .. sound_suffix
			end
		elseif voice_type == "come" then
			interact_type = "cmd_come"
			local static_data = managers.criminals:character_static_data_by_unit(prime_target.unit)

			if static_data then
				local character_code = static_data.ssuffix
				sound_name = "f21" .. character_code .. "_sin"
			else
				sound_name = "f38_any"
			end
		elseif voice_type == "revive" then
			interact_type = "cmd_get_up"
			local static_data = managers.criminals:character_static_data_by_unit(prime_target.unit)

			if not static_data then
				return
			end

			local character_code = static_data.ssuffix
			sound_name = "f36x_any"

            local inspired = false

			if math.random() < self._ext_movement:rally_skill_data().revive_chance + self._ext_movement:rally_skill_data().revive_chance_inc then
				prime_target.unit:interaction():interact(self._unit)
                self._ext_movement:rally_skill_data().revive_chance_inc = 0
                inspired = true
                managers.player:disable_cooldown_upgrade("cooldown", "long_dis_revive")
            else
                managers.player:disable_cooldown_upgrade("cooldown", "long_dis_revive", 2)
                self._ext_movement:rally_skill_data().revive_chance_inc = self._ext_movement:rally_skill_data().revive_chance_inc + 0.05
			end
            log("revive chance = "..tonumber(self._ext_movement:rally_skill_data().revive_chance).." & inc = "..tonumber(self._ext_movement:rally_skill_data().revive_chance_inc))

            if inspired and managers.player:has_category_upgrade("player", "chain_inspire") then
                local _inspire_AOE_check = function(from, to)
                    if not to then
                        return false
                    end
                    if not to.unit or not alive(to.unit) then
                        return false
                    end
                    if from.unit == to.unit then
                        return false
                    end
                    local distance_ok = mvector3.distance(from.unit:position(), to.unit:position()) <= 600
                    if not distance_ok then
                        return false
                    end
                    local obstructed = World:raycast("ray", from.unit:position(), to.unit:position(), "slot_mask", slotmask_world_geometry)
                    if obstructed then
                        return false
                    end
                    return true
			    end
			    local revive_units = {}
			    for c_key, c_data in pairs(managers.groupai:state():all_player_criminals()) do
				    if _inspire_AOE_check(prime_target, c_data) then
                        if not table.contains(revive_units, c_data.unit) then
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
			    end
			    for c_key, c_data in pairs(managers.groupai:state():all_AI_criminals()) do
				    if _inspire_AOE_check(prime_target, c_data) then
                        if not table.contains(revive_units, c_data.unit) then
				    	    revive_units[c_data.unit:key()] = c_data.unit
                        end	
				    end
			    end
			    for _, r_unit in pairs(revive_units) do
				    if r_unit:interaction() then
					    if r_unit:interaction():active() then
					    	r_unit:interaction():interact(self._unit)
					    end
				    end
			    end
                revive_units = nil
            end

			self._ext_movement:rally_skill_data().morale_boost_delay_t = managers.player:player_timer():time() + (self._ext_movement:rally_skill_data().morale_boost_cooldown_t or 3.5)
		elseif voice_type == "boost" then
			interact_type = "cmd_gogo"
			local static_data = managers.criminals:character_static_data_by_unit(prime_target.unit)

			if not static_data then
				return
			end

			local character_code = static_data.ssuffix
			sound_name = "g18"
			self._ext_movement:rally_skill_data().morale_boost_delay_t = managers.player:player_timer():time() + (self._ext_movement:rally_skill_data().morale_boost_cooldown_t or 3.5)
		elseif voice_type == "escort" then
			interact_type = "cmd_point"
			sound_name = "f41_" .. sound_suffix
		elseif voice_type == "escort_keep" or voice_type == "escort_go" then
			interact_type = "cmd_point"
			sound_name = "f40_any"
		elseif voice_type == "bridge_codeword" then
			sound_name = "bri_14"
			interact_type = "cmd_point"
		elseif voice_type == "bridge_chair" then
			sound_name = "bri_29"
			interact_type = "cmd_point"
		elseif voice_type == "undercover_interrogate" then
			sound_name = "f46x_any"
			interact_type = "cmd_point"
		elseif voice_type == "undercover_escort" then
			sound_name = "f41_any"
			interact_type = "cmd_point"
		elseif voice_type == "mark_camera" then
			sound_name = "f39_any"
			interact_type = "cmd_point"

			prime_target.unit:contour():add("mark_unit", true, managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1))
		elseif voice_type == "mark_turret" then
			sound_name = "f44x_any"
			interact_type = "cmd_point"
			local type = prime_target.unit:base().get_type and prime_target.unit:base():get_type()

			prime_target.unit:contour():add(managers.player:get_contour_for_marked_enemy(type), true, managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1))
		elseif voice_type == "ai_stay" then
			sound_name = "f48x_any"
			interact_type = "cmd_stop"
		end

		self:_do_action_intimidate(t, interact_type, sound_name, skip_alert)
	end
end

function PlayerStandard:_check_action_primary_attack(t, input)
	local new_action = nil
	local action_wanted = input.btn_primary_attack_state or input.btn_primary_attack_release
	action_wanted = action_wanted or self:is_shooting_count()

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
							start = start or fire_mode == "auto" and input.btn_primary_attack_state
							start = start or fire_mode == "burst" and input.btn_primary_attack_press
							start = start and not fire_on_release
							start = start or fire_on_release and input.btn_primary_attack_release

							if start then
								if managers.player:get_bulletstorm() or type(managers.player:get_bulletstorm())=="number" and managers.player:get_bulletstorm() > 0 then
									managers.player:add_to_temporary_property("bullet_storm", managers.player:get_bulletstorm(), 1)
									managers.player:set_bulletstorm(0)
								end
								
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
					local weapon_tweak_data = weap_base:weapon_tweak_data()
					local primary_category = weapon_tweak_data.categories[1]

					if not weapon_tweak_data.ignore_damage_multipliers then
						dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "dmg_multiplier_outnumbered", 1)

						if managers.player:has_category_upgrade("player", "overkill_all_weapons") or weap_base:is_category("shotgun", "saw") then
							dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "overkill_damage_multiplier", 1)
						end

						local health_ratio = self._ext_damage:health_ratio()
						local damage_health_ratio = managers.player:get_damage_health_ratio(health_ratio, primary_category)

						if damage_health_ratio > 0 then
							local upgrade_name = weap_base:is_category("saw") and "melee_damage_health_ratio_multiplier" or "damage_health_ratio_multiplier"
							local damage_ratio = damage_health_ratio
							dmg_mul = dmg_mul * (1 + managers.player:upgrade_value("player", upgrade_name, 0) * damage_ratio)
						end

						dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "berserker_damage_multiplier", 1)
						dmg_mul = dmg_mul * managers.player:get_property("trigger_happy", 1)
					end

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
					elseif fire_mode == "auto" then
						if input.btn_primary_attack_state then
							fired = weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
						end
					elseif fire_mode == "burst" then
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

						if (fire_mode == "single" or fire_mode == "burst") and weap_base:get_name_id() ~= "saw" then
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

                            if time_shooting >= 2 then
                                if managers.player:has_category_upgrade("weapon", "heat_to_damage") and not weapon_tweak_data.ignore_damage_multipliers then
                                    dmg_mul = dmg_mul * math.max((managers.player:upgrade_value("weapon", "heat_to_damage", 1) * math.clamp(time_shooting-2, 1, 10)), 1)
                                end
                            end

                            if time_shooting >= 5 then
                                if managers.player:has_category_upgrade("temporary", "heat_to_overkill") then
                                    managers.player:activate_temporary_upgrade("temporary", "heat_to_overkill")
                                end
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
						elseif weap_base.akimbo and not weap_base:weapon_tweak_data().allow_akimbo_autofire or fire_mode == "single" or fire_mode == "burst" then
							self._ext_network:send("shot_blank", impact, 0)
						end
					elseif fire_mode == "single" then
						new_action = false
					elseif fire_mode == "burst" and weap_base:shooting_count() == 0 then
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

function PlayerStandard:_start_action_reload_enter(t)
	local weapon = self._equipped_unit:base()

	if weapon and weapon:can_reload() then
		if managers.player:get_bulletstorm() or type(managers.player:get_bulletstorm())=="number" and managers.player:get_bulletstorm() > 0 then
			managers.player:add_to_temporary_property("bullet_storm", managers.player:get_bulletstorm(), 1)
			managers.player:set_bulletstorm(0)
		end
		managers.player:send_message_now(Message.OnPlayerReload, nil, self._equipped_unit)
		self:_interupt_action_steelsight(t)

		if not self.RUN_AND_RELOAD then
			self:_interupt_action_running(t)
		end

		local is_reload_not_empty = weapon:clip_not_empty()
		local base_reload_enter_expire_t = weapon:reload_enter_expire_t(is_reload_not_empty)

		if base_reload_enter_expire_t and base_reload_enter_expire_t > 0 then
			local speed_multiplier = weapon:reload_speed_multiplier()

			self._ext_camera:play_redirect(Idstring("reload_enter_" .. weapon.name_id), speed_multiplier)

			self._state_data.reload_enter_expire_t = t + base_reload_enter_expire_t / speed_multiplier

			weapon:tweak_data_anim_play("reload_enter", speed_multiplier)

			return
		end

		self:_start_action_reload(t)
	end
end

function PlayerStandard:_start_action_ducking(t)
	if self:_interacting() or self:_on_zipline() then
		return
	end

	self:_interupt_action_running(t)

	self._state_data.ducking = true

	self:_stance_entered()
	self:_update_crosshair_offset()

	local velocity = self._unit:mover():velocity()

	self._unit:kill_mover()
	self:_activate_mover(PlayerStandard.MOVER_DUCK, velocity)
	self._ext_network:send("action_change_pose", 2, self._unit:position())
	if not self._ext_movement:ninja_escape_t() then
		self:_upd_attention()
	end
end

function PlayerStandard:_end_action_ducking(t, skip_can_stand_check)
	if not skip_can_stand_check and not self:_can_stand() then
		return
	end

	self._state_data.ducking = false

	self:_stance_entered()
	self:_update_crosshair_offset()

	local velocity = self._unit:mover():velocity()

	self._unit:kill_mover()
	self:_activate_mover(PlayerStandard.MOVER_STAND, velocity)
	self._ext_network:send("action_change_pose", 1, self._unit:position())
	if not self._ext_movement:ninja_escape_t() then
		self:_upd_attention()
	end
end

--post
Hooks:PostHook(PlayerStandard, "_check_stop_shooting", "RaIDPost_PlayerStandard__check_stop_shooting", function(self)
	if not self._shooting_t then
		if managers.player:has_activate_temporary_upgrade("temporary", "heat_to_overkill") then
            managers.player:deactivate_temporary_upgrade("temporary", "heat_to_overkill")
        end
	end
end)

function PlayerStandard:_do_mover()
	self._unit:mover():set_velocity(self._last_velocity_xy + (self._last_velocity_xy * 0.8))
	self._unit:mover():set_gravity(Vector3(0, 0, 0))
end