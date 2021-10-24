if RequiredScript == "lib/managers/playermanager" then
	local old_use_messiah_charge = PlayerManager.use_messiah_charge
	function PlayerManager:use_messiah_charge(...)
		if self:has_category_upgrade("player", "cheat_messiah_chance") then
			return self:use_ace_messiah_charge()
		end
		return old_use_messiah_charge(self, ...)
	end
	_incremental_cheat_messiah = 0
	function PlayerManager:use_ace_messiah_charge()
		local r = math.random()
		local chance = managers.player:upgrade_value("player", "cheat_messiah_chance", 0)
		chance = chance + (_incremental_cheat_messiah/100)
		if self._messiah_charges then
			if r <= chance then
				_incremental_cheat_messiah = 0
				self._messiah_charges = math.max(self._messiah_charges - 0, self._messiah_charges)
				managers.chat:_receive_message(1, managers.localization:text("Messiah"), managers.localization:text("Messiah_Free_Info"), Color.blue) 
			else
				_incremental_cheat_messiah = _incremental_cheat_messiah + math.random(10)
				self._messiah_charges = math.max(self._messiah_charges - 1, 0)
			end
		end
	end
	
end

Hooks:PreHook(PlayerManager, "init", "RaID_PlayerManager_Init", function(self, ...)
	self._full_mag_inc = 0
	self._full_mag_has_success = false
	self._no_ammo_cost_mk2_delay = nil
	self._all_hostages_count = 0 or nil
	self._super_syndrome_time = {
		next_t = nil,
		remaining = nil,
		active = false
	}
	self._add_pickup_ammo_chance = 0
	self._interact_jammed = {
		"drill_jammed",
		"lance_jammed",
		"gen_int_saw_jammed",
		"apartment_saw_jammed",
		"hospital_saw_jammed",
		"secret_stash_saw_jammed"
	}
	self._sicario = {
		last_gain_val = 0,
		_damaged_speed_up_cd_t = nil
	}
	self._chico = {
		_twothird = 0.62,
		_onethird = 0.31
	}
	self._h4x0r_enabled = false
	self._h4x0r = {
		_is_jammer_active = false,
		_next_tick = nil,
		_last_dmg_t = nil
	}
	self._taser_mk2 = {
		increment = 0,
		cd_time = nil
	}
	self._sentry_data = {
		_lives = 0,
		_kill_chance = 0,
		_kill_chance_cd = nil
	}
	self._interact_bypass = false
end)

function PlayerManager:_ace_add_equipment(params)
	if self:has_equipment(params.equipment) then
		return
	end

	local equipment = params.equipment
	local tweak_data = tweak_data.equipments[equipment]
	local amount = {}
	local amount_digest = {}
	local quantity = tweak_data.quantity

	for i = 1, #quantity, 1 do
		local equipment_name = equipment

		if tweak_data.upgrade_name then
			equipment_name = tweak_data.upgrade_name[i]
		end

		local amt = (quantity[i] or 0) + self:equiptment_upgrade_value(equipment_name, "quantity")
		amt = math.ceil(amt * self:upgrade_value("player", "second_deployable_mul", 1))
		--amt = amt * 20
		amt = managers.modifiers:modify_value("PlayerManager:GetEquipmentMaxAmount", amt, params)

		table.insert(amount, amt)
		table.insert(amount_digest, Application:digest_value(0, true))
	end

	local icon = params.icon or tweak_data and tweak_data.icon
	local use_function_name = params.use_function_name or tweak_data and tweak_data.use_function_name
	local use_function = use_function_name or nil

	table.insert(self._equipment.selections, {
		equipment = equipment,
		amount = amount_digest,
		use_function = use_function,
		action_timer = tweak_data.action_timer,
		icon = icon,
		unit = tweak_data.unit,
		on_use_callback = tweak_data.on_use_callback
	})

	self._equipment.selected_index = self._equipment.selected_index or 1

	if #amount > 1 then
		managers.hud:add_item_from_string({
			amount_str = string.format("%01d|%01d", amount[1], amount[2]),
			amount = amount,
			icon = icon
		})
	else
		managers.hud:add_item({
			amount = amount[1],
			icon = icon
		})
	end

	for i = 1, #amount, 1 do
		self:add_equipment_amount(equipment, amount[i], i)
	end
end

function PlayerManager:__add_equipment(params)
	if self:has_equipment(params.equipment) then
		return
	end

	local equipment = params.equipment
	local tweak_data = tweak_data.equipments[equipment]
	local amount = {}
	local amount_digest = {}
	local quantity = tweak_data.quantity

	for i = 1, #quantity, 1 do
		local equipment_name = equipment

		if tweak_data.upgrade_name then
			equipment_name = tweak_data.upgrade_name[i]
		end

		local amt = (quantity[i] or 0) + self:equiptment_upgrade_value(equipment_name, "quantity")
		amt = math.ceil(amt * 0.75)
		amt = managers.modifiers:modify_value("PlayerManager:GetEquipmentMaxAmount", amt, params)

		table.insert(amount, amt)
		table.insert(amount_digest, Application:digest_value(0, true))
	end

	local icon = params.icon or tweak_data and tweak_data.icon
	local use_function_name = params.use_function_name or tweak_data and tweak_data.use_function_name
	local use_function = use_function_name or nil

	table.insert(self._equipment.selections, {
		equipment = equipment,
		amount = amount_digest,
		use_function = use_function,
		action_timer = tweak_data.action_timer,
		icon = icon,
		unit = tweak_data.unit,
		on_use_callback = tweak_data.on_use_callback
	})

	self._equipment.selected_index = self._equipment.selected_index or 1

	if #amount > 1 then
		managers.hud:add_item_from_string({
			amount_str = string.format("%01d|%01d", amount[1], amount[2]),
			amount = amount,
			icon = icon
		})
	else
		managers.hud:add_item({
			amount = amount[1],
			icon = icon
		})
	end

	for i = 1, #amount, 1 do
		self:add_equipment_amount(equipment, amount[i], i)
	end
end

function PlayerManager:check_skills()
	self:send_message_now("check_skills")
	self._coroutine_mgr:clear()

	self._saw_panic_when_kill = self:has_category_upgrade("saw", "panic_when_kill")
	self._unseen_strike = self:has_category_upgrade("player", "unseen_increased_crit_chance")

	if self:has_category_upgrade("pistol", "stacked_accuracy_bonus") then
		self._message_system:register(Message.OnEnemyShot, self, callback(self, self, "_on_expert_handling_event"))
	else
		self._message_system:unregister(Message.OnEnemyShot, self)
	end

	if self:has_category_upgrade("pistol", "stacking_hit_damage_multiplier") then
		self._message_system:register(Message.OnEnemyShot, "trigger_happy", callback(self, self, "_on_enter_trigger_happy_event"))
	else
		self._message_system:unregister(Message.OnEnemyShot, "trigger_happy")
	end

	if self:has_category_upgrade("player", "melee_damage_stacking") then
		local function start_bloodthirst_base(weapon_unit, variant)
			if variant ~= "melee" and not self._coroutine_mgr:is_running(PlayerAction.BloodthirstBase) then
				local data = self:upgrade_value("player", "melee_damage_stacking", nil)

				if data and type(data) ~= "number" then
					self._coroutine_mgr:add_coroutine(PlayerAction.BloodthirstBase, PlayerAction.BloodthirstBase, self, data.melee_multiplier, data.max_multiplier)
				end
			end
		end

		self._message_system:register(Message.OnEnemyKilled, "bloodthirst_base", start_bloodthirst_base)
	else
		self._message_system:unregister(Message.OnEnemyKilled, "bloodthirst_base")
	end

	if self:has_category_upgrade("player", "messiah_revive_from_bleed_out") then
		self._messiah_charges = self:upgrade_value("player", "messiah_revive_from_bleed_out", 0)
		self._max_messiah_charges = self._messiah_charges

		self._message_system:register(Message.OnEnemyKilled, "messiah_revive_from_bleed_out", callback(self, self, "_on_messiah_event"))
	else
		self._messiah_charges = 0
		self._max_messiah_charges = self._messiah_charges

		self._message_system:unregister(Message.OnEnemyKilled, "messiah_revive_from_bleed_out")
	end

	if self:has_category_upgrade("player", "recharge_messiah") then
		self._message_system:register(Message.OnDoctorBagUsed, "recharge_messiah", callback(self, self, "_on_messiah_recharge_event"))
	else
		self._message_system:unregister(Message.OnDoctorBagUsed, "recharge_messiah")
	end

	if self:has_category_upgrade("player", "double_drop") then
		self._target_kills = self:upgrade_value("player", "double_drop", 0)

		self._message_system:register(Message.OnEnemyKilled, "double_ammo_drop", callback(self, self, "_on_spawn_extra_ammo_event"))
	else
		self._target_kills = 0

		self._message_system:unregister(Message.OnEnemyKilled, "double_ammo_drop")
	end

	if self:has_category_upgrade("temporary", "single_shot_fast_reload") then
		self._message_system:register(Message.OnLethalHeadShot, "activate_aggressive_reload", callback(self, self, "_on_activate_aggressive_reload_event"))
	else
		self._message_system:unregister(Message.OnLethalHeadShot, "activate_aggressive_reload")
	end

	if self:has_category_upgrade("player", "head_shot_ammo_return") then
		self._ammo_efficiency = self:upgrade_value("player", "head_shot_ammo_return", nil)

		self._message_system:register(Message.OnHeadShot, "ammo_efficiency", callback(self, self, "_on_enter_ammo_efficiency_event"))
	else
		self._ammo_efficiency = nil

		self._message_system:unregister(Message.OnHeadShot, "ammo_efficiency")
	end

	if self:has_category_upgrade("player", "melee_kill_increase_reload_speed") then
		self._message_system:register(Message.OnEnemyKilled, "bloodthirst_reload_speed", callback(self, self, "_on_enemy_killed_bloodthirst"))
	else
		self._message_system:unregister(Message.OnEnemyKilled, "bloodthirst_reload_speed")
	end

	if self:has_category_upgrade("player", "super_syndrome") then
		self._super_syndrome_count = self:upgrade_value("player", "super_syndrome")
	else
		self._super_syndrome_count = 0
	end

	if self:has_category_upgrade("player", "dodge_shot_gain") then
		local last_gain_time = 0
		local dodge_gain = self:upgrade_value("player", "dodge_shot_gain")[1]
		local cooldown = self:upgrade_value("player", "dodge_shot_gain")[2]

		local function on_player_damage(attack_data)
			local t = TimerManager:game():time()

			if attack_data.variant == "bullet" and t > last_gain_time + cooldown then
				last_gain_time = t

				managers.player:_dodge_shot_gain(managers.player:_dodge_shot_gain() + dodge_gain)
			end
		end

		self:register_message(Message.OnPlayerDodge, "dodge_shot_gain_dodge", callback(self, self, "_dodge_shot_gain", 0))
		self:register_message(Message.OnPlayerDamage, "dodge_shot_gain_damage", on_player_damage)
	else
		self:unregister_message(Message.OnPlayerDodge, "dodge_shot_gain_dodge")
		self:unregister_message(Message.OnPlayerDamage, "dodge_shot_gain_damage")
	end

	if self:has_category_upgrade("player", "dodge_replenish_armor") then
		self:register_message(Message.OnPlayerDodge, "dodge_replenish_armor", callback(self, self, "_dodge_replenish_armor"))
	else
		self:unregister_message(Message.OnPlayerDodge, "dodge_replenish_armor")
	end

	if managers.blackmarket:equipped_grenade() == "smoke_screen_grenade" then
		local last_gain_time = self._sicario._damaged_speed_up_cd_t
		local function speed_up_on_kill()
			local value = 0
			if #managers.player:smoke_screens() == 0 then
				value = value + 2
			else
				value = value + 1
			end
			managers.player:speed_up_grenade_cooldown(value)
		end
		local function speed_up_on_damage(attack_data)
			local t = TimerManager:game():time()
			local in_smoke = self:_is_in_my_smoke()
			if (attack_data.variant == "bullet" or attack_data.variant == "melee") and not last_gain_time and in_smoke then
				local value = math.random(5)
				managers.player:speed_up_grenade_cooldown(value)
				self._sicario._damaged_speed_up_cd_t = t + 2 --in_smoke and t + 2 or t + 5
			end
		end

		self:register_message(Message.OnEnemyKilled, "speed_up_smoke_grenade", speed_up_on_kill)
		self:register_message(Message.OnPlayerDamage, "speed_up_smoke_grenaded", speed_up_on_damage)
		
	else
		self:unregister_message(Message.OnEnemyKilled, "speed_up_smoke_grenade")
		self:unregister_message(Message.OnPlayerDamage, "speed_up_smoke_grenaded")
	end

	self:add_coroutine("damage_control", PlayerAction.DamageControl)

	if self:has_category_upgrade("snp", "graze_damage") then
		self:register_message(Message.OnWeaponFired, "graze_damage", callback(SniperGrazeDamage, SniperGrazeDamage, "on_weapon_fired"))
	else
		self:unregister_message(Message.OnWeaponFired, "graze_damage")
	end
	
	--[[if managers.blackmarket:equipped_grenade() == "tag_team" then
		local function speed_up_on_kill()
			if not self._coroutine_mgr:is_running("tag_team") then
				managers.player:speed_up_grenade_cooldown(2 * math.random(5,10) * 0.1)
			end
		end

		self:register_message(Message.OnEnemyKilled, "speed_up_tag_team", speed_up_on_kill)
	else
		self:unregister_message(Message.OnEnemyKilled, "speed_up_tag_team")
	end]]
	
	if self:has_category_upgrade("player", "replenish_super_syndrome_chance") or self:has_category_upgrade("player", "hostage_replenish_super_syndrome_chance") then
		self._super_syndrome_recharge_chance = 0
	else
		self._super_syndrome_recharge_chance = nil
	end

	if self:has_category_upgrade("player", "replenish_super_syndrome_chance") then
		self._message_system:register(Message.OnDoctorBagUsed, "replenish_super_syndrome_chance", callback(self, self, "_on_recharge_super_syndrome_event"))
	else
		self._message_system:unregister(Message.OnDoctorBagUsed, "replenish_super_syndrome_chance")
	end
	
	if self:has_category_upgrade("player", "lucky_mag") then
		self._message_system:register(Message.OnAmmoPickup, "lucky_mag", callback(self, self, "_on_try_lucky_mag"))
	else
		self._message_system:unregister(Message.OnAmmoPickup, "lucky_mag")
	end
	
	if self:has_category_upgrade("player", "weapon_add_pickup_chance") then
		self._message_system:register(Message.OnAmmoPickup, "lucky_mag", callback(self, self, "_on_try_lucky_mag"))
	else
		self._message_system:unregister(Message.OnAmmoPickup, "lucky_mag")
	end

	if self:has_category_upgrade("player", "no_ammo_cost_mk2") then
		self._no_ammo_cost_mk2_inc = 0
		self:register_message(Message.OnEnemyKilled, "no_ammo_cost_mk2", callback(self, self, "_no_ammo_cost_mk2")) --self:register_message(Message.OnWeaponFired, "no_ammo_cost_mk2", callback(self, self, "_no_ammo_cost_mk2"))
	else
		self._no_ammo_cost_mk2_inc = 0
		self:unregister_message(Message.OnEnemyKilled, "no_ammo_cost_mk2") --self:unregister_message(Message.OnWeaponFired, "no_ammo_cost_mk2")
	end

	if self:has_category_upgrade("player", "doctor_kill_heal") then
		self._dkh = {
			delay_t = 0
		}
		self:register_message(Message.OnEnemyKilled, "doctor_kill_heal", callback(self, self, "_on_enemy_medic_killed_heal_chance"))
	else
		self._dkh = {
			delay_t = nil
		}
		self:unregister_message(Message.OnEnemyKilled, "doctor_kill_heal")
	end

	if self:has_category_upgrade("cooldown", "long_dis_revive") and self:has_category_upgrade("player", "long_dis_reduce") then
		self._inspire_reduce = {
			delay_t = 0
		}
		self:register_message(Message.OnEnemyKilled, "long_dis_reduce", callback(self, self, "_on_enemy_killed_reduce_long_dis_cd"))
	else
		self._inspire_reduce = {
			delay_t = nil
		}
		self:unregister_message(Message.OnEnemyKilled, "long_dis_reduce")
	end
	
	if self:has_category_upgrade("player", "AOE_intimidate") then
		self._AOE_int_chance_t = 0.2
	else
		self._AOE_int_chance_t = nil
	end

	if self:has_category_upgrade("player", "melee_kill_regen_armor") then
		self._melee_kill_regen_armor_t = nil
		self._message_system:register(Message.OnEnemyKilled, "m_melee_kill_regen_armor", callback(self, self, "_on_enemy_killed_melee_regen_armor"))
	else
		self._message_system:unregister(Message.OnEnemyKilled, "m_melee_kill_regen_armor")
	end

	--[[if self:has_category_upgrade("player", "crowd_control_mk2") then
		self._crowd_control = {
			value = 0,
			trigger = 0,
			inactive_trg = 0,
			inactive_t = nil,
			delay = false,
			delay_t = nil,
			active_t = nil
		}
		self:register_message(Message.OnWeaponFired, "crowd_control_mk2", callback(self, self, "_crowd_control_mk2"))
	else
		self._crowd_control = {
			value = 0,
			trigger = 0,
			inactive_trg = 0,
			inactive_t = nil,
			delay = false,
			delay_t = nil,
			active_t = nil
		}
		self:unregister_message(Message.OnWeaponFired, "crowd_control_mk2")
	end]]
	
	if self:has_category_upgrade("player", "sure_fire_mk2") then
		self._surefire = {
			value = 0,
			activated = false,
			active_t = nil,
			delay_t = nil
		}
		self:register_message(Message.OnWeaponFired, "sure_fire_mk2", callback(self, self, "_on_sure_keep_firing"))
	else
		self._surefire = {
			value = 0,
			activated = false,
			active_t = nil,
			delay_t = nil
		}
		self:unregister_message(Message.OnWeaponFired, "sure_fire_mk2")
	end
	
	if self:has_category_upgrade("player", "drill_resume") then
		self._drill_resume_on_kill = {
			chance = 0,
			activated = false,
			_repaired = false,
			_kill_t = nil,
			delay_t = nil
		}
		self:register_message(Message.OnEnemyKilled, "drill_resume", callback(self, self, "_find_drill"))
	else
		self._drill_resume_on_kill = {
			chance = 0,
			activated = false,
			_repaired = false,
			_kill_t = nil,
			delay_t = nil
		}
		self:unregister_message(Message.OnEnemyKilled, "drill_resume")
	end

	if self:has_category_upgrade("sentry_gun", "destroy_auto_pickup") then
		self._sentry_data._lives = self:upgrade_value("sentry_gun", "destroy_auto_pickup", 1)
		--[[if self:has_category_upgrade("sentry_gun", "destroy_auto_pickup_2") then
			self._sentry_data._lives = math.min(self._sentry_data._lives + self:upgrade_value("sentry", "destroy_auto_pickup_2", 1), 12)
		end]]
	end
end

Hooks:PreHook(PlayerManager, "_add_equipment", "RaID_add_equipment", function(self, params)
	if params and type(params.slot) == "number" and params.slot == 2 then
		if self:has_category_upgrade("player", "second_deployable_mul") then
			self:_ace_add_equipment(params)
		end
	end
end)

function PlayerManager:update(t, dt)
	self._message_system:update()
	self:_update_timers(t)
	
	if self._need_to_send_player_status then
		self._need_to_send_player_status = nil

		self:need_send_player_status()
	end

	self._sent_player_status_this_frame = nil
	local local_player = self:local_player()

	if self:has_category_upgrade("player", "close_to_hostage_boost") and (not self._hostage_close_to_local_t or self._hostage_close_to_local_t <= t) then
		self._is_local_close_to_hostage = alive(local_player) and managers.groupai and managers.groupai:state():is_a_hostage_within(local_player:movement():m_pos(), tweak_data.upgrades.hostage_near_player_radius)
		self._hostage_close_to_local_t = t + tweak_data.upgrades.hostage_near_player_check_t
	end

	self:_update_damage_dealt(t, dt)

	if #self._global.synced_cocaine_stacks >= 1 then
		local amount = 0

		for i, stack in pairs(self._global.synced_cocaine_stacks) do
			if stack.in_use then
				amount = amount + stack.amount
			end

			if PlayerManager.TARGET_COCAINE_AMOUNT <= amount then
				managers.achievment:award("mad_5")
			end
		end
	end

	self._coroutine_mgr:update(t, dt)
	self._action_mgr:update(t, dt)

	if self._unseen_strike and not self._coroutine_mgr:is_running(PlayerAction.UnseenStrike) and managers.platform:presence() == "Playing" then
		local data = self:upgrade_value("player", "unseen_increased_crit_chance", 0)

		if data ~= 0 then
			self._coroutine_mgr:add_coroutine(PlayerAction.UnseenStrike, PlayerAction.UnseenStrike, self, data.min_time, data.max_duration, data.crit_chance)
		end
	end
	
	if self._no_ammo_cost_mk2_delay then
		if self._no_ammo_cost_mk2_delay <= t then
			self._no_ammo_cost_mk2_delay = nil
		end
	end
	if self._surefire.active_t then
		if self._surefire.active_t < t or not self._surefire.activated then
			self._surefire.active_t = nil
		end
	end
	if self._drill_resume_on_kill.delay_t then
		if self._drill_resume_on_kill.delay_t < t then
			self._drill_resume_on_kill.delay_t = nil
			self._drill_resume_on_kill.activated = false
		end
	end
	if self._drill_resume_on_kill._kill_t then
		if self._drill_resume_on_kill._kill_t < t then
			self._drill_resume_on_kill._kill_t = nil
		end
	end
	if self._sicario._damaged_speed_up_cd_t then
		if self._sicario._damaged_speed_up_cd_t < t then
			self._sicario._damaged_speed_up_cd_t = nil
		end
	end
	--[[
	if self._h4x0r._is_jammer_active then
		self:_jammmer_crowd_ctrl()
	end
	if self._h4x0r._next_tick then
		if self._h4x0r._next_tick < t then
			self._h4x0r._next_tick = nil
		end
	end
	]]
	if managers.groupai and managers.groupai:state():whisper_mode() then
		if self._h4x0r._next_tick then
			if self._h4x0r._next_tick < t then
				self._h4x0r._next_tick = nil
			end
		end
		if self._timers.replenish_grenades and not self._h4x0r._next_tick then
			self:_pocket_ecm_jammer_speed_up_on_stealth()
		end
	end
	--[[if self._crowd_control then
		if self._crowd_control.active_t then
			if self._crowd_control.active_t < t then
				self._crowd_control.trigger = 0
				self._crowd_control.active_t = nil
				if self._crowd_control.delay == true then
					local data = self:upgrade_value("player", "crowd_control_mk2")
					self._crowd_control.delay_t = t + data.delay
					self._crowd_control.delay = false
				end
			end
		end
		if self._crowd_control.inactive_t then
			if self._crowd_control.inactive_t < t then
				self._crowd_control.inactive_trg = 0
				self._crowd_control.inactive_t = nil
			end
		end
		if self._crowd_control.delay_t then
			if self._crowd_control.delay_t < t then
				self._crowd_control.delay_t = nil
			end
		end
	end]]
	if self._taser_mk2 then
		if self._taser_mk2.cd_time then
			if self._taser_mk2.cd_time < t then
				self._taser_mk2.cd_time = nil
			end
			--self._taser_mk2.cd_time = self._taser_mk2.cd_time < t and nil or self._taser_mk2.cd_time
		end
	end
	if self._sentry_data then
		if self._sentry_data._kill_chance_cd then
			if self._sentry_data._kill_chance_cd < t then
				self._sentry_data._kill_chance_cd = nil
			end
			--self._sentry_data._kill_chance_cd = self._sentry_data._kill_chance_cd < t and nil or self._sentry_data._kill_chance_cd
		end
	end
	
	if self._melee_kill_regen_armor_t then
		self._melee_kill_regen_armor_t = self._melee_kill_regen_armor_t < t and nil or self._melee_kill_regen_armor_t
	end

	local has_stockholm = self:has_category_upgrade("player", "super_syndrome")
	local stockholm_used = has_stockholm and self._super_syndrome_count == 0 and true or false
	local stockholm_recharges = self:has_category_upgrade("player", "replenish_super_syndrome_chance") or self:has_category_upgrade("player", "hostage_replenish_super_syndrome_chance")
	local can_recharges_stockholm = stockholm_recharges and stokholm_used

	if can_recharges_stockholm and self._super_syndrome_time then
		if self._super_syndrome_time.active then
			if self._super_syndrome_time.next_t then
				if self._super_syndrome_time.next_t < t then
					self:_on_hostages_recharge_super_syndrome_event()
					self:_stop_hostage_time()
				end 
			end
		end
		if self._super_syndrome_time.active == false then
			self:_upd_hostage_time()
		end
	end
	
	self:update_smoke_screens(t, dt)
end

function PlayerManager:damage_absorption()
	local total = 0

	for _, absorption in pairs(self._damage_absorption) do
		total = total + Application:digest_value(absorption, false)
	end
	--log(self:get_best_cocaine_damage_absorption(managers.network:session():local_peer():id()))
	total = total + self:get_best_cocaine_damage_absorption(managers.network:session():local_peer():id())
	total = managers.modifiers:modify_value("PlayerManager:GetDamageAbsorption", total)
	--log(total)
	return total
end

function PlayerManager:set_damage_absorption(key, value)
	self._damage_absorption[key] = value and Application:digest_value(value, true) or nil

	managers.hud:set_absorb_active(HUDManager.PLAYER_PANEL, self:damage_absorption() * (type(self:local_player():character_damage():_max_health())=="number" and self:local_player():character_damage():_max_health() or 1))
end

function PlayerManager:update_cocaine_hud()
	if managers.hud then
		if self:player_unit() and self:player_unit():character_damage() and Utils:IsInGameState() then
			managers.hud:set_absorb_active(HUDManager.PLAYER_PANEL, self:damage_absorption() * (type(self:player_unit():character_damage():_max_health())=="number" and self:player_unit():character_damage():_max_health() or 1))
		end
	end
end

function PlayerManager:_start_hostage_time()
	local now = TimerManager:game():time()
	self._super_syndrome_time.next_t = now + 600
end

function PlayerManager:_pause_hostage_time()
	local now = TimerManager:game():time()
	self._super_syndrome_time.remaining = self._super_syndrome_time.next_t - now
	self._super_syndrome_time.next_t = nil
end

function PlayerManager:_resume_hostage_time()
	local now = TimerManager:game():time()
	self._super_syndrome_time.next_t = t + self._super_syndrome_time.remaining
	self._super_syndrome_time.remaining = nil
end

function PlayerManager:_stop_hostage_time()
	self._super_syndrome_time.remaining = nil
	self._super_syndrome_time.next_t = nil
	self._super_syndrome_time.active = false
end

function PlayerManager:_chk_hostage_count()
	local num_hostages = managers.groupai:state():hostage_count()
	local num_minions = managers.groupai:state():get_amount_enemies_converted_to_criminals()
	local count = num_hostages + num_minions
	self._all_hostages_count = count

	return self._all_hostages_count
end

function PlayerManager:on_hostages_count_changed()
	self:_chk_hostage_count()
	self:_upd_hostage_time()
end

function PlayerManager:_upd_hostage_time()
	if not self:has_category_upgrade("player", "super_syndrome") then
		return
	end
	if self._super_syndrome_count == 0 then
		if self:_chk_hostage_count() > 0 then
			if self._super_syndrome_time.active == false then
				if self._super_syndrome_time.remaining then
					self:_resume_hostage_time()
				else
					self:_start_hostage_time()
				end
				self._super_syndrome_time.active = true
			end
		elseif self:_chk_hostage_count() <= 0 then
			if self._super_syndrome_time.active == true then
				self:_pause_hostage_time()
				self._super_syndrome_time.active = false
			end
		end
	end
end

function PlayerManager:enable_cooldown_upgrade(category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return
	end

	local time = upgrade_value[2]
	self._global.cooldown_upgrades[category] = self._global.cooldown_upgrades[category] or {}
	self._global.cooldown_upgrades[category][upgrade] = {
		cooldown_time = math.max(0, Application:time() - time)
	}
end

function PlayerManager:enable_cooldown_upgrade_time(category, upgrade, time)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return
	end

	local time = time
	local cd = self._global.cooldown_upgrades[category][upgrade].cooldown_time
	self._global.cooldown_upgrades[category] = self._global.cooldown_upgrades[category] or {}
	self._global.cooldown_upgrades[category][upgrade] = {
		cooldown_time = math.max(0, math.min(cd, cd - time))
	}
	
end

function PlayerManager:_on_recharge_super_syndrome_event()
	if self:has_category_upgrade("player", "super_syndrome") and self._super_syndrome_count == 0 then
		local val = self:upgrade_value("player", "replenish_super_syndrome_chance") + self._super_syndrome_recharge_chance
		if math.random() <= val then
			self._super_syndrome_count = self:upgrade_value("player", "super_syndrome")
			self._super_syndrome_recharge_chance = 0
			log("Super_Syndrome = "..self._super_syndrome_count)
			managers.chat:_receive_message(1, managers.localization:text("StockholmSyndrome"), managers.localization:text("StockholmSyndrome_Doc_Info"), Color.blue) 
		else
			self._super_syndrome_recharge_chance = self._super_syndrome_recharge_chance + 0.1
		end
	end
end

function PlayerManager:_on_hostages_recharge_super_syndrome_event()
	if self:has_category_upgrade("player", "super_syndrome") and self._super_syndrome_count == 0 then
		local val = self:upgrade_value("player", "hostage_replenish_super_syndrome_chance") + self._super_syndrome_recharge_chance
		if math.random() <= val then
			self._super_syndrome_count = self:upgrade_value("player", "super_syndrome")
			self._super_syndrome_recharge_chance = 0
			log("Super_Syndrome = "..self._super_syndrome_count)
			managers.chat:_receive_message(1, managers.localization:text("StockholmSyndrome"), managers.localization:text("StockholmSyndrome_Hos_Info"), Color.blue) 
		else
			self._super_syndrome_recharge_chance = self._super_syndrome_recharge_chance + (math.random(1,10) * 0.01)
		end
	end
end

function PlayerManager:_attempt_pocket_ecm_jammer()
	local player_inventory = self:player_unit():inventory()
	
	--local last_dmg_time = self._h4x0r._last_dmg_t
	
	if player_inventory:is_jammer_active() then
		return false
	end

	local in_stealth = managers.groupai and managers.groupai:state():whisper_mode()

	if in_stealth then
		player_inventory:start_jammer_effect()
	else
		player_inventory:start_feedback_effect()
	end

	local base_upgrade = self:upgrade_value("player", "pocket_ecm_jammer_base")

	local function speed_up_on_kill(equipped_unit, variant, killed_unit)
		if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
			return
		end
		local unit_dmg = killed_unit:character_damage()
		local unit_max_health = unit_dmg._HEALTH_INIT
		local hp = unit_max_health --CopDamage._get_health_init(killed_unit) --tweak_data.character[killed_unit:base()._tweak_table].HEALTH_INIT or 0
		local inc = math.min(math.round(hp/60, 0.1), 6)
		local cd = base_upgrade.cooldown_drain
		local value = nil
		if in_stealth then
			if player_inventory:is_jammer_active() then
				if inc >= cd * 0.5 then
					value = 3
				else
					value = math.random(cd*0.5)
				end
			else
				if inc >= cd then
					value = cd
				else
					value = math.round(inc) == 0 and math.random(cd) or math.random(math.round(inc), cd)
				end
			end
		else
			if player_inventory:is_jammer_active() then
				if inc >= cd then
					value = 6
				else
					value = math.round(inc) == 0 and math.random(cd) or math.random(math.round(inc), cd)
				end
			else
				value = math.round(inc) == 0 and cd or math.min(math.random(cd, cd + math.round(inc)), cd*2)
			end
		end
		--local value = player_inventory:is_jammer_active() and math.random(2, base_upgrade.cooldown_drain + inc) or base_upgrade.cooldown_drain + math.min(inc, 3)
		--local value = in_stealth and player_inventory:is_jammer_active() and cd * 0.5 + math.min(inc, 3) or in_stealth and not player_inventory:is_jammer_active() and cd + math.min(inc, 3) or not in_stealth and player_inventory:is_jammer_active() and math.clamp(math.random(cd) + inc, 2, 10) or math.min(cd + inc, 12)
		--log("Inc = "..tostring(inc).."\n Value = "..tostring(value))
		if type(value) == "number" and value > 0 then
			managers.player:speed_up_grenade_cooldown(value)
		end
	end
	
	--[[local function speed_up_on_damage(attack_data)
		local t = TimerManager:game():time()
		local is_jammer_on = player_inventory:is_jammer_active()
		if (attack_data.variant == "bullet" or attack_data.variant == "melee") and not last_dmg_time then
			last_dmg_time = is_jammer_on and t + 2 or t + (math.max(7 - attack_data.damage, 2))
			
			local value = player_inventory:is_jammer_active() and math.random(base_upgrade.cooldown_drain + 1, base_upgrade.cooldown_drain + 1) - 0.5 or base_upgrade.cooldown_drain * 2
			managers.player:speed_up_grenade_cooldown(value)
		end
	end]]

	self:register_message(Message.OnEnemyKilled, "speed_up_pocket_ecm_jammer", speed_up_on_kill)
	--self:register_message(Message.OnPlayerDamage, "speed_up_pocket_ecm_jammerd", speed_up_on_damage)
	
	managers.hud:activate_teammate_ability_radial(HUDManager.PLAYER_PANEL, base_upgrade.duration)

	return true
end

function PlayerManager:_pocket_ecm_jammer_speed_up_on_stealth()
	local player = self:local_player()
	if not alive(player) or not player then
		return
	end

	local player_inventory = self:player_unit():inventory()
	if player_inventory:is_jammer_active() then
		return
	end

	local t = TimerManager:game():time()

	local skill = self:has_category_upgrade("player", "pocket_stealth")
	if not skill then return end
	local data = self:upgrade_value("player", "pocket_stealth")

	if not next_t then
		managers.player:speed_up_grenade_cooldown(data.inc)
		self._h4x0r._next_tick = t + data.tick
	end
end

function PlayerManager:_no_ammo_cost_mk2(weapon_unit)
	if not alive(weapon_unit) then
		return
	end
	local player = self:local_player()
	if not alive(player) then
		return
	end
	local t = TimerManager:game():time()
	local weapon = self:equipped_weapon_unit()
	if weapon_unit ~= weapon then
		return
	end
	if self._no_ammo_cost_mk2_delay then return end
	local data = self:upgrade_value("player", "no_ammo_cost_mk2")
	local pass = 0
	local chk_delay = 0
	local ammo_found = AmmoBagBase.GetAmmoBag(managers.player:local_player():position())

	if self:has_category_upgrade("player", "no_ammo_cost_mk2") and not self:has_active_temporary_property("bullet_storm") and ammo_found then
		pass = data.chance + self._no_ammo_cost_mk2_inc
		local succeed = pass > math.random()
		--log("no ammo cost mk2 : "..pass.." is succeed = "..tostring(succeed))
		if succeed then
			local extra = self:has_category_upgrade("player", "no_ammo_cost_mk2_extra", 0) and self:upgrade_value("player", "no_ammo_cost_mk2_extra", 0) or 0
			extra = math.random(extra)
			chk_delay = data.duration + extra
			self._no_ammo_cost_mk2_delay = t + chk_delay + data.delay
			self._no_ammo_cost_mk2_inc = 0
			managers.player:add_to_temporary_property("bullet_storm", chk_delay, 1)
		else
			chk_delay = math.random(data.delay * 0.5, data.delay_inactive)
			self._no_ammo_cost_mk2_delay = t + (chk_delay * 0.1)
			self._no_ammo_cost_mk2_inc = self._no_ammo_cost_mk2_inc + (math.random(data.inc)*0.01)
		end
	end
end
--[[
function PlayerManager:_crowd_control_mk2(weapon_unit)
	if not alive(weapon_unit) then
		return
	end
	local player = self:local_player()
	if not alive(player) then
		return
	end
	local weapon = self:equipped_weapon_unit()
	if weapon_unit ~= weapon then
		return
	end
	local t = TimerManager:game():time()
	local has_skill = self:has_category_upgrade("player", "crowd_control_mk2")
	local data = has_skill and self:upgrade_value("player", "crowd_control_mk2")
	local stats = self._crowd_control
	local pass = 0
	
	if stats.delay_t then
		return
	end
	
	local has_active = stats.active_t and t < stats.active_t
	local max_trig = stats.inactive_trg and stats.inactive_trg >= 3
	
	if not max_trig or has_active then
		pass = pass + data.base + stats.value
		if pass or has_active then
			self:_on_crowd_ctrl_mk2_trg(t, player, weapon, data, stats)
			stats.value = 0
			return
		end
	end
	
	stats.value = stats.value + (data.increment * 0.01)
	stats.inactive_trg = stats.inactive_trg + 1
	stats.inactive_t = t + 1

end

function PlayerManager:_on_crowd_ctrl_mk2_trg(t, player, weapon, data, stats)
	local can_trigger = stats.trigger < data.trigger_max
	if stats.active_t then
		if not can_trigger then
			stats.trigger = 0
			stats.active_t = nil
			return
		end
	else
		stats.active_t = t + data.active_t
	end
	local slotmask = managers.slot:get_mask("trip_mine_targets")
	local stealth_state = managers.groupai:state():whisper_mode()
	local units = World:find_units_quick("sphere", player:movement():m_pos(), data.radius, slotmask)
	for e_key, unit_key in pairs(units) do
		if alive(unit_key) and unit_key:character_damage() and not unit_key:character_damage():dead() then
			local is_civ = CopDamage.is_civilian(unit_key:base()._tweak_table)
			local is_converted = unit_key:brain() and unit_key:brain()._logic_data and unit_key:brain()._logic_data.is_converted
			local is_enggage = unit_key:brain() and unit_key:brain():is_hostile() 
			local unit_mov = unit_key:movement()
			local unit_enggage = unit_mov and not unit_mov:cool()
			local unit_hostile = unit_mov and unit_mov:stance_name() == "hos"
			local unit_cbt = unit_mov and unit_mov:stance_name() == "cbt"
			local unit_dmg = unit_key:character_damage()
			if is_civ and (unit_enggage or unit_hostile) then
				unit_key:brain():on_intimidated(math.random(5), player)
			end
			if not is_civ and not is_converted and is_enggage and unit_enggage and (unit_hostile or unit_cbt) then
				local action_data2 = {
					variant = 0,
					damage = stealth_state and math.random(10) * 0.1 or 1 * math.min((math.floor(math.random()*100)/100)+0.1,1),
					damage_effect = 2,
					attacker_unit = player,
					weapon_unit = weapon,
					col_ray = { body = unit_key:body("body"), position = unit_key:position() + math.UP * 100},
					attack_dir = player:movement():m_head_rot():y()
				}
				if unit_dmg then
					unit_dmg:damage_melee(action_data2)
				end
				if stealth_state then
					unit_key:brain():on_intimidated(100, player)
				else
					unit_dmg:build_suppression(250, 1)
				end
			end
		end
	end
	
	if not stealth_state then
		stats.delay = true
	end
	stats.trigger = stats.trigger + 1
	log("Crowd control = "..tostring(stats.trigger))
end
]]

function PlayerManager:AOE_intimidate(prime_target)
	local player = self:local_player()
	if not alive(player) then
		return
	end
	local stealth_state = managers.groupai:state():whisper_mode()
	local slotmask = managers.slot:get_mask("trip_mine_targets")
	--[[local _AOE_check = function(_c_data, _pos, prime_target)
		if _c_data and _c_data.unit and alive(_c_data.unit) and mvector3.distance(_pos, _c_data.unit:position()) <= 350 and prime_target.unit ~= _c_data.unit then
			return true
		end
		return false
	end]]
	self._affected_enemy_unit = self._affected_enemy_unit or {}
	local units = World:find_units_quick("sphere", player:movement():m_pos(), 450, slotmask)
	for c_key, c_data in pairs(units) do
		if not table.contains(self._affected_enemy_unit, c_data) and c_data:key() ~= prime_target.unit:key() then
			table.insert(self._affected_enemy_unit, c_data)
		end
	end
	if stealth_state then
		local unitss = World:find_units_quick("sphere", prime_target.unit:position(), 350, slotmask)
		for c_key, c_data in pairs(unitss) do
			if not table.contains(self._affected_enemy_unit, c_data) and c_data:key() ~= prime_target.unit:key() then
				table.insert(self._affected_enemy_unit, c_data)
			end
		end
		for e_key, unit_key in pairs(self._affected_enemy_unit) do
			if alive(unit_key) and unit_key:character_damage() and not unit_key:character_damage():dead() then
				local is_civ = CopDamage.is_civilian(unit_key:base()._tweak_table)
				local is_converted = unit_key:brain() and unit_key:brain()._logic_data and unit_key:brain()._logic_data.is_converted
				local is_enggage = unit_key:brain() and unit_key:brain():is_hostile() 
				local unit_mov = unit_key:movement()
				local unit_enggage = unit_mov and not unit_mov:cool()
				local unit_hostile = unit_mov and unit_mov:stance_name() == "hos"
				local unit_cbt = unit_mov and unit_mov:stance_name() == "cbt"
				local unit_dmg = unit_key:character_damage()
				if is_civ and (unit_enggage or unit_hostile) then
					unit_key:brain():on_intimidated(math.random(5), player)
				end
				if not is_civ and not is_converted and is_enggage and unit_enggage and (unit_hostile or unit_cbt) then
					local action_data = {
						variant = 0,
						damage = math.random(10) * 0.1,
						damage_effect = damage * 2,
						attacker_unit = player,
						weapon_unit = player:inventory():equipped_unit(),
						col_ray = { body = unit_key:body("body"), position = unit_key:position() + math.UP * 100},
						attack_dir = player:movement():m_head_rot():y()
					}
					if unit_dmg then
						unit_dmg:damage_melee(action_data)
					end
					unit_key:brain():on_intimidated(100, player)
				end
			end
		end
	end
	if not stealth_state then
		for e_key, unit_key in pairs(self._affected_enemy_unit) do
			if alive(unit_key) and unit_key:character_damage() and not unit_key:character_damage():dead() then
				local is_civ = CopDamage.is_civilian(unit_key:base()._tweak_table)
				local is_converted = unit_key:brain() and unit_key:brain()._logic_data and unit_key:brain()._logic_data.is_converted
				local is_enggage = unit_key:brain() and unit_key:brain():is_hostile() 
				local unit_mov = unit_key:movement()
				local unit_enggage = unit_mov and not unit_mov:cool()
				local unit_hostile = unit_mov and unit_mov:stance_name() == "hos"
				local unit_cbt = unit_mov and unit_mov:stance_name() == "cbt"
				local unit_dmg = unit_key:character_damage()
				if is_civ and (unit_enggage or unit_hostile) then
					unit_key:brain():on_intimidated(math.random(5), player)
				end
			end
		end
		if self._AOE_int_chance_t < math.random() then
			self._AOE_int_chance_t = self._AOE_int_chance_t + (math.random(20) * 0.01)
		else
			self._AOE_int_chance_t = 0.2
			for e_key, unit_key in pairs(self._affected_enemy_unit) do
				if alive(unit_key) and unit_key:character_damage() and not unit_key:character_damage():dead() then
					local is_civ = CopDamage.is_civilian(unit_key:base()._tweak_table)
					local is_converted = unit_key:brain() and unit_key:brain()._logic_data and unit_key:brain()._logic_data.is_converted
					local is_enggage = unit_key:brain() and unit_key:brain():is_hostile() 
					local unit_mov = unit_key:movement()
					local unit_enggage = unit_mov and not unit_mov:cool()
					local unit_hostile = unit_mov and unit_mov:stance_name() == "hos"
					local unit_cbt = unit_mov and unit_mov:stance_name() == "cbt"
					local unit_dmg = unit_key:character_damage()
					if not is_civ and not is_converted and is_enggage and unit_enggage and (unit_hostile or unit_cbt) then
						managers.fire:add_doted_enemy( unit_key , self:player_timer():time() , self:player_unit():inventory():equipped_unit() , math.random(2, 7) , 1, self:player_unit(), false )
					end
				end
			end
		end
		log("Chances = "..tostring(self._AOE_int_chance_t))
	end					
	self._affected_enemy_unit = nil
end

function PlayerManager:_on_enemy_killed_melee_regen_armor(equipped_unit, variant, killed_unit)
	local player_unit = self:player_unit()
	if not player_unit then
		return
	end

	local t = Application:time()
	local damage_ext = player_unit:character_damage()

	if variant == "melee" then
		if damage_ext and not self._melee_kill_regen_armor_t then
			damage_ext:restore_armor(2)
			self._melee_kill_regen_armor_t = t + 1
		end
	end
end

function PlayerManager:_on_enemy_killed_reduce_long_dis_cd()
	local player = self:local_player()
	if not alive(player) then
		return
	end
	local cd = managers.player:has_disabled_cooldown_upgrade("cooldown", "long_dis_revive")
	if not cd then
		return
	end
	local data = self._inspire_reduce
	local can_reduce = false
	local t = TimerManager:game():time()
	if data.delay_t then
		can_reduce = math.max(0, data.delay_t - t) <= 0 and true or false
	end
	if not can_reduce then
		return
	end
	self:enable_cooldown_upgrade_time("cooldown", "long_dis_revive", 1)
	self._inspire_reduce.delay_t = self._inspire_reduce.delay_t + 1
end

function PlayerManager:_on_enemy_medic_killed_heal_chance(equipped_unit, variant, killed_unit)
	local player = self:local_player()
	if not alive(player) then
		return
	end
	local player_dmg = player:character_damage()
	if managers.platform:presence() == "Playing" and (player_dmg:arrested() or player_dmg:incapacitated() or player_dmg:is_downed() or player_dmg:need_revive()) then
		return
	end
	local is_medic = killed_unit:base():has_tag("medic")
	if not is_medic then
		return
	end
	local data = self._dkh
	local activate = false
	local t = TimerManager:game():time()
	if data.delay_t then
		activate = math.max(0, data.delay_t - t) <= 0 and true or false
	end
	if not activate then
		return
	end
	player_dmg:_medic_heal()
	self._dkh.delay_t = self._dkh.delay_t + 1
end

function PlayerManager:_on_sure_keep_firing(weapon_unit)
	if not alive(weapon_unit) then
		return
	end
	local player = self:local_player()
	if not alive(player) then
		return
	end
	local weapon = self:equipped_weapon_unit()
	local weap_base = weapon:base()
	if weapon_unit ~= weapon then
		return
	end
	local data = self._surefire
	local is_active = data.activated
	if managers.player:has_active_temporary_property("bullet_storm") or managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier") then
		return
	end
	if weap_base:fire_mode() ~= "auto" or weap_base:is_category("bow") then
		if is_active then
			data.activated = false
		end
		return
	end
	local t = TimerManager:game():time()
	local skills = self:upgrade_value("player", "sure_fire_mk2")
	local out_ammo = weap_base:out_of_ammo()
	local clip_empty = weap_base:clip_empty()
	local ammo_in_clip = weap_base:get_ammo_remaining_in_clip()
	local max_per_clip = weap_base:get_ammo_max_per_clip()
	local ammo_is_full = ammo_in_clip == max_per_clip
	local last_bullet = ammo_in_clip == 1
	local is_more_clip = ammo_in_clip > 1
	local delay = data.delay_t
	local is_delay = data.delay_t and data.delay_t > t
	local is_active_t = data.active_t and data.active_t > t
	
	if is_active and (out_of_ammo or clip_empty or ammo_is_full or not is_active_t) then
		data.activated = false
	end
	if is_active and last_bullet and not out_ammo and not clip_empty and is_active_t then
		weap_base:on_reload()
	end
	
	if is_more_clip and not is_active and not is_delay and not is_active_t then
		local chance = skills.base
		chance = chance + data.value
		local succeed = chance >= math.random()
		if succeed then
			data.activated = true
			data.active_t = t + 4
			data.value = 0
		else
			local add = 0
			add = add + ((math.random(skills.increment, skills.increment_max) * 0.01) + 1)
			add = (add / max_per_clip) * (math.random(10)*0.1)
			add = math.min(add, 1/max_per_clip)
			data.value = data.value + add
			--log("increment sure fire")
		end
		data.delay_t = t + 1.25
	end
	
	if delay then
		--log("max trigger per time")
		if data.delay_t < t then
			data.delay_t = nil
		end
	end
end

function PlayerManager:_on_try_add_pickup()
	local has_skill = self:has_category_upgrade("player", "add_pickup_ammo")
	local player = self:local_player()

	if not has_skill then return end
	if not alive(player) or not player then
		return
	end

	local data = self:upgrade_value("player", "add_pickup_ammo", nil)

	local any_special = false

	for id, weapon in pairs(player:inventory():available_selections()) do
		if type(weapon) == "table" and weapon.unit and not weapon.unit:base():ammo_full() and weapon.unit:base()._ammo_pickup[2] == 0 then
			any_special = true
			break
		end
	end

	local random = math.random()
	if random < self._add_pickup_ammo_chance then
		for id, weapon in pairs(player:inventory():available_selections()) do
			local weapon_base = weapon.unit:base()
			if not weapon_base:ammo_full() and weapon_base._ammo_pickup[2] == 0 then
				if not table.contains(tweak_data.weapon[weapon_base._name_id].categories, "saw") then
					weapon_base:add_ammo_to_pool(1, id)
				else
					weapon_base:add_ammo_to_pool(50, id)
				end
			end
		end
		self._add_pickup_ammo_chance = 0
	else
		self._add_pickup_ammo_chance = self._add_pickup_ammo_chance + data.inc
	end

end

--[[function PlayerManager:_on_try_lucky_mag()
	local has_skill_base = self:has_category_upgrade("player", "lucky_mag")
	local has_skill_special = self:has_category_upgrade("player", "lucky_mag_special")
	local has_skill_specials = self:has_category_upgrade("player", "lucky_mag_special_plus")
	local has_skill_saw = self:has_category_upgrade("player", "lucky_mag_saw")
	local player = self:local_player()
	
	if not has_skill_base then return end
	if not alive(player) or not player then
		return
	end

	local data = self:upgrade_value("player", "lucky_mag", nil)

	local equipped_unit = self:get_current_state()._equipped_unit:base()
	local ammo = equipped_unit and equipped_unit:get_ammo_max_per_clip()
	local ammo_full = equipped_unit and equipped_unit:ammo_full()
	local index = equipped_unit and self:equipped_weapon_index()
	if not equipped_unit then return end
	local is_saw = table.contains(tweak_data.weapon[equipped_unit._name_id].categories, "saw")
	local is_special = equipped_unit._ammo_pickup[2] == 0 and not is_saw
	local is_regular = not is_saw and not is_special

	if ammo_full then return end

	local base_chance = data.base
	local chance = 0
	chance = not self._full_mag_has_success and chance + base_chance + self._full_mag_inc or 1
	
	local random = math.random()
	if is_special and has_skill_special or is_saw and has_skill_saw or is_regular then
		if random < chance then
			local add = is_regular and ammo * 0.3 or is_saw and 50 or is_special and ammo > 1 and math.round(math.random(ammo * 10)*0.1) or is_special and ammo == 1 and 1
			add = add - math.floor(add) >= 0.5 and math.floor(add) > 0 and math.ceil(add) or math.floor(add) > 0 and math.floor(add) or 1
			add = is_special and has_skill_specials and ammo > 1 and add < ammo * 0.5 and add + 1 or add
			equipped_unit:add_ammo_to_pool(add, index)
			self._full_mag_inc = 0
		else
			self._full_mag_inc = self._full_mag_inc + data.inc
		end
	end
end]]

function PlayerManager:_find_drill()
	local player = self:local_player() or self._unit
	local t = TimerManager:game():time()
	local skill = self:upgrade_value("player", "drill_resume")
	
	if self._drill_resume_on_kill._kill_t then
		return
	else
		self._drill_resume_on_kill._kill_t = t + skill.kill_t
	end
	
	local get_drill = self:find_drill(player)
	
	if not get_drill then 
		self:delete_drill()
		return 
	end
	
	local data = self._drill_resume_on_kill
	
	if data.delay_t and data.delay_t > t then 
		self:delete_drill() 
		return 
	end
	
	local chance = 0
	chance = chance + skill.base + data.chance
	if chance > math.random() and not data.activated then
		data.activated = true
		data.chance = 0
	else
		data.chance = data.chance + skill.inc
	end
	
	if not data.activated then 
		self:delete_drill()
		return 
	end
	
	for id, hit_unit in ipairs(self._drill_jammed_resume) do
		local hit_dir = player:position() - hit_unit:position()
		local distance = mvector3.normalize(hit_dir)
		if distance < 301 and hit_unit:interaction() and hit_unit:interaction().tweak_data and table.contains(self._interact_jammed, hit_unit:interaction().tweak_data) then
			hit_unit:interaction():interact(player)
			table.remove(self._drill_jammed_resume, id)
			data._repaired = true
			log("drill_repaired")
		end
	end
	
	if data._repaired then
		data.delay_t = t + skill.cooldown
	end
	
	self:delete_drill()
	
end

function PlayerManager:find_drill(player)
	local user = self:local_player() or player
	local units = World:find_units("sphere", user:position(), 300, managers.slot:get_mask("bullet_impact_targets"))
	local result = false
	for id, drill_unit in pairs(units) do
		if Drill:is_drill_saw(drill_unit) then
			self._drill_jammed_resume = self._drill_jammed_resume or {}
			table.insert(self._drill_jammed_resume, drill_unit)
			result = true
			--log("drill_found")
			break
		end
	end
	return result
end

function PlayerManager:delete_drill()
	if not self._drill_jammed_resume or next(self._drill_jammed_resume) == nil then
		return
	end
	for id, drill_unit in ipairs(self._drill_jammed_resume) do
		table.remove(self._drill_jammed_resume, id)
	end
end

function PlayerManager:spawn_smoke_screen(position, normal, grenade_unit, has_dodge_bonus)
	local add = self:has_category_upgrade("player", "smoke_screen_timer") and self:upgrade_value("player", "smoke_screen_timer") or 0
	local time = tweak_data.projectiles.smoke_screen_grenade.duration
	time = time + add
	
	self._smoke_screen_effects = self._smoke_screen_effects or {}

	table.insert(self._smoke_screen_effects, SmokeScreenEffect:new(position, normal, time, has_dodge_bonus, grenade_unit))

	if alive(self._smoke_grenade) then
		self._smoke_grenade:set_slot(0)
	end

	self._smoke_grenade = grenade_unit
end

function PlayerManager:_attempt_chico_injector()
	if self:has_activate_temporary_upgrade("temporary", "chico_injector") then
		return false
	end

	local duration = self:upgrade_value("temporary", "chico_injector")[2]
	local now = managers.game_play_central:get_heist_timer()
	local player = self:local_peer()
	local data = self._chico
	local full_hp = player:character_damage():_max_health()
	local twothird_hp = full_hp * data._twothird
	local onethird_hp = full_hp * data._onethird

	managers.network:session():send_to_peers("sync_ability_hud", now + duration, duration)
	self:activate_temporary_upgrade("temporary", "chico_injector")

	local function speed_up_on_kill()
		local value = 0
		if player:character_damage():get_real_health() > twothird_hp then
			value = value + 1
		elseif player:character_damage():get_real_health() > onethird_hp and player:character_damage():get_real_health() <= twothird_hp then
			value = value + 2
			log("2/3 health")
		else
			value = value + math.random(2, 6)
			log("1/3 health")
		end
		managers.player:speed_up_grenade_cooldown(value or 1)
	end

	self:register_message(Message.OnEnemyKilled, "speed_up_chico_injector", speed_up_on_kill)

	return true
end

function PlayerManager:on_enter_custody(_player, already_dead)
	local player = _player or self:player_unit()

	if not player then
		Application:error("[PlayerManager:on_enter_custody] Unable to get player")

		return
	end

	if player == self:player_unit() then
		local equipped_grenade = managers.blackmarket:equipped_grenade()

		if equipped_grenade and tweak_data.blackmarket.projectiles[equipped_grenade] and tweak_data.blackmarket.projectiles[equipped_grenade].ability then
			self:reset_ability_hud()
		end
	end
	
	if player == self:local_player() then
		if self:has_category_upgrade("player", "maniac_ictb") then
			player:character_damage():_reset_ictb("_maniac")
		end
		if self:has_category_upgrade("player", "vice_prez") then
			player:character_damage():_reset_ictb("_biker")
		end
		if self:has_category_upgrade("player", "replenish_super_syndrome_chance") or self:has_category_upgrade("player", "hostage_replenish_super_syndrome_chance") then
			self:_stop_hostage_time()
			self._super_syndrome_recharge_chance = 0
		end
	end

	managers.mission:call_global_event("player_in_custody")

	local peer_id = managers.network:session():local_peer():id()

	if self._super_syndrome_count and self._super_syndrome_count > 0 and not self._action_mgr:is_running("stockholm_syndrome_trade") then
		self._action_mgr:add_action("stockholm_syndrome_trade", StockholmSyndromeTradeAction:new(player:position(), peer_id))
	end

	self:force_drop_carry()
	managers.statistics:downed({
		death = true
	})

	if not already_dead then
		player:network():send("sync_player_movement_state", "dead", player:character_damage():down_time(), player:id())
		managers.groupai:state():on_player_criminal_death(peer_id)
	end

	self._listener_holder:call(self._custody_state, player)
	game_state_machine:change_state_by_name("ingame_waiting_for_respawn")
	player:character_damage():set_invulnerable(true)
	player:character_damage():set_health(0)
	player:base():_unregister()
	World:delete_unit(player)
	managers.hud:remove_interact()
end

function PlayerManager:_get_local_cocaine_stack()
	local local_peer_id = managers.network:session() and managers.network:session():local_peer():id()

	if not local_peer_id or not self:has_category_upgrade("player", "cocaine_stacking") then
		return
	end

	local cocaine_stack = self:get_synced_cocaine_stacks(local_peer_id)
	local amount = cocaine_stack and cocaine_stack.amount or 0
	
	return amount
end

function PlayerManager:_is_in_my_smoke()
	if not self._smoke_screen_effects then
		return false
	end
	for _, smoke_screen in ipairs(self._smoke_screen_effects or {}) do
		if smoke_screen:is_in_smoke(self:player_unit() or self:local_player()) then
			if smoke_screen:mine() then
				return true
			end
		end
	end
	return false
end

function PlayerManager:_jammer_crewd(set)
	if not set and type(set) == "nil" then
		return self._h4x0r._is_jammer_active
	end
	if set and type(set) == "boolean" then
		self._h4x0r._is_jammer_active = set
	end
end

function PlayerManager:_jammmer_crowd_ctrl()
	local player = self:local_player()
	if not alive(player) or not player then
		return
	end
	
	local player_inventory = self:player_unit():inventory()
	if not player_inventory:is_jammer_active() then
		return
	end
	local t = TimerManager:game():time()
	
	local stats = self._h4x0r
	--[[local is_active = stats._is_jammer_active
	
	if not is_active then return end]]
	
	local skill = self:has_category_upgrade("player", "pocket_crewd")
	if not skill then return end
	local data = self:upgrade_value("player", "pocket_crewd")
	local next_t = stats._next_tick
	
	if not next_t then
		local slotmask = managers.slot:get_mask("trip_mine_targets")
		local units = World:find_units_quick("sphere", player:movement():m_pos(), data.radius, slotmask)
	
		for e_key, unit_key in pairs(units) do
			if alive(unit_key) and unit_key:character_damage() and not unit_key:character_damage():dead() then
				local is_civ = CopDamage.is_civilian(unit_key:base()._tweak_table)
				local is_converted = unit_key:brain() and unit_key:brain()._logic_data and unit_key:brain()._logic_data.is_converted
				local is_enggage = unit_key:brain() and unit_key:brain():is_hostile() 
				local unit_mov = unit_key:movement()
				local unit_enggage = unit_mov and not unit_mov:cool()
				local unit_hostile = unit_mov and unit_mov:stance_name() == "hos"
				local unit_cbt = unit_mov and unit_mov:stance_name() == "cbt"
				--if is_civ and (unit_enggage or unit_hostile) then
				if not is_civ and not is_converted and is_enggage and unit_enggage and (unit_hostile or unit_cbt) then
					--unit_key:brain():on_intimidated(1, player)
					unit_key:brain():on_intimidated(100, player)
					log("active")
				end
			end
		end
		
		next_t = t + data.tick
	end
end

function PlayerManager:_taser_mal_incr(set)
	if set and type(set) == "number" then
		self._taser_mk2.increment = set == 0 and set or self._taser_mk2.increment + set
	else
		return self._taser_mk2.increment
	end
end

function PlayerManager:_taser_mal_incr_cd(set)
	if set and type(set) == "number" then
		self._taser_mk2.cd_time = set
	else
		return self._taser_mk2.cd_time
	end
end

function PlayerManager:_sentry_lives(set)
	if set and type(set) == "number" then
		self._sentry_data._lives = set == 0 and set or math.max(self._sentry_data._lives - set, 0)
	else
		--log(tostring(self._sentry_data._lives))
		return self._sentry_data._lives
	end
end

function PlayerManager:_has_sentry_lives()
	return self:_sentry_lives() > 0 and true or false
end

--[[function PlayerManager:_sentry_repair(set)
	if set and type(set) == "number" then
		self._sentry_data._repair = set == 0 and set or math.max(self._sentry_data._repair - set, 0)
	else
		return self._sentry_data._repair
	end
end

function PlayerManager:_has_sentry_lives()
	local count = self:_sentry_repair()
	local result = count > 0 and true or false
	return result
end]]

function PlayerManager:_s_roll_restore_chance()
	local chance = self._sentry_data._kill_chance
	local skill = self:upgrade_value("sentry_gun", "kill_restore_ammo_chance")
	local base = skill.chance
	local value = base + chance --+ 100
	local result = false
	if math.random() < value then
		self._sentry_data._kill_chance = 0
		result = true
	else
		self._sentry_data._kill_chance = self._sentry_data._kill_chance + (math.random(skill.inc) * 0.01)
	end
	return result
end

function PlayerManager:_s_kill_restore_chance_cd()
	local t = TimerManager:game():time()
	local skill = self:upgrade_value("sentry_gun", "kill_restore_ammo_chance")
	self._sentry_data._kill_chance_cd = t + skill.interval
end

function PlayerManager:_s_kill_restore_chance_is_cd()
	return self._sentry_data._kill_chance_cd 
end

function PlayerManager:send_log(log)
	local log = log
	log = type(log)=="number" and tonumber(log) or tostring(log)
	log("Log = "..tonumber(log))
end

function PlayerManager:interact_bp(value)
	if value and type(value)=="number" then
		self._interact_bypass = value > 0 and true or false
	else
		return self._interact_bypass
	end
end

local orig_pm_remove_equipment = PlayerManager.remove_equipment

function PlayerManager:remove_equipment(equipment_id, slot)
	if self._interact_bypass then
		return
	else
		return orig_pm_remove_equipment(self, equipment_id, slot)
	end
end

