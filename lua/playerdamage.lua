Hooks:PostHook(PlayerDamage, "revive", "RaID_PlayerDamage_revive", function(self, silent)
	self._data_dodge._dodge_count = 0
	if self._data_dmg_resevoir.reset_t then
		self._data_dmg_resevoir.count = 0
		self._data_dmg_resevoir.refill = 0
		self._data_dmg_resevoir.reset_t = nil
	end
	if self._has_rur then
		local data_rur = self._data_rur
		local _skill_rur = data_rur._skill
		local _cd = data_rur.cd_t
		local _inc = data_rur.increment
		local pm = managers.player
		local t = pm:player_timer():time()
		
		local chance = 0
		chance = chance + _skill_rur.chance + _inc
		if chance >= math.random() and not _cd then
			local activated = self:_find_Drill(self._unit)
			if activated then
				_cd = t + _skill_rur.delay_t
				_inc = 0
			else
				_inc = _inc + _skill_rur.inc
				_inc = math.clamp(_inc, 0, 1 - _skill_rur.chance)
			end
		else
			_inc = _inc + _skill_rur.inc
		end
	end
	if self._has_iryf then
		PlayerStandard:_activate_iryf(self._unit)
	end
	if managers.player:has_category_upgrade("player", "maniac_ictb") and self:_get_ictb("_maniac") == 0 then
		self:_add_ictb("_maniac")
	end
	if managers.player:has_category_upgrade("player", "vice_prez") and self:_get_ictb("_biker") == 0 then
		self:_add_ictb("_biker")
	end
	if self._damage_boost then
		if self._damage_boost._has_dmg_boost then
			if self._damage_boost._has_active_dmg_boost then
				managers.player:deactivate_temporary_upgrade("temporary", "damage_boost_multiplier")
			end
		end
	end
	if self._has_revive_protection then
		self._can_take_dmg_timer = managers.player:upgrade_value("player", "running_from_death")
	end
	if self._has_revive_heal then
		self._has_revive_heal_t = managers.player:player_timer():time() + 12
	end
end)

function PlayerDamage:init(unit)
	self._lives_init = tweak_data.player.damage.LIVES_INIT

	if Global.game_settings.one_down then
		self._lives_init = 2
	end

	self._lives_init = managers.modifiers:modify_value("PlayerDamage:GetMaximumLives", self._lives_init)
	self._unit = unit
	self._max_health_reduction = managers.player:upgrade_value("player", "max_health_reduction", 1)
	self._healing_reduction = managers.player:upgrade_value("player", "healing_reduction", 1)
	self._revives = Application:digest_value(0, true)
	self._uppers_elapsed = 0

	self:replenish()

	local player_manager = managers.player
	self._bleed_out_health = Application:digest_value(tweak_data.player.damage.BLEED_OUT_HEALTH_INIT * player_manager:upgrade_value("player", "bleed_out_health_multiplier", 1), true)
	self._god_mode = Global.god_mode
	self._invulnerable = false
	self._mission_damage_blockers = {}
	self._gui = Overlay:newgui()
	self._ws = self._gui:create_screen_workspace()
	self._focus_delay_mul = 1
	self._dmg_interval = tweak_data.player.damage.MIN_DAMAGE_INTERVAL
	self._next_allowed_dmg_t = Application:digest_value(-100, true)
	self._last_received_dmg = 0
	self._next_allowed_sup_t = -100
	self._last_received_sup = 0
	self._supperssion_data = {}
	self._inflict_damage_body = self._unit:body("inflict_reciever")

	self._inflict_damage_body:set_extension(self._inflict_damage_body:extension() or {})

	local body_ext = PlayerBodyDamage:new(self._unit, self, self._inflict_damage_body)
	self._inflict_damage_body:extension().damage = body_ext

	managers.sequence:add_inflict_updator_body("fire", self._unit:key(), self._inflict_damage_body:key(), self._inflict_damage_body:extension().damage)

	self._doh_data = tweak_data.upgrades.damage_to_hot_data or {}
	self._damage_to_hot_stack = {}
	self._armor_stored_health = 0
	self._can_take_dmg_timer = 0
	self._regen_on_the_side_timer = 0
	self._regen_on_the_side = false
	self._interaction = managers.interaction
	self._armor_regen_mul = managers.player:upgrade_value("player", "armor_regen_time_mul", 1)
	self._dire_need = managers.player:has_category_upgrade("player", "armor_depleted_stagger_shot")
	self._has_damage_speed = managers.player:has_inactivate_temporary_upgrade("temporary", "damage_speed_multiplier")
	self._has_damage_speed_team = managers.player:upgrade_value("player", "team_damage_speed_multiplier_send", 0) ~= 0
	self._has_damage_speed_act = nil
	self._has_damage_speed_ab = managers.player:has_category_upgrade("player", "armor_depleted_get_absorption")
	self._has_damage_speed_ab_act = nil
	self._has_damage_speed_ab_t = nil
	self._has_damage_speed_ab_key = {}

	self._has_pain_killer_ab = managers.player:has_category_upgrade("player", "pain_killer_ab")
	self._pain_killer_ab_key = {}
	self._pain_killer_ab_t = nil

	self._has_revive_protection = managers.player:has_category_upgrade("player", "running_from_death")
	self._has_revive_heal = managers.player:has_category_upgrade("player", "up_you_goh")
	self._has_revive_heal_t = nil
	
	self._damage_boost = {
		_has_dmg_boost = managers.player:has_category_upgrade("temporary", "damage_boost_multiplier"),
		_upg_val = managers.player:upgrade_value("temporary", "damage_boost_multiplier", 0),
		_has_inactive_dmg_boost = managers.player:has_inactivate_temporary_upgrade("temporary", "damage_boost_multiplier"),
		_has_active_dmg_boost = managers.player:has_activate_temporary_upgrade("temporary", "damage_boost_multiplier"),
		_dmg_boost_active_t = nil,
		_dmg_boost_cd_t = nil
	}


	self._doctor_kill_heal_chance = 0

	if managers.player:has_category_upgrade("player", "doctor_kill_heal") then
		self._doctor_kill_heal_chance = 0.2
	end

	local function revive_player()
		self:revive(true)
	end

	managers.player:register_message(Message.RevivePlayer, self, revive_player)

	self._current_armor_fill = 0
	local has_swansong_skill = player_manager:has_category_upgrade("temporary", "berserker_damage_multiplier")
	self._current_state = nil
	self._listener_holder = unit:event_listener()

	if player_manager:has_category_upgrade("player", "damage_to_armor") then
		local damage_to_armor_data = player_manager:upgrade_value("player", "damage_to_armor", nil)
		local armor_data = tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor(true, true)]

		if damage_to_armor_data and armor_data then
			local idx = armor_data.upgrade_level
			self._damage_to_armor = {
				armor_value = damage_to_armor_data[idx][1],
				target_tick = damage_to_armor_data[idx][2],
				elapsed = 0
			}

			local function on_damage(damage_info)
				local attacker_unit = damage_info and damage_info.attacker_unit

				if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
					attacker_unit = attacker_unit:base():thrower_unit()
				end

				if self._unit == attacker_unit then
					local time = Application:time()

					if self._damage_to_armor.target_tick < time - self._damage_to_armor.elapsed then
						self._damage_to_armor.elapsed = time

						self:restore_armor(self._damage_to_armor.armor_value, true)
					end
				end
			end

			CopDamage.register_listener("on_damage", {
				"on_damage"
			}, on_damage)
		end
	end

	self._listener_holder:add("on_use_armor_bag", {
		"on_use_armor_bag"
	}, callback(self, self, "_on_use_armor_bag_event"))
	
	if self:_init_armor_grinding_data() then
		function self._on_damage_callback_func()
			return callback(self, self, "_on_damage_armor_grinding")
		end

		self:_add_on_damage_event()
		self._listener_holder:add("on_enter_bleedout", {
			"on_enter_bleedout"
		}, callback(self, self, "_on_enter_bleedout_event"))

		if has_swansong_skill then
			self._listener_holder:add("on_enter_swansong", {
				"on_enter_swansong"
			}, callback(self, self, "_on_enter_swansong_event"))
			self._listener_holder:add("on_exit_swansong", {
				"on_enter_bleedout"
			}, callback(self, self, "_on_exit_swansong_event"))
		end

		self._listener_holder:add("on_revive", {
			"on_revive"
		}, callback(self, self, "_on_revive_event"))
	else
		self:_init_standard_listeners()
	end

	--[[
	if player_manager:has_category_upgrade("temporary", "revive_damage_reduction") then
		self._listener_holder:add("combat_medic_damage_reduction", {
			"on_revive"
		}, callback(self, self, "_activate_combat_medic_damage_reduction"))
	end
	Cancel Add Listener
	]]
	
	--[[
	if player_manager:has_category_upgrade("temporary", "passive_revive_damage_reduction") then
		self._listener_holder:add("combat_medic_damage_reduction_passive", {
			"on_revive"
		}, callback(self, self, "_activate_combat_medic_damage_reduction"))
	end 
	Canceled Mods
	]]

	if player_manager:has_category_upgrade("player", "revive_damage_reduction") and player_manager:has_category_upgrade("temporary", "revive_damage_reduction") then
		local function on_revive_interaction_start()
			--[[if managers.player:has_activate_temporary_upgrade("temporary", "revive_damage_reduction") then 
				managers.player:deactivate_temporary_upgrade("temporary", "revive_damage_reduction") 
			end]]
			managers.player:set_property("revive_damage_reduction", player_manager:upgrade_value("player", "revive_damage_reduction"), 1)
		end

		local function on_exit_interaction()
			managers.player:remove_property("revive_damage_reduction")
		end

		local function on_revive_interaction_success()
			managers.player:remove_property("revive_damage_reduction")
			managers.player:activate_temporary_upgrade("temporary", "revive_damage_reduction")
			if managers.player:has_category_upgrade("player", "pain_killer_ab") then
				self:_revive_absorption_bonuses()
			end
		end

		self._listener_holder:add("on_revive_interaction_start", {
			"on_revive_interaction_start"
		}, on_revive_interaction_start)
		self._listener_holder:add("on_revive_interaction_interrupt", {
			"on_revive_interaction_interrupt"
		}, on_exit_interaction)
		self._listener_holder:add("on_revive_interaction_success", {
			"on_revive_interaction_success"
		}, on_revive_interaction_success)
	end

	self._down_restore_inc = 0
	self._recharge_messiah_inc = 0
	self._incremental_cheat_death = 0
	self._no_drop = false
	self._fall_dmg = {
		_height_limit = 315,
		_death_limit = 650
	}
	
	self._data_dodge = {
		_dmg_interval_max = 3,
		_dmg_interval_mul = 4,
		_dodge_up = 0,
		_dodge_count = 0
	}
	
	self._has_allowed_dmg_dampener = managers.player:has_category_upgrade("player", "allowed_dmg_dam")
	self._data_dmg_resevoir = {
		_last_received_dmg = 0,
		active_t = 5,
		hold_factor = 0.7,
		hold_icr = 0.1,
		count = 0,
		refill = 0,
		reset_t = nil
	}
	
	self._melee_life_leech_dmg_reset_t = nil
	
	self._has_sharing_ishurt = managers.player:has_category_upgrade("player", "sharing_is_hurting")
	self._data_sharing_hurting = {
		_skill = managers.player:upgrade_value("player", "sharing_is_hurting", 0),
		num_enemies = 0,
		delay_t = nil
	}

	self._has_firetrap_arm = managers.player:has_category_upgrade("player", "fire_trap_mk2")
	self._data_firetrap = {
		_skill = managers.player:upgrade_value("player", "fire_trap_mk2", 0),
		delay_t = nil
	}
	
	self._has_rur = managers.player:has_category_upgrade("player", "revived_up_running")
	self._data_rur = {
		_skill = managers.player:upgrade_value("player", "revived_up_running", 0),
		increment = 0,
		cd_t = nil
	}
	self._has_iryf = managers.player:has_category_upgrade("player", "revived_up_enemy_fall")
	self.ictb = {
		_maniac = {
			_ictb = 1,
			_ictb_max = 1,
			_ictb_min = 0
		},
		_biker = {
			_ictb = 1,
			_ictb_max = 1,
			_ictb_min = 0
		}
	}

	managers.mission:add_global_event_listener("player_regenerate_armor", {
		"player_regenerate_armor"
	}, callback(self, self, "_regenerate_armor"))
	managers.mission:add_global_event_listener("player_force_bleedout", {
		"player_force_bleedout"
	}, callback(self, self, "force_into_bleedout", false))

	local level_tweak = tweak_data.levels[managers.job:current_level_id()]

	if level_tweak and level_tweak.is_safehouse and not level_tweak.is_safehouse_combat then
		self:set_mission_damage_blockers("damage_fall_disabled", true)
		self:set_mission_damage_blockers("invulnerable", true)
	end

	self._delayed_damage = {
		epsilon = 0.001,
		chunks = {}
	}

	self:clear_delayed_damage()
end

function PlayerDamage:update(unit, t, dt)
	if _G.IS_VR and self._heartbeat_t and t < self._heartbeat_t then
		local intensity_mul = 1 - (t - self._heartbeat_start_t) / (self._heartbeat_t - self._heartbeat_start_t)
		local controller = self._unit:base():controller():get_controller("vr")

		for i = 0, 1 do
			local intensity = get_heartbeat_value(t)
			intensity = intensity * (1 - math.clamp(self:health_ratio() / 0.3, 0, 1))
			intensity = intensity * intensity_mul

			controller:trigger_haptic_pulse(i, 0, intensity * 900)
		end
	end

	self:_check_update_max_health()
	self:_check_update_max_armor()
	self:_update_can_take_dmg_timer(dt)
	self:_update_regen_on_the_side(dt)

	if not self._armor_stored_health_max_set then
		self._armor_stored_health_max_set = true

		self:update_armor_stored_health()
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "chico_injector") then
		self._chico_injector_active = true
		local total_time = managers.player:upgrade_value("temporary", "chico_injector")[2]
		local current_time = managers.player:get_activate_temporary_expire_time("temporary", "chico_injector") - t

		managers.hud:set_player_ability_radial({
			current = current_time,
			total = total_time
		})
	elseif self._chico_injector_active then
		managers.hud:set_player_ability_radial({
			current = 0,
			total = 1
		})

		self._chico_injector_active = nil
	end

	local is_berserker_active = managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

	if self._check_berserker_done then
		if is_berserker_active then
			if self._unit:movement():tased() then
				self._tased_during_berserker = true
			else
				self._tased_during_berserker = false
			end
		end

		if not is_berserker_active then
			if self._unit:movement():tased() then
				self._bleed_out_blocked_by_tased = true
			else
				self._bleed_out_blocked_by_tased = false
				self._check_berserker_done = nil

				managers.hud:set_teammate_condition(HUDManager.PLAYER_PANEL, "mugshot_normal", "")
				managers.hud:set_player_custom_radial({
					current = 0,
					total = self:_max_health(),
					revives = Application:digest_value(self._revives, false)
				})
				self:force_into_bleedout()

				if not self._bleed_out then
					self._disable_next_swansong = true
				end
			end
		else
			local expire_time = managers.player:get_activate_temporary_expire_time("temporary", "berserker_damage_multiplier")
			local total_time = managers.player:upgrade_value("temporary", "berserker_damage_multiplier")
			total_time = total_time and total_time[2] or 0
			local delta = 0
			local max_health = self:_max_health()

			if total_time ~= 0 then
				delta = math.clamp((expire_time - Application:time()) / total_time, 0, 1)
			end

			managers.hud:set_player_custom_radial({
				current = delta * max_health,
				total = max_health,
				revives = Application:digest_value(self._revives, false)
			})
			managers.network:session():send_to_peers("sync_swansong_timer", self._unit, delta * max_health, max_health, Application:digest_value(self._revives, false), managers.network:session():local_peer():id())
		end
	end

	if self._bleed_out_blocked_by_zipline and not self._unit:movement():zipline_unit() then
		self:force_into_bleedout(true)

		self._bleed_out_blocked_by_zipline = nil
	end

	if self._bleed_out_blocked_by_movement_state and not self._unit:movement():current_state():bleed_out_blocked() then
		self:force_into_bleedout()

		self._bleed_out_blocked_by_movement_state = nil
	end

	if self._bleed_out_blocked_by_tased and not self._tased_during_berserker and not self._unit:movement():tased() then
		self:force_into_bleedout()

		self._bleed_out_blocked_by_tased = nil
	end

	if self._current_state then
		self:_current_state(t, dt)
	end

	self:_update_armor_hud(t, dt)

	if self._tinnitus_data then
		self._tinnitus_data.intensity = (self._tinnitus_data.end_t - t) / self._tinnitus_data.duration

		if self._tinnitus_data.intensity <= 0 then
			self:_stop_tinnitus()
		else
			SoundDevice:set_rtpc("downed_state_progression", math.max(self._downed_progression or 0, self._tinnitus_data.intensity * 100))
		end
	end

	if self._concussion_data then
		self._concussion_data.intensity = (self._concussion_data.end_t - t) / self._concussion_data.duration

		if self._concussion_data.intensity <= 0 then
			self:_stop_concussion()
		else
			SoundDevice:set_rtpc("concussion_effect", self._concussion_data.intensity * 100)
		end
	end

	if not self._downed_timer and self._downed_progression then
		self._downed_progression = math.max(0, self._downed_progression - dt * 50)

		if not _G.IS_VR then
			managers.environment_controller:set_downed_value(self._downed_progression)
		end

		SoundDevice:set_rtpc("downed_state_progression", self._downed_progression)

		if self._downed_progression == 0 then
			self._unit:sound():play("critical_state_heart_stop")

			self._downed_progression = nil
		end
	end

	if self._auto_revive_timer then
		if not managers.platform:presence() == "Playing" or not self._bleed_out or self._dead or self:incapacitated() or self:arrested() or self._check_berserker_done then
			--[[if self._check_berserker_done then
				self._auto_revive_timer = self._auto_revive_timer
			else
				self._auto_revive_timer = nil
			end]]
			self._auto_revive_timer = self._auto_revive_timer and self._check_berserker_done and self._auto_revive_timer or nil
		else
			self._auto_revive_timer = self._auto_revive_timer - dt

			if self._auto_revive_timer <= 0 then
				self:revive(true)
				self._unit:sound_source():post_event("nine_lives_skill")

				self._auto_revive_timer = nil
			end
		end
	end

	if self._revive_miss then
		self._revive_miss = self._revive_miss - dt

		if self._revive_miss <= 0 then
			self._revive_miss = nil
		end
	end
	
	if self._has_revive_heal then
		if self._has_revive_heal_t then
			if self._has_revive_heal_t > t and (self:incapacitated() or self:is_downed() or self:need_revive() or self:dead()) then
				self._has_revive_heal_t = nil
			end
			if type(self._has_revive_heal_t)== "number" and self._has_revive_heal_t <= t then
				self:_give_revive_heal()
				self._has_revive_heal_t = nil
			end
		end
	end

	if self._has_damage_speed_ab then
		if self._has_damage_speed_ab_t and (self._has_damage_speed_ab_t < t or self:incapacitated() or self:is_downed() or self:need_revive() or self:dead() or not self._has_damage_speed_ab_act) then
			managers.player:set_damage_absorption(self._has_damage_speed_ab_key, nil)
			self._has_damage_speed_ab_t = nil
			log("Delete Damage Absorp")
		end
	end

	if self._has_pain_killer_ab then
		if self._pain_killer_ab_t and (self._pain_killer_ab_t < t or self:incapacitated() or self:is_downed() or self:need_revive() or self:dead()) then
			managers.player:set_damage_absorption(self._pain_killer_ab_key, nil)
			self._pain_killer_ab_t = nil
		end
	end

	if self._data_dmg_resevoir.reset_t then
		if self._data_dmg_resevoir.reset_t < t or self:incapacitated() or self:is_downed() or self:need_revive() or self:dead() then
			self._data_dmg_resevoir.count = 0
			self._data_dmg_resevoir.refill = 0
			self._data_dmg_resevoir.reset_t = nil
		end
	end
	
	if self._data_sharing_hurting.delay_t then
		if self._data_sharing_hurting.delay_t < t or self:incapacitated() or self:is_downed() or self:need_revive() or self:dead() then
			self._data_sharing_hurting.delay_t = nil
		end
	end
	
	if self._data_firetrap.delay_t then
		if self._data_firetrap.delay_t < t or self:incapacitated() or self:is_downed() or self:need_revive() or self:dead() then
			self._data_firetrap.delay_t = nil
		end
	end
	
	if self._melee_life_leech_dmg_reset_t then
		if self._melee_life_leech_dmg_reset_t < t or self:incapacitated() or self:is_downed() or self:need_revive() or self:dead() then
			self._melee_life_leech_dmg_reset_t = nil
		end
	end
	
	if self._data_rur.cd_t then
		if self._data_rur.cd_t < t or self:dead() then
			self._data_rur.cd_t = nil
		end
	end
	
	if self._damage_boost then
		local data = self._damage_boost
		if data._dmg_boost_active_t then
			local data_active = data._dmg_boost_active_t
			if data_active < t then
				data_active = nil
			end
		end
		if data._dmg_boost_cd_t then
			local data_cd = data._dmg_boost_cd_t
			if data_cd < t then
				data_cd = nil
			end
		end
		if self:incapacitated() or self:is_downed() or self:need_revive() or self:dead() then
			if data._dmg_boost_active_t then
				local data_active = data._dmg_boost_active_t
				data_active = nil
			end
			if data._dmg_boost_cd_t then
				local data_cd = data._dmg_boost_cd_t
				data_cd = nil
			end
		end
	end
	
	self:_upd_suppression(t, dt)

	if not self._dead and not self._bleed_out and not self._check_berserker_done then
		self:_upd_health_regen(t, dt)
	end

	if not self:is_downed() then
		self:_update_delayed_damage(t, dt)
	end
end

function PlayerDamage:damage_bullet(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local firetrap = self._has_firetrap_arm
	local fire_data = firetrap and self._data_firetrap or nil

	local damage_info = {
		result = {
			variant = "bullet",
			type = "hurt"
		},
		attacker_unit = attack_data.attacker_unit
	}
	local pm = managers.player
	local dmg_mul = pm:damage_reduction_skill_multiplier("bullet")

	if firetrap and not fire_data.delay_t then
		self:_fire_trap_skill(attack_data, fire_data)
	end

	attack_data.damage = attack_data.damage * dmg_mul
	attack_data.damage = managers.mutators:modify_value("PlayerDamage:TakeDamageBullet", attack_data.damage)
	attack_data.damage = managers.modifiers:modify_value("PlayerDamage:TakeDamageBullet", attack_data.damage)

	if _G.IS_VR then
		local distance = mvector3.distance(self._unit:position(), attack_data.attacker_unit:position())

		if tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
			local step = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2], 0, 1)
			local mul = 1 - math.step(tweak_data.vr.long_range_damage_reduction[1], tweak_data.vr.long_range_damage_reduction[2], step)
			attack_data.damage = attack_data.damage * mul
		end
	end

	local damage_absorption = pm:damage_absorption()
	local has_resevoir = self._has_allowed_dmg_dampener
	local data_resevoir = has_resevoir and self._data_dmg_resevoir
	
	if damage_absorption > 0 then
		local dmg_absorp_val = damage_absorption * 0.1
		local absorp_dmg = self:_max_health() * dmg_absorp_val
		attack_data.damage = math.max(0, attack_data.damage - absorp_dmg)
		--[[local dmg_absorp_over = damage_absorption > 5 and damage_absorption - 5 or nil
		local dmg_absorp_val = math.min(damage_absorption, 5)
		local dmg_absorp_val_over = dmg_absorp_over and math.min(dmg_absorp_over * 0.5, 5) or 0
		dmg_absorp_val = (dmg_absorp_val + dmg_absorp_val_over) * 0.1
		local absorp_dmg = self:_max_health() * dmg_absorp_val
		local remaining_dmg = math.max(0, attack_data.damage - absorp_dmg)
		attack_data.damage = remaining_dmg > 0 and remaining_dmg or 0.01]]
	end

	if self._god_mode then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, attack_data.damage)
		end

		self:_call_listeners(damage_info)

		return
	elseif self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self:is_friendly_fire(attack_data.attacker_unit) then
		return
	elseif self:_chk_dmg_too_soon(attack_data.damage) then
		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif self._revive_miss and math.random() < self._revive_miss then
		self:play_whizby(attack_data.col_ray.position)

		return
	end
	
	if has_resevoir and data_resevoir and data_resevoir.reset_t then
		if data_resevoir._last_received_dmg > 0 then
			local substracted = 0
			substracted = substracted + attack_data.damage
			attack_data.damage = math.max(attack_data.damage - data_resevoir._last_received_dmg, 0)
			substracted = substracted - attack_data.damage
			data_resevoir._last_received_dmg = math.max(data_resevoir._last_received_dmg - substracted, 0)
		else
			data_resevoir.refill = math.min(data_resevoir.refill + 1, 5)
			data_resevoir._last_received_dmg = attack_data.damage * (1 - (0.1 * data_resevoir.refill))
		end
		if attack_data.damage ~= 0 then	
			attack_data.damage = attack_data.damage * (data_resevoir.hold_factor - (data_resevoir.hold_icr * data_resevoir.count))
		end
		data_resevoir.count = math.min(data_resevoir.count + 1, 4)
	end
	
	self._last_received_dmg = attack_data.damage
	self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)
	local dodge_roll = math.random()
	local dodge_value = tweak_data.player.damage.DODGE_INIT or 0
	local armor_dodge_chance = pm:body_armor_value("dodge")
	local skill_dodge_chance = pm:skill_dodge_chance(self._unit:movement():running(), self._unit:movement():crouching(), self._unit:movement():zipline_unit())
	dodge_value = dodge_value + armor_dodge_chance + skill_dodge_chance
	
	local dodge_value_orig = 0 + dodge_value
	local dodge_value_2 = 0

	local in_smoke = false
	
	if self._temporary_dodge_t and TimerManager:game():time() < self._temporary_dodge_t then
		dodge_value = dodge_value + self._temporary_dodge
	end

	local smoke_dodge = 0

	for _, smoke_screen in ipairs(managers.player._smoke_screen_effects or {}) do
		if smoke_screen:is_in_smoke(self._unit) then
			smoke_dodge = tweak_data.projectiles.smoke_screen_grenade.dodge_chance
			
			in_smoke = true
			
			break
		end
	end
	
	dodge_value = 1 - (1 - dodge_value) * (1 - smoke_dodge)
	
	--local is_smoke_dodge = smoke_dodge ~= 0
	
	local high_dodge = not in_smoke and dodge_value > 0.55 or dodge_value_orig > 0.55

	if self._data_dodge._dodge_count > 3 and high_dodge then
		dodge_value = dodge_value - 0.01
		self._data_dodge._dodge_count = 0
	end
	dodge_value = math.clamp(dodge_value, 0, 1)
	
	dodge_value = dodge_value + self._data_dodge._dodge_up
	
	if dodge_roll <= dodge_value then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, 0)
		end

		self:_call_listeners(damage_info)
		self:play_whizby(attack_data.col_ray.position)
		self:_hit_direction(attack_data.attacker_unit:position())
		
		local interval = 0
		interval = interval + math.random(self._data_dodge._dmg_interval_max)
		
		if dodge_roll <= self._data_dodge._dodge_up then
			interval = math.min(interval + math.random(self._data_dodge._dmg_interval_max), self._data_dodge._dmg_interval_mul)
		end
		
		interval = interval + self._dmg_interval
		
		self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + interval , true)
		self._last_received_dmg = attack_data.damage
		
		self._data_dodge._dodge_up = 0
		self._data_dodge._dodge_count = self._data_dodge._dodge_count + 1
		
		managers.player:send_message(Message.OnPlayerDodge)
		return
	end
	
	local dodgeup = dodge_value > 0.6 and 0.01 or (math.random(4) * 0.01)
	
	self._data_dodge._dodge_up = self._data_dodge._dodge_up + dodgeup
	self._data_dodge._dodge_count = 0
	
	local en_shareskill = self._has_sharing_ishurt
	local val_sharing = self._data_sharing_hurting
	local sih_data = val_sharing._skill
	
	if attack_data.attacker_unit:base()._tweak_table == "tank" then
		managers.achievment:set_script_data("dodge_this_fail", true)
	end

	if self:get_real_armor() > 0 then
		self._unit:sound():play("player_hit")
	else
		self._unit:sound():play("player_hit_permadamage")
	end

	local shake_armor_multiplier = pm:body_armor_value("damage_shake") * pm:upgrade_value("player", "damage_shake_multiplier", 1)
	local gui_shake_number = tweak_data.gui.armor_damage_shake_base / shake_armor_multiplier
	gui_shake_number = gui_shake_number + pm:upgrade_value("player", "damage_shake_addend", 0)
	shake_armor_multiplier = tweak_data.gui.armor_damage_shake_base / gui_shake_number
	local shake_multiplier = math.clamp(attack_data.damage, 0.2, 2) * shake_armor_multiplier

	self._unit:camera():play_shaker("player_bullet_damage", 1 * shake_multiplier)

	if not _G.IS_VR then
		managers.rumble:play("damage_bullet")
	end

	self:_hit_direction(attack_data.attacker_unit:position())
	pm:check_damage_carry(attack_data)

	attack_data.damage = managers.player:modify_value("damage_taken", attack_data.damage, attack_data)

	if self._bleed_out then
		self:_bleed_out_damage(attack_data)

		return
	end

	if not attack_data.ignore_suppression and not self:is_suppressed() then
		return
	end

	self:_check_chico_heal(attack_data)

	local armor_reduction_multiplier = 0

	if self:get_real_armor() <= 0 then
		armor_reduction_multiplier = 1
	end

	local health_subtracted = self:_calc_armor_damage(attack_data)

	if attack_data.armor_piercing then
		attack_data.damage = attack_data.damage - health_subtracted
	else
		attack_data.damage = attack_data.damage * armor_reduction_multiplier
	end
	
	local health_dmg_sharing = 0
	local dmg_nil = attack_data.damage <= 0
	
	if self:get_real_armor() <= 0 and not self._bleed_out and not dmg_nil then
		self:_deactive_temp_skill()
	end
	
	if self:get_real_armor() <= 0 and not dmg_nil and en_shareskill and not val_sharing.delay_t and (not self._bleed_out or not self:incapacitated() or not self:is_downed()) then
		local health_dmg_sharing = self:_damage_sharing(attack_data)
		local self_damage = sih_data.damage_s
		if health_dmg_sharing > 0 then
			health_dmg_sharing = math.min(health_dmg_sharing, sih_data.stack)
			health_dmg_sharing = health_dmg_sharing * sih_data.damage_u
			health_dmg_sharing = math.clamp(self_damage - health_dmg_sharing, sih_data.damage_a, 1)
			log("damage shared = "..tostring(health_dmg_sharing))
		else
			health_dmg_sharing = self_damage
			log("[NO ENEMY CLOSE] damage reducted = "..tostring(health_dmg_sharing))
		end
		attack_data.damage = attack_data.damage * health_dmg_sharing
	end
	
	if self:get_real_armor() <= 0 and not dmg_nil and has_resevoir and not data_resevoir.reset_t and (not self._bleed_out or not self:incapacitated() or not self:is_downed()) then
		local now = pm:player_timer():time()
		data_resevoir._last_received_dmg = attack_data.damage
		data_resevoir.reset_t = now + data_resevoir.active_t
	end

	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)
	
	if not self._bleed_out and health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	elseif self._bleed_out and attack_data.attacker_unit and attack_data.attacker_unit:alive() and attack_data.attacker_unit:base()._tweak_table == "tank" then
		self._kill_taunt_clbk_id = "kill_taunt" .. tostring(self._unit:key())

		managers.enemy:add_delayed_clbk(self._kill_taunt_clbk_id, callback(self, self, "clbk_kill_taunt", attack_data), TimerManager:game():time() + tweak_data.timespeed.downed.fade_in + tweak_data.timespeed.downed.sustain + tweak_data.timespeed.downed.fade_out)
	end

	pm:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)
end

function PlayerDamage:_calc_health_damage(attack_data)
	local health_subtracted = 0
	health_subtracted = self:get_real_health()

	self:change_health(-attack_data.damage)

	health_subtracted = health_subtracted - self:get_real_health()
	local trigger_skills = table.contains({
		"bullet",
		"explosion",
		"melee",
		"delayed_tick"
	}, attack_data.variant)
	
	local chk_skills = managers.player:has_category_upgrade("player", "maniac_ictb") or managers.player:has_category_upgrade("player", "vice_prez")
	
	if self:get_real_health() == 0 and chk_skills then
		local lives
		local full_hp = self:_max_health()
		if managers.player:has_category_upgrade("player", "maniac_ictb") then
			lives = self:_get_ictb("_maniac")
			local cocaine = managers.player:_get_local_cocaine_stack()
			if lives > 0 and cocaine ~= 0 then
				self:change_health(math.min(cocaine, full_hp))
				self:activate_revived_skill()
				self:_use_ictb("_maniac")
			end
		end
		if managers.player:has_category_upgrade("player", "vice_prez") then
			lives = self:_get_ictb("_biker")
			if lives > 0 then
				local hp = full_hp * 0.2
				self:change_health(hp)
				self:_use_ictb("_biker")
			end
		end
		self._unit:sound_source():post_event("nine_lives_skill")
	end

	if self:get_real_health() == 0 and trigger_skills then
		self:_chk_cheat_death()
	end

	self:_damage_screen()
	self:_check_bleed_out(trigger_skills)
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	managers.statistics:health_subtracted(health_subtracted)

	return health_subtracted
end

function PlayerDamage:_chk_dmg_too_soon(damage)
	local next_allowed_dmg_t = type(self._next_allowed_dmg_t) == "number" and self._next_allowed_dmg_t or Application:digest_value(self._next_allowed_dmg_t, false)

	if damage < self._last_received_dmg + 0.02 and managers.player:player_timer():time() < next_allowed_dmg_t then
		return true
	end
end

function PlayerDamage:_chk_cheat_death()
	local has_skill = managers.player:has_category_upgrade("player", "cheat_death_chance")
	if Application:digest_value(self._revives, false) > 1 and not self._check_berserker_done and has_skill then
		local r = math.random()
		local base = managers.player:upgrade_value("player", "cheat_death_chance", 0)
		base = base + (self._incremental_cheat_death * 0.01)
		local stopinfo = false
		if self._auto_revive_timer then
			stopinfo = true
		end
		if r <= base then
			self._auto_revive_timer = 1
			self._incremental_cheat_death = 0
			if RaID:get_data("toggle_feign_death_plus") then
				if self._no_drop ~= true then
					self._no_drop = true
				end
			end
			if stopinfo == false then 
				if RaID:get_data("toggle_send_feign_death_info") then
					managers.chat:send_message(ChatManager.GAME, managers.network.account:username(), managers.localization:text("FeignDeath_Revive_Chat"))
				else
					managers.chat:_receive_message(1, managers.localization:text("FeignDeath"), managers.localization:text("FeignDeath_Revive_Info"), Color.blue)
				end
			end
		else
			self._incremental_cheat_death = self._incremental_cheat_death + math.random(5)
		end
	end
end

function PlayerDamage:_drop_blood_sample()
	local remove = false
	
	if math.random() > 0.5 and self._no_drop ~= true then
		remove = true
	end

	if not remove then
		self._no_drop = false 
		return
	end

	local removed = false

	if managers.player:has_special_equipment("blood_sample") then
		removed = true

		managers.player:remove_special("blood_sample")
		managers.hint:show_hint("dropped_blood_sample")
	end

	if managers.player:has_special_equipment("blood_sample_verified") then
		removed = true

		managers.player:remove_special("blood_sample_verified")
		managers.hint:show_hint("dropped_blood_sample")
	end

	if removed then
		self._unit:sound():play("vial_break_2d")
		self._unit:sound():say("g29", false)

		if managers.groupai:state():bain_state() then
			managers.dialog:queue_dialog("hos_ban_139", {})
		end

		local splatter_from = self._unit:position() + math.UP * 5
		local splatter_to = self._unit:position() - math.UP * 45
		local splatter_ray = World:raycast("ray", splatter_from, splatter_to, "slot_mask", managers.game_play_central._slotmask_world_geometry)

		if splatter_ray then
			World:project_decal(Idstring("blood_spatter"), splatter_ray.position, splatter_ray.ray, splatter_ray.unit, nil, splatter_ray.normal)
		end
	end
	
	if self._no_drop then
		self._no_drop = false 
	end
	
end

function PlayerDamage:damage_fall(data)
	local damage_info = {
		result = {
			variant = "fall",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif self._mission_damage_blockers.damage_fall_disabled then
		return
	end

	local player_armor_eq = managers.blackmarket:equipped_armor(true, true)
	local heavy_armor = player_armor_eq == "level_7"
	local height_limit = self._fall_dmg._height_limit
	local death_limit = self._fall_dmg._death_limit
	
	height_limit = heavy_armor and 300 or height_limit
	death_limit = heavy_armor and 700 or death_limit
	
	if data.height < height_limit then
		return
	end

	local die = death_limit < data.height

	self._unit:sound():play("player_hit")
	managers.environment_controller:hit_feedback_down()
	managers.hud:on_hit_direction(Vector3(0, 0, 0), die and HUDHitDirection.DAMAGE_TYPES.HEALTH or HUDHitDirection.DAMAGE_TYPES.ARMOUR, 0)

	if self._bleed_out and self._unit:movement():current_state_name() ~= "jerry1" then
		return
	end

	local health_damage_multiplier = 0
	local drop_damage = heavy_armor and data.height > height_limit and data.height < death_limit
	local extra_alert = nil

	if die then
		self._check_berserker_done = false

		self:set_health(0)

		if self._unit:movement():current_state_name() == "jerry1" then
			self._revives = Application:digest_value(1, true)
		end
	elseif drop_damage then
		extra_alert = true
		
		health_damage_multiplier = managers.player:upgrade_value("player", "fall_damage_multiplier", 1) * managers.player:upgrade_value("player", "fall_health_damage_multiplier", 1)
		
		local damage = tweak_data.player.fall_health_damage * 0.5
		
		self:change_health(-(damage * health_damage_multiplier))
	else
		health_damage_multiplier = managers.player:upgrade_value("player", "fall_damage_multiplier", 1) * managers.player:upgrade_value("player", "fall_health_damage_multiplier", 1)

		self:change_health(-(tweak_data.player.fall_health_damage * health_damage_multiplier))
	end

	if die or health_damage_multiplier > 0 then
		local alert_rad = tweak_data.player.fall_damage_alert_size or 500
		alert_rad = extra_alert and alert_rad * 2.4 or alert_rad
		
		local new_alert = {
			"vo_cbt",
			self._unit:movement():m_head_pos(),
			alert_rad,
			self._unit:movement():SO_access(),
			self._unit
		}

		managers.groupai:state():propagate_alert(new_alert)
	end

	local max_armor = self:_max_armor()

	if die then
		self:set_armor(0)
	else
		local get_armor_dmg = drop_damage and -max_armor * 0.1 or -max_armor * managers.player:upgrade_value("player", "fall_damage_multiplier", 1)
		self:change_armor(get_armor_dmg)
	end

	SoundDevice:set_rtpc("shield_status", 0)
	self:_send_set_armor()

	self._bleed_out_blocked_by_movement_state = nil

	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	self:_damage_screen()
	self:_check_bleed_out(nil, true)
	self:_call_listeners(damage_info)

	return true
end

function PlayerDamage:recover_health()
	if managers.platform:presence() == "Playing" and (self:arrested() or self:need_revive()) then
		self:revive(true)
	end
	
	local rally_skill_data = self._unit:movement():rally_skill_data()
	local inspire_is_cd = rally_skill_data and rally_skill_data.long_dis_revive and managers.player:has_disabled_cooldown_upgrade("cooldown", "long_dis_revive")

	if inspire_is_cd then
		managers.player:enable_cooldown_upgrade("cooldown", "long_dis_revive")
	end
	
	self:_regenerated(true)
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
end

function PlayerDamage:_deactive_temp_skill()
	local life_leach_in_delay = managers.player:has_category_upgrade("temporary", "melee_life_leech") and managers.player:has_activate_temporary_upgrade("temporary", "melee_life_leech") and not self._melee_life_leech_dmg_reset_t
	local ammo_heal_player = managers.player:has_category_upgrade("temporary", "loose_ammo_restore_health") and managers.player:has_activate_temporary_upgrade("temporary", "loose_ammo_restore_health")
	
	if life_leach_in_delay then
		managers.player:deactivate_temporary_upgrade("temporary", "melee_life_leech")
		self._melee_life_leech_dmg_reset_t = managers.player:player_timer():time() + 1
	end
	if ammo_heal_player then
		managers.player:deactivate_temporary_upgrade("temporary", "loose_ammo_restore_health")
	end
end

function PlayerDamage:_fire_trap_skill(attack_data, skill_data)
	if not self._has_firetrap_arm then
		return
	end
	local pm = managers.player
	local player = pm:local_player() or self._unit
	local t = pm:player_timer():time()
	local data = skill_data
	local skill = data._skill
	local attacker = attack_data.attacker_unit
	local hit_dir = player:position() - attacker:position()
	local distance = mvector3.normalize(hit_dir)
	local dmg_reduc = 1 - (distance/skill.distance)
	if distance < skill.distance and dmg_reduc > 0 and not data.delay_t then
		local damage_data = 0
		damage_data = damage_data + attack_data.damage
		damage_data = damage_data * skill.dmg_mul
		damage_data = damage_data * dmg_reduc
		if alive(attacker) and attacker:character_damage() and not attacker:character_damage():dead() then
			local atk_dmg = attacker:character_damage()
			local action_data = {
				variant = "taser_tased",
				damage = damage_data,
				damage_effect = 2,
				attacker_unit = player,
				col_ray = { body = attacker:body("body"), position = attacker:position() + math.UP * 100},
				attack_dir = player:movement():m_head_rot():y()
			}
			if atk_dmg then
				atk_dmg:damage_melee(action_data)
				managers.fire:add_doted_enemy( attacker , t , player:inventory():equipped_unit() , skill.burn_time , damage_data * 0.2 , player , true )
			end
		end
		local slotmask = managers.slot:get_mask("enemies")
		local units = World:find_units_quick("sphere", attacker:position(), skill.radius, slotmask)
		for e_key, unit_key in pairs(units) do
			if alive(unit_key) and unit_key:character_damage() and not unit_key:character_damage():dead() then
				local is_converted = unit_key:brain() and unit_key:brain()._logic_data and unit_key:brain()._logic_data.is_converted
				local is_enggage = unit_key:brain() and unit_key:brain():is_hostile()
				local unit_dmg = unit_key:character_damage()
				local unit_mov = unit_key:movement()
				local unit_enggage = unit_mov and not unit_mov:cool()
				local unit_hostile = unit_mov and unit_mov:stance_name() == "hos"
				local unit_cbt = unit_mov and unit_mov:stance_name() == "cbt"
				if not is_converted and is_enggage and unit_enggage and (unit_hostile or unit_cbt) then
					local action_data = {
						variant = "taser_tased",
						damage = damage_data,
						damage_effect = 2,
						attacker_unit = player,
						col_ray = { body = unit_key:body("body"), position = unit_key:position() + math.UP * 100},
						attack_dir = player:movement():m_head_rot():y()
					}
					if unit_dmg then
						unit_dmg:damage_melee(action_data)
						managers.fire:add_doted_enemy( unit_key , t , player:inventory():equipped_unit() , skill.burn_time , damage_data * 0.2 , player , true )
						--log("given damage to enemies")
					end
				end
			end
		end
		data.delay_t = t + skill.delay
	end
end

function PlayerDamage:_find_Drill(user)
	if self:incapacitated() or self:is_downed() or self:need_revive() or self:dead() then
		return false
	end
	local pm = managers.player
	local player = pm:local_player() or user
	local units = World:find_units("sphere", player:position(), 300, managers.slot:get_mask("bullet_impact_targets"))
	local int_obj = {}
	local result = false
	
	for id, hit_unit in pairs(units) do
		if hit_unit:interaction() and hit_unit:interaction().tweak_data and table.contains(self._interact_jammed, hit_unit:interaction().tweak_data) then
			table.insert(int_obj, hit_unit:interaction())
		end
	end
	
	for interaction_id, interaction in ipairs(int_obj) do 
		interaction:interact(player) 
		table.remove(int_obj, interaction_id)
		result = true
	end 
	
	return result
end

function PlayerDamage:_get_ictb(category)
	return self.ictb[category]._ictb
end

function PlayerDamage:_add_ictb(category)
	self.ictb[category]._ictb = math.min(self.ictb[category]._ictb + 1, self.ictb[category]._ictb_max)
end

function PlayerDamage:_use_ictb(category)
	self.ictb[category]._ictb = math.max(self.ictb[category]._ictb - 1, self.ictb[category]._ictb_min)
end

function PlayerDamage:_reset_ictb(category)
	self.ictb[category]._ictb = 1
end

function PlayerDamage:activate_revived_skill()
	if managers.player:has_inactivate_temporary_upgrade("temporary", "revived_damage_resist") then
		managers.player:activate_temporary_upgrade("temporary", "revived_damage_resist")
	end

	if managers.player:has_inactivate_temporary_upgrade("temporary", "increased_movement_speed") then
		managers.player:activate_temporary_upgrade("temporary", "increased_movement_speed")
	end

	if managers.player:has_inactivate_temporary_upgrade("temporary", "swap_weapon_faster") then
		managers.player:activate_temporary_upgrade("temporary", "swap_weapon_faster")
	end

	if managers.player:has_inactivate_temporary_upgrade("temporary", "reload_weapon_faster") then
		managers.player:activate_temporary_upgrade("temporary", "reload_weapon_faster")
	end
	
	if self._has_rur then
		local data_rur = self._data_rur
		local _skill_rur = data_rur._skill
		local _cd = data_rur.cd_t
		local _inc = data_rur.increment
		local pm = managers.player
		local t = pm:player_timer():time()
		
		local chance = 0
		chance = chance + _skill_rur.chance + _inc
		if chance >= math.random() and not _cd then
			local activated = self:_find_Drill(self._unit)
			if activated then
				_cd = t + _skill_rur.delay_t
				_inc = 0
			else
				_inc = _inc + _skill_rur.inc
				_inc = math.clamp(_inc, 0, 1 - _skill_rur.chance)
			end
		else
			_inc = _inc + _skill_rur.inc
		end
	end
	
	if self._has_iryf then
		PlayerStandard:_activate_iryf(self._unit)
	end
end

function PlayerDamage:_damage_sharing(attack_data)
	local en_shareskill = self._has_sharing_ishurt
	if not en_shareskill then
		return 0
	end
	local val_sharing = self._data_sharing_hurting
	local num = val_sharing.num_enemies
	num = 0
	local activated = val_sharing.num_enemies > 0
	local pm = managers.player
	local player = pm:local_player() or self._unit
	local weapon = player:equipped_weapon_unit()
	local t = pm:player_timer():time()
	local slotmask = managers.slot:get_mask("enemies")
	local units = World:find_units_quick("sphere", player:movement():m_pos(), 900, slotmask)
	if not val_sharing.delay_t then
		for e_key, unit_key in pairs(units) do
			if alive(unit_key) and unit_key:character_damage() and not unit_key:character_damage():dead() then
				local is_converted = unit_key:brain() and unit_key:brain()._logic_data and unit_key:brain()._logic_data.is_converted
				local is_enggage = unit_key:brain() and unit_key:brain():is_hostile()
				local unit_dmg = unit_key:character_damage()
				local unit_mov = unit_key:movement()
				local unit_enggage = unit_mov and not unit_mov:cool()
				local unit_hostile = unit_mov and unit_mov:stance_name() == "hos"
				local unit_cbt = unit_mov and unit_mov:stance_name() == "cbt"
				if not is_converted and is_enggage and unit_enggage and (unit_hostile or unit_cbt) then
					local damage_data = 0
					damage_data = damage_data + attack_data.damage
					damage_data = damage_data * val_sharing._skill.damage_m
					damage_data = damage_data + (damage_data * val_sharing._skill.damage_e)
					local action_data = {
						variant = "expl_hurt",
						damage = damage_data,
						damage_effect = 2,
						attacker_unit = player,
						weapon_unit = weapon,
						col_ray = { body = unit_key:body("body"), position = unit_key:position() + math.UP * 100},
						attack_dir = player:movement():m_head_rot():y()
					}
					if unit_dmg then
						unit_dmg:damage_melee(action_data)
						--log("given damage to enemies")
					end
					self._data_sharing_hurting.num_enemies = self._data_sharing_hurting.num_enemies + 1
				end
			end
		end
	end
	if activated then
		self._data_sharing_hurting.delay_t = t + self._data_sharing_hurting._skill.delay
	end
	return self._data_sharing_hurting.num_enemies
end

function PlayerDamage:_revive_bonuses()
	local upg = managers.player:upgrade_value("player", "pain_killer", 1)
	local full_hp = self:_max_health()
	local painkiller = full_hp * upg
	self:change_health(painkiller * self._healing_reduction)
end

function PlayerDamage:_revive_absorption_bonuses()
	if self._has_pain_killer_ab then
		if not self._pain_killer_ab_t then
			local t = managers.player:player_timer():time()
			self._pain_killer_ab_t = t + 7
			managers.player:set_damage_absorption(self._pain_killer_ab_key, managers.player:upgrade_value("player", "pain_killer_ab", 1))
		end
	end
end

function PlayerDamage:_activate_combat_medic_damage_reduction()
	--[[local skill = managers.player:has_category_upgrade("temporary", "passive_revive_damage_reduction")
	
	if skill then
		managers.player:activate_temporary_upgrade("temporary", "passive_revive_damage_reduction")
	end]]
end

function PlayerDamage:_on_damage_armor_grinding()
	self._current_state = self._update_armor_grinding
end

function PlayerDamage:_update_armor_grinding(t, dt)
	self._armor_grinding.elapsed = self._armor_grinding.elapsed + dt

	if self._armor_grinding.target_tick <= self._armor_grinding.elapsed then
		self._armor_grinding.elapsed = 0

		self:change_armor(self._armor_grinding.armor_value)
	end

	local armor_broken = self:_max_armor() ~= 0 and self:get_real_armor() == 0
	local t = managers.player:player_timer():time()
	if armor_broken and self._has_damage_speed and not self._has_damage_speed_act then
		managers.player:activate_temporary_upgrade("temporary", "damage_speed_multiplier")

		if self._has_damage_speed_team then
			managers.player:send_activate_temporary_team_upgrade_to_peers("temporary", "team_damage_speed_multiplier_received")
		end
		self._has_damage_speed_act = true
	end
	if armor_broken and self._has_damage_speed_ab and not self._has_damage_speed_ab_act and not self._has_damage_speed_ab_t then
		local absorption = math.max(self:_max_health()*0.5, 4)
		self._has_damage_speed_ab_t = t + 5
		managers.player:set_damage_absorption(self._has_damage_speed_ab_key, absorption)
		self._has_damage_speed_ab_act = true
		log("set damage absorp anarchist")
	end
end

function PlayerDamage:_on_damage_event()
	self:set_regenerate_timer_to_max()
	
	local t = managers.player:player_timer():time()
	
	local armor_broken = self:_max_armor() > 0 and self:get_real_armor() <= 0

	if armor_broken and self._has_damage_speed then
		managers.player:activate_temporary_upgrade("temporary", "damage_speed_multiplier")

		if self._has_damage_speed_team then
			managers.player:send_activate_temporary_team_upgrade_to_peers("temporary", "team_damage_speed_multiplier_received")
		end
	end

	if armor_broken and self._has_damage_speed_ab and not self._has_damage_speed_ab_act and not self._has_damage_speed_ab_t then
		local absorption = math.max(self:_max_health()*0.5, 4)
		self._has_damage_speed_ab_t = t + 5
		managers.player:set_damage_absorption(self._has_damage_speed_ab_key, absorption)
		self._has_damage_speed_ab_act = true
		log("set damage absorp regular")
	end
	
	local dmg_bst = self._damage_boost
	local dmg_bst_skill = dmg_bst._has_dmg_boost
	
	if armor_broken and dmg_bst_skill then
		local dmg_bst_val = dmg_bst_skill and dmg_bst._upg_val
		local dmg_bst_active = dmg_bst._dmg_boost_active_t
		local dmg_bst_cd = dmg_bst._dmg_boost_cd_t
		local dmg_bst_inactive = dmg_bst._has_inactive_dmg_boost
		if not dmg_bst_active and not dmg_bst_cd and dmg_bst_inactive then
			managers.player:activate_temporary_upgrade("temporary", "damage_boost_multiplier")
			dmg_bst_active = t + dmg_bst_val[2]
			dmg_bst_cd = dmg_bst_active + 5
		end
	end
end

--[[function PlayerDamage:change_armor(change)
	self:_check_update_max_armor()
	self:set_armor(self:get_real_armor() + change)
	self:_chk_armor_for_skill()
end]]

function PlayerDamage:set_armor(armor)
	self:_check_update_max_armor()

	local get_armor = armor
	local armored = self:_max_armor() > 0
	local maxed_arm = armored and get_armor >= self:_max_armor() and true or false

	armor = math.clamp(armor, 0, self:_max_armor())
	if self._armor then
		local current_armor = self:get_real_armor()

		if current_armor == 0 and armor ~= 0 then
			self:consume_armor_stored_health()
		elseif current_armor ~= 0 and armor == 0 and self._dire_need then
			local function clbk()
				return self:is_regenerating_armor()
			end

			managers.player:add_coroutine(PlayerAction.DireNeed, PlayerAction.DireNeed, clbk, managers.player:upgrade_value("player", "armor_depleted_stagger_shot", 0))
		end
	end
	if maxed_arm then
		if self._has_damage_speed_act then
			self._has_damage_speed_act = nil
			log("set dmg active to "..tostring(self._has_damage_speed_act))
		end
		if self._has_damage_speed_ab_act then
			self._has_damage_speed_ab_act = nil
			log("set ab active to "..tostring(self._has_damage_speed_ab_act))
		end
		
	end
	self._armor = Application:digest_value(armor, true)
end

function PlayerDamage:_give_revive_heal()
	self:change_health(self:_max_health())
end

--[[function PlayerDamage:_chk_armor_for_skill()
	self:_check_update_max_armor()
	local armor = self:get_real_armor()
	local max_armor = self:_max_armor()
	local armor_fully_generated = max_armor > 0 and armor >= max_armor
	if armor_fully_generated then
		if self._has_damage_speed_act then
			self._has_damage_speed_act = nil
		end
		if self._has_damage_speed_ab_act then
			self._has_damage_speed_ab_act = nil
		end
	end
end]]

function PlayerDamage:_medic_heal()
	if managers.platform:presence() == "Playing" and (self:arrested() or self:incapacitated() or self:is_downed() or self:need_revive()) then
		return
	end
	if self:dead() then
		return
	end
	local chance = self._doctor_kill_heal_chance
	if math.random() < chance then
		self:_do_medic_heal()
		self._doctor_kill_heal_chance = 0.2
	else
		self._doctor_kill_heal_chance = self._doctor_kill_heal_chance + (math.random(10) * 0.01)
	end
end

function PlayerDamage:_do_medic_heal()
	local full_hp = self:_max_health()
	local heal = full_hp * 0.05 * self._healing_reduction
	self:change_health(heal)
end

if RequiredScript == "lib/units/beings/player/playerdamage" then
local old_band_aid_health = PlayerDamage.band_aid_health
local old_restore_health = PlayerDamage.restore_health

function PlayerDamage:restore_health(health_restored, is_static, chk_health_ratio, ...)
	if health_restored * self._healing_reduction == 0 then
		return
	end
	return old_restore_health(self, health_restored, is_static, chk_health_ratio, ...)
end

function PlayerDamage:band_aid_health(...)
	if managers.player:has_category_upgrade("first_aid_kit", "downs_restore_chance") or managers.player:has_category_upgrade("first_aid_kit", "recharge_messiah_chance") then
		return self:ace_band_aid_health()
	end
	return old_band_aid_health(self, ...)
end

function PlayerDamage:ace_band_aid_health()
	
	if managers.platform:presence() == "Playing" and (self:arrested() or self:need_revive()) then
		return
	end

	self:change_health(self:_max_health() * self._healing_reduction)

	self._said_hurt = false
	
	local r = math.random()
	local base = managers.player:upgrade_value("first_aid_kit", "downs_restore_chance", 0)
	base = base + (self._down_restore_inc * 0.01)
	local base_ = managers.player:upgrade_value("first_aid_kit", "recharge_messiah_chance", 0) 
	base_ = base_ + (self._recharge_messiah_inc * 0.01)
	
	if r <= base then
		self._revives = Application:digest_value(math.min(self._lives_init + managers.player:upgrade_value("player", "additional_lives", 0), Application:digest_value(self._revives, false) + 1), true)
		self._revive_health_i = math.max(self._revive_health_i - 1, 1)

		managers.environment_controller:set_last_life(Application:digest_value(self._revives, false) <= 1)
		
		self._down_restore_inc = 0
		managers.chat:_receive_message(1, managers.localization:text("FAK"), managers.localization:text("FAK_Downs_Info"), Color.blue)
	else
		self._down_restore_inc = self._down_restore_inc + math.random(10)
	end
	
	if r <= base_ then
		managers.player:_on_messiah_recharge_event()

		managers.chat:_receive_message(1, managers.localization:text("FAK"), managers.localization:text("FAK_Messiah_Info"), Color.blue) 
		self._recharge_messiah_inc = 0
	else
		self._recharge_messiah_inc = self._recharge_messiah_inc + math.random(10)
	end

end

end