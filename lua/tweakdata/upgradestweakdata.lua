_init_UpgradesTweakData = UpgradesTweakData.init

function UpgradesTweakData:init(...)
	_init_UpgradesTweakData(self, ...)

    -- Armor Tweaks --
	self.values.player.body_armor.armor = {
		0,
		3,
		4,
		8,
		10,
		12,
		20
	}
	self.values.player.body_armor.movement = {
		1.15,
		1.08,
		1.04,
		1.02,
		1,
		0.8,
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

	--Damage multiplier ratio threshold thing (Yakuza etc)
	self.player_damage_health_ratio_threshold = 0.5

	--Grinder
	self.damage_to_hot_data = {
		tick_time = 0.3,
		works_with_armor_kit = true,
		stacking_cooldown = 1.5,
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
		0.3,
		0.4
	}
	self.values.player.damage_to_hot_extra_ticks = {
		4
	}
	self.values.player.armor_piercing_chance = {
		0.2,
		0.4
	}

	--Maniac Activation/Check Deck
	self.values.player.cocaine_stacking = {
		1
	}
	--Maniac data
	self.cocaine_stacks_convert_levels = {
		25,
		16
	}
	self.cocaine_stacks_tick_t = 4 --4
	self.max_cocaine_stacks_per_tick = 240
	self.max_total_cocaine_stacks = 600
	self.cocaine_stacks_decay_t = 10 --8
	self.cocaine_stacks_decay_amount_per_tick = 70 --80
	self.cocaine_stacks_decay_percentage_per_tick = 0.55 --0.6
	self.values.player.cocaine_stacks_decay_multiplier = {
		0.5
	}
	self.values.player.cocaine_stack_absorption_multiplier = {
		2
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

	--Anarchist
	self.values.player.armor_grinding = {
		{
			{
				1,
				1.5
			},
			{
				1.5,
				2.5
			},
			{
				2,
				3.5
			},
			{
				2.5,
				4.5
			},
			{
				4,
				6
			},
			{
				5,
				7
			},
			{
				9,
				10
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
				3.5,
				1.5
			},
			{
				3.5,
				1.5
			},
			{
				3.5,
				1.5
			},
			{
				3.5,
				1.5
			},
			{
				3.5,
				1.5
			},
			{
				3.5,
				1.5
			},
			{
				3.5,
				1.5
			}
		}
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
		105
	}
	self.values.player.damage_control_passive = {
		{
			80,
			12
		}
	}
	self.values.player.damage_control_auto_shrug = {
		3.4
	}
	self.values.player.damage_control_cooldown_drain = {
		{
			0,
			1
		},
		{
			45,
			2
		}
	}
	self.values.player.damage_control_healing = {
		66.6
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
	
	--Hacker
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

	--forced friendship
	self.values.team.damage = {
		hostage_absorption = {
			0.025
		},
		hostage_absorption_limit = 8
	}

	--combat medic
	self.values.temporary.passive_revive_damage_reduction = {
		{
			0.7,
			5
		},
		{
			0.2,
			5
		}
	}
	self.values.temporary.revive_damage_reduction = {
		{
			0.7,
			5
		}
	}
	self.values.player.revive_damage_reduction = {
		0.7
	}

    --inspire / revive speed (modded)
    self.values.player.revive_interaction_speed_multiplier = {
		0.65,
        0.45
	}

    self.definitions.player_revive_interaction_speed_multiplier2 = {
		name_id = "menu_player_revive_interaction_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "revive_interaction_speed_multiplier",
			category = "player"
		}
	}

    --inspire
    self.values.cooldown.long_dis_revive = {
		{
			0.5,
			30
		}
	}

    --chain inspire
    self.values.player.chain_inspire = {
		true
	}
    self.definitions.player_chain_inspire = {
		name_id = "menu_player_chain_inspire",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "chain_inspire",
			category = "player"
		}
	}

    --scavenger
    self.values.player.increased_pickup_area = {
        1.5
	}

    --Fully Loaded + Buff + Fixes
	self.values.player.regain_throwable_from_ammo = {
		{
			chance = 0.1,
			chance_inc = 0.02
		},
		{
			chance = 0.16,
			chance_inc = 0.04
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

	--heavy impact
	self.values.weapon.knock_down = {
		0.05,
		0.25
	}

    --feign death
    self.values.player.cheat_death_chance = {
		0.3,
		0.5
	}

	--Berserker
	self.values.player.melee_damage_health_ratio_multiplier = {
		2.75
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
		0.8,
		0.5
	}
	self.values.player.max_health_reduction = {
		0.36
	}

    --Specialized Killer (modded)
	self.values.weapon.silencer_damage_multiplier = {
		1.15,
		1.35
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
		0.4
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
    self.values.weapon.silencer_special_damage_multiplier = {
		1.2,
		1.7
	}
	self.definitions.weapon_silencer_special_damage_multiplier_1 = {
		category = "feature",
		name_id = "silencer_special_damage_multiplier",
		upgrade = {
			category = "weapon",
			upgrade = "silencer_special_damage_multiplier",
			value = 1
		}
	}
	self.definitions.weapon_silencer_special_damage_multiplier_2 = {
		category = "feature",
		name_id = "silencer_special_damage_multiplier",
		upgrade = {
			category = "weapon",
			upgrade = "silencer_special_damage_multiplier",
			value = 2
		}
	}

    --heat to damage / heavy impact (modded)
    self.values.weapon.heat_to_damage = {
		1.1,
		1.15
	}
	self.definitions.weapon_heat_to_damage_1 = {
		category = "feature",
		name_id = "heat_to_damage",
		upgrade = {
			category = "weapon",
			upgrade = "heat_to_damage",
			value = 1
		}
	}
	self.definitions.weapon_heat_to_damage_2 = {
		category = "feature",
		name_id = "heat_to_damage",
		upgrade = {
			category = "weapon",
			upgrade = "heat_to_damage",
			value = 2
		}
	}

    --heat to overkill
    self.values.temporary.heat_to_overkill = {
		{
			1,
			2
		}
	}
    self.definitions.temporary_heat_to_overkill_1 = {
		name_id = "menu_temporary_heat_to_overkill",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "heat_to_overkill",
			category = "temporary"
		}
	}

	--Inspire Cooldown Reduce
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

	--Close Hostage Fear Enemies
	self.values.player.close_hostage_fear = {
		true
	}
    self.definitions.player_close_hostage_fear = {
		name_id = "menu_player_close_hostage_fear",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "close_hostage_fear",
			category = "player"
		}
	}

	--Stockholm Syndrome Replenish
	self.values.player.replenish_super_syndrome_chance = {0.25}
	self.definitions.player_replenish_super_syndrome_chance = {
		name_id = "menu_player_replenish_super_syndrome_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "replenish_super_syndrome_chance",
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

	--Revive relief
	self.values.player.reviving_relief = {
		0.05
	}
	self.definitions.player_reviving_relief_1 = {
		category = "feature",
		name_id = "menu_player_reviving_relief",
		upgrade = {
			category = "player",
			upgrade = "reviving_relief",
			value = 1
		}
	}
end