--[[
Here is I give some notes

recoil = Stability
spread = Accuracy
spread_moving = ????
spread_multi = ????
moving_spread = ????
Damage = Damage
Suppression = Threat
Alert_size = Alert sound (higger = silent)
Concealment = Concealment
Value = ???
Extra_ammo = Mag_extra
]]

local initwf_pd2 = WeaponFactoryTweakData.init
 
function WeaponFactoryTweakData:init(tweak_data)
    initwf_pd2(self, tweak_data)
	
	---Modification---
	--body--
	self.parts.wpn_fps_saw_body_silent.stats = {value = 1, suppression = 9, alert_size = 12} --SAW Silent Motor						--- # Butchermod Special
	self.parts.wpn_fps_saw_body_speed.stats = {value = 1, damage = 4, suppression = -3} --SAW Speed Motor								--- # Butchermod Special

	--barrel ext
	-- -1 star
	self.parts.wpn_fps_upg_ns_ass_smg_large.stats = {value = 5, suppression = 12, alert_size = 12, damage = -1, recoil = 1, spread_moving = 2, spread = 2, concealment = -3} --The Bigger The Better suppressor		--- # Basemod SMG Rifle Ext
	
	-- -3 stars
	self.parts.wpn_fps_upg_ns_ass_smg_medium.stats = {value = 2, suppression = 12, alert_size = 12, damage = -3, recoil = 1, spread = 1, concealment = -2} --Medium suppressor
	--self.parts.wpn_fps_ass_shak12_ns_suppressor.stats = {alert_size = 12, spread = 3, damage = -2, suppression = 12, value = 1, recoil = 1, concealment = -5 } --KS12 Long silencer								--- # Basemod SMG Rifle Ext
	
	-- -4 stars
	self.parts.wpn_fps_upg_ns_ass_smg_small.stats = {value = 3, suppression = 12, alert_size = 12, damage = -4} --Low Profile suppressor	
	
	--1 star
	self.parts.wpn_fps_upg_ass_ns_battle.stats = {value = 1, damage = 2, spread = 1, concealment = -2} --Ported Compensator
	
	--2 stars
	self.parts.wpn_fps_upg_ass_ns_surefire.stats = {spread = 3, concealment = -2, damage = 1, suppression = 0, value = 5, } --Tactical Compensator	
	
	--3 stars
	self.parts.wpn_fps_lmg_hk51b_ns_jcomp.stats = {value = 1, concealment = -1, damage = 1, spread = 1, recoil = 1, suppression = -1} --Verdunkeln Muzzle Brake
	

	--extra--
	self.parts.wpn_fps_snp_m95_bipod = { 
		a_obj = "a_body", type = "extra",
		name_id = "bm_wp_m14_body_dmr", unit = "units/pd2_dlc_gage_snp/weapons/wpn_fps_snp_m95_pts/wpn_fps_snp_m95_bipod", 
		stats = {value = 1, recoil = 2}
	} --m95 extra bipod
	self.parts.wpn_fps_upg_o_m14_scopemount.stats = {value = 1, spread = 3, concealment = -1}
	
	--grip
	self.parts.wpn_fps_upg_g_m4_surgeon.stats = {spread = 1, concealment = 2, value = 1} --titanium skeleton
	self.parts.wpn_fps_snp_tti_g_grippy.stats = {value = 1, recoil = 2} --contractor grip

	--mag
	self.parts.wpn_fps_upg_m4_m_quad.stats = { extra_ammo = 15, value = 3, 	concealment = -3, spread_moving = -20 } --Car Quadstacked
	self.parts.wpn_fps_upg_ak_m_quad.stats = { extra_ammo = 15, value = 3, 	concealment = -3, spread_moving = -20 } --Ak Quadstacked

	--ammo
	self.parts.wpn_fps_upg_a_custom = {
		pcs = {},
		type = "ammo",
		name_id = "bm_wp_upg_a_custom",
		a_obj = "a_body",
		unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		dlc = "gage_pack_shotgun",
		texture_bundle_folder = "gage_pack_shotgun",
		is_a_unlockable = true,
		stats = {value = 5, damage = 16},
		internal_part = true,
		sub_type = "ammo_custom"
	} --buckshot dlc
	self.parts.wpn_fps_upg_a_custom_free.stats = {value = 5, damage = 15} --buckshot free

	self.parts.wpn_fps_upg_a_mod = {
		pcs = {},
		type = "ammo",
		name_id = "bm_wp_upg_a_custom",
		a_obj = "a_body",
		unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		dlc = "mods",
		is_a_unlockable = true,
		stats = {value = 5},
		internal_part = true,
		sub_type = "ammo_custom"
	}
end