local data = SkillTreeTweakData.init
function SkillTreeTweakData:init(...)
	data(self, ...)
	
	--combat medic
	self.skills.combat_medic = {
		{
			upgrades = {
				"temporary_revive_damage_reduction_1",
				"player_revive_damage_reduction_1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_revive_health_boost",
				--add
				"player_reviving_relief_1"
			},
			cost = self.costs.pro
		},
		name_id = "menu_combat_medic_beta",
		desc_id = "menu_combat_medic_beta_desc",
		icon_xy = {
			5,
			7
		}
	}

	--quick fix
	self.skills.tea_time = {
		{
			upgrades = {
				"first_aid_kit_deploy_time_multiplier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"first_aid_kit_damage_reduction_upgrade",
				--moved from tea_cookies (uppers)
				"first_aid_kit_auto_recovery_1"
			},
			cost = self.costs.pro
		},
		name_id = "menu_tea_time_beta",
		desc_id = "menu_tea_time_beta_desc",
		icon_xy = {
			1,
			11
		}
	}

	--pain killer
	self.skills.fast_learner = {
		{
			upgrades = {
				"player_revive_damage_reduction_level_1",
				--add
				"player_pain_killer_a1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_revive_damage_reduction_level_2",
				--add
				"player_pain_killer_a2"
			},
			cost = self.costs.pro
		},
		name_id = "menu_fast_learner_beta",
		desc_id = "menu_fast_learner_beta_desc",
		icon_xy = {
			0,
			10
		}
	}

	--uppers
	self.skills.tea_cookies = {
		{
			upgrades = {
				"first_aid_kit_quantity_increase_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"first_aid_kit_quantity_increase_2",
				--add
				"first_aid_kit_downs_restore_chance"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_tea_cookies_beta",
		desc_id = "menu_tea_cookies_beta_desc",
		icon_xy = {
			2,
			11
		}
	}

    --combat doctor
    self.skills.medic_2x = {
		{
			upgrades = {
				"doctor_bag_quantity",
                --add
                "player_revive_interaction_speed_multiplier"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"doctor_bag_amount_increase1",
                --add
                "player_revive_interaction_speed_multiplier2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_medic_2x_beta",
		desc_id = "menu_medic_2x_beta_desc",
		icon_xy = {
			5,
			8
		}
	}

    --inspire
    self.skills.inspire = {
		{
			upgrades = {
                --"player_revive_interaction_speed_multiplier",
                "player_morale_boost",
                --moved from aced
                "cooldown_long_dis_revive"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				--addon
				"player_chain_inspire",
				"player_long_dis_reduce" 
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_inspire_beta",
		desc_id = "menu_inspire_beta_desc",
		icon_xy = {
			4,
			9
		}
	}

	--confident
	self.skills.cable_guy = {
		{
			upgrades = {
				"player_intimidate_range_mul",
				"player_intimidate_aura",
				"player_civ_intimidation_mul"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				--add
				"player_hostage_damage_reduction_multiplier_1",
				"player_close_hostage_fear"
			},
			cost = self.costs.pro
		},
		name_id = "menu_cable_guy_beta",
		desc_id = "menu_cable_guy_beta_desc",
		icon_xy = {
			2,
			8
		}
	}

	--joker
	self.skills.joker = {
		{
			upgrades = {
				"player_convert_enemies_damage_multiplier_1",
				"player_convert_enemies",
				"player_convert_enemies_max_minions_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_convert_enemies_damage_multiplier_2",
				"player_convert_enemies_interaction_speed_multiplier",
				--addon
				"player_passive_convert_enemies_damage_multiplier" 
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_joker_beta",
		desc_id = "menu_joker_beta_desc",
		icon_xy = {
			6,
			8
		}
	}

	--stockholm syndrome
	self.skills.stockholm_syndrome = {
		{
			upgrades = {
				"player_civ_calming_alerts",
				--moved from aced
				"player_super_syndrome_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				--add
				"player_replenish_super_syndrome_chance"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_stockholm_syndrome_beta",
		desc_id = "menu_stockholm_syndrome_beta_desc",
		icon_xy = {
			3,
			8
		}
	}

	--partner in crime
	self.skills.control_freak = {
		{
			upgrades = {
				"player_minion_master_speed_multiplier",
				"player_passive_convert_enemies_health_multiplier_1",
				--moved from cable_guy aced (confident)
				"player_convert_enemies_max_minions_2" 
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_minion_master_health_multiplier",
				"player_passive_convert_enemies_health_multiplier_2",
				--add
				"player_convert_enemies_health_multiplier"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_control_freak_beta",
		desc_id = "menu_control_freak_beta_desc",
		icon_xy = {
			1,
			10
		}
	}

	--shock and awe
	self.skills.iron_man = {
		{
			upgrades = {
				"team_armor_regen_time_multiplier",
				--add
				"player_damage_taken_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				--add
				"player_damage_taken_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_iron_man_beta",
		desc_id = "menu_iron_man_beta_desc",
		icon_xy = {
			8,
			10
		}
	}

	--resilience
	self.skills.oppressor = {
		{
			upgrades = {
				"player_armor_regen_time_mul_1",
				--moved from oppressor aced (resilience)
				"player_flashbang_multiplier_1"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_flashbang_multiplier_2"
			},
			cost = self.costs.pro
		},
		name_id = "menu_oppressor_beta",
		desc_id = "menu_oppressor_beta_desc",
		icon_xy = {
			2,
			12
		}
	}

    --scavenger
    self.skills.scavenging = {
		{
			upgrades = {
                --moved from bandoliers (fully loaded)
				"player_pick_up_ammo_multiplier",
                "player_regain_throwable_from_ammo_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_double_drop_1",
                --up to aced
                "player_increased_pickup_area_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_scavenging_beta",
		desc_id = "menu_scavenging_beta_desc",
		icon_xy = {
			8,
			11
		}
	}

    --fully loaded
    self.skills.bandoliers = {
		{
			upgrades = {
				"extra_ammo_multiplier1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_pick_up_ammo_multiplier_2",
                --add
				"player_regain_throwable_from_ammo_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_bandoliers_beta",
		desc_id = "menu_bandoliers_beta_desc",
		icon_xy = {
			3,
			0
		}
	}

	--jack of all trades
	self.skills.jack_of_all_trades = {
		{
			upgrades = {
				"deploy_interact_faster_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_second_deployable_mul_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_jack_of_all_trades_beta",
		desc_id = "menu_jack_of_all_trades_beta_desc",
		icon_xy = {
			9,
			4
		}
	}

	--more fire power
	self.skills.more_fire_power = {
		{
			upgrades = {
				"shape_charge_quantity_increase_1",
				"trip_mine_quantity_increase_1",
				--moved from fire_trap (fire trap)
				"trip_mine_fire_trap_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"shape_charge_quantity_increase_2",
				"trip_mine_quantity_increase_2",
				--moved from fire_trap (fire trap)
				"trip_mine_fire_trap_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_more_fire_power",
		desc_id = "menu_more_fire_power_desc",
		icon_xy = {
			9,
			7
		}
	}

	--fire trap
	self.skills.fire_trap = {
		{
			upgrades = {
				"player_demo_expert_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_demo_expert_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_fire_trap_beta",
		desc_id = "menu_fire_trap_beta_desc",
		icon_xy = {
			4, --9
			11 --9
		}
	}

    --steady grip
    self.skills.steady_grip = {
		{
			upgrades = {
				"player_weapon_accuracy_increase_1",
                --moved from heavy_impact (heavy impact)
                "weapon_knock_down_2"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_stability_increase_bonus_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_steady_grip_beta",
		desc_id = "menu_steady_grip_beta_desc",
		icon_xy = {
			9,
			11
		}
	}

    --fire control
	self.skills.fire_control = {
		{
			upgrades = {
				"player_hip_fire_accuracy_inc_1",
                --moved from iron_man (shock and awe)
                "player_shield_knock"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_weapon_movement_stability_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_fire_control_beta",
		desc_id = "menu_fire_control_beta_desc",
		icon_xy = {
			9,
			10
		}
	}

    --heavy impact (modded)
    self.skills.heavy_impact = {
		{
			upgrades = {
				"weapon_heat_to_damage_1"--"weapon_knock_down_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"weapon_heat_to_damage_2",--"weapon_knock_down_2"
                "temporary_heat_to_overkill_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_heavy_impact_beta",
		desc_id = "menu_heavy_impact_beta_desc",
		icon_xy = {
			10,
			1
		}
	}

	--Nimble (modded)
	self.skills.second_chances = {
		{
			upgrades = {
				"player_tape_loop_duration_1",
				"player_tape_loop_duration_2"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_pick_lock_hard",
				"player_pick_lock_easy_speed_multiplier",
				--moved from ecm overdrive
				"ecm_jammer_can_open_sec_doors"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_second_chances_beta",
		desc_id = "menu_second_chances_beta_desc",
		icon_xy = {
			10,
			4
		}
	}

	--ecm specialist (modded)
	self.skills.ecm_2x = {
		{
			upgrades = {
				"ecm_jammer_quantity_increase_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"ecm_jammer_affects_pagers",
				--moved from ecm overdrive
				"ecm_jammer_duration_multiplier",
				"ecm_jammer_feedback_duration_boost"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_ecm_2x_beta",
		desc_id = "menu_ecm_2x_beta_desc",
		icon_xy = {
			3,
			4
		}
	}

	--ecm overdrive (modded)
	self.skills.ecm_booster = {
		{
			upgrades = {
				--moved from ecm specialist
				"ecm_jammer_duration_multiplier_2",
				"ecm_jammer_feedback_duration_boost_2",
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				--add
				"player_ninja_escape_move",
				"player_suspicious_movement"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_ecm_booster_beta",
		desc_id = "menu_ecm_booster_beta_desc",
		icon_xy = {
			0,
			4
		}
		--[[icon_xy = {
			0,
			3
		}]]
	}

    --second wind
    self.skills.scavenger = {
		{
			upgrades = {
				"temporary_damage_speed_multiplier"
			},
			cost = self.costs.default
		},
		{
			upgrades = {
				"player_team_damage_speed_multiplier_send",
				--moved from dire_need (dire need)
				"player_armor_depleted_stagger_shot_1"
			},
			cost = self.costs.pro
		},
		name_id = "menu_scavenger_beta",
		desc_id = "menu_scavenger_beta_desc",
		icon_xy = {
			10,
			9
		}
	}

    --low blow
    self.skills.backstab = {
		{
			upgrades = {
				"player_detection_risk_add_crit_chance_1",
                --moved from optic_illusions (optic illusions)
                "player_camouflage_bonus_1",
				"player_camouflage_bonus_2"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"player_detection_risk_add_crit_chance_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_backstab_beta",
		desc_id = "menu_backstab_beta_desc",
		icon_xy = {
			0,
			12
		}
	}

    --the professional
    self.skills.silence_expert = {
		{
			upgrades = {
				"weapon_silencer_recoil_index_addend",
				"weapon_silencer_enter_steelsight_speed_multiplier"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"weapon_silencer_spread_index_addend",
                --add
                "player_silencer_concealment_penalty_decrease_1",
				"player_silencer_concealment_increase_1"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_silence_expert_beta",
		desc_id = "menu_silence_expert_beta_desc",
		icon_xy = {
			4,
			4
		}
	}

    --optic illusion / specialized killing (modded)
    self.skills.optic_illusions = {
		{
			upgrades = {
				"weapon_silencer_special_damage_multiplier_1",
                "weapon_silencer_armor_piercing_chance_1"
			},
			cost = self.costs.hightier
		},
		{
			upgrades = {
				"weapon_silencer_special_damage_multiplier_2",
                "weapon_silencer_armor_piercing_chance_2"
			},
			cost = self.costs.hightierpro
		},
		name_id = "menu_optic_illusions",
		desc_id = "menu_optic_illusions_desc",
		icon_xy = {
			5,
			9
		}
	}

	--Trees Changes
	self.trees[4].tiers = {
		{
			"underdog"
		},
		{
			"close_by",
			"far_away"
		},
		{
			"shotgun_cqb",
			"shotgun_impact"
		},
		{
			"overkill"
		}
	}
    self.trees[5].tiers = {
		{
            "oppressor"
        },
        {
            "pack_mule",
            "iron_man"
        },
        {
            "show_of_force",
            "prison_wife"
        },
        {
            "juggernaut"
        }
	}
    self.trees[9].tiers = {
        {
            "steady_grip"
        },
        {
            "fast_fire",
            "fire_control"
        },
        {
            "shock_and_awe",
            "heavy_impact"
        },
        {
            "body_expertise"
        }
    }
	self.trees[10].tiers = {
		{
			"jail_workout"
		},
		{
			"second_chances",
			"chameleon"
		},
		{
			"ecm_2x",
			"cleaner"
		},
		{
			"ecm_booster"
		}
	}
    self.trees[12].tiers = {
        {
            "scavenger"
        },
        {
            "backstab",
            "silence_expert"
        },
        {
            "unseen_strike",
            "hitman"
        },
        {
            "optic_illusions"
        }
    }

	self.default_upgrades = {
		"player_fall_damage_multiplier",
		"player_fall_health_damage_multiplier",
		"player_silent_kill",
		"player_primary_weapon_when_downed",
		"player_intimidate_enemies",
		"player_special_enemy_highlight",
		"player_hostage_trade",
		"player_sec_camera_highlight",
		"player_corpse_dispose",
		"player_corpse_dispose_amount_1",
		"player_civ_harmless_melee",
		"player_walk_speed_multiplier",
		"player_steelsight_when_downed",
		"player_crouch_speed_multiplier",
		"carry_interact_speed_multiplier_1",
		"carry_interact_speed_multiplier_2",
		"carry_movement_speed_multiplier",
		"trip_mine_sensor_toggle",
		"trip_mine_sensor_highlight",
		"trip_mine_can_switch_on_off",
		"ecm_jammer_can_activate_feedback",
		"ecm_jammer_interaction_speed_multiplier",
		"ecm_jammer_can_retrigger",
		"ecm_jammer_affects_cameras",
		"striker_reload_speed_default",
		"temporary_first_aid_damage_reduction",
		--removed unused ovk? "temporary_passive_revive_damage_reduction_2",
		"akimbo_recoil_index_addend_1",
		"doctor_bag",
		"ammo_bag",
		"trip_mine",
		"ecm_jammer",
		"first_aid_kit",
		"sentry_gun",
		"bodybags_bag",
		"saw",
		"cable_tie",
		"jowi",
		"x_1911",
		"x_b92fs",
		"x_deagle",
		"x_g22c",
		"x_g17",
		"x_usp",
		"x_sr2",
		"x_mp5",
		"x_akmsu",
		"x_packrat",
		"x_p226",
		"x_m45",
		"x_mp7",
		"x_ppk",
		--moved from jack_of_all_trades (jack of all trades)
		"second_deployable_1",
		--moved from heavy_impact (heavy impact)
		"weapon_knock_down_1"
	}
    
end