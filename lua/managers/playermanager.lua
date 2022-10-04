Hooks:PreHook(PlayerManager, "init", "RaID_PlayerManager_Init", function(self, ...)
	self._has_bulletstorm = 0
	self._has_set_active_bs = nil
	self._fully_loaded_reserv = 0
	--[[
	self._ninja_gone = {
		uncovered = false,
		active_t = nil,
		cooldown = nil
	}
	]]
end)

Hooks:PreHook(PlayerManager, "_add_equipment", "RaID_PlayerManager__add_equipment", function(self, params)
	if params and type(params.slot) == "number" and params.slot == 2 then
		if self:has_category_upgrade("player", "second_deployable_mul") then
			self:_ace_add_equipment(params)
		end
	end
end)

Hooks:PostHook(PlayerManager, "update", "RaID_PlayerManager_Update", function(self, t, dt)

	if self._unseen_strike and not self._coroutine_mgr:is_running(PlayerAction.UnseenStrike) and managers.platform:presence() == "Playing" then
		local data = self:upgrade_value("player", "unseen_increased_crit_chance", 0)

		if data ~= 0 then
			self._coroutine_mgr:add_coroutine(PlayerAction.UnseenStrike, PlayerAction.UnseenStrike, self, data.min_time, data.max_duration, data.crit_chance)
		end
	end
	
	if self._hostage_fired_t then
		if self._hostage_fired_t < t then
			self._hostage_fired_t = 0 or nil
		end
	end
	--[[if self._ninja_gone.uncovered and not self._coroutine_mgr:is_running(PlayerAction.NinjaGone) and managers.platform:presence() == "Playing" then
		local key_press = self:player_unit():base():controller()
		--local interact_pressed = key_press:get_input_pressed("interact")

		self._coroutine_mgr:add_coroutine(PlayerAction.NinjaGone, PlayerAction.NinjaGone, self, managers.hud, key_press)
	end

	if self._ninja_gone.active_t and self._ninja_gone.active_t < t then
		--do update attention?
		self._ninja_gone.active_t = nil
	end

	if self._ninja_gone.cooldown and self._ninja_gone.cooldown < t then
		self._ninja_gone.cooldown = nil
	end]]
	--[[if self._has_bulletstorm or type(self._has_bulletstorm)=="number" and self._has_bulletstorm > 0 then
		if not self._has_set_active_bs then
			self._message_system:register(Message.OnPlayerReload, "bullet_storm", callback(self, self, "_on_reload_trigger_bullet_storm_event"))
			self._has_set_active_bs = true
		end
	else
		if self._has_set_active_bs then
			self._has_set_active_bs = nil
			self._message_system:unregister(Message.OnPlayerReload, "bullet_storm")
		end
	end]]
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

	if self:has_category_upgrade("player", "replenish_super_syndrome_chance") then
		self._super_syndrome_recharge_chance = 0
		self._message_system:register(Message.RevivePlayer, "replenish_super_syndrome_chance", callback(self, self, "_on_recharge_super_syndrome_event"))
	else
		self._message_system:unregister(Message.RevivePlayer, "replenish_super_syndrome_chance")
		self._super_syndrome_recharge_chance = nil
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
		local function speed_up_on_kill()
			if #managers.player:smoke_screens() == 0 then
				managers.player:speed_up_grenade_cooldown(1)
			end
		end

		self:register_message(Message.OnEnemyKilled, "speed_up_smoke_grenade", speed_up_on_kill)
	else
		self:unregister_message(Message.OnEnemyKilled, "speed_up_smoke_grenade")
	end

	self:add_coroutine("damage_control", PlayerAction.DamageControl)

	if self:has_category_upgrade("snp", "graze_damage") then
		self:register_message(Message.OnWeaponFired, "graze_damage", callback(SniperGrazeDamage, SniperGrazeDamage, "on_weapon_fired"))
	else
		self:unregister_message(Message.OnWeaponFired, "graze_damage")
	end

	if self:has_category_upgrade("player", "close_hostage_fear") then
		self._hostage_close_f = false
		self._hostage_fired_t = 0

		local function on_player_damage(attack_data)
			local close_fear_act = self:close_hostage_fear_val() and self:close_hostage_fear_val() == true
			local last_dmg_t = 0
			if not close_fear_act then
				return
			end

			local t = TimerManager:game():time()

			local attacker = attack_data.attacker_unit
			local is_alive = alive(attacker) and attacker:character_damage() and not attacker:character_damage():dead()
			local is_sentry = is_alive and attacker:base() and attacker:base().sentry_gun

			if attacker and is_alive and not is_sentry and t > last_dmg_t + 1 then
				last_dmg_t = t
				local targets = World:find_units_quick("sphere", attacker:position(), 1000, managers.slot:get_mask("enemies", "civilians"))
			
				self:on_close_hostage_feared(targets)
			end
		end

		self:register_message(Message.OnWeaponFired, "close_hostage_fear", callback(self, self, "on_close_hostage_fear_fired"))
		self:register_message(Message.OnPlayerDamage, "close_hostage_fear_damage", on_player_damage)
	else
		self._hostage_close_f = nil
		self._hostage_fired_t = nil
		self:unregister_message(Message.OnWeaponFired, "close_hostage_fear")
		self:unregister_message(Message.OnPlayerDamage, "close_hostage_fear_damage", on_player_damage)
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
end

function PlayerManager:_update_damage_dealt(t, dt)
	local local_peer_id = managers.network:session() and managers.network:session():local_peer():id()

	if not local_peer_id or not self:has_category_upgrade("player", "cocaine_stacking") then
		return
	end

	local player_unit = self:player_unit()
	local is_low = player_unit and player_unit:character_damage():get_real_health() <= player_unit:character_damage():_max_health() * 0.35

	self._damage_dealt_to_cops_t = self._damage_dealt_to_cops_t or t + (is_low and 1.2 or tweak_data.upgrades.cocaine_stacks_tick_t or 1)
	self._damage_dealt_to_cops_decay_t = self._damage_dealt_to_cops_decay_t or t + (tweak_data.upgrades.cocaine_stacks_decay_t or 5)
	local cocaine_stack = self:get_synced_cocaine_stacks(local_peer_id)
	local amount = cocaine_stack and cocaine_stack.amount or 0
	local new_amount = amount

	if self._damage_dealt_to_cops_t <= t then
		self._damage_dealt_to_cops_t = is_low and t + 1.2 or t + (tweak_data.upgrades.cocaine_stacks_tick_t or 1)
		local new_stacks = (self._damage_dealt_to_cops or 0) * (tweak_data.gui.stats_present_multiplier or 10) * self:upgrade_value("player", "cocaine_stacking", 0)
		self._damage_dealt_to_cops = 0
		new_amount = new_amount + math.min(new_stacks, tweak_data.upgrades.max_cocaine_stacks_per_tick or 20)
	end

	if self._damage_dealt_to_cops_decay_t <= t then
		self._damage_dealt_to_cops_decay_t = t + (tweak_data.upgrades.cocaine_stacks_decay_t or 5)
		local decay = amount * (tweak_data.upgrades.cocaine_stacks_decay_percentage_per_tick or 0)
		decay = decay + (tweak_data.upgrades.cocaine_stacks_decay_amount_per_tick or 20) * self:upgrade_value("player", "cocaine_stacks_decay_multiplier", 1)
		new_amount = new_amount - decay
	end

	new_amount = math.clamp(math.floor(new_amount), 0, tweak_data.upgrades.max_total_cocaine_stacks or 2047)

	if new_amount ~= amount then
		self:update_synced_cocaine_stacks_to_peers(new_amount, self:upgrade_value("player", "sync_cocaine_upgrade_level", 1), self:upgrade_level("player", "cocaine_stack_absorption_multiplier", 0))
	end
end

function PlayerManager:on_killshot(killed_unit, variant, headshot, weapon_id)
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
		return
	end

	local weapon_melee = weapon_id and tweak_data.blackmarket and tweak_data.blackmarket.melee_weapons and tweak_data.blackmarket.melee_weapons[weapon_id] and true

	if killed_unit:brain().surrendered and killed_unit:brain():surrendered() and (variant == "melee" or weapon_melee) then
		managers.custom_safehouse:award("daily_honorable")
	end

	managers.modifiers:run_func("OnPlayerManagerKillshot", player_unit, killed_unit:base()._tweak_table, variant)

	local equipped_unit = self:get_current_state()._equipped_unit
	self._num_kills = self._num_kills + 1

	if self._num_kills % self._SHOCK_AND_AWE_TARGET_KILLS == 0 and self:has_category_upgrade("player", "automatic_faster_reload") then
		self:_on_enter_shock_and_awe_event()
	end

	self._message_system:notify(Message.OnEnemyKilled, nil, equipped_unit, variant, killed_unit)

	if self._saw_panic_when_kill and variant ~= "melee" then
		local equipped_unit = self:get_current_state()._equipped_unit:base()

		if equipped_unit:is_category("saw") then
			local pos = player_unit:position()
			local skill = self:upgrade_value("saw", "panic_when_kill")

			if skill and type(skill) ~= "number" then
				local area = skill.area
				local chance = skill.chance
				local amount = skill.amount
				local enemies = World:find_units_quick("sphere", pos, area, 12, 21)

				for i, unit in ipairs(enemies) do
					if unit:character_damage() then
						unit:character_damage():build_suppression(amount, chance)
					end
				end
			end
		end
	end

	local t = Application:time()
	local damage_ext = player_unit:character_damage()

	if self:has_category_upgrade("player", "kill_change_regenerate_speed") then
		local amount = self:body_armor_value("skill_kill_change_regenerate_speed", nil, 1)
		local multiplier = self:upgrade_value("player", "kill_change_regenerate_speed", 0)

		damage_ext:change_regenerate_speed(amount * multiplier, tweak_data.upgrades.kill_change_regenerate_speed_percentage)
	end

	local gain_throwable_per_kill = managers.player:upgrade_value("team", "crew_throwable_regen", 0)

	if gain_throwable_per_kill ~= 0 then
		self._throw_regen_kills = (self._throw_regen_kills or 0) + 1

		if gain_throwable_per_kill < self._throw_regen_kills then
			managers.player:add_grenade_amount(1, true)

			self._throw_regen_kills = 0
		end
	end

	if self:has_activate_temporary_upgrade("temporary", "copr_ability") then
		local kill_life_leech = self:upgrade_value_nil("player", "copr_kill_life_leech")
		local static_damage_ratio = self:upgrade_value_nil("player", "copr_static_damage_ratio")

		if kill_life_leech and static_damage_ratio and damage_ext then
			self._copr_kill_life_leech_num = (self._copr_kill_life_leech_num or 0) + 1

			if kill_life_leech <= self._copr_kill_life_leech_num then
				self._copr_kill_life_leech_num = 0
				local current_health_ratio = damage_ext:health_ratio()
				local wanted_health_ratio = math.floor((current_health_ratio + 0.01 + static_damage_ratio) / static_damage_ratio) * static_damage_ratio
				local health_regen = wanted_health_ratio - current_health_ratio

				if health_regen > 0 then
					damage_ext:restore_health(health_regen)
					damage_ext:on_copr_killshot()
				end
			end
		end
	end

	if self._on_killshot_t and t < self._on_killshot_t then
		return
	end

	local regen_armor_bonus = self:upgrade_value("player", "killshot_regen_armor_bonus", 0)
	local dist_sq = mvector3.distance_sq(player_unit:movement():m_pos(), killed_unit:movement():m_pos())
	local close_combat_sq = tweak_data.upgrades.close_combat_distance * tweak_data.upgrades.close_combat_distance

	if dist_sq <= close_combat_sq then
		regen_armor_bonus = regen_armor_bonus + self:upgrade_value("player", "killshot_close_regen_armor_bonus", 0)
		local panic_chance = self:upgrade_value("player", "killshot_close_panic_chance", 0)
		panic_chance = managers.modifiers:modify_value("PlayerManager:GetKillshotPanicChance", panic_chance)

		if panic_chance > 0 or panic_chance == -1 then
			local slotmask = managers.slot:get_mask("enemies")
			local units = World:find_units_quick("sphere", player_unit:movement():m_pos(), tweak_data.upgrades.killshot_close_panic_range, slotmask)

			for e_key, unit in pairs(units) do
				if alive(unit) and unit:character_damage() and not unit:character_damage():dead() then
					unit:character_damage():build_suppression(0, panic_chance)
				end
			end
		end
	end

	if damage_ext and regen_armor_bonus > 0 then
		damage_ext:restore_armor(regen_armor_bonus)
	end

	local regen_health_bonus = 0

	if variant == "melee" then
		regen_health_bonus = regen_health_bonus + self:upgrade_value("player", "melee_kill_life_leech", 0)
	end

	if damage_ext and regen_health_bonus > 0 then
		damage_ext:restore_health(regen_health_bonus)
	end

	self._on_killshot_t = t + (tweak_data.upgrades.on_killshot_cooldown or 0)

	if _G.IS_VR then
		local steelsight_multiplier = equipped_unit:base():enter_steelsight_speed_multiplier()
		local stamina_percentage = (steelsight_multiplier - 1) * tweak_data.vr.steelsight_stamina_regen
		local stamina_regen = player_unit:movement():_max_stamina() * stamina_percentage

		player_unit:movement():add_stamina(stamina_regen)
	end
end

function PlayerManager:_check_damage_to_hot(t, unit, damage_info)
	local player_unit = self:player_unit()

	if not self:has_category_upgrade("player", "damage_to_hot") then
		return
	end

	if not alive(player_unit) or player_unit:character_damage():need_revive() or player_unit:character_damage():dead() then
		return
	end

	if not alive(unit) or not unit:base() or not damage_info then
		return
	end

	if damage_info.is_fire_dot_damage then
		return
	end

	local data = tweak_data.upgrades.damage_to_hot_data

	if not data then
		return
	end

	if self._next_allowed_doh_t and t < self._next_allowed_doh_t then
		return
	end

	local add_stack_sources = data.add_stack_sources or {}

	if not add_stack_sources.swat_van and unit:base().sentry_gun then
		return
	elseif not add_stack_sources.civilian and CopDamage.is_civilian(unit:base()._tweak_table) then
		return
	end

	if not add_stack_sources[damage_info.variant] then
		return
	end

	if not unit:brain():is_hostile() then
		return
	end

	local player_armor = managers.blackmarket:equipped_armor(data.works_with_armor_kit, true)

	if not table.contains(data.armors_allowed or {}, player_armor) then
		return
	end

	player_unit:character_damage():add_damage_to_hot()

	local is_low = player_unit:character_damage():get_real_health() <= player_unit:character_damage():_max_health() * 0.35

	self._next_allowed_doh_t = t + (is_low and 1 or data.stacking_cooldown or 1)
end

function PlayerManager:damage_reduction_skill_multiplier(damage_type)
	local multiplier = 1
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_outnumbered", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_outnumbered_strong", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_close_contact", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "revived_damage_resist", 1)
	multiplier = multiplier * self:upgrade_value("player", "damage_dampener", 1)
	multiplier = multiplier * self:upgrade_value("player", "health_damage_reduction", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "first_aid_damage_reduction", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "revive_damage_reduction", 1)
	multiplier = multiplier * self:get_hostage_bonus_multiplier("damage_dampener")
	multiplier = multiplier * self:get_hostage_bonus_multiplier("damage_reduction")
	multiplier = multiplier * self._properties:get_property("revive_damage_reduction", 1)
	multiplier = multiplier * self._temporary_properties:get_property("revived_damage_reduction", 1)
	local dmg_red_mul = self:team_upgrade_value("damage_dampener", "team_damage_reduction", 1)

	if self:has_category_upgrade("player", "passive_damage_reduction") then
		local health_ratio = self:player_unit():character_damage():health_ratio()
		local min_ratio = self:upgrade_value("player", "passive_damage_reduction")

		if health_ratio < min_ratio then
			dmg_red_mul = dmg_red_mul - (1 - dmg_red_mul)
		end
	end

	multiplier = multiplier * dmg_red_mul

	if damage_type == "melee" then
		multiplier = multiplier * managers.player:upgrade_value("player", "melee_damage_dampener", 1)
	end

	local current_state = self:get_current_state()

	if current_state and current_state:_interacting() then
		multiplier = multiplier * managers.player:upgrade_value("player", "interacting_damage_multiplier", 1)
	end

	return math.truncate(multiplier, 3)
end

function PlayerManager:get_damage_health_ratio(health_ratio, category)
	local damage_ratio = 1 - health_ratio / math.max(0.01, self:_get_damage_health_ratio_threshold(category))
	damage_ratio = math.round(damage_ratio, 0.001)
	damage_ratio = math.truncate(damage_ratio, 3)
	return math.max(math.round(damage_ratio,0.01), 0)
end

function PlayerManager:clbk_super_syndrome_respawn(data)
	local trade_manager = managers.trade
	self._clbk_super_syndrome_respawn = nil
	local best_hostage = trade_manager:get_best_hostage(data.pos, true)
	local criminal = trade_manager:get_criminal_by_peer(data.peer_id)

	if criminal and best_hostage then
		local pos = best_hostage.unit:position()
		local rot = best_hostage.unit:rotation()

		trade_manager:criminal_respawn(pos, rot, criminal)
		trade_manager:begin_hostage_trade(pos, rot, best_hostage, true, true, true)
		if CopDamage.is_civilian(best_hostage.unit:base()._tweak_table) then
			if managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.relation_with_bulldozer.mask then
				managers.achievment:award_progress(tweak_data.achievement.relation_with_bulldozer.stat)
			end
		end
	end
end

function PlayerManager:_on_recharge_super_syndrome_event()
	if self:has_category_upgrade("player", "super_syndrome") and self._super_syndrome_count == 0 and alive(self:player_unit()) and not self:player_unit():character_damage():dead() then
		local val = self:upgrade_value("player", "replenish_super_syndrome_chance") + self._super_syndrome_recharge_chance
		if math.random() <= val then
			self._super_syndrome_count = math.min(self:upgrade_value("player", "super_syndrome"), 1)
			self._super_syndrome_recharge_chance = 0

			managers.chat:feed_system_message(ChatManager.GAME, "Stockholm Syndrome Replenish")
		else
			self._super_syndrome_recharge_chance = self._super_syndrome_recharge_chance + 0.1
		end
	end
end

function PlayerManager:disable_cooldown_upgrade(category, upgrade, tmod)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return
	end

	local time = tmod and type(tmod)=="number" and tmod or upgrade_value[2]
	self._global.cooldown_upgrades[category] = self._global.cooldown_upgrades[category] or {}
	self._global.cooldown_upgrades[category][upgrade] = {
		cooldown_time = Application:time() + time
	}
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

function PlayerManager:_get_local_cocaine_stack()
	local local_peer_id = managers.network:session() and managers.network:session():local_peer():id()

	if not local_peer_id or not self:has_category_upgrade("player", "cocaine_stacking") then
		return
	end

	local cocaine_stack = self:get_synced_cocaine_stacks(local_peer_id)
	local amount = cocaine_stack and cocaine_stack.amount or 0
	
	return amount
end

function PlayerManager:damage_absorption()
	local total = 0

	for _, absorption in pairs(self._damage_absorption) do
		total = total + Application:digest_value(absorption, false)
	end

	total = total + self:get_best_cocaine_damage_absorption(managers.network:session():local_peer():id())
	total = managers.modifiers:modify_value("PlayerManager:GetDamageAbsorption", total)

	--log(total)
	return total
end

function PlayerManager:close_hostage_fear_val(set)
	if not set then
		return self._hostage_close_f
	end
	self._hostage_close_f = set
end

function PlayerManager:on_close_hostage_fear_fired()
	local close_fear_act = self:close_hostage_fear_val() and self:close_hostage_fear_val() == true
	if not close_fear_act then
		return
	end
	if self._hostage_fired_t or self._hostage_fired_t > 0 then
		return
	end
	local targets = World:find_units_quick("sphere", self:player_unit():movement():m_pos(), 1000, managers.slot:get_mask("enemies", "civilians"))
	self:on_close_hostage_feared(targets)
	self._hostage_fired_t = TimerManager:game():time() + 0.5
end

function PlayerManager:on_close_hostage_feared(target)
	if not target then
		return
	end
	local chance = math.random(45, 90)
	local chance_val = chance * 0.01
	for key, unit in pairs(target) do
		if alive(unit) and unit:character_damage() and not unit:character_damage():dead() then
			local is_civ = CopDamage.is_civilian(unit:base()._tweak_table)
			local is_converted = unit:brain() and unit:brain()._logic_data and unit:brain()._logic_data.is_converted
			local is_enggage = unit:brain() and unit:brain():is_hostile() 
			local is_sentry = unit:base() and unit:base().sentry_gun
			local unit_mov = unit:movement()
			local unit_enggage = unit_mov and not unit_mov:cool()
			local unit_hostile = unit_mov and unit_mov:stance_name() == "hos"
			local unit_cbt = unit_mov and unit_mov:stance_name() == "cbt"
			if not is_civ and not is_sentry and not is_converted and (is_enggage or unit_enggage) and (unit_hostile or unit_cbt) then
				unit:character_damage():build_suppression(200, chance_val)
			end
		end
	end
end

function PlayerManager:set_bulletstorm(val)
	self._has_bulletstorm = val > 0 and val or nil
end

function PlayerManager:get_bulletstorm()
	return self._has_bulletstorm
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
	self._inspire_reduce.delay_t = self._inspire_reduce.delay_t + 1.5
end

function PlayerManager:_on_armor_break_headshot_dealt_cd_remove()
	if self._on_headshot_dealt_t then
		self._on_headshot_dealt_t = 0 or nil
	end
end

--[[function PlayerManager:_on_reload_trigger_bullet_storm_event()
	self:add_to_temporary_property("bullet_storm", self._has_bulletstorm, 1)
	self:set_bulletstorm(0)
end]]
