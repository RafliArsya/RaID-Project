local old_band_aid_health = PlayerDamage.band_aid_health

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

	self._has_pain_killer_ab = managers.player:has_category_upgrade("player", "pain_killer_ab")
	self._pain_killer_ab_key = {}
	self._pain_killer_ab_t = nil

	self._dodge_inc = 0

	self._doh_data = tweak_data.upgrades.damage_to_hot_data or {}
	self._doh_damage_return_l = false
	self._doh_damage_return = false
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

	if player_manager:has_category_upgrade("temporary", "revive_damage_reduction") then
		self._listener_holder:add("combat_medic_damage_reduction", {
			"on_revive"
		}, callback(self, self, "_activate_combat_medic_damage_reduction"))
	end

	if player_manager:has_category_upgrade("player", "revive_damage_reduction") and player_manager:has_category_upgrade("temporary", "revive_damage_reduction") then
		local function on_revive_interaction_start()
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
			if managers.player:has_category_upgrade("player", "reviving_relief") then
				self:_on_relief_act()
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

	self._fak_down_restore_inc = 0
	self._fak_recharge_messiah_inc = 0
	self._cheat_death_inc = 0
	self._melee_life_leech_dmg_reset_t = nil

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

	if not self._armor_change_blocked and self._current_state then
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

	self:_upd_suppression(t, dt)

	if not self._dead and not self._bleed_out and not self._check_berserker_done then
		if self._doh_damage_return_l then
			if self._doh_damage_return_l <= t then
				managers.player:player_unit():sound():play("perkdeck_cooldown_over")
				self._doh_damage_return_l = nil
			end
		end
		local has_regen = managers.player:health_regen() > 0
		local has_fixed_regen = managers.player:fixed_health_regen() > 0
		if has_regen then
			self:_upd_health_regen_d(t, dt)
		end
		if has_fixed_regen then
			self:_upd_health_regen_f(t, dt)
		end
		self:_upd_health_regen(t, dt)
	end

	if not self:is_downed() then
		self:_update_delayed_damage(t, dt)
	end
end

function PlayerDamage:_chk_cheat_death()
    local has_skill = managers.player:has_category_upgrade("player", "cheat_death_chance")
	if Application:digest_value(self._revives, false) > 1 and not self._check_berserker_done and has_skill then
        
        if self._auto_revive_timer and type(self._auto_revive_timer) == "number" then
			return
		end

		local r = math.random()
		local base = managers.player:upgrade_value("player", "cheat_death_chance", 0)
		local send_info = false

		if r <= base + (self._cheat_death_inc * 0.01) then
			self._auto_revive_timer = 1
            self._cheat_death_inc = self._cheat_death_inc == 0 and -2 or 0
			if not send_info then
				--managers.chat:feed_system_message(ChatManager.GAME, "Feign Death Active")
				managers.chat:send_message(ChatManager.GAME, managers.network.account:username(), managers.localization:text("FeignDeath_Chat"))
			end
        else
            self._cheat_death_inc = self._cheat_death_inc + 2
		end
	end
end

function PlayerDamage:_drop_blood_sample()

    if self._auto_revive_timer and type(self._auto_revive_timer) == "number" then
        return
    end

    local remove = math.truncate(math.random(), 2) < 0.5

	if not remove then
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
			local params = {}

			if not self._blood_sample_reminder_given then
				function params.done_cbk()
					managers.dialog:queue_dialog("Play_pln_nmh_73", {
						delay = 3
					})
				end

				self._blood_sample_reminder_given = true
			end

			managers.dialog:queue_dialog("Play_pln_nmh_72", params)
		end

		local splatter_from = self._unit:position() + math.UP * 5
		local splatter_to = self._unit:position() - math.UP * 45
		local splatter_ray = World:raycast("ray", splatter_from, splatter_to, "slot_mask", managers.game_play_central._slotmask_world_geometry)

		if splatter_ray then
			World:project_decal(Idstring("blood_spatter"), splatter_ray.position, splatter_ray.ray, splatter_ray.unit, nil, splatter_ray.normal)
		end
	end
end

function PlayerDamage:add_damage_to_hot()
	if self:got_max_doh_stacks() then
		return
	end

	if self:need_revive() or self:dead() or self._check_berserker_done then
		return
	end

	table.insert(self._damage_to_hot_stack, {
		next_tick = TimerManager:game():time() + (self._doh_data.tick_time or 1),
		ticks_left = (self._doh_data.total_ticks or 1) + managers.player:upgrade_value("player", "damage_to_hot_extra_ticks", 0)
	})
	table.sort(self._damage_to_hot_stack, function (x, y)
		return x.next_tick < y.next_tick
	end)
end

function PlayerDamage:_upd_health_regen_d(t, dt)
	if self._health_regen_update_timer then
		self._health_regen_update_timer = self._health_regen_update_timer - dt
	
		if self._health_regen_update_timer <= 0 then
			self._health_regen_update_timer = nil
		end
	end
	
	if not self._health_regen_update_timer then
		local max_health = self:_max_health()
	
		if self:get_real_health() < max_health then
			self:restore_health(managers.player:health_regen(), false)
	
			local athird = self:get_real_health() <= max_health * 0.35
	
			self._health_regen_update_timer = athird and 3 or 5
		end
	end
end

function PlayerDamage:_upd_health_regen_f(t, dt)

	if self._health_regen_update_timer_f then
		self._health_regen_update_timer_f = self._health_regen_update_timer_f - dt
	
		if self._health_regen_update_timer_f <= 0 then
			self._health_regen_update_timer_f = nil
		end
	end
	
	if not self._health_regen_update_timer_f then
		local max_health = self:_max_health()
	
		if self:get_real_health() < max_health then
			self:restore_health(managers.player:fixed_health_regen(self:health_ratio()), true)
	
			self._health_regen_update_timer_f = 5
		end
	end
end

function PlayerDamage:_upd_health_regen(t, dt)
	--[[if self._health_regen_update_timer then
		self._health_regen_update_timer = self._health_regen_update_timer - dt

		if self._health_regen_update_timer <= 0 then
			self._health_regen_update_timer = nil
		end
	end

	if not self._health_regen_update_timer then
		local max_health = self:_max_health()

		if self:get_real_health() < max_health then
			self:restore_health(managers.player:health_regen(), false)
			self:restore_health(managers.player:fixed_health_regen(self:health_ratio()), true)

			local athird = self:get_real_health() <= max_health * 0.4

			self._health_regen_update_timer = athird and 3 or 5
		end
	end]]

	if #self._damage_to_hot_stack > 0 then
		repeat
			local next_doh = self._damage_to_hot_stack[1]
			local done = not next_doh or TimerManager:game():time() < next_doh.next_tick

			if not done then
				local regen_rate = managers.player:upgrade_value("player", "damage_to_hot", 0)
				local is_low = self:get_real_health() <= self:_max_health() * 0.5
				local multiplication = 1
				if is_low then
					local hp = self:get_real_health()
					local inc = 0
					for i = 5, 1, -1 do
						if hp > self:_max_health() * (i * 0.1) then
							break
						end
						inc = inc + 1
					end
					
					multiplication = multiplication + (inc*0.1)
					--log(tostring(multiplication))
					if not self._doh_damage_return_l then
						if not self._doh_damage_return then
							managers.player:player_unit():sound():play("perkdeck_activate")
							self._doh_damage_return = true
						end
					end
				end

				--self:restore_health(is_low and regen_rate * 0.25 or regen_rate, not is_low)
				self:restore_health(regen_rate*multiplication, false)

				next_doh.ticks_left = next_doh.ticks_left - 1

				if next_doh.ticks_left == 0 then
					table.remove(self._damage_to_hot_stack, 1)
				else
					--next_doh.next_tick = next_doh.next_tick + (is_low and 0.2 or self._doh_data.tick_time and self._doh_data.tick_time or 1)
					next_doh.next_tick = next_doh.next_tick + (self._doh_data.tick_time or 1)
				end

				table.sort(self._damage_to_hot_stack, function (x, y)
					return x.next_tick < y.next_tick
				end)
			end
		until done
	end
end

function PlayerDamage:band_aid_health()
	if managers.platform:presence() == "Playing" and (self:arrested() or self:need_revive()) then
		return
	end

	self:change_health(self:_max_health() * self._healing_reduction)

	self._said_hurt = false

	local r = math.random()
	local drc = managers.player:upgrade_value("first_aid_kit", "downs_restore_chance", 0)
	drc = drc + (self._fak_down_restore_inc * 0.01)
	local rmc = managers.player:upgrade_value("first_aid_kit", "recharge_messiah_chance", 0) 
	rmc = rmc + (self._fak_recharge_messiah_inc * 0.01)
	
	if r <= drc then
		self._revives = Application:digest_value(math.min(self._lives_init + managers.player:upgrade_value("player", "additional_lives", 0), Application:digest_value(self._revives, false) + 1), true)
		
		self._revive_health_i = math.max(self._revive_health_i - 1, 1)

		managers.environment_controller:set_last_life(Application:digest_value(self._revives, false) <= 1)
		
		managers.chat:_receive_message(ChatManager.GAME, managers.localization:to_upper_text("menu_system_message"), managers.localization:text("FAK_SKILL_1"), tweak_data.system_chat_color)
		--managers.chat:feed_system_message(ChatManager.GAME, "Downs restored [First Aid Kit]") 
		--managers.chat:_receive_message(1, managers.localization:text("FAK"), managers.localization:text("FAK_Downs_Info"), Color.blue)
		
		self:_send_set_revives()
		self._fak_down_restore_inc = 0
	else
		self._fak_down_restore_inc = self._fak_down_restore_inc + math.random(10)
	end
	
	if r <= rmc then
		managers.player:_on_messiah_recharge_event()
		
		self._fak_recharge_messiah_inc = 0

		managers.chat:_receive_message(ChatManager.GAME, managers.localization:to_upper_text("menu_system_message"), managers.localization:text("FAK_SKILL_2"), tweak_data.system_chat_color)
		--managers.chat:feed_system_message(ChatManager.GAME, "Messiah Recharged [First Aid Kit]") 
		--managers.chat:_receive_message(1, managers.localization:text("FAK"), managers.localization:text("FAK_Messiah_Info"), Color.blue) 
	else
		self._fak_recharge_messiah_inc = self._fak_recharge_messiah_inc + math.random(10)
	end
end

function PlayerDamage:restore_health(health_restored, is_static, chk_health_ratio)
	if not health_restored or health_restored == 0 or Application:digest_value(self._health, false) == self:_max_health() * self._max_health_reduction then
		return false
	end

	if chk_health_ratio and managers.player:is_damage_health_ratio_active(self:health_ratio()) then
		return false
	end

	if is_static then
		return self:change_health(health_restored * self._healing_reduction)
	else
		local max_health = self:_max_health()

		return self:change_health(max_health * health_restored * self._healing_reduction)
	end
end

function PlayerDamage:damage_bullet(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local damage_info = {
		result = {
			variant = "bullet",
			type = "hurt"
		},
		attacker_unit = attack_data.attacker_unit
	}
	local pm = managers.player
	local dmg_mul = pm:damage_reduction_skill_multiplier("bullet")
	attack_data.damage = attack_data.damage * dmg_mul
	attack_data.damage = managers.mutators:modify_value("PlayerDamage:TakeDamageBullet", attack_data.damage)
	attack_data.damage = managers.modifiers:modify_value("PlayerDamage:TakeDamageBullet", attack_data.damage, attack_data.attacker_unit:base()._tweak_table)

	if _G.IS_VR then
		local distance = mvector3.distance(self._unit:position(), attack_data.attacker_unit:position())

		if tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
			local step = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2], 0, 1)
			local mul = 1 - math.step(tweak_data.vr.long_range_damage_reduction[1], tweak_data.vr.long_range_damage_reduction[2], step)
			attack_data.damage = attack_data.damage * mul
		end
	end

	local damage_absorption = pm:damage_absorption()

	if damage_absorption > 0 then
		local hp = self:_max_health() * self._max_health_reduction
		local ap = self:_max_armor() 
		local absorp_dmg = math.truncate(((hp + ap) * 0.5) * damage_absorption, 3)
		attack_data.damage = math.max(0, attack_data.damage - absorp_dmg)
	end

	self:copr_update_attack_data(attack_data)

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

	self._last_received_dmg = attack_data.damage
	self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)
	local dodge_roll = math.random()
	local dodge_value = tweak_data.player.damage.DODGE_INIT or 0
	local armor_dodge_chance = math.max(pm:body_armor_value("dodge"), 0)
	local skill_dodge_chance = pm:skill_dodge_chance(self._unit:movement():running(), self._unit:movement():crouching(), self._unit:movement():zipline_unit())
	dodge_value = dodge_value + armor_dodge_chance + skill_dodge_chance

	if self._temporary_dodge_t and TimerManager:game():time() < self._temporary_dodge_t then
		dodge_value = dodge_value + self._temporary_dodge
	end

	local smoke_dodge = 0

	for _, smoke_screen in ipairs(managers.player._smoke_screen_effects or {}) do
		if smoke_screen:is_in_smoke(self._unit) then
			smoke_dodge = tweak_data.projectiles.smoke_screen_grenade.dodge_chance

			break
		end
	end

	dodge_value = 1 - (1 - dodge_value) * (1 - smoke_dodge)
	
	dodge_value = math.truncate(dodge_value, 2)
	dodge_roll = math.truncate(dodge_roll, 2)

	if dodge_roll <= dodge_value + self._dodge_inc then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, 0)
		end

		self:_call_listeners(damage_info)
		self:play_whizby(attack_data.col_ray.position)
		self:_hit_direction(attack_data.attacker_unit:position())

		self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + 1.5, true)
		self._last_received_dmg = attack_data.damage

		self._dodge_inc = 0

		managers.player:send_message(Message.OnPlayerDodge)

		return
	end

	local increase = dodge_value >= 0.6 and 0.02 or 10
	local add_inc = increase > 1 and math.random(10) * 0.01 or increase
	self._dodge_inc = self._dodge_inc + add_inc

	if self._doh_damage_return and self._doh_damage_return == true then
		if attack_data.damage > 0 then
			--log("dodgin damage of "..tostring(attack_data.damage))
			self:_send_damage_drama(attack_data, 0)
		end
		self._doh_damage_return_l = pm:player_timer():time() + 2
		self._doh_damage_return = false

		self:_call_listeners(damage_info)
		self:play_whizby(attack_data.col_ray.position)
		self:_hit_direction(attack_data.attacker_unit:position())

		self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + 0.7, true)
		self._last_received_dmg = self:_max_health()

		managers.player:send_message(Message.OnPlayerDodge)
		return
	end

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

	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

	if not self._bleed_out and health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	elseif self._bleed_out then
		self:chk_queue_taunt_line(attack_data)
	end

	pm:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)
end

function PlayerDamage:damage_fire_hit(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local damage_info = {
		result = {
			variant = "fire",
			type = "hurt"
		},
		attacker_unit = attack_data.attacker_unit
	}
	local pm = managers.player
	local dmg_mul = pm:damage_reduction_skill_multiplier("bullet")
	attack_data.damage = attack_data.damage * dmg_mul
	attack_data.damage = managers.mutators:modify_value("PlayerDamage:TakeDamageBullet", attack_data.damage)
	attack_data.damage = managers.modifiers:modify_value("PlayerDamage:TakeDamageBullet", attack_data.damage, attack_data.attacker_unit:base()._tweak_table)

	if _G.IS_VR then
		local distance = mvector3.distance(self._unit:position(), attack_data.attacker_unit:position())

		if tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
			local step = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2], 0, 1)
			local mul = 1 - math.step(tweak_data.vr.long_range_damage_reduction[1], tweak_data.vr.long_range_damage_reduction[2], step)
			attack_data.damage = attack_data.damage * mul
		end
	end

	local damage_absorption = pm:damage_absorption()

	if damage_absorption > 0 then
		local hp = self:_max_health() * self._max_health_reduction
		local ap = self:_max_armor() * 0.5
		local absorp_dmg = (hp + ap) * damage_absorption
		attack_data.damage = math.max(0, attack_data.damage - absorp_dmg)
	end

	self:copr_update_attack_data(attack_data)

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
	end

	self._last_received_dmg = attack_data.damage
	self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)

	local dodge_roll = math.random()
	local dodge_value = tweak_data.player.damage.DODGE_INIT or 0
	local armor_dodge_chance = math.max(pm:body_armor_value("dodge"), 0)
	local skill_dodge_chance = pm:skill_dodge_chance(self._unit:movement():running(), self._unit:movement():crouching(), self._unit:movement():zipline_unit())
	dodge_value = dodge_value + armor_dodge_chance + skill_dodge_chance

	if self._temporary_dodge_t and TimerManager:game():time() < self._temporary_dodge_t then
		dodge_value = dodge_value + self._temporary_dodge
	end

	local smoke_dodge = 0

	for _, smoke_screen in ipairs(managers.player._smoke_screen_effects or {}) do
		if smoke_screen:is_in_smoke(self._unit) then
			smoke_dodge = tweak_data.projectiles.smoke_screen_grenade.dodge_chance

			break
		end
	end

	dodge_value = 1 - (1 - dodge_value) * (1 - smoke_dodge)
	
	dodge_value = math.truncate(dodge_value, 2)
	dodge_roll = math.truncate(dodge_roll, 2)

	if dodge_roll <= dodge_value then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, 0)
		end

		self:_call_listeners(damage_info)
		self:play_whizby(attack_data.col_ray.position)
		self:_hit_direction(attack_data.attacker_unit:position())

		self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + 1.5, true)
		self._last_received_dmg = attack_data.damage

		managers.player:send_message(Message.OnPlayerDodge)

		return
	end

	local increase = dodge_value >= 0.6 and 0.02 or 10
	local add_inc = increase > 1 and math.random(10) * 0.01 or increase
	self._dodge_inc = self._dodge_inc + add_inc

	if self._doh_damage_return and self._doh_damage_return == true then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, 0)
		end
		self._doh_damage_return_l = pm:player_timer():time() + 2
		self._doh_damage_return = false

		self:_call_listeners(damage_info)
		self:play_whizby(attack_data.col_ray.position)
		self:_hit_direction(attack_data.attacker_unit:position())

		self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + 0.7, true)
		self._last_received_dmg = self:_max_health()

		managers.player:send_message(Message.OnPlayerDodge)
		return
	end

	if self:get_real_armor() > 0 then
		self._unit:sound():play("player_hit")
	else
		self._unit:sound():play("player_hit_permadamage")
	end

	self:_hit_direction(attack_data.attacker_unit:position())
	pm:check_damage_carry(attack_data)

	attack_data.damage = managers.player:modify_value("damage_taken", attack_data.damage, attack_data)

	if self._bleed_out then
		self:_bleed_out_damage(attack_data)

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

	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

	if not self._bleed_out and health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	elseif self._bleed_out then
		self:chk_queue_taunt_line(attack_data)
	end

	pm:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)
end

function PlayerDamage:_calc_armor_damage(attack_data)
	local health_subtracted = 0

	if self:get_real_armor() > 0 then
		health_subtracted = self:get_real_armor()

		local mul = 1
		mul = mul * 0.84
		mul = mul * managers.player:upgrade_value("player", "armor_damage_taken", 1)

		local damage = attack_data.damage
		damage = damage * mul

		attack_data.damage = attack_data.damage * mul

		self:change_armor(-damage)

		health_subtracted = health_subtracted - self:get_real_armor()

		self:_damage_screen()
		SoundDevice:set_rtpc("shield_status", self:armor_ratio() * 100)
		self:_send_set_armor()

		if self:get_real_armor() <= 0 then
			self._unit:sound():play("player_armor_gone_stinger")

			if attack_data.armor_piercing then
				self._unit:sound():play("player_sniper_hit_armor_gone")
			end

			local pm = managers.player

			self:_start_regen_on_the_side(pm:upgrade_value("player", "passive_always_regen_armor", 0))

			if pm:has_inactivate_temporary_upgrade("temporary", "armor_break_invulnerable") then
				pm:activate_temporary_upgrade("temporary", "armor_break_invulnerable")

				self._can_take_dmg_timer = pm:temporary_upgrade_value("temporary", "armor_break_invulnerable", 0)
			end

			pm:_on_armor_break_headshot_dealt_cd_remove()
		end
	end

	managers.hud:damage_taken()

	return health_subtracted
end

function PlayerDamage:_calc_health_damage(attack_data)
	local health_subtracted = 0
	health_subtracted = self:get_real_health()

	local mul = 1
	mul = mul * managers.player:upgrade_value("player", "hp_damage_taken", 1)

	local damage = attack_data.damage
	damage = damage * mul

	self:change_health(-damage)

	health_subtracted = health_subtracted - self:get_real_health()

	if managers.player:has_activate_temporary_upgrade("temporary", "copr_ability") and health_subtracted > 0 then
		local teammate_heal_level = managers.player:upgrade_level_nil("player", "copr_teammate_heal")

		if teammate_heal_level and self:get_real_health() > 0 then
			self._unit:network():send("copr_teammate_heal", teammate_heal_level)
		end
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "armor_break_invulnerable") then
		managers.player:deactivate_temporary_upgrade("temporary", "armor_break_invulnerable")
	end

	local trigger_skills = table.contains({
		"bullet",
		"explosion",
		"melee",
		"delayed_tick"
	}, attack_data.variant)

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

function PlayerDamage:revive(silent)
	if Application:digest_value(self._revives, false) == 0 then
		self._revive_health_multiplier = nil

		return
	end

	local arrested = self:arrested()

	managers.player:set_player_state("standard")
	managers.player:remove_copr_risen_cooldown()

	if not silent then
		PlayerStandard.say_line(self, "s05x_sin")
	end

	self._bleed_out = false
	self._incapacitated = nil
	self._downed_timer = nil
	self._downed_start_time = nil

	if not arrested then
		self:set_health(self:_max_health() * tweak_data.player.damage.REVIVE_HEALTH_STEPS[self._revive_health_i] * (self._revive_health_multiplier or 1) * managers.player:upgrade_value("player", "revived_health_regain", 1))
		self:set_armor(self:_max_armor())

		self._revive_health_i = math.min(#tweak_data.player.damage.REVIVE_HEALTH_STEPS, self._revive_health_i + 1)
		self._revive_miss = 2
	end

	self:_regenerate_armor()
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	managers.hud:pd_stop_progress()

	self._revive_health_multiplier = nil

	self._listener_holder:call("on_revive")

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

	if managers.player:has_activate_temporary_upgrade("temporary", "armor_break_invulnerable") then
		managers.player:deactivate_temporary_upgrade("temporary", "armor_break_invulnerable")
	end
end

function PlayerDamage:_on_relief_act()
	self:restore_health(managers.player:upgrade_value("player", "revive_relief", 1) or 0.05, false)
end

function PlayerDamage:_revive_absorption_bonuses()
	if self._has_pain_killer_ab then
		if not self._pain_killer_ab_t then
			local t = managers.player:player_timer():time()
			self._pain_killer_ab_t = t + 7
			managers.player:set_damage_absorption(self._pain_killer_ab_key, managers.player:upgrade_value("player", "pain_killer_ab", 0))
		end
	end
end

function PlayerDamage:_chk_dmg_too_soon(damage, dmg_eater)
	local next_allowed_dmg_t = type(self._next_allowed_dmg_t) == "number" and self._next_allowed_dmg_t or Application:digest_value(self._next_allowed_dmg_t, false)

	if dmg_eater and type(dmg_eater) == "boolean" and dmg_eater == true then
		if damage >= self._last_received_dmg and managers.player:player_timer():time() < next_allowed_dmg_t then
			dmg_eater = managers.player:player_timer():time() + 3
		end
	end

	if damage <= self._last_received_dmg + 0.01 and managers.player:player_timer():time() < next_allowed_dmg_t then
		return true
	end
end

function PlayerDamage:_start_concussion(mul)
	if self._concussion_data then
		self._concussion_data.intensity = mul
		local duration_tweak = tweak_data.projectiles.concussion.duration
		self._concussion_data.duration = math.max(0, (duration_tweak.min + mul * math.lerp(duration_tweak.additional - 2, duration_tweak.additional + 2, math.random())) - (4 + mul * managers.player:upgrade_value("player", "flashbang_multiplier", 1)))
		self._concussion_data.end_t = managers.player:player_timer():time() + self._concussion_data.duration

		SoundDevice:set_rtpc("concussion_effect", self._concussion_data.intensity * 100)
	else
		local duration = 4 + mul * math.lerp(8, 12, math.random())
		duration = math.max(0, duration - (4 + mul * managers.player:upgrade_value("player", "flashbang_multiplier", 1)))
		self._concussion_data = {
			intensity = mul,
			duration = duration,
			end_t = managers.player:player_timer():time() + duration
		}
	end

	self._unit:sound():play("concussion_player_disoriented_sfx")
	self._unit:sound():play("concussion_effect_on")
end

function PlayerDamage:_start_tinnitus(sound_eff_mul, skip_explosion_sfx)
	if self._tinnitus_data then
		if sound_eff_mul < self._tinnitus_data.intensity then
			return
		end

		self._tinnitus_data.intensity = sound_eff_mul
		self._tinnitus_data.duration = math.max(0, 4 + sound_eff_mul * math.lerp(8, 12, math.random()) - (4 + sound_eff_mul * managers.player:upgrade_value("player", "flashbang_multiplier", 1)))
		self._tinnitus_data.end_t = managers.player:player_timer():time() + self._tinnitus_data.duration

		if self._tinnitus_data.snd_event then
			self._tinnitus_data.snd_event:stop()
		end

		SoundDevice:set_rtpc("downed_state_progression", math.max(self._downed_progression or 0, self._tinnitus_data.intensity * 100))

		self._tinnitus_data.snd_event = self._unit:sound():play("tinnitus_beep")
	else
		local duration = 4 + sound_eff_mul * math.lerp(8, 12, math.random())
		duration = math.max(0, duration - (4 + sound_eff_mul * managers.player:upgrade_value("player", "flashbang_multiplier", 1)))

		SoundDevice:set_rtpc("downed_state_progression", math.max(self._downed_progression or 0, sound_eff_mul * 100))

		self._tinnitus_data = {
			intensity = sound_eff_mul,
			duration = duration,
			end_t = managers.player:player_timer():time() + duration,
			snd_event = self._unit:sound():play("tinnitus_beep")
		}
	end

	if not skip_explosion_sfx then
		self._unit:sound():play("flashbang_explode_sfx_player")
	end
end

--[[function PlayerDamage:_doh_return_damaged()
	if self._doh_damage_return_l == true then
		self._doh_damage_return_l = false
	end
end]]