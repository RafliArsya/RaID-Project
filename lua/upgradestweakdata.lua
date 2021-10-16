_init_UpgradesTweakData = UpgradesTweakData.init

function UpgradesTweakData:init(...)
	_init_UpgradesTweakData(self, ...)
	
	-- Start up Ammo --
	self.values.player.extra_ammo_multiplier = {
		1.25,
		1.7
	}
	self.definitions.extra_ammo_multiplier2 = {
		category = "feature",
		name_id = "debug_upgrade_extra_start_out_ammo1",
		upgrade = {
			upgrade = "extra_ammo_multiplier",
			category = "player",
			value = 2
		}
	}

	-- Armor Tweaks --
	self.values.player.body_armor.armor = {
		0,
		3,
		5,
		8,
		12,
		14,
		21.5
	}
	self.values.player.body_armor.movement = {
		1.2,
		1.1,
		1.05,
		1,
		0.8,
		0.7,
		0.6
	}
	self.values.player.body_armor.dodge = {
		0.1,
		0.05,
		0.03,
		0.01,
		0,
		-0.01,
		-0.05
	}
	self.values.player.body_armor.damage_shake = {
		1,
		0.95,
		0.92,
		0.85,
		0.8,
		0.6,
		0.4
	}
	self.values.player.body_armor.stamina = {
		1.1,
		1.05,
		1.025,
		1,
		0.9,
		0.8,
		0.7
	}
	self.values.player.body_armor.skill_ammo_mul = {
		1,
		1.025,
		1.05,
		1.1,
		1.2,
		1.4,
		1.8
	}
	
	--Default Skills
	self.values.weapon.passive_headshot_damage_multiplier = {
		1.275
	}

	self.values.temporary.first_aid_damage_reduction = {
		{
			0.88,
			120
		}
	}
	--Damage multiplier ratio threshold thing (Yakuza etc)
	self.player_damage_health_ratio_threshold = 0.6
	
	--Hostage Handler thing
	self.hostage_max_num = {
		damage_dampener = 3,
		health_regen = 3,
		stamina = 7,
		health = 7
	}
	
	--Akimbo Stability things
	self.values.akimbo.recoil_index_addend = {
		-6,
		-3,
		-1,
		-1,
		1 --addon
	}
	--not sure needed
	self.definitions.akimbo_recoil_index_addend_5 = {
		incremental = true,
		name_id = "menu_akimbo_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 5,
			upgrade = "recoil_index_addend",
			category = "akimbo"
		}
	}
	
	--Pickup Ammo More (Deck 6 & Fully Loaded)
	self.values.player.pick_up_ammo_multiplier = {1.35, 1.4, 1.7, 2}
	self.definitions.player_pick_up_ammo_multiplier_3 = {
		name_id = "menu_player_pick_up_ammo_multiplier_3",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "pick_up_ammo_multiplier",
			category = "player"
		}
	}
	self.definitions.player_pick_up_ammo_multiplier_4 = {
		name_id = "menu_player_pick_up_ammo_multiplier_3",
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "pick_up_ammo_multiplier",
			category = "player"
		}
	}
	
	--Deck 8
	self.values.weapon.passive_damage_multiplier = {
		1.05
	}
	
	--Deck 9 Bonus
	self.values.player.passive_loot_drop_multiplier = {
		1.25
	}

	--crew chief
	self.values.team.health.hostage_multiplier = {
		1.06
	}
	self.values.team.stamina.hostage_multiplier = {
		1.12
	}
	self.values.team.damage_dampener.team_damage_reduction = {
		0.9
	}
	self.values.team.damage_dampener.hostage_multiplier = {
		0.9
	}
	self.values.player.passive_intimidate_range_mul = {
		1.5
	}
	
	--crew chief passive damage reduction
	self.values.player.passive_damage_reduction = {
		0.5,
		0.75
	}
	self.definitions.player_passive_damage_reduction_2 = {
		name_id = "menu_player_damage_reduction",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_damage_reduction",
			category = "player"
		}
	}
	
	--Muscle Passive Health Mul
	self.values.player.passive_health_multiplier = {
		1.2,
		1.4,
		1.6,
		1.9,
		2.2,
		2.5
	}
	self.definitions.player_passive_health_multiplier_5 = {
		name_id = "menu_player_health_multiplier",
		category = "feature",
		upgrade = {
			value = 5,
			upgrade = "passive_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_health_multiplier_6 = {
		name_id = "menu_player_health_multiplier",
		category = "feature",
		upgrade = {
			value = 6,
			upgrade = "passive_health_multiplier",
			category = "player"
		}
	}
	
	--Muscle Health Regen
	self.values.player.passive_health_regen = {
		0.05,
		0.03
	}
	self.definitions.player_passive_health_regen_low = {
		name_id = "menu_player_passive_health_regen",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "passive_health_regen",
			category = "player"
		}
	}
	
	--Armorer
	self.values.player.armor_regen_timer_multiplier_passive = {
		0.85
	}
	--Armorer team armor recov
	self.values.team.armor.passive_regen_time_multiplier = {
		0.9
	}
	--Armorer Armor tier multiplier
	self.values.player.tier_armor_multiplier = {
		1.2, 
		1.3, 
		1.4, 
		1.5, 
		1.6, 
		1.7,
		1.85,
		2 --[[1.05, 1.1, 1.2, 1.3, 1.15, 1.35]]
	}
	self.definitions.player_tier_armor_multiplier_7 = {
		name_id = "menu_player_tier_armor_multiplier_7",
		category = "feature",
		upgrade = {
			value = 7,
			upgrade = "tier_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_armor_multiplier_8 = {
		name_id = "menu_player_tier_armor_multiplier_8",
		category = "feature",
		upgrade = {
			value = 8,
			upgrade = "tier_armor_multiplier",
			category = "player"
		}
	}
	
	--Armor break Invulnerable
	self.values.temporary.armor_break_invulnerable = {
		{2, 12}
	}
	
	--Ex-President
	self.values.player.body_armor.skill_max_health_store = {
		15,
		14,
		13,
		12,
		11,
		10,
		5
	}
	self.values.player.body_armor.skill_kill_change_regenerate_speed = {
		15,
		14,
		13,
		12.5,
		11,
		10,
		5
	}
	self.values.player.armor_health_store_amount = {
		0.4,
		0.9,
		1.4
	}
	self.values.player.armor_max_health_store_multiplier = {
		1.7
	}
	
	--Rogue Swap Speed
	self.values.weapon.passive_swap_speed_multiplier = {
		1.375,
		1.825
	}
	--Rouge AP
	self.values.weapon.armor_piercing_chance = {
		0.3
	}
	self.values.weapon.armor_piercing_chance_2 = {
		0.15
	}
	--Rogue Dodge || Passive dodge chance || 1/9 crook dodge
	self.values.player.passive_dodge_chance = {
		0.15,
		0.3,
		0.45
	}
	--Rogue camouflage
	self.values.player.camouflage_multiplier = {0.8}
	
	--Hitman
	self.values.player.passive_always_regen_armor = {
		1.25 --, 10
	}
	self.definitions.player_passive_always_regen_armor_1 = {
		name_id = "player_always_regen_armor",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_always_regen_armor",
			category = "player"
		}
	}
	--[[self.definitions.player_passive_always_regen_armor_slow = {
		name_id = "player_always_regen_armor",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_always_regen_armor",
			category = "player"
		}
	}
	]]
	
	self.values.player.perk_armor_regen_timer_multiplier = {
		0.95,
		0.825,
		0.7,
		0.65,
		0.525,
		0.5
	}
	self.definitions.player_perk_armor_regen_timer_multiplier_6 = {
		name_id = "menu_player_perk_armor_regen_timer_multiplier",
		category = "feature",
		upgrade = {
			value = 6,
			upgrade = "perk_armor_regen_timer_multiplier",
			category = "player"
		}
	}

	--Crook
	self.values.player.level_2_armor_multiplier = {
		1.2,
		1.45,
		1.70
	}
	self.values.player.level_3_armor_multiplier = {
		1.2,
		1.45,
		1.70
	}
	self.values.player.level_4_armor_multiplier = {
		1.2,
		1.45,
		1.70
	}
	self.values.player.level_2_dodge_addend = {
		0.05,
		0.15,
		0.25
	}
	self.values.player.level_3_dodge_addend = {
		0.05,
		0.15,
		0.25
	}
	self.values.player.level_4_dodge_addend = {
		0.05,
		0.15,
		0.25
	}
	self.values.player.armor_regen_timer_multiplier_tier = {
		0.85
	}
	--Crook addon
	self.values.player.level_1_dodge_addend = {
		0.04,
		0.08,
		0.16
	}
	self.values.player.level_1_armor_multiplier = {
		1.5,
		2,
		2.75
	}
	self.values.player.level_5_dodge_addend = {
		0.04,
		0.08,
		0.16
	}
	self.values.player.level_5_armor_multiplier = {
		1.2,
		1.4,
		1.6
	}
	self.definitions.player_level_1_armor_multiplier_1 = {
		incremental = true,
		name_id = "menu_player_level_1_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_1_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_1_armor_multiplier_2 = {
		incremental = true,
		name_id = "menu_player_level_1_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_1_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_1_armor_multiplier_3 = {
		incremental = true,
		name_id = "menu_player_level_1_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "level_1_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_5_armor_multiplier_1 = {
		incremental = true,
		name_id = "menu_player_level_5_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_5_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_5_armor_multiplier_2 = {
		incremental = true,
		name_id = "menu_player_level_5_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_5_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_5_armor_multiplier_3 = {
		incremental = true,
		name_id = "menu_player_level_5_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "level_5_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_1_dodge_addend_1 = {
		incremental = true,
		name_id = "menu_player_level_1_dodge_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_1_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_1_dodge_addend_2 = {
		incremental = true,
		name_id = "menu_player_level_1_dodge_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_1_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_1_dodge_addend_3 = {
		incremental = true,
		name_id = "menu_player_level_1_dodge_addend",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "level_1_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_5_dodge_addend_1 = {
		incremental = true,
		name_id = "menu_player_level_1_dodge_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_5_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_5_dodge_addend_2 = {
		incremental = true,
		name_id = "menu_player_level_5_dodge_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_5_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_5_dodge_addend_3 = {
		incremental = true,
		name_id = "menu_player_level_5_dodge_addend",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "level_5_dodge_addend",
			category = "player"
		}
	}

	--Buglar
	self.values.player.corpse_dispose_speed_multiplier = {
		0.75
	}
	self.values.player.pick_lock_speed_multiplier = {
		0.725
	}
	self.values.player.alarm_pager_speed_multiplier = {0.7}
	self.values.player.stand_still_crouch_camouflage_bonus = {
		0.85,
		0.75,
		0.7
	}
	self.values.player.armor_regen_timer_stand_still_multiplier = {
		0.8
	}
	self.values.player.tier_dodge_chance = {
		0.25,
		0.3,
		0.35
	}
	
	--Infiltrator
	self.values.melee.stacking_hit_damage_multiplier = {14, 21, 43}
	self.definitions.melee_stacking_hit_damage_multiplier_3 = {
		name_id = "menu_melee_stacking_hit_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "stacking_hit_damage_multiplier",
			category = "melee"
		}
	}
	self.values.melee.stacking_hit_expire_t = {7}
	self.max_melee_weapon_dmg_mul_stacks = 1
	self.values.temporary.melee_life_leech = {
		{
			0.2,
			7
		}
	}
	self.values.temporary.dmg_dampener_close_contact = {
		{
			0.9,
			7
		},
		{
			0.8,
			7
		},
		{
			0.7,
			7
		}
	}
	self.values.temporary.dmg_dampener_outnumbered_strong = {
		{
			0.865,
			7
		}
	}
	
	--Combat distance (Sociopath + Infiltrator mods)
	self.close_combat_distance = 2000
	self.killshot_close_panic_range = 1000
	
	--Sociopath
	self.values.player.melee_kill_life_leech = {
		0.15
	}
	self.values.player.killshot_regen_armor_bonus = {
		3.5
	}
	self.values.player.killshot_close_regen_armor_bonus = {
		3.5
	}
	self.values.player.killshot_close_panic_chance = {
		0.75
	}
	
	--Gambler
	self.loose_ammo_restore_health_values = {
		{
			0,
			4
		},
		{
			4,
			8
		},
		{
			8,
			12
		},
		multiplier = 0.25,
		cd = 3,
		base = 8
	}
	self.values.temporary.loose_ammo_restore_health = {
		{
			{
				8,
				12
			},
			3
		},
		{
			{
				12,
				16
			},
			2
		},
		{
			{
				20,
				25
			},
			1.5
		}
	}
	
	--Yakuza
	self.values.player.armor_regen_damage_health_ratio_multiplier = {
		0.25,
		0.5,
		0.7
	}
	self.values.player.movement_speed_damage_health_ratio_multiplier = {
		0.25
	}
	self.values.player.armor_regen_damage_health_ratio_threshold_multiplier = {
		2
	}
	self.values.player.movement_speed_damage_health_ratio_threshold_multiplier = {
		2
	}
	self.values.player.melee_kill_regen_armor = {true}
	self.definitions.player_melee_kill_regen_armor = {
		name_id = "menu_player_melee_kill_regen_armor",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_kill_regen_armor",
			category = "player"
		}
	}
	
	--Grinder
	self.damage_to_hot_data = {
		tick_time = 0.3,
		works_with_armor_kit = true,
		stacking_cooldown = 1.4,
		total_ticks = 10,
		max_stacks = false,
		armors_allowed = {
			"level_1",
			"level_2"
		},
		add_stack_sources = {
			projectile = true,
			fire = true,
			bullet = true,
			melee = true,
			explosion = true,
			civilian = true,
			poison = true,
			taser_tased = true,
			swat_van = true
		}
	}
	self.values.player.damage_to_hot = {
		0.1,
		0.2,
		0.35,
		0.45
	}
	self.values.player.damage_to_hot_extra_ticks = {
		5
	}
	self.values.player.armor_piercing_chance = {
		0.2,
		0.4
	}
	
	--Anarchist
	--[[self.values.player.armor_grinding = {
		{
			{
				1,
				2
			},
			{
				1.5,
				2.5
			},
			{
				2.5,
				4
			},
			{
				3,
				5
			},
			{
				3.5,
				6
			},
			{
				5,
				7
			},
			{
				9,
				9.5
			}
		}
	}]]
	self.values.player.armor_grinding = {
		{
			{
				1,
				2
			},
			{
				1.05,
				2
			},
			{
				1.07,
				2
			},
			{
				1.1,
				2
			},
			{
				1.2,
				2
			},
			{
				1.28,
				2
			},
			{
				1.7,
				2
			}
		}
	}
	self.values.player.health_decrease = {
		0.5
	}
	self.values.player.armor_increase = {
		1,
		1.15,
		1.3
	}
	self.values.player.damage_to_armor = {
		{
			{
				1,
				1.5
			},
			{
				2,
				1.5
			},
			{
				2,
				1.5
			},
			{
				2,
				1.5
			},
			{
				2.5,
				1.5
			},
			{
				2.75,
				1.5
			},
			{
				3,
				1.5
			}
		}
	}
	
	--Maniac Activation/Check Deck
	self.values.player.cocaine_stacking = {
		1
	}
	--Maniac data
	self.cocaine_stacks_convert_levels = {
		30,
		25
	}
	self.cocaine_stacks_tick_t = 2 --4
	self.max_cocaine_stacks_per_tick = 250 --240 555
	self.max_total_cocaine_stacks = 1500 --600 1500
	self.cocaine_stacks_decay_t = 8 --8
	self.cocaine_stacks_decay_amount_per_tick = 70 --80
	self.cocaine_stacks_decay_percentage_per_tick = 0.6 --0.6
	self.values.player.cocaine_stacks_decay_multiplier = {
		0.5
	}
	--Cocaine convert per value
	self.cocaine_stacks_dmg_absorption_value = 0.01
	--Maniac Networked data
	self.values.player.sync_cocaine_stacks = {
		true
	}
	self.values.player.sync_cocaine_upgrade_level = {
		2
	}
	self.values.player.cocaine_stack_absorption_multiplier = {
		2
	}
	
	--Biker
	self.wild_trigger_time = 4
	self.wild_max_triggers_per_time = 6
	self.values.player.wild_health_amount = {
		1
	}
	self.values.player.wild_armor_amount = {
		1.5
	}
	self.values.player.less_health_wild_armor = {
		{
			0.1,
			1
		}
	}
	self.values.player.less_health_wild_cooldown = {
		{
			0.1,
			0.5
		}
	}
	self.values.player.less_armor_wild_health = {
		{
			0.1,
			0.5
		}
	}
	self.values.player.less_armor_wild_cooldown = {
		{
			0.1,
			0.2
		}
	}
	
	--Kingpin
	self.values.temporary.chico_injector = {
		{
			0.8,
			6
		}
	}
	self.values.player.chico_preferred_target = {
		true
	}
	self.values.player.chico_injector_low_health_multiplier = {
		{
			0.6, --health below
			0.25 --multiply
		}
	}
	self.values.player.chico_injector_health_to_speed = {
		{
			2.5,
			1
		}
	}
	--Kingpin unused stats
	self.values.player.chico_armor_multiplier = {
		1.15,
		1.2,
		1.25
	}
	
	--Stoic
	self.values.player.armor_to_health_conversion = {
		100
	}
	self.values.player.damage_control_passive = {
		{
			77,
			9
		}
	}
	self.values.player.damage_control_auto_shrug = {
		3.7
	}
	self.values.player.damage_control_cooldown_drain = {
		{
			0,
			1
		},
		{
			40,
			2
		}
	}
	self.values.player.damage_control_healing = {
		60
	}
	
	--Sicario
	self.values.player.dodge_shot_gain = {
		{
			0.2,
			3
		}
	}
	self.values.player.dodge_replenish_armor = {
		true
	}
	self.values.player.smoke_screen_ally_dodge_bonus = {
		0.1
	}
	self.values.player.sicario_multiplier = {
		2.05
	}
	self.values.player.smoke_screen_timer = {
		1.5, 
		3, 
		5.5
	}
	self.definitions.player_smoke_screen_time_1 = {
		name_id = "menu_player_smoke_screen_time_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "smoke_screen_timer",
			category = "player"
		}
	}
	self.definitions.player_smoke_screen_time_2 = {
		name_id = "menu_player_smoke_screen_time_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "smoke_screen_timer",
			category = "player"
		}
	}
	self.definitions.player_smoke_screen_time_3 = {
		name_id = "menu_player_smoke_screen_time_3",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "smoke_screen_timer",
			category = "player"
		}
	}
	
	--Tag team
	self.values.player.tag_team_base = {
		{
			kill_health_gain = 2,
			radius = 0.6, --LOL WUT?
			distance = 18.5,
			kill_extension = 1, --1.3,
			duration = 13,
			tagged_health_gain_ratio = 0.4
		}
	}
	self.values.player.tag_team_cooldown_drain = {
		{
			tagged = 1,
			owner = 2
		},
		{
			tagged = 2,
			owner = 2
		}
	}
	self.values.player.tag_team_damage_absorption = {
		{
			kill_gain = 0.2,
			max = 5
		}
	}
	
	--H4x0R
	self.values.player.pocket_ecm_jammer_base = {
		{
			cooldown_drain = 6,
			duration = 7
		}
	}
	self.values.player.pocket_ecm_heal_on_kill = {
		2
	}
	self.values.team.pocket_ecm_heal_on_kill = {
		1
	}
	self.values.temporary.pocket_ecm_kill_dodge = {
		{
			0.2,
			30,
			1
		}
	}
	
	--Forced Friendship
	self.values.team.damage = {
		hostage_absorption = {
			0.09 --0.05
		},
		hostage_absorption_limit = 8
	}
	
	--Confident
	self.values.player.intimidate_range_mul = {
		1.75
	}
	self.values.player.intimidate_aura = {
		1250
	}
	
	--Uppers
	self.values.first_aid_kit.first_aid_kit_auto_recovery = {600}
	
	--Ammo Efficiency
	self.values.player.head_shot_ammo_return = {
		{
			ammo = 1,
			time = 7,
			headshots = 3
		},
		{
			ammo = 1,
			time = 7,
			headshots = 2
		}
	}
	
	--Hostage Taker
	self.values.player.hostage_health_regen_addend = {
		0.02,
		0.05
	}
	
	--Inspire Cooldown
	self.values.cooldown.long_dis_revive = {
		--orig {1, 20},
		{1, 40} --addon
	}
	--Inspire Cooldown Addon
	self.values.player.long_dis_reduce = {true}
	self.definitions.player_long_dis_reduce = {
		category = "feature",
		name_id = "menu_player_long_dis_reduce",
		upgrade = {
			value = 1,
			upgrade = "long_dis_reduce",
			category = "player"
		}
	}

	--Combat Medic
	self.values.temporary.revive_damage_reduction = {
		{
			0.7,
			5
		},
		{
			0.7,
			8
		}
	}
	self.definitions.temporary_revive_damage_reduction_2 = {
		name_id = "menu_temporary_revive_damage_reduction",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "revive_damage_reduction",
			category = "temporary"
		}
	}
	self.values.player.revive_damage_reduction = {
		0.7
	}
		
	--Passive revive damage reduction
	self.values.temporary.passive_revive_damage_reduction = {
		{
			0.9,
			5
		},
		{
			0.8,
			5
		}
	}
	self.definitions.temporary_passive_revive_damage_reduction_1 = {
		name_id = "menu_passive_revive_damage_reduction_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_revive_damage_reduction",
			category = "temporary"
		}
	}
	self.definitions.temporary_passive_revive_damage_reduction_2 = {
		name_id = "menu_passive_revive_damage_reduction",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_revive_damage_reduction",
			category = "temporary"
		}
	}
	--unfortunately this not implemented, so i reworked -not really lol
	
	--Resilience
	self.values.player.armor_regen_time_mul = {
		0.8
	}
	--Flashbang
	self.values.player.flashbang_multiplier = {0.25, 0.1}

	--Saw Massacre
	self.values.saw.enemy_slicer = {
		7,
		3
	}
	self.definitions.saw_enemy_slicer_2 = {
		name_id = "menu_saw_enemy_slicer",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "enemy_slicer",
			category = "saw"
		}
	}
	self.values.saw.panic_when_kill = {
		{
			chance = 0.75,
			area = 1000,
			amount = 250
		}
	}
	
	--Portable Saw
	self.values.saw.lock_damage_multiplier = {
		1.4,
		2
	}
	self.values.player.saw_speed_multiplier = {
		0.65,
		0.45
	}
	
	--Overkill
	self.values.temporary.overkill_damage_multiplier = {
		{
			1.77,
			21
		}
	}
	self.values.weapon.swap_speed_multiplier = {
		1.8
	}
	
	--Transporter
	self.values.player.armor_carry_bonus = {
		1.02
	}

	--Die Hard
	self.values.player.level_2_armor_addend = {5}
	self.values.player.level_3_armor_addend = {5}
	self.values.player.level_4_armor_addend = {5}
	--addon
	self.values.player.level_5_armor_addend = {2}
	self.values.player.level_6_armor_addend = {2}
	self.values.player.level_7_armor_addend = {2}
	self.definitions.player_level_5_armor_addend = {
		name_id = "menu_player_level_5_armor_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_5_armor_addend",
			category = "player"
		}
	}
	self.definitions.player_level_6_armor_addend = {
		name_id = "menu_player_level_6_armor_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_6_armor_addend",
			category = "player"
		}
	}
	self.definitions.player_level_7_armor_addend = {
		name_id = "menu_player_level_7_armor_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_7_armor_addend",
			category = "player"
		}
	}

	--Bullseye
	self.values.player.headshot_regen_armor_bonus = {
		1,--0.5
		3
	}

	--Juggernaut
	self.values.player.armor_multiplier = {
		1.2,
		1.5

	}
	self.definitions.player_armor_multiplier2 = {
		name_id = "menu_player_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "armor_multiplier",
			category = "player"
		}
	}

	--Chameleon
	self.values.player.suspicion_multiplier = {
		0.5
	}
	self.values.player.small_loot_multiplier = {1.4}
	
	--Optic Illusion
	self.values.player.camouflage_bonus = {
		0.65,
		0.45
	}
	
	--Duck And Cover
	self.values.player.run_dodge_chance = {
		0.15
	}
	self.values.player.on_zipline_dodge_chance = {
		0.2
	}
	self.values.player.stamina_regen_timer_multiplier = {0.75}
	self.values.player.stamina_regen_multiplier = {1.3}
	
	--Taser Malfunction
	self.values.player.taser_malfunction = {
		{
			interval = 1,
			chance_to_trigger = 0.3
		}
	}
	
	--Dire need
	self.values.player.armor_depleted_stagger_shot = {
		1,
		7
	}
	
	--High Value Target HVT
	self.values.player.marked_enemy_damage_mul = 1.2
	--ACED HVT
	self.values.player.marked_inc_dmg_distance = {
		{
			900,
			1.7
		}
	}
	self.values.player.marked_distance_mul = {
		22
	}
	
	--Sneaky Bastard
	self.values.player.detection_risk_add_dodge_chance = {
		{
			0.02,
			3,
			"below",
			35,
			0.25
		},
		{
			0.02,
			2,
			"below",
			35,
			0.25
		}
	}
	
	--Unseen Strike
	self.values.player.unseen_increased_crit_chance = {
		{
			min_time = 4,
			max_duration = 7,
			crit_chance = 1.35
		},
		{
			min_time = 3.5,
			max_duration = 20,
			crit_chance = 1.5
		}
	}
	
	--Low Blow
	self.values.player.detection_risk_add_crit_chance = {
		{
			0.03,
			3,
			"below",
			35,
			0.35
		},
		{
			0.03,
			1,
			"below",
			35,
			0.35
		}
	}
	
	--Second Wind
	self.values.temporary.damage_speed_multiplier = {
		{
			1.35,
			5
		}--[[,
		{
			1.40,
			5
		}
		]]
	}
	--[[self.definitions.temporary_damage_speed_multiplier_2 = {
		name_id = "menu_temporary_damage_speed_1",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "damage_speed_multiplier",
			category = "temporary"
		}
	}]]
	--Send to peers
	self.values.temporary.team_damage_speed_multiplier_received = {
		{
			1.3,
			5
		}
	}
	
	--Second wind reload speed
	self.values.temporary.reload_weapon_faster_second = {
		{
			1.3,
			7
		}
	}
	self.definitions.reload_weapon_faster_second_multiplier_1 = {
		name_id = "menu_temporary_reload_weapon_faster_second_multiplier_1",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "reload_weapon_faster_second",
			category = "temporary"
		}
	}
	
	--running from death
	self.values.temporary.increased_movement_speed = {
		{
			1.25,
			10
		}
	}
	--[[self.values.temporary.swap_weapon_faster = {
		{
			2,
			10
		}
	}
	self.values.temporary.reload_weapon_faster = {
		{
			2,
			10
		}
	}]]
	--Running from death no ammo cost
	self.values.temporary.no_ammo_revenge = {
		{
			true,
			7
		}
	}
	self.definitions.temporary_no_ammo_revenge = {
		name_id = "menu_temporary_no_ammo_revenge_1",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "no_ammo_revenge",
			category = "temporary"
		}
	}

    --Up you go
	self.values.temporary.revived_damage_resist = {
		{
			0.7,
			12
		}
	}
	--[[self.values.temporary.revived_damage_resist = {
		{
			0.7,
			10
		}
	}
	self.values.player.revived_health_regain = {
		1.4
	}
	]]
	--Revived Damage Immune
	self.values.player.running_from_death = {2}
	self.definitions.player_running_from_death_1 = {
		category = "feature",
		name_id = "menu_player_running_from_death",
		upgrade = {
			category = "player",
			upgrade = "running_from_death",
			value = 1
		}
	}

	--Up you go dmg boost
	self.values.temporary.damage_boost_revenge = {
		{
			50,
			7
		}
	}
	self.definitions.temporary_damage_boost_revenge = {
		name_id = "menu_temporary_damage_boost_1",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "damage_boost_revenge",
			category = "temporary"
		}
	}
	
	--Martial Arts
	self.values.player.melee_damage_dampener = {
		0.5
	}
	self.values.player.melee_knockdown_mul = {
		1.7
	}
	
	--Bloodthrist Basic
	self.values.player.melee_damage_stacking = {
		{
			max_multiplier = 21,
			melee_multiplier = 1
		},
		{
			max_multiplier = 32,
			melee_multiplier = 1
		}
	}
	self.definitions.player_melee_damage_stacking_1 = {
		name_id = "menu_player_melee_damage_stacking",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_damage_stacking",
			category = "player"
		}
	}
	self.definitions.player_melee_damage_stacking_2 = {
		name_id = "menu_player_melee_damage_stacking",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "melee_damage_stacking",
			category = "player"
		}
	}
	
	--Pumping Iron
	self.values.player.non_special_melee_multiplier = {
		2.5
	}
	self.values.player.melee_damage_multiplier = {
		2.25
	}
	
	--Berserker
	self.values.player.melee_damage_health_ratio_multiplier = {
		2.5
	}
	self.values.player.damage_health_ratio_multiplier = {
		1.2
	}
	
	--Frenzy
	self.values.player.healing_reduction = {
		0.35,
		1
	}
	self.values.player.health_damage_reduction = {
		0.68,
		0.35
	}
	self.values.player.max_health_reduction = {
		0.335
	}
	
	--Graze Explode
	self.values.snp.graze_damage = {
		{
			radius = 375,
			damage_factor = 0.5,
			damage_factor_headshot = 0.85
		},
		{
			radius = 485,
			damage_factor = 0.85,
			damage_factor_headshot = 1.05
		}
	}
	
	--explosive breacher
	self.values.player.explosive_breacher = {
		true
	}
	self.definitions.player_explosive_breacher_1 = {
		name_id = "menu_trip_mine_explosive_breacher",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "explosive_breacher",
			category = "player"
		}
	}


	--Tower Defense
	self.values.sentry_gun.quantity = {
		1,
		3
	}
	
	--Trip Mine Deploy
	self.values.player.trip_mine_deploy_time_multiplier = {
		0.6,
		0.5
	}

	--More Firepower
	self.values.shape_charge.quantity = {
		3,
		5 --1, 3
	}

	--Combat Engineering
	self.values.trip_mine.explosion_size_multiplier_1 = {
		1.45
	}
	self.values.trip_mine.damage_multiplier = {
		1.5
	}
	--unused Combat Engineering
	self.values.trip_mine.explosion_size_multiplier_2 = {
		1.7
	}
	
	--Expanded and Enhanced Explosion
	self.values.player.expanded_n_enhanced = {
		{
			base = 0.5,
			inc = 0.02
		},
		{
			base = 0.5,
			inc = 0.05
		}
	}
	self.definitions.player_expanded_n_enhanced_1 = {
		name_id = "menu_player_expanded_n_enhanced",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "expanded_n_enhanced",
			category = "player"
		}
	}
	self.definitions.player_expanded_n_enhanced_2 = {
		name_id = "menu_player_expanded_n_enhanced",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "expanded_n_enhanced",
			category = "player"
		}
	}
	
	--Trip Mine Alert Size
	self.values.trip_mine.alert_size_multiplier = {
		0.15,
		0.15
	}
	self.definitions.trip_mine_alert_size_multiplier_1 = {
		name_id = "menu_trip_mine_alert_size_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "alert_size_multiplier",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_alert_size_multiplier_2 = {
		name_id = "menu_trip_mine_alert_size_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "alert_size_multiplier",
			category = "trip_mine"
		}
	}

	--Fire Trap
	self.values.trip_mine.fire_trap = {
		{15, 1.25},
		{25, 1.875}
	}

	--Lockdown Trap
	self.values.trip_mine.lockdown_trap = {
		{
			dmg = 50,
			range = 1000
		},
		{
			dmg = 100,
			range = 2000
		}
	}
	self.definitions.trip_mine_lockdown_trap_1 = {
		name_id = "menu_player_lockdown_trap",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "lockdown_trap",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_lockdown_trap_2 = {
		name_id = "menu_player_lockdown_trap",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "lockdown_trap",
			category = "trip_mine"
		}
	}

	--Flame Trap
	self.values.player.flame_trap = {
		{
			chance = 0.15,
			inc = 0.02
		},
		{
			chance = 0.32,
			inc = 0.02
		}
	}
	self.definitions.player_flame_trap_1 = {
		name_id = "menu_player_flame_trap",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "flame_trap",
			category = "player"
		}
	}
	self.definitions.player_flame_trap_2 = {
		name_id = "menu_player_flame_trap",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "flame_trap",
			category = "player"
		}
	}
	
	--Fire Trap MK2
	self.values.player.fire_trap_mk2 = {
		{
			delay = 4,
			dmg_mul = 2,
			distance = 1100,
			burn_time = 5,
			base = 0.3,
			inc = 0.02,
			radius = 600
		},
		{
			delay = 2.5,
			dmg_mul = 4,
			distance = 2100,
			burn_time = 12,
			base = 0.3,
			inc = 0.02,
			radius = 900
		}
	}
	self.definitions.player_fire_trap_mk2_1 = {
		name_id = "menu_player_fire_trap_mk2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "fire_trap_mk2",
			category = "player"
		}
	}
	self.definitions.player_fire_trap_mk2_2 = {
		name_id = "menu_player_fire_trap_mk2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "fire_trap_mk2",
			category = "player"
		}
	}
	
	--Drill auto repair
	self.values.player.drill_autorepair_1 = {
		0.20
	}
	self.values.player.drill_autorepair_2 = {
		0.30
	}
	
	--Drill
	self.values.player.drill_alert_rad = {
		800
	}
	self.values.player.silent_drill = {
		true
	}
	
	--Drill Expert
	self.values.player.drill_speed_multiplier = {
		0.8,
		0.65
	}
	
	--Heavy Impact
	self.values.weapon.knock_down = {
		0.15,
		0.33
	}
	
	--Lock N load
	self.values.player.automatic_faster_reload = {
		{
			min_reload_increase = 1.3,
			penalty = 0.015,
			target_enemies = 2,
			min_bullets = 20,
			max_reload_increase = 2
		}
	}
	
	--Sure fire
	self.values.player.automatic_mag_increase = {
		15,
		25
	}
	self.definitions.player_automatic_mag_increase_1 = {
		name_id = "menu_automatic_mag_increase",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "automatic_mag_increase",
			category = "player"
		}
	}
	self.definitions.player_automatic_mag_increase_2 = {
		name_id = "menu_automatic_mag_increase",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "automatic_mag_increase",
			category = "player"
		}
	}
	
	--Body Expertise
	self.values.weapon.automatic_head_shot_add = {0.465, 0.975}
	
	--Increase Pickup Area
	self.values.player.increased_pickup_area = {1.7}
	
	--Swan song
	self.berserker_movement_speed_multiplier = 0.5
	self.values.temporary.berserker_damage_multiplier = {
		{
			1.2,
			3.7
		},
		{
			1.45,
			6.5
		}
	}
	
	--Feign Death
	self.values.player.cheat_death_chance = {
		0.2,
		0.45
	}
	--Trigger Happy + Old Vanilla test
	self.values.pistol.stacking_hit_damage_multiplier = {
		{
			max_stacks = 5,
			max_time = 4,
			damage_bonus = 0.2
		},
		{
			max_stacks = 5,
			max_time = 8,
			damage_bonus = 0.2
		}
	}
	
	--Nimble(LOCK)
	self.values.player.pick_lock_easy_speed_multiplier = {0.45}
	
	--Convert enemies (PIC-JOKER-CONFIDENT)
	self.values.player.convert_enemies_max_minions = {
		1,
		2
	}
	self.values.player.minion_master_speed_multiplier = {
		1.175
	}
	self.values.player.minion_master_health_multiplier = {
		1.375
	}
	self.values.player.convert_enemies_interaction_speed_multiplier = {
		0.3
	}
	--Not Working Convert enemies stats? or perhaps Server Side Check?
	self.values.player.passive_convert_enemies_damage_multiplier = {
		1.25 --1.15
	}
	self.values.player.convert_enemies_damage_multiplier = {
		1, --0.65
		1.35 --1
	}
	self.values.player.passive_convert_enemies_health_multiplier = {
		0.55,
		0.01
	}
	self.values.player.convert_enemies_health_multiplier = {
		0.45
	}
	
	--Nine Lives
	self.values.player.bleed_out_health_multiplier = {
		1.7
	}
	
	--One Handed Talent
	self.values.pistol.damage_addend = {
		1.5,
		3.3
	}
	
	--Desperado
	self.values.pistol.stacked_accuracy_bonus = {
		{
			max_stacks = 4,
			accuracy_bonus = 0.9,
			max_time = 10
		},
		{
			max_stacks = 7,
			accuracy_bonus = 0.9,
			max_time = 12
		}
	}
	self.definitions.pistol_stacked_accuracy_bonus_1 = {
		name_id = "menu_pistol_stacked_accuracy_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stacked_accuracy_bonus",
			category = "pistol"
		}
	}
	self.definitions.pistol_stacked_accuracy_bonus_2 = {
		name_id = "menu_pistol_stacked_accuracy_bonus",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "stacked_accuracy_bonus",
			category = "pistol"
		}
	}
	
	--Specialized Killer
	self.values.weapon.silencer_damage_multiplier = {
		1.07,
		1.15
	}
	self.definitions.weapon_silencer_damage_multiplier_1 = {
		category = "feature",
		name_id = "silencer_damage_multiplier",
		upgrade = {
			category = "weapon",
			upgrade = "silencer_damage_multiplier",
			value = 1
		}
	}
	self.definitions.weapon_silencer_damage_multiplier_2 = {
		category = "feature",
		name_id = "silencer_damage_multiplier",
		upgrade = {
			category = "weapon",
			upgrade = "silencer_damage_multiplier",
			value = 2
		}
	}
	self.values.weapon.armor_piercing_chance_silencer = {
		0.15,
		0.31
	}
	self.definitions.weapon_silencer_armor_piercing_chance_1 = {
		incremental = true,
		name_id = "menu_weapon_silencer_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance_silencer",
			category = "weapon"
		}
	}
	self.definitions.weapon_silencer_armor_piercing_chance_2 = {
		incremental = true,
		name_id = "menu_weapon_silencer_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance_silencer",
			category = "weapon"
		}
	}
	
	--First Aid Kit Chance Restore Downs Counter
	self.values.first_aid_kit.downs_restore_chance = {0.5}
	self.definitions.first_aid_kit_downs_restore_chance = {
		incremental = true,
		name_id = "menu_first_aid_kit_downs_restore_chance",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "downs_restore_chance",
			category = "first_aid_kit"
		}
	}
	
	--First Aid Kit Recharge Messiah Charges
	self.values.first_aid_kit.recharge_messiah_chance = {0.5}
	self.definitions.first_aid_kit_recharge_messiah_chance = {
		incremental = true,
		name_id = "menu_first_aid_kit_recharge_messiah_chance",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "recharge_messiah_chance",
			category = "first_aid_kit"
		}
	}
	
	--Messiah Free Charges
	self.values.player.cheat_messiah_chance = {0.4}
	self.definitions.player_cheat_messiah_chance = {
		incremental = true,
		name_id = "menu_player_cheat_messiah_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cheat_messiah_chance",
			category = "player"
		}
	}
	
	--Allowed damage dampener
	self.values.player.allowed_dmg_dam = {true}
	self.definitions.player_allowed_dmg_dam = {
		category = "feature",
		name_id = "menu_player_allowed_dmg_dam",
		upgrade = {
			value = 1,
			upgrade = "allowed_dmg_dam",
			category = "player"
		}
	}
	
	--Sentry Auto Picked Up
	self.values.sentry_gun.destroy_auto_pickup = {6}
	self.values.sentry_gun.destroy_auto_pickup_2 = {4}
	self.definitions.sentry_gun_destroy_auto_pickup = {
		category = "feature",
		name_id = "menu_sentry_gun_destroy_auto_pickup",
		upgrade = {
			value = 1,
			upgrade = "destroy_auto_pickup",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_destroy_auto_pickup_2 = {
		category = "feature",
		name_id = "menu_sentry_gun_destroy_auto_pickup_2",
		upgrade = {
			value = 1,
			upgrade = "destroy_auto_pickup_2",
			category = "sentry_gun"
		}
	}
	
	--Sentry Explode
	self.values.sentry_gun.destroy_explosion = {
		{
			radius = 200,
			damage = 75,
			slotmask = "bullet_impact_targets"
		},
		{
			radius = 400,
			damage = 125,
			slotmask = "bullet_impact_targets"
		}
	}
	self.definitions.sentry_gun_destroy_explosion_1 = {
		category = "feature",
		name_id = "menu_sentry_gun_destroy_explosion_1",
		upgrade = {
			value = 1,
			upgrade = "destroy_explosion",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_destroy_explosion_2 = {
		category = "feature",
		name_id = "menu_sentry_gun_destroy_explosion_2",
		upgrade = {
			value = 2,
			upgrade = "destroy_explosion",
			category = "sentry_gun"
		}
	}
	
	--Sentry Auto Mark Special + mark boost
	self.values.sentry_gun.special_mark = {true}
	self.values.sentry_gun.mark_boost = {true}
	self.definitions.sentry_gun_special_mark = {
		category = "feature",
		name_id = "menu_sentry_gun_special_mark",
		upgrade = {
			value = 1,
			upgrade = "special_mark",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_mark_boost = {
		category = "feature",
		name_id = "menu_sentry_gun_mark_boost",
		upgrade = {
			value = 1,
			upgrade = "mark_boost",
			category = "sentry_gun"
		}
	}

	--Sentry Restore Ammo on Kill
	self.values.sentry_gun.kill_restore_ammo = {true}
	self.definitions.sentry_gun_kill_restore_ammo = {
		category = "feature",
		name_id = "menu_sentry_gun_kill_restore_ammo",
		upgrade = {
			value = 1,
			upgrade = "kill_restore_ammo",
			category = "sentry_gun"
		}
	}
	self.values.sentry_gun.kill_restore_ammo_chance = {
		{
			chance = 0.15,
			interval = 3,
			inc = 3
		}
	}
	self.definitions.sentry_gun_kill_restore_ammo_chance_1 = {
		name_id = "menu_sentry_gun_kill_restore_ammo_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "kill_restore_ammo_chance",
			category = "sentry_gun"
		}
	}
	
	--Sentry Buff
	self.values.sentry_gun.armor_multiplier2 = {8}
	self.values.sentry_gun.armor_multiplier = {7}
	
	--Sentry AP Mark 2
	self.values.sentry_gun.ap_buff = {{
		fire_rate = 0.5
	}}
	self.definitions.sentry_gun_ap_buff = {
		name_id = "menu_sentry_gun_ap_buff",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "ap_buff",
			category = "sentry_gun"
		}
	}
	
	--Sentry Damage Multiplier
	self.values.sentry_gun.damage_explosion = {
		{
			radius = 150,
			interval = 10,
			min_interval = 0.5,
			damage = 40,
			slotmask = "bullet_impact_targets"
		},
		{
			radius = 200,
			interval = 6,
			min_interval = 0.5,
			damage = 80,
			slotmask = "bullet_impact_targets"
		}
	}
	self.definitions.sentry_gun_damage_explosion_1 = {
		name_id = "menu_sentry_gun_damage_explosion",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_explosion",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_damage_explosion_2 = {
		name_id = "menu_sentry_gun_damage_explosion",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "damage_explosion",
			category = "sentry_gun"
		}
	}
	
	--Tower Explosion
	self.values.sentry_gun.tower_explosion = {
		{
			damage = 25,
			min_interval = 0.3,
			interval = 3,
			radius = 200,
			slotmask = "bullet_impact_targets"
		},
		{
			damage = 50,
			min_interval = 0.3,
			interval = 3,
			radius = 400,
			slotmask = "bullet_impact_targets"
		}
	}
	self.definitions.sentry_gun_tower_explosion_1 = {
		name_id = "menu_sentry_gun_tower_explosion",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "tower_explosion",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_tower_explosion_2 = {
		name_id = "menu_sentry_gun_tower_explosion",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "tower_explosion",
			category = "sentry_gun"
		}
	}
	
	--Minion Damage Multiplier
	self.values.player.minion_damage_explosion = {
		{
			radius = 200,
			delay = 4,
			min = 0.4,
			damage = 60
		},
		{
			radius = 250,
			delay = 4,
			min = 0.4,
			damage = 120
		}
	}
	self.definitions.player_minion_damage_explosion_1 = {
		name_id = "menu_player_minion_damage_explosion",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "minion_damage_explosion",
			category = "player"
		}
	}
	self.definitions.player_minion_damage_explosion_2 = {
		name_id = "menu_player_minion_damage_explosion",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "minion_damage_explosion",
			category = "player"
		}
	}
		
	--Sure fire mk2
	self.values.player.sure_fire_mk2 = {
		{
			base = 0.1,
			increment = 1,
			increment_max = 5
		}
	}
	self.definitions.player_sure_fire_mk2_1 = {
		name_id = "menu_player_sure_fire_mk2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sure_fire_mk2",
			category = "player"
		}
	}
	
	--Sharing Damage to Enemies is Caring
	self.values.player.sharing_is_hurting = {
		{
			damage_e = 0.25,
			damage_m = 4,
			damage_s = 0.88,
			damage_a = 0.4,
			damage_u = 0.1,
			delay = 3.4,
			stack = 6
		},
		{
			damage_e = 0.25,
			damage_m = 7,
			damage_s = 0.85,
			damage_a = 0.25,
			damage_u = 0.1,
			delay = 2,
			stack = 6
		}
	}
	self.definitions.player_sharing_is_hurting_1 = {
		name_id = "menu_player_sharing_is_hurting",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sharing_is_hurting",
			category = "player"
		}
	}
	self.definitions.player_sharing_is_hurting_2 = {
		name_id = "menu_player_sharing_is_hurting",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "sharing_is_hurting",
			category = "player"
		}
	}
	
	--Fully Loaded + Buff + Fixes
	self.values.player.regain_throwable_from_ammo = {
		{
			chance = 0.1,
			chance_inc = 0.02
		},
		{
			chance = 0.3,
			chance_inc = 0.03
		}
	}
	self.definitions.player_regain_throwable_from_ammo_1 = {
		name_id = "menu_player_regain_throwable_from_ammo",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "regain_throwable_from_ammo",
			category = "player"
		}
	}
	self.definitions.player_regain_throwable_from_ammo_2 = {
		name_id = "menu_player_regain_throwable_from_ammo",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "regain_throwable_from_ammo",
			category = "player"
		}
	}
	
	--Ammo Pickup Got Lucky Mag
	self.values.player.lucky_mag = {
		{
			base = 0.1,
			inc = 0.02,
			special = false
		},
		{
			base = 0.12,
			inc = 0.03,
			special = true
		}
	}
	self.definitions.player_lucky_mag_1 = {
		name_id = "menu_player_lucky_mag",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "lucky_mag",
			category = "player"
		}
	}
	self.definitions.player_lucky_mag_2 = {
		name_id = "menu_player_lucky_mag",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "lucky_mag",
			category = "player"
		}
	}
	self.values.player.lucky_mag_saw = { true }
	self.definitions.player_lucky_mag_saw = {
		name_id = "menu_player_lucky_mag_saw",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "lucky_mag_saw",
			category = "player"
		}
	}
	self.values.player.lucky_mag_special = { true }
	self.definitions.player_lucky_mag_special = {
		name_id = "menu_player_lucky_mag_special",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "lucky_mag_special",
			category = "player"
		}
	}
	self.values.player.lucky_mag_special_plus = { true }
	self.definitions.player_lucky_mag_special_plus = {
		name_id = "menu_player_lucky_mag_special_2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "lucky_mag_special_plus",
			category = "player"
		}
	}

	--Ammo Pickup Add
	self.values.player.weapon_add_pickup_ammo = {
		{
			base = 0.33,
			inc = 3,
		}
	}
	self.definitions.weapon_add_pickup_ammo = {
		name_id = "menu_player_weapon_add_pickup_ammo",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "weapon_add_pickup_ammo",
			category = "player"
		}
	}
	
	--Bullet Storm 2
	self.values.player.no_ammo_cost_mk2 = {{
		chance = 0.15, 
		duration = 3, 
		delay = 2,
		delay_inactive = 10,
		inc = 5
	}}
	self.definitions.temporary_no_ammo_cost_mk2 = {
		name_id = "temporary_no_ammo_cost_mk2",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "no_ammo_cost_mk2",
			category = "player"
		}
	}
	self.values.player.no_ammo_cost_mk2_extra = { 4 }
	self.definitions.temporary_no_ammo_cost_mk2_extra = {
		name_id = "menu_player_no_ammo_cost_mk2_extra",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "no_ammo_cost_mk2_extra",
			category = "player"
		}
	}
	
	--Stockholm Syndrome Replenish
	--docbag
	self.values.player.replenish_super_syndrome_chance = {0.32}
	self.definitions.player_replenish_super_syndrome_chance = {
		name_id = "menu_player_replenish_super_syndrome_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "replenish_super_syndrome_chance",
			category = "player"
		}
	}
	--hostage
	self.values.player.replenish_super_syndrome_chance = {0.1}
	self.definitions.player_replenish_super_syndrome_chance = {
		name_id = "menu_player_replenish_super_syndrome_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "replenish_super_syndrome_chance",
			category = "player"
		}
	}
	
	--Auto Counter Spooc
	self.values.player.auto_counter_spooc = {0.5}
	self.definitions.player_auto_counter_spooc = {
		name_id = "menu_player_auto_counter_spooc",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "auto_counter_spooc",
			category = "player"
		}
	}
	
	--Normal Second Deployable
	self.values.player.second_deployable_mul = {
		0.5,
		1,
		1
	}
	self.definitions.player_second_deployable_mul_1 = {
		name_id = "menu_player_second_deployable_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "second_deployable_mul",
			category = "player"
		}
	}
	self.definitions.player_second_deployable_mul_2 = {
		name_id = "menu_player_second_deployable_mul",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "second_deployable_mul",
			category = "player"
		}
	}
	self.definitions.player_second_deployable_mul_3 = {
		name_id = "menu_player_second_deployable_mul",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "second_deployable_mul",
			category = "player"
		}
	}
	
	--Stealth Movement
	self.values.player.suspicious_movement = {true}
	self.definitions.player_suspicious_movement = {
		category = "feature",
		name_id = "menu_player_suspicious_movement",
		upgrade = {
			value = 1,
			upgrade = "suspicious_movement",
			category = "player"
		}
	}

	--Ninja Escape
	self.values.player.ninja_escape_move = {true}
	self.definitions.player_ninja_escape_move = {
		category = "feature",
		name_id = "menu_player_ninja_escape_move",
		upgrade = {
			value = 1,
			upgrade = "ninja_escape_move",
			category = "player"
		}
	}
	
	--Revived Repair Drill
	self.values.player.revived_drill_fixed = {
		true
	}
	self.definitions.player_revived_drill_fixed_1 = {
		category = "feature",
		name_id = "menu_player_revived_drill_fixed",
		upgrade = {
			value = 1,
			upgrade = "revived_drill_fixed",
			category = "player"
		}
	}
	
	--Maniac Revive
	self.values.player.maniac_ictb = {true}
	self.definitions.player_maniac_ictb_1 = {
		category = "feature",
		name_id = "menu_player_maniac_ictb",
		upgrade = {
			value = 1,
			upgrade = "maniac_ictb",
			category = "player"
		}
	}
	
	--Biker Revive
	self.values.player.vice_prez = {true}
	self.definitions.player_vice_prez_1 = {
		category = "feature",
		name_id = "menu_player_vice_prez",
		upgrade = {
			value = 1,
			upgrade = "vice_prez",
			category = "player"
		}
	}
	
	--Drill resume on kill
	self.values.player.drill_resume = {
		{
			base = 0.25,
			inc = 0.02,
			kill_t = 3,
			cooldown = 12
		},
		{
			base = 0.32,
			inc = 0.02,
			kill_t = 2,
			cooldown = 10
		}
	}
	self.definitions.player_drill_resume_1 = {
		category = "feature",
		name_id = "menu_player_drill_resume",
		upgrade = {
			value = 1,
			upgrade = "drill_resume",
			category = "player"
		}
	}
	self.definitions.player_drill_resume_2 = {
		category = "feature",
		name_id = "menu_player_drill_resume",
		upgrade = {
			value = 2,
			upgrade = "drill_resume",
			category = "player"
		}
	}
	
	--Pocket Ecm Crowd Control
	self.values.player.pocket_crewd = {
		{
			radius = 600,
			tick = 1
		}
	}
	self.definitions.player_pocket_crewd_1 = {
		name_id = "menu_player_pocket_crewd",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pocket_crewd",
			category = "player"
		}
	}

	--Pocket Ecm Faster Cooldown
	self.values.player.pocket_stealth = {
		{
			tick = 0.5, 
			inc = 0.25
		}
	}
	self.definitions.player_pocket_stealth_1 = {
		name_id = "menu_player_pocket_stealth",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pocket_stealth",
			category = "player"
		}
	}
	
	--Revive pain killer abs
	self.values.player.pain_killer_ab = {
		0.07,
		0.15
	}
	self.definitions.player_pain_killer_a1 = {
		category = "feature",
		name_id = "menu_player_pain_killer",
		upgrade = {
			category = "player",
			upgrade = "pain_killer_ab",
			value = 1
		}
	}
	self.definitions.player_pain_killer_a2 = {
		category = "feature",
		name_id = "menu_player_pain_killer",
		upgrade = {
			category = "player",
			upgrade = "pain_killer_ab",
			value = 2
		}
	}

	--Kill Medic Heal My Self
	self.values.player.doctor_kill_heal = {true}
	self.definitions.doctor_kill_heal = {
		category = "feature",
		name_id = "menu_player_doctor_kill_heal",
		upgrade = {
			value = 1,
			upgrade = "doctor_kill_heal",
			category = "player"
		}
	}

	--Armor Break Give Absorbtion
	self.values.player.armor_depleted_get_absorption = {
		true
	}
	self.definitions.player_armor_depleted_get_absorption_1 = {
		category = "feature",
		name_id = "menu_player_armor_depleted_get_absorption",
		upgrade = {
			category = "player",
			upgrade = "armor_depleted_get_absorption",
			value = 1
		}
	}

	--Reload Speed Multiplier
	self.values.saw.reload_speed_multiplier = {
		1.3
	}
	self.definitions.saw_reload_speed_multiplier = {
		name_id = "menu_saw_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "saw"
		}
	}
	self.values.grenade_launcher.reload_speed_multiplier = {
		1.2
	}
	self.definitions.grenade_launcher_reload_speed_multiplier = {
		name_id = "menu_saw_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "grenade_launcher"
		}
	}
	self.values.minigun.reload_speed_multiplier = {
		1.25
	}
	self.definitions.minigun_reload_speed_multiplier = {
		name_id = "menu_saw_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "minigun"
		}
	}
	self.values.bow.reload_speed_multiplier = {
		1.25
	}
	self.definitions.bow_reload_speed_multiplier = {
		name_id = "menu_saw_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "bow"
		}
	}
	self.values.crossbow.reload_speed_multiplier = {
		1.25
	}
	self.definitions.xbow_reload_speed_multiplier = {
		name_id = "menu_saw_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "crossbow"
		}
	}
	self.values.flamethrower.reload_speed_multiplier = {
		1.25
	}
	self.definitions.flamethrower_reload_speed_multiplier = {
		name_id = "menu_saw_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "flamethrower"
		}
	}


	--[[TEST SKILL START HERE
	--Close Hostage Increase Confident
	self.values.player.close_hostage_inc_hp_armor = {{hp = 3, ap = 1}}
	self.definitions.player_close_hostage_inc_hp_armor = {
		category = "feature",
		name_id = "menu_player_close_hostage_inc_hp_armor",
		upgrade = {
			value = 1,
			upgrade = "close_hostage_inc_hp_armor",
			category = "player"
		}
	}
	
	--Intimidate Explode Enemies
	self.values.player.super_intimidate_power = {0.5}
	self.definitions.player_super_intimidate_power = {
		category = "feature",
		name_id = "menu_player_super_intimidate_power",
		upgrade = {
			value = 1,
			upgrade = "super_intimidate_power",
			category = "player"
		}
	}
	
	--Sentry Fire Arrow
	self.values.sentry_gun.arrow_chance = {{
		chance = 0.3,
		increment = 12,
		interval = 15
	}}
	self.definitions.sentry_gun_arrow_chance = {
		name_id = "menu_sentry_gun_arrow_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "arrow_chance",
			category = "sentry_gun"
		}
	}
	--double chance regain throwable from ammo
	self.values.player.double_chance_regain_throwable = {true}
	self.definitions.player_double_chance_regain_throwable = {
		name_id = "menu_player_double_chance_regain_throwable",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "double_chance_regain_throwable",
			category = "player"
		}
	}
	
	--Stockholm Syndrome Follow
	self.values.player.super_syndrome_follow = {2}
	self.definitions.player_super_syndrome_follow = {
		name_id = "menu_player_super_syndrome_follow",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "super_syndrome_follow",
			category = "player"
		}
	}
	
	--Scavenger Ace Mark 2
	self.values.player.double_drop_s = {7}
	self.definitions.player_double_drop_s = {
		name_id = "menu_player_double_drop_s",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "double_drop_s",
			category = "player"
		}
	}
	
	--Second Wind DMG Boost
	self.values.temporary.damage_boost_multiplier = {
		{
			1.07,
			7
		}
	}
	self.definitions.temporary_damage_boost_multiplier = {
		name_id = "menu_temporary_damage_boost_1",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "damage_boost_multiplier",
			category = "temporary"
		}
	}

	--Stay Up You Go[t] Health
	self.values.player.up_you_goh = {true}
	self.definitions.player_up_you_goh_1 = {
		category = "feature",
		name_id = "menu_player_up_you_goh",
		upgrade = {
			category = "player",
			upgrade = "up_you_goh",
			value = 1
		}
	}

	--Trip Mine Breach Door MK2
	self.values.trip_mine.breach_mk2 = {
		true
	}
	self.definitions.trip_mine_breach_mk2 = {
		name_id = "menu_trip_mine_breach_mk2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "breach_mk2",
			category = "trip_mine"
		}
	}

	--Revive pain killer
	self.values.player.pain_killer = {
		0.03,
		0.1
	}
	self.definitions.player_pain_killer_1 = {
		category = "feature",
		name_id = "menu_player_pain_killer",
		upgrade = {
			category = "player",
			upgrade = "pain_killer",
			value = 1
		}
	}
	self.definitions.player_pain_killer_2 = {
		category = "feature",
		name_id = "menu_player_pain_killer",
		upgrade = {
			category = "player",
			upgrade = "pain_killer",
			value = 2
		}
	}
	
	--Revived Damage AOE
	self.values.player.revived_up_enemy_fall = {
		{
			aoe = 700,
			dmg = 10,
			slotmask = "trip_mine_targets",
			tick_t = 0.8,
			active_t = 8
		},
		{
			aoe = 900,
			dmg = 10,
			slotmask = "enemies",
			tick_t = 0.8,
			active_t = 12
		}
	}
	self.definitions.player_revived_up_enemy_fall_1 = {
		category = "feature",
		name_id = "menu_player_revived_up_enemy_fall",
		upgrade = {
			value = 1,
			upgrade = "revived_up_enemy_fall",
			category = "player"
		}
	}
	self.definitions.player_revived_up_enemy_fall_2 = {
		category = "feature",
		name_id = "menu_player_revived_up_enemy_fall",
		upgrade = {
			value = 2,
			upgrade = "revived_up_enemy_fall",
			category = "player"
		}
	}

	--Gunshot Crowd Control
	self.values.player.crowd_control_mk2 = {
		{
			radius = 600,
			base = 0.2,
			increment = 3,
			active_t = 2,
			trigger_max = 4,
			delay = 5
		}
	}
	self.definitions.player_crowd_control_mk2_1 = {
		name_id = "menu_player_crowd_control_mk2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "crowd_control_mk2",
			category = "player"
		}
	}
	self.values.player.AOE_intimidate = {
		true
	}
	self.definitions.player_AOE_intimidate = {
		name_id = "menu_player_player_AOE_intimidate",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "AOE_intimidate",
			category = "player"
		}
	}

	--HOST ONLY SKILL
	--ECM (HOST ONLY)
	self.ecm_jammer_base_range = 3000
	self.ecm_feedback_interval = 1
	self.ecm_feedback_retrigger_interval = 200
	self.ecm_feedback_retrigger_chance = 1
	]]--

end