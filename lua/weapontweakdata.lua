local PICKUP = {
	SNIPER_HIGH_DAMAGE = 6,
	SHOTGUN_HIGH_CAPACITY = 4,
	AR_HIGH_CAPACITY = 2,
	OTHER = 1,
	SNIPER_LOW_DAMAGE = 5,
	AR_MED_CAPACITY = 3
}

local CATIDX = {
	OTHER = 0,
	SNIPER_HEAVY = 1,
	SNIPER_HIGH_DAMAGE = 2,
	SNIPER_SEMI_AUTO = 3,
	SNIPER = 4,
	REPEATER = 5,
	DMR = 6,
	AR_HEAVY = 7,
	AR_LIGHT = 8,
	SHOTGUN_HIGH_DAMAGE = 9,
	SHOTGUN_HIGH_CAPACITY = 10,
	LMG_LOW_RATE = 11,
	LMG_HIGH_RATE = 12,
	REVOLVER = 13,
	PISTOL_AP = 14,
	PISTOL_HEAVY = 14,
	PISTOL_AUTO = 15,
	PISTOL_LIGHT = 16,
	SMG_HIGH_DAMAGE = 17,
	SMG_LOW_CAPACITY = 18,
	SMG_LIGHT = 19,
	MINIGUN = 20,
	GL_HIGH_CAPACITY = 21,
	GL_LOW_CAPACITY = 22,
	FLAMETHROWER = 23,
	ROCKET = 24,
	XBOW = 25,
	BOW = 26,
	AIR_BOW = 27,
	MICRO = 28
}

function WeaponTweakData:_pickup_chance(max_ammo, selection_index)
	local low, high = nil

	if _G.IS_VR then
		if selection_index == PICKUP.AR_HIGH_CAPACITY then
			low = 0.03
			high = 0.055
		elseif selection_index == PICKUP.AR_MED_CAPACITY then
			low = 0.03
			high = 0.055
		elseif selection_index == PICKUP.SHOTGUN_HIGH_CAPACITY then
			low = 0.05
			high = 0.075
		elseif selection_index == PICKUP.SNIPER_LOW_DAMAGE then
			low = 0.05
			high = 0.075
		elseif selection_index == PICKUP.SNIPER_HIGH_DAMAGE then
			low = 0.005
			high = 0.015
		else
			low = 0.01
			high = 0.035
		end
	elseif selection_index == PICKUP.AR_HIGH_CAPACITY then
		low = 0.04
		high = 0.09
	elseif selection_index == PICKUP.AR_MED_CAPACITY then
		low = 0.04
		high = 0.08
	elseif selection_index == PICKUP.SHOTGUN_HIGH_CAPACITY then
		low = 0.05
		high = 0.1
	elseif selection_index == PICKUP.SNIPER_LOW_DAMAGE then
		low = 0.035
		high = 0.085
	elseif selection_index == PICKUP.SNIPER_HIGH_DAMAGE then
		low = 0.005
		high = 0.055
	else
		low = 0.025
		high = 0.075
	end

	return {
		max_ammo * low,
		max_ammo * high
	}
end

local old_init = WeaponTweakData.init

function WeaponTweakData:init(tweak_data)
	old_init(self, tweak_data)

	--SNIPER
	--EXTREME DAMAGE
	--m95 / Thanatos
	self.m95.CLIP_AMMO_MAX = 5
	self.m95.NR_CLIPS_MAX = 4
	self.m95.AMMO_MAX = self.m95.CLIP_AMMO_MAX * self.m95.NR_CLIPS_MAX
	self.m95.AMMO_PICKUP = {0.05, 0.8}
	self.m95.stats.damage = 140
	self.m95.stats_modifiers.damage = 25
	
	--HIGH DAMAGE
	--model70 / Platypus
	self.model70.CLIP_AMMO_MAX = 5
	self.model70.NR_CLIPS_MAX = 7
	self.model70.AMMO_MAX = self.model70.CLIP_AMMO_MAX * self.model70.NR_CLIPS_MAX
	self.model70.AMMO_PICKUP =  {0.2, 1.275}
	self.model70.stats.alert_size = 10
	self.model70.stats.damage = 83
	self.model70.stats_modifiers.damage = 4

	--R93
	self.r93.CLIP_AMMO_MAX = 6
	self.r93.NR_CLIPS_MAX = 6
	self.r93.AMMO_MAX = self.r93.CLIP_AMMO_MAX * self.r93.NR_CLIPS_MAX
	self.r93.AMMO_PICKUP = { 0.15, 1.25 }
	self.r93.stats.alert_size = 10
	self.r93.stats.damage = 86
	self.r93.stats_modifiers.damage = 4

	--mosin / Nagant
	self.mosin.CLIP_AMMO_MAX = 5
	self.mosin.NR_CLIPS_MAX = 6
	self.mosin.AMMO_MAX = self.mosin.CLIP_AMMO_MAX * self.mosin.NR_CLIPS_MAX
	self.mosin.AMMO_PICKUP = { 0.15, 1.35 }
	self.mosin.stats.alert_size = 10
	self.mosin.stats.damage = 84
	self.mosin.stats_modifiers.damage = 4

	--Desertfox
	self.desertfox.CLIP_AMMO_MAX = 5
	self.desertfox.NR_CLIPS_MAX = 8
	self.desertfox.AMMO_MAX = self.desertfox.CLIP_AMMO_MAX * self.desertfox.NR_CLIPS_MAX
	self.desertfox.AMMO_PICKUP = { 0.15, 1.3 }
	self.desertfox.stats.alert_size = 10
	self.desertfox.stats.damage = 81
	self.desertfox.stats_modifiers.damage = 4

	--[[
		M95 : (+) Extremely high damage (-) Low Ammo (-) Low Concealment (-) Extremely Low Ammo Pickup chance
		R93 : (+) High Damage+3 (-) Low Ammo (-) Low Concealment (-) Low Ammo Pickup chance+1
		Mosin : (+) High Damage+2 (+) Average Ammo (-) Low Concealment (-) Low Ammo Pickup chance+3
		Model70 : (+) High Damage+1 (+) Average Ammo+1 (-) Low Concealment (-) Low Ammo Pickup chance
		Desertfox : (+) High Damage (+) Average Ammo+2 (+) High Concealment (-) Low Ammo Pickup chance+2
	]]--
	
	--LOW DAMAGE
	--msr / Rattlesnake
	self.msr.CLIP_AMMO_MAX = 10
	self.msr.NR_CLIPS_MAX = 5
	self.msr.AMMO_MAX = self.msr.CLIP_AMMO_MAX * self.msr.NR_CLIPS_MAX
	self.msr.AMMO_PICKUP = { 0.25, 1.4 }
	self.msr.stats.alert_size = 10
	self.msr.stats.damage = 145
	self.msr.stats_modifiers.damage = 2

	--R700
	self.r700.CLIP_AMMO_MAX = 10
	self.r700.NR_CLIPS_MAX = 5
	self.r700.AMMO_MAX = self.r700.CLIP_AMMO_MAX * self.r700.NR_CLIPS_MAX
	self.r700.AMMO_PICKUP = {0.25, 1.45}
	self.r700.stats.alert_size = 10
	self.r700.stats.damage = 140
	self.r700.stats_modifiers.damage = 2

	--SNIPER SEMI AUTO
	--wa2000 / Lebensauger
	self.wa2000.CLIP_AMMO_MAX = 10
	self.wa2000.NR_CLIPS_MAX = 5
	self.wa2000.AMMO_MAX = self.wa2000.CLIP_AMMO_MAX * self.wa2000.NR_CLIPS_MAX
	self.wa2000.AMMO_PICKUP = { 0.25, 2.55 }
	self.wa2000.stats.alert_size = 10
	self.wa2000.stats.damage = 110
	self.wa2000.stats_modifiers.damage = 2

	--tti / Contractor
	self.tti.CLIP_AMMO_MAX = 20
	self.tti.NR_CLIPS_MAX = 3
	self.tti.AMMO_MAX = self.tti.CLIP_AMMO_MAX * self.tti.NR_CLIPS_MAX
	self.tti.AMMO_PICKUP = { 0.25, 2.65 } 
	self.tti.stats.alert_size = 10
	self.tti.stats.damage = 107
	self.tti.stats_modifiers.damage = 2

	--siltstone _grv / Grom
	self.siltstone.CLIP_AMMO_MAX = 10
	self.siltstone.NR_CLIPS_MAX = 5
	self.siltstone.AMMO_MAX = self.siltstone.CLIP_AMMO_MAX * self.siltstone.NR_CLIPS_MAX
	self.siltstone.AMMO_PICKUP = { 0.27, 2.6 }
	self.siltstone.stats.alert_size = 10
	self.siltstone.stats.damage = 110
	self.siltstone.stats_modifiers.damage = 2

	--REPEATER
	--winchester1874 / Repeater 1874
	self.winchester1874.fire_mode_data = {
		fire_rate = 0.35
	}
	self.winchester1874.single = {
		fire_rate = 0.35
	}
	self.winchester1874.CLIP_AMMO_MAX = 15
	self.winchester1874.NR_CLIPS_MAX = 4
	self.winchester1874.AMMO_MAX = self.winchester1874.CLIP_AMMO_MAX * self.winchester1874.NR_CLIPS_MAX
	self.winchester1874.AMMO_PICKUP = { 0.25, 3 } --self:_pickup_chance(self.winchester1874.AMMO_MAX, PICKUP.SNIPER_LOW_DAMAGE)
	self.winchester1874.stats.alert_size = 10
	self.winchester1874.stats.damage = 130
	self.winchester1874.stats_modifiers.damage = 2

	--sbl / Bernetti Rangehitter
	self.sbl.fire_mode_data = {
		fire_rate = 0.25
	}
	self.sbl.single = {
		fire_rate = 0.25
	}
	self.sbl.CLIP_AMMO_MAX = 10
	self.sbl.NR_CLIPS_MAX = 5
	self.sbl.AMMO_MAX = self.sbl.CLIP_AMMO_MAX * self.sbl.NR_CLIPS_MAX
	self.sbl.AMMO_PICKUP = { 0.25, 3.2 } --self:_pickup_chance(self.sbl.AMMO_MAX, PICKUP.SNIPER_LOW_DAMAGE)
	self.sbl.stats.damage = 120
	self.sbl.stats.alert_size = 7
	self.sbl.stats_modifiers.damage = 2

	--DMR
	--new_m14 / m308
	self.new_m14.CLIP_AMMO_MAX = 10
	self.new_m14.NR_CLIPS_MAX = 7
	self.new_m14.AMMO_MAX = self.new_m14.CLIP_AMMO_MAX * self.new_m14.NR_CLIPS_MAX
	self.new_m14.AMMO_PICKUP = { 0.27, 3.5 } --self:_pickup_chan(self.new_m14.AMMO_MAX, CATIDX.DMR, 4)
	self.new_m14.stats.damage = 175
	self.new_m14.can_shoot_through_enemy = true
	self.new_m14.armor_piercing_chance = 1

	--ching / Galant
	self.ching.CLIP_AMMO_MAX = 8
	self.ching.NR_CLIPS_MAX = 9
	self.ching.AMMO_MAX = self.ching.CLIP_AMMO_MAX * self.ching.NR_CLIPS_MAX
	self.ching.AMMO_PICKUP = { 0.27, 3.55 } --self:_pickup_chan(self.ching.AMMO_MAX, CATIDX.DMR, 4)
	self.ching.stats.damage = 170
	self.new_m14.can_shoot_through_enemy = true
	self.ching.armor_piercing_chance = 1

	-- contraband & contraband m203 / Little Friend
	self.contraband.CLIP_AMMO_MAX = 20
	self.contraband.NR_CLIPS_MAX = 3
	self.contraband.AMMO_MAX = self.contraband.CLIP_AMMO_MAX * self.contraband.NR_CLIPS_MAX
	self.contraband.AMMO_PICKUP = {0.27, 3.3} --self:_pickup_chan(self.contraband.AMMO_MAX, CATIDX.DMR, 6) 
	self.contraband.stats.damage = 170
	self.contraband.armor_piercing_chance = 0.4
	self.contraband_m203.CLIP_AMMO_MAX = 1
	self.contraband_m203.NR_CLIPS_MAX = 3
	self.contraband_m203.AMMO_MAX = self.contraband_m203.CLIP_AMMO_MAX * self.contraband_m203.NR_CLIPS_MAX
	self.contraband_m203.AMMO_PICKUP = {0.2, 0.75}

	--sub2000 / Cavity 9mm
	self.sub2000.CLIP_AMMO_MAX = 33
	self.sub2000.NR_CLIPS_MAX = 3
	self.sub2000.AMMO_MAX = self.sub2000.CLIP_AMMO_MAX * self.sub2000.NR_CLIPS_MAX + 1
	self.sub2000.AMMO_PICKUP = {0.27, 3.65}
	self.sub2000.stats.damage = 168
	self.sub2000.armor_piercing_chance = 1

	--Semi DMR
	--g3 / Ghewer 3 [ModKit]
	self.g3.CLIP_AMMO_MAX = 20
	self.g3.NR_CLIPS_MAX = 5
	self.g3.AMMO_MAX = self.g3.CLIP_AMMO_MAX * self.g3.NR_CLIPS_MAX
	self.g3.AMMO_PICKUP = {0.3, 3.6}
	self.g3.stats.damage = 112

	--fal / Falcon [ModKit]
	self.fal.CLIP_AMMO_MAX = 20
	self.fal.NR_CLIPS_MAX = 5
	self.fal.AMMO_MAX = self.fal.CLIP_AMMO_MAX * self.fal.NR_CLIPS_MAX
	self.fal.AMMO_PICKUP = {0.32, 3.6} --self:_pickup_chan(self.fal.CLIP_AMMO_MAX, CATIDX.DMR, 2)
	self.fal.stats.damage = 111
	self.fal.armor_piercing_chance = 0.5

	--scar / Eagle Heavy
	self.scar.CLIP_AMMO_MAX = 20
	self.scar.NR_CLIPS_MAX = 5
	self.scar.AMMO_MAX = self.scar.CLIP_AMMO_MAX * self.scar.NR_CLIPS_MAX
	self.scar.AMMO_PICKUP = {0.32, 3.6} --self:_pickup_chan(self.scar.CLIP_AMMO_MAX, CATIDX.DMR, 2)
	self.scar.stats.damage = 111
	self.scar.armor_piercing_chance = 0.5

	--AR HEAVY (DMG-5) > 90
	--akm / AK.762 [Hybrid DMR +2]
	self.akm.CLIP_AMMO_MAX = 30
	self.akm.NR_CLIPS_MAX = 3
	self.akm.AMMO_MAX = self.akm.CLIP_AMMO_MAX * self.akm.NR_CLIPS_MAX
	self.akm.AMMO_PICKUP = {0.3, 3.6} --self:_pickup_chan(self.akm.CLIP_AMMO_MAX, CATIDX.DMR, 1)
	self.akm.stats.damage = 95
	
	--akm_gold / AK.762 G [Hybrid DMR +2]
	self.akm_gold.CLIP_AMMO_MAX = 30
	self.akm_gold.NR_CLIPS_MAX = 3
	self.akm_gold.AMMO_MAX = self.akm_gold.CLIP_AMMO_MAX * self.akm_gold.NR_CLIPS_MAX
	self.akm_gold.AMMO_PICKUP = {0.33, 3.6} --self:_pickup_chan(self.akm.CLIP_AMMO_MAX, CATIDX.DMR, 1)
	self.akm_gold.stats.damage = 95
	self.akm_gold.stats.suppression = 7

	--flint / AK17
	self.flint.CLIP_AMMO_MAX = 35
	self.flint.NR_CLIPS_MAX = 4
	self.flint.AMMO_MAX = self.flint.CLIP_AMMO_MAX * self.flint.NR_CLIPS_MAX
	self.flint.AMMO_PICKUP = {0.4, 3.6}
	self.flint.stats.damage = 96

	--m16 / AMR-16
	self.m16.CLIP_AMMO_MAX = 30
	self.m16.NR_CLIPS_MAX = 3
	self.m16.AMMO_MAX = self.m16.CLIP_AMMO_MAX * self.m16.NR_CLIPS_MAX
	self.m16.AMMO_PICKUP = {0.35, 4} --self:_pickup_chan(self.m16.CLIP_AMMO_MAX, CATIDX.DMR, 1)
	self.m16.stats.damage = 92

	--AR AVERAGE 50 < (DMG+3) < 90
	--komodo / Tempest-21
	self.komodo.CLIP_AMMO_MAX = 30
	self.komodo.NR_CLIPS_MAX = 5
	self.komodo.AMMO_MAX = self.komodo.CLIP_AMMO_MAX * self.komodo.NR_CLIPS_MAX
	self.komodo.AMMO_PICKUP = {1.35, 8} --self:_pickup_chance(self.komodo.AMMO_MAX, 3)
	self.komodo.panic_suppression_chance = 0.2
	self.komodo.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 58,
		alert_size = 8,
		spread = 16,
		spread_moving = 15,
		recoil = 14,
		value = 9,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 26
	}

	--corgi / Union
	self.corgi.CLIP_AMMO_MAX = 30
	self.corgi.NR_CLIPS_MAX = 5
	self.corgi.AMMO_MAX = self.corgi.CLIP_AMMO_MAX * self.corgi.NR_CLIPS_MAX
	self.corgi.AMMO_PICKUP = {4, 8} --self:_pickup_chance(self.corgi.AMMO_MAX, 3)
	self.corgi.panic_suppression_chance = 0.2
	self.corgi.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 58,
		alert_size = 8,
		spread = 18,
		spread_moving = 15,
		recoil = 18,
		value = 9,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 20
	}

	--vhs / Lion Roar
	self.vhs.CLIP_AMMO_MAX = 30
	self.vhs.NR_CLIPS_MAX = 5
	self.vhs.AMMO_MAX = self.vhs.CLIP_AMMO_MAX * self.vhs.NR_CLIPS_MAX
	self.vhs.AMMO_PICKUP = {4, 8} --self:_pickup_chance(self.vhs.AMMO_MAX, PICKUP.AR_MED_CAPACITY)
	self.vhs.panic_suppression_chance = 0.2
	self.vhs.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 58,
		alert_size = 8,
		spread = 16,
		spread_moving = 15,
		recoil = 16,
		value = 9,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 17
	}

	--l85a2 / Queen's Wrath
	self.l85a2.CLIP_AMMO_MAX = 30
	self.l85a2.NR_CLIPS_MAX = 5
	self.l85a2.AMMO_MAX = self.l85a2.CLIP_AMMO_MAX * self.l85a2.NR_CLIPS_MAX
	self.l85a2.AMMO_PICKUP = {4, 8.2} --self:_pickup_chance(self.l85a2.AMMO_MAX, PICKUP.AR_MED_CAPACITY)
	self.l85a2.panic_suppression_chance = 0.2
	self.l85a2.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 58,
		alert_size = 8,
		spread = 17,
		spread_moving = 15,
		recoil = 16,
		value = 9,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 16
	}

	--galil / Gecko
	self.galil.CLIP_AMMO_MAX = 30
	self.galil.NR_CLIPS_MAX = 5
	self.galil.AMMO_MAX = self.galil.CLIP_AMMO_MAX * self.galil.NR_CLIPS_MAX
	self.galil.AMMO_PICKUP = {3.8, 8.2} --self:_pickup_chance(self.galil.AMMO_MAX, PICKUP.AR_MED_CAPACITY)
	self.galil.panic_suppression_chance = 0.2
	self.galil.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 57,
		alert_size = 7,
		spread = 13,
		spread_moving = 10,
		recoil = 18,
		value = 4,
		extra_ammo = 51,
		reload = 11,
		suppression = 7,
		concealment = 15
	}

	--ak74 / AK Rifle [Hybrid DMR +1]
	self.ak74.CLIP_AMMO_MAX = 30
	self.ak74.NR_CLIPS_MAX = 5
	self.ak74.AMMO_MAX = self.ak74.CLIP_AMMO_MAX * self.ak74.NR_CLIPS_MAX
	self.ak74.AMMO_PICKUP = {3.8, 8.25} --self:_pickup_chan(self.ak74.CLIP_AMMO_MAX, CATIDX.AR_HEAVY, 4)
	--self.ak74.stats.damage = 70
	self.ak74.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 56,
		alert_size = 7,
		spread = 13,
		spread_moving = 11,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 10,
		concealment = 16
	}
	
	--aug / UAR
	self.aug.CLIP_AMMO_MAX = 30
	self.aug.NR_CLIPS_MAX = 5
	self.aug.AMMO_MAX = self.aug.CLIP_AMMO_MAX * self.aug.NR_CLIPS_MAX
	self.aug.AMMO_PICKUP = {4, 8.25} --self:_pickup_chance(self.aug.AMMO_MAX, PICKUP.AR_MED_CAPACITY)
	self.aug.panic_suppression_chance = 0.2
	self.aug.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 55,
		alert_size = 7,
		spread = 17,
		spread_moving = 15,
		recoil = 11,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 10,
		concealment = 20
	}

	--new_m4 / CAR-4 [Hybrid DMR +1]
	self.new_m4.CLIP_AMMO_MAX = 30
	self.new_m4.NR_CLIPS_MAX = 5
	self.new_m4.AMMO_MAX = self.new_m4.CLIP_AMMO_MAX * self.new_m4.NR_CLIPS_MAX
	self.new_m4.AMMO_PICKUP = {4, 8.25} --self:_pickup_chan(self.new_m4.CLIP_AMMO_MAX, CATIDX.AR_HEAVY, 4)
	--self.new_m4.stats.damage = 65
	self.new_m4.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 52,
		alert_size = 7,
		spread = 12,
		spread_moving = 10,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 10,
		concealment = 20
	}

	--AK5
	self.ak5.CLIP_AMMO_MAX = 30
	self.ak5.NR_CLIPS_MAX = 5
	self.ak5.AMMO_MAX = self.ak5.CLIP_AMMO_MAX * self.ak5.NR_CLIPS_MAX
	self.ak5.AMMO_PICKUP = {4, 8.5} --self:_pickup_chance(self.ak5.AMMO_MAX, PICKUP.AR_MED_CAPACITY)
	self.ak5.panic_suppression_chance = 0.2
	self.ak5.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 55,
		alert_size = 7,
		spread = 16,
		spread_moving = 14,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 10,
		concealment = 18
	}

	--AR LIGHT (DMG+4) < 50
	--g36 / JP36
	self.g36.CLIP_AMMO_MAX = 30
	self.g36.NR_CLIPS_MAX = 8
	self.g36.AMMO_MAX = self.g36.CLIP_AMMO_MAX * self.g36.NR_CLIPS_MAX
	self.g36.AMMO_PICKUP = {4, 11} --self:_pickup_chance(self.g36.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.g36.panic_suppression_chance = 0.2
	self.g36.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 44,
		alert_size = 7,
		spread = 11,
		spread_moving = 9,
		recoil = 17,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 11,
		concealment = 19
	}

	--s552 / Commando
	self.s552.CLIP_AMMO_MAX = 30
	self.s552.NR_CLIPS_MAX = 8
	self.s552.AMMO_MAX = self.s552.CLIP_AMMO_MAX * self.s552.NR_CLIPS_MAX
	self.s552.AMMO_PICKUP = {5, 10} --self:_pickup_chance(self.s552.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.s552.panic_suppression_chance = 0.2
	self.s552.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 42,
		alert_size = 7,
		spread = 10,
		spread_moving = 8,
		recoil = 15,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 22
	}

	--AMCAR
	self.amcar.CLIP_AMMO_MAX = 20
	self.amcar.NR_CLIPS_MAX = 12
	self.amcar.AMMO_MAX = self.amcar.CLIP_AMMO_MAX * self.amcar.NR_CLIPS_MAX
	self.amcar.AMMO_PICKUP = {5, 11.3} --self:_pickup_chance(self.amcar.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.amcar.panic_suppression_chance = 0.2
	self.amcar.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 42,
		alert_size = 7,
		spread = 10,
		spread_moving = 8,
		recoil = 20,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 10,
		concealment = 21
	}

	--asval / Valkyria
	self.asval.CLIP_AMMO_MAX = 20
	self.asval.NR_CLIPS_MAX = 12
	self.asval.AMMO_MAX = self.asval.CLIP_AMMO_MAX * self.asval.NR_CLIPS_MAX
	self.asval.AMMO_PICKUP = {5, 11.5} --self:_pickup_chance(self.asval.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.asval.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 41,
		alert_size = 12,
		spread = 15,
		spread_moving = 8,
		recoil = 17,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 24,
		concealment = 26
	}

	--famas / Clarion
	self.famas.CLIP_AMMO_MAX = 30
	self.famas.NR_CLIPS_MAX = 8
	self.famas.AMMO_MAX = self.famas.CLIP_AMMO_MAX * self.famas.NR_CLIPS_MAX
	self.famas.AMMO_PICKUP = {5, 11.7} --self:_pickup_chance(self.famas.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.famas.panic_suppression_chance = 0.2
	self.famas.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 41,
		alert_size = 7,
		spread = 10,
		spread_moving = 8,
		recoil = 18,
		value = 4,
		extra_ammo = 51,
		reload = 11,
		suppression = 10,
		concealment = 24
	}

	self.tecci.CLIP_AMMO_MAX = 100
	self.tecci.NR_CLIPS_MAX = 2.7
	self.tecci.AMMO_MAX = self.tecci.CLIP_AMMO_MAX * self.tecci.NR_CLIPS_MAX
	self.tecci.AMMO_PICKUP = {6, 12} --self:_pickup_chance(self.tecci.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.tecci.panic_suppression_chance = 0.2
	self.tecci.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 40,
		alert_size = 7,
		spread = 7,
		spread_moving = 10,
		recoil = 14,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 10,
		concealment = 20
	}

	--Akimbo
	--Akimbo Revolver
	--x_2006m / Matever
	self.x_2006m.CLIP_AMMO_MAX = 12
	self.x_2006m.NR_CLIPS_MAX = 5
	self.x_2006m.AMMO_MAX = self.x_2006m.CLIP_AMMO_MAX * self.x_2006m.NR_CLIPS_MAX
	self.x_2006m.AMMO_PICKUP = {0.25, 2.5} --self:_pickup_chance(self.x_2006m.AMMO_MAX, PICKUP.OTHER)
	self.x_2006m.panic_suppression_chance = 0.2
	self.x_2006m.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 185, --180
		alert_size = 7,
		spread = 22,
		spread_moving = 22,
		recoil = 4,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 7,
		concealment = 20
	}

	--x_chinchilla / Castigo
	self.x_chinchilla.CLIP_AMMO_MAX = 12
	self.x_chinchilla.NR_CLIPS_MAX = 6
	self.x_chinchilla.AMMO_MAX = self.x_chinchilla.CLIP_AMMO_MAX * self.x_chinchilla.NR_CLIPS_MAX
	self.x_chinchilla.AMMO_PICKUP = {0.25, 5} --self:_pickup_chance(self.x_chinchilla.AMMO_MAX, PICKUP.OTHER)
	self.x_chinchilla.panic_suppression_chance = 0.2
	self.x_chinchilla.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 180,
		alert_size = 7,
		spread = 20,
		spread_moving = 5,
		recoil = 2,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 7,
		concealment = 28
	}

	--x_rage / Bronco
	self.x_rage.CLIP_AMMO_MAX = 12
	self.x_rage.NR_CLIPS_MAX = 6
	self.x_rage.AMMO_MAX = self.x_rage.CLIP_AMMO_MAX * self.x_rage.NR_CLIPS_MAX
	self.x_rage.AMMO_PICKUP = {0.25, 5.75} --self:_pickup_chance(self.x_rage.AMMO_MAX, PICKUP.OTHER)
	self.x_rage.panic_suppression_chance = 0.2
	self.x_rage.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 180, --175
		alert_size = 7,
		spread = 20,
		spread_moving = 5,
		recoil = 2,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 7,
		concealment = 26
	}

	--x_model3 / Frenchman model 87
	self.x_model3.CLIP_AMMO_MAX = 12
	self.x_model3.NR_CLIPS_MAX = 8
	self.x_model3.AMMO_MAX = self.x_model3.CLIP_AMMO_MAX * self.x_model3.NR_CLIPS_MAX
	self.x_model3.AMMO_PICKUP = {0.25, 6} --self:_pickup_chance(self.x_model3.AMMO_MAX, PICKUP.OTHER)
	self.x_model3.panic_suppression_chance = 0.2
	self.x_model3.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 135, --130
		alert_size = 8,
		spread = 20,
		spread_moving = 5,
		recoil = 8,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 8,
		concealment = 26
	}

	--Akimbo Pistol
	--x_deagle / Deagle
	self.x_deagle.CLIP_AMMO_MAX = 20
	self.x_deagle.NR_CLIPS_MAX = 3
	self.x_deagle.AMMO_MAX = self.x_deagle.CLIP_AMMO_MAX * self.x_deagle.NR_CLIPS_MAX
	self.x_deagle.AMMO_PICKUP = {0.4, 5.5} --self:_pickup_chance(self.x_deagle.AMMO_MAX, PICKUP.OTHER)
	self.x_deagle.panic_suppression_chance = 0.2
	self.x_deagle.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 120,
		alert_size = 7,
		spread = 20,
		spread_moving = 4,
		recoil = 8,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 7,
		concealment = 26
	}

	--x_packrat / Contractor
	self.x_packrat.CLIP_AMMO_MAX = 30
	self.x_packrat.NR_CLIPS_MAX = 3
	self.x_packrat.AMMO_MAX = self.x_packrat.CLIP_AMMO_MAX * self.x_packrat.NR_CLIPS_MAX
	self.x_packrat.AMMO_PICKUP = {1.2, 6.5} --self:_pickup_chance(self.x_packrat.AMMO_MAX, PICKUP.OTHER)
	self.x_packrat.panic_suppression_chance = 0.2
	self.x_packrat.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 66,
		alert_size = 7,
		spread = 18,
		spread_moving = 18,
		recoil = 16,
		value = 4,
		extra_ammo = 51,
		reload = 11,
		suppression = 15,
		concealment = 27
	}

	--x_1911 / Crosskill
	self.x_1911.CLIP_AMMO_MAX = 20
	self.x_1911.NR_CLIPS_MAX = 5
	self.x_1911.AMMO_MAX = self.x_1911.CLIP_AMMO_MAX * self.x_1911.NR_CLIPS_MAX
	self.x_1911.AMMO_PICKUP = {1.2, 6.5} --self:_pickup_chance(self.x_1911.AMMO_MAX, PICKUP.OTHER)
	self.x_1911.panic_suppression_chance = 0.2
	self.x_1911.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 65,
		alert_size = 7,
		spread = 18,
		spread_moving = 18,
		recoil = 14,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 27
	}

	--x_g22c / Chimano Custom
	self.x_g22c.CLIP_AMMO_MAX = 32
	self.x_g22c.NR_CLIPS_MAX = 3
	self.x_g22c.AMMO_MAX = self.x_g22c.CLIP_AMMO_MAX * self.x_g22c.NR_CLIPS_MAX
	self.x_g22c.AMMO_PICKUP = {1.2, 6.7} --self:_pickup_chance(self.x_g22c.AMMO_MAX, PICKUP.OTHER)
	self.x_g22c.panic_suppression_chance = 0.2
	self.x_g22c.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 65,
		alert_size = 7,
		spread = 18,
		spread_moving = 18,
		recoil = 14,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 15,
		concealment = 29
	}

	--x_usp / Interceptor
	self.x_usp.CLIP_AMMO_MAX = 26
	self.x_usp.NR_CLIPS_MAX = 4
	self.x_usp.AMMO_MAX = self.x_usp.CLIP_AMMO_MAX * self.x_usp.NR_CLIPS_MAX
	self.x_usp.AMMO_PICKUP = {1.2, 6.75} --self:_pickup_chance(self.x_usp.AMMO_MAX, PICKUP.OTHER)
	self.x_usp.panic_suppression_chance = 0.2
	self.x_usp.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 65,
		alert_size = 7,
		spread = 18,
		spread_moving = 18,
		recoil = 14,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 16,
		concealment = 29
	}

	--x_holt / HOLT
	self.x_holt.CLIP_AMMO_MAX = 30
	self.x_holt.NR_CLIPS_MAX = 3
	self.x_holt.AMMO_MAX = self.x_holt.CLIP_AMMO_MAX * self.x_holt.NR_CLIPS_MAX
	self.x_holt.AMMO_PICKUP = {1.25, 7} --self:_pickup_chance(self.x_holt.AMMO_MAX, PICKUP.OTHER)
	self.x_holt.panic_suppression_chance = 0.2
	self.x_holt.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 65,
		alert_size = 7,
		spread = 17,
		spread_moving = 18,
		recoil = 18,
		value = 4,
		extra_ammo = 51,
		reload = 11,
		suppression = 15,
		concealment = 28
	}

	--x_shrew / Crosskill Guard
	self.x_shrew.CLIP_AMMO_MAX = 34
	self.x_shrew.NR_CLIPS_MAX = 5
	self.x_shrew.AMMO_MAX = self.x_shrew.CLIP_AMMO_MAX * self.x_shrew.NR_CLIPS_MAX
	self.x_shrew.AMMO_PICKUP = {2, 9.5} --self:_pickup_chance(self.x_shrew.AMMO_MAX, 1)
	self.x_shrew.panic_suppression_chance = 0.2
	self.x_shrew.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 37,
		alert_size = 7,
		spread = 17,
		spread_moving = 14,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 16,
		concealment = 30
	}

	--x_b92fs / Bernetti 9
	self.x_b92fs.CLIP_AMMO_MAX = 28
	self.x_b92fs.NR_CLIPS_MAX = 6
	self.x_b92fs.AMMO_MAX = self.x_b92fs.CLIP_AMMO_MAX * self.x_b92fs.NR_CLIPS_MAX
	self.x_b92fs.AMMO_PICKUP = {2, 9.8} --self:_pickup_chance(self.x_b92fs.AMMO_MAX, PICKUP.OTHER)
	self.x_b92fs.panic_suppression_chance = 0.2
	self.x_b92fs.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 37,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 17,
		concealment = 28
	}

	--x_legacy / M13
	self.x_legacy.CLIP_AMMO_MAX = 26
	self.x_legacy.NR_CLIPS_MAX = 6
	self.x_legacy.AMMO_MAX = self.x_legacy.CLIP_AMMO_MAX * self.x_legacy.NR_CLIPS_MAX
	self.x_legacy.AMMO_PICKUP = {2, 9.8} --self:_pickup_chance(self.x_legacy.AMMO_MAX, PICKUP.OTHER)
	self.x_legacy.panic_suppression_chance = 0.2
	self.x_legacy.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 37,
		alert_size = 7,
		spread = 12,
		spread_moving = 12,
		recoil = 13,
		value = 4,
		extra_ammo = 51,
		reload = 11,
		suppression = 15,
		concealment = 30
	}

	--jowi / Chimano Compact
	self.jowi.CLIP_AMMO_MAX = 20
	self.jowi.NR_CLIPS_MAX = 8
	self.jowi.AMMO_MAX = self.jowi.CLIP_AMMO_MAX * self.jowi.NR_CLIPS_MAX
	self.jowi.AMMO_PICKUP = {1, 10} --self:_pickup_chance(self.jowi.AMMO_MAX, PICKUP.OTHER)
	self.jowi.panic_suppression_chance = 0.2
	self.jowi.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 37,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 15,
		concealment = 30
	}

	--x_g17 / Chimano 88
	self.x_g17.CLIP_AMMO_MAX = 34
	self.x_g17.NR_CLIPS_MAX = 5
	self.x_g17.AMMO_MAX = self.x_g17.CLIP_AMMO_MAX * self.x_g17.NR_CLIPS_MAX
	self.x_g17.AMMO_PICKUP = {2, 10} --self:_pickup_chance(self.x_g17.AMMO_MAX, PICKUP.OTHER)
	self.x_g17.panic_suppression_chance = 0.2
	self.x_g17.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 37,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 16,
		concealment = 30
	}

	--Akimbo Auto Pistol
	--x_stech /Igor Automatik
	self.x_stech.CLIP_AMMO_MAX = 40
	self.x_stech.NR_CLIPS_MAX = 3
	self.x_stech.AMMO_MAX = self.x_stech.CLIP_AMMO_MAX * self.x_stech.NR_CLIPS_MAX
	self.x_stech.AMMO_PICKUP = {1.15, 6.2} --self:_pickup_chance(self.x_stech.AMMO_MAX, PICKUP.OTHER)
	self.x_stech.panic_suppression_chance = 0.2
	self.x_stech.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 65,
		alert_size = 7,
		spread = 15,
		spread_moving = 7,
		recoil = 8,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 16,
		concealment = 25
	}

	--x_czech / Czech 92
	self.x_czech.CLIP_AMMO_MAX = 30
	self.x_czech.NR_CLIPS_MAX = 6
	self.x_czech.AMMO_MAX = self.x_czech.CLIP_AMMO_MAX * self.x_czech.NR_CLIPS_MAX
	self.x_czech.AMMO_PICKUP = {2, 9} --self:_pickup_chance(self.x_czech.AMMO_MAX, PICKUP.OTHER)
	self.x_czech.panic_suppression_chance = 0.2
	self.x_czech.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 38,
		alert_size = 7,
		spread = 16,
		spread_moving = 14,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 26
	}

	--x_beer / Bernetti Auto
	self.x_beer.CLIP_AMMO_MAX = 30
	self.x_beer.NR_CLIPS_MAX = 7
	self.x_beer.AMMO_MAX = self.x_beer.CLIP_AMMO_MAX * self.x_beer.NR_CLIPS_MAX
	self.x_beer.AMMO_PICKUP = {2, 10} --self:_pickup_chance(self.x_beer.AMMO_MAX, PICKUP.OTHER)
	self.x_beer.panic_suppression_chance = 0.2
	self.x_beer.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 25,
		alert_size = 7,
		spread = 11,
		spread_moving = 11,
		recoil = 20,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 28
	}

	--Akimbo SMG
	--x_m45 / Swedish K
	self.x_m45.CLIP_AMMO_MAX = 80
	self.x_m45.NR_CLIPS_MAX = 1
	self.x_m45.AMMO_MAX = self.x_m45.CLIP_AMMO_MAX * self.x_m45.NR_CLIPS_MAX
	self.x_m45.AMMO_PICKUP = {0.4, 6.5} --self:_pickup_chance(self.x_m45.AMMO_MAX, PICKUP.OTHER)
	self.x_m45.panic_suppression_chance = 0.2
	self.x_m45.stats.damage = 94 --99

	--x_akmsu / Krinkov
	self.x_akmsu.CLIP_AMMO_MAX = 60
	self.x_akmsu.NR_CLIPS_MAX = 2
	self.x_akmsu.AMMO_MAX = self.x_akmsu.CLIP_AMMO_MAX * self.x_akmsu.NR_CLIPS_MAX
	self.x_akmsu.AMMO_PICKUP = {0.4, 6.75} --self:_pickup_chance(self.x_akmsu.AMMO_MAX, PICKUP.OTHER)
	self.x_akmsu.panic_suppression_chance = 0.2
	self.x_akmsu.stats.damage = 94 --99

	--x_hajk / CR 805B
	self.x_hajk.CLIP_AMMO_MAX = 60
	self.x_hajk.NR_CLIPS_MAX = 2
	self.x_hajk.AMMO_MAX = self.x_hajk.CLIP_AMMO_MAX * self.x_hajk.NR_CLIPS_MAX
	self.x_hajk.AMMO_PICKUP = {0.4, 6.9} --self:_pickup_chance(self.x_hajk.AMMO_MAX, PICKUP.OTHER)
	self.x_hajk.panic_suppression_chance = 0.2
	self.x_hajk.stats.damage = 94 --99

	--x_sr2 / Heater
	self.x_sr2.CLIP_AMMO_MAX = 64
	self.x_sr2.NR_CLIPS_MAX = 3
	self.x_sr2.AMMO_MAX = self.x_sr2.CLIP_AMMO_MAX * self.x_sr2.NR_CLIPS_MAX
	self.x_sr2.AMMO_PICKUP = {4, 11.2} --self:_pickup_chance(self.x_sr2.AMMO_MAX, PICKUP.OTHER)
	self.x_sr2.panic_suppression_chance = 0.2
	self.x_sr2.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 58,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 14,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 15,
		concealment = 28
	}

	--x_mac10 / Mark10
	self.x_mac10.CLIP_AMMO_MAX = 80
	self.x_mac10.NR_CLIPS_MAX = 2
	self.x_mac10.AMMO_MAX = self.x_mac10.CLIP_AMMO_MAX * self.x_mac10.NR_CLIPS_MAX
	self.x_mac10.AMMO_PICKUP = {4, 11.5} --self:_pickup_chance(self.x_mac10.AMMO_MAX, PICKUP.OTHER)
	self.x_mac10.panic_suppression_chance = 0.2
	self.x_mac10.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 58,
		alert_size = 7,
		spread = 13,
		spread_moving = 13,
		recoil = 17,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 27
	}

	--x_mp7 / SpecOps
	self.x_mp7.CLIP_AMMO_MAX = 40
	self.x_mp7.NR_CLIPS_MAX = 5
	self.x_mp7.AMMO_MAX = self.x_mp7.CLIP_AMMO_MAX * self.x_mp7.NR_CLIPS_MAX
	self.x_mp7.AMMO_PICKUP = {4, 11.75} --self:_pickup_chance(self.x_mp7.AMMO_MAX, PICKUP.OTHER)
	self.x_mp7.panic_suppression_chance = 0.2
	self.x_mp7.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 58,
		alert_size = 7,
		spread = 17,
		spread_moving = 17,
		recoil = 18,
		value = 7,
		extra_ammo = 51,
		reload = 11,
		suppression = 16,
		concealment = 23
	}

	--x_polymer / Kross Vertex
	self.x_polymer.CLIP_AMMO_MAX = 60
	self.x_polymer.NR_CLIPS_MAX = 3
	self.x_polymer.AMMO_MAX = self.x_polymer.CLIP_AMMO_MAX * self.x_polymer.NR_CLIPS_MAX
	self.x_polymer.AMMO_PICKUP = {4, 12} --self:_pickup_chance(self.x_polymer.AMMO_MAX, PICKUP.OTHER)
	self.x_polymer.panic_suppression_chance = 0.2
	self.x_polymer.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 58,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 20,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 20
	}

	--x_m1928 / Chicago Typewriter
	self.x_m1928.CLIP_AMMO_MAX = 100
	self.x_m1928.NR_CLIPS_MAX = 2
	self.x_m1928.AMMO_MAX = self.x_m1928.CLIP_AMMO_MAX * self.x_m1928.NR_CLIPS_MAX
	self.x_m1928.AMMO_PICKUP = {4, 12.2} --self:_pickup_chance(self.x_m1928.AMMO_MAX, PICKUP.OTHER)
	self.x_m1928.panic_suppression_chance = 0.2
	self.x_m1928.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 58,
		alert_size = 8,
		spread = 13,
		spread_moving = 13,
		recoil = 18,
		value = 9,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 18
	}

	--x_cobray / Jacket's Piece
	self.x_cobray.CLIP_AMMO_MAX = 64
	self.x_cobray.NR_CLIPS_MAX = 3
	self.x_cobray.AMMO_MAX = self.x_cobray.CLIP_AMMO_MAX * self.x_cobray.NR_CLIPS_MAX
	self.x_cobray.AMMO_PICKUP = {4, 12.5} --self:_pickup_chance(self.x_cobray.AMMO_MAX, PICKUP.OTHER)
	self.x_cobray.panic_suppression_chance = 0.2
	self.x_cobray.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 57,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 18,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 25
	}

	--x_p90 / Kobus
	self.x_p90.CLIP_AMMO_MAX = 100
	self.x_p90.NR_CLIPS_MAX = 2
	self.x_p90.AMMO_MAX = self.x_p90.CLIP_AMMO_MAX * self.x_p90.NR_CLIPS_MAX
	self.x_p90.AMMO_PICKUP = {4, 12.75} --self:_pickup_chance(self.x_p90.AMMO_MAX, PICKUP.OTHER)
	self.x_p90.panic_suppression_chance = 0.2
	self.x_p90.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 56,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 25
	}

	--x_olympic / Para
	self.x_olympic.CLIP_AMMO_MAX = 50
	self.x_olympic.NR_CLIPS_MAX = 4
	self.x_olympic.AMMO_MAX = self.x_olympic.CLIP_AMMO_MAX * self.x_olympic.NR_CLIPS_MAX
	self.x_olympic.AMMO_PICKUP = {4, 13} --self:_pickup_chance(self.x_olympic.AMMO_MAX, PICKUP.OTHER)
	self.x_olympic.panic_suppression_chance = 0.2
	self.x_olympic.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 55,
		alert_size = 7,
		spread = 12,
		spread_moving = 11,
		recoil = 17,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 10,
		concealment = 24
	}

	--x_baka / Micro Uzi
	self.x_baka.timers = {
		reload_not_empty = 3,
		reload_empty = 3,
		unequip = 0.5,
		equip = 0.5
	}
	self.x_baka.CLIP_AMMO_MAX = 64
	self.x_baka.NR_CLIPS_MAX = 4
	self.x_baka.AMMO_MAX = self.x_baka.CLIP_AMMO_MAX * self.x_baka.NR_CLIPS_MAX
	self.x_baka.AMMO_PICKUP = {6, 14.2} --self:_pickup_chance(self.x_baka.AMMO_MAX, PICKUP.OTHER)
	self.x_baka.panic_suppression_chance = 0.2
	self.x_baka.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 44,
		alert_size = 7,
		spread = 8,
		spread_moving = 4,
		recoil = 20,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 29
	}

	--x_scorpion / Cobra
	self.x_scorpion.CLIP_AMMO_MAX = 40
	self.x_scorpion.NR_CLIPS_MAX = 6
	self.x_scorpion.AMMO_MAX = self.x_scorpion.CLIP_AMMO_MAX * self.x_scorpion.NR_CLIPS_MAX
	self.x_scorpion.AMMO_PICKUP = {6, 14.5} --self:_pickup_chance(self.x_scorpion.AMMO_MAX, PICKUP.OTHER)
	self.x_scorpion.panic_suppression_chance = 0.2
	self.x_scorpion.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 44,
		alert_size = 7,
		spread = 8,
		spread_moving = 8,
		recoil = 18,
		value = 7,
		extra_ammo = 51,
		reload = 11,
		suppression = 17,
		concealment = 28
	}

	--x_tec9 / Blaster 9mm
	self.x_tec9.CLIP_AMMO_MAX = 40
	self.x_tec9.NR_CLIPS_MAX = 6
	self.x_tec9.AMMO_MAX = self.x_tec9.CLIP_AMMO_MAX * self.x_tec9.NR_CLIPS_MAX
	self.x_tec9.AMMO_PICKUP = {6, 14.75} --self:_pickup_chance(self.x_tec9.AMMO_MAX, PICKUP.OTHER)
	self.x_tec9.panic_suppression_chance = 0.2
	self.x_tec9.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 44,
		alert_size = 7,
		spread = 8,
		spread_moving = 8,
		recoil = 20,
		value = 7,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 27
	}

	--x_mp9 / CMP
	self.x_mp9.CLIP_AMMO_MAX = 60
	self.x_mp9.NR_CLIPS_MAX = 4
	self.x_mp9.AMMO_MAX = self.x_mp9.CLIP_AMMO_MAX * self.x_mp9.NR_CLIPS_MAX
	self.x_mp9.AMMO_PICKUP = {6, 15} --self:_pickup_chance(self.x_mp9.AMMO_MAX, PICKUP.OTHER)
	self.x_mp9.panic_suppression_chance = 0.2
	self.x_mp9.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 44,
		alert_size = 7,
		spread = 8,
		spread_moving = 8,
		recoil = 20,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 16,
		concealment = 26
	}

	--x_mp5 / Compact-5
	self.x_mp5.CLIP_AMMO_MAX = 60
	self.x_mp5.NR_CLIPS_MAX = 4
	self.x_mp5.AMMO_MAX = self.x_mp5.CLIP_AMMO_MAX * self.x_mp5.NR_CLIPS_MAX
	self.x_mp5.AMMO_PICKUP = {6.5, 15} --self:_pickup_chance(self.x_mp5.AMMO_MAX, PICKUP.OTHER)
	self.x_mp5.panic_suppression_chance = 0.2
	self.x_mp5.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 44,
		alert_size = 7,
		spread = 12,
		spread_moving = 8,
		recoil = 21,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 17,
		concealment = 24
	}

	--x_uzi / Uzi
	self.x_uzi.timers = {
		reload_not_empty = 3,
		reload_empty = 3,
		unequip = 0.5,
		equip = 0.5
	}
	self.x_uzi.CLIP_AMMO_MAX = 80
	self.x_uzi.NR_CLIPS_MAX = 3
	self.x_uzi.AMMO_MAX = self.x_uzi.CLIP_AMMO_MAX * self.x_uzi.NR_CLIPS_MAX
	self.x_uzi.AMMO_PICKUP = {6.5, 15} --self:_pickup_chance(self.x_uzi.AMMO_MAX, PICKUP.OTHER)
	self.x_uzi.panic_suppression_chance = 0.2
	self.x_uzi.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 44,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 18,
		value = 7,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 24
	}

	--x_sterling / Patchett L2A1
	self.x_sterling.CLIP_AMMO_MAX = 40
	self.x_sterling.NR_CLIPS_MAX = 6
	self.x_sterling.AMMO_MAX = self.x_sterling.CLIP_AMMO_MAX * self.x_sterling.NR_CLIPS_MAX
	self.x_sterling.AMMO_PICKUP = {7, 15} --self:_pickup_chance(self.x_sterling.AMMO_MAX, PICKUP.OTHER)
	self.x_sterling.panic_suppression_chance = 0.2
	self.x_sterling.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 42,
		alert_size = 7,
		spread = 8,
		spread_moving = 8,
		recoil = 20,
		value = 7,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 20
	}

	--Akimbo Shotgun
	--High Damage Shotgun
	--x_judge / Judge
	self.x_judge.rays = 12
	self.x_judge.use_shotgun_reload = false
	self.x_judge.CLIP_AMMO_MAX = 10
	self.x_judge.NR_CLIPS_MAX = 4
	self.x_judge.AMMO_MAX = self.x_judge.CLIP_AMMO_MAX * self.x_judge.NR_CLIPS_MAX
	self.x_judge.AMMO_PICKUP = {0.26, 1.8} --self:_pickup_chance(self.x_judge.AMMO_MAX, PICKUP.SNIPER_HIGH_DAMAGE)
	self.x_judge.stats.damage = 155
	self.x_judge.stats.concealment = 29

	--Low Damage Shotgun
	--x_rota / Goliath
	self.x_rota.rays = 12
	self.x_rota.use_shotgun_reload = false
	self.x_rota.CLIP_AMMO_MAX = 12
	self.x_rota.NR_CLIPS_MAX = 6
	self.x_rota.AMMO_MAX = self.x_rota.CLIP_AMMO_MAX * self.x_rota.NR_CLIPS_MAX
	self.x_rota.AMMO_PICKUP = {2.6, 7.8} --self:_pickup_chance(self.x_rota.AMMO_MAX, 4)
	self.x_rota.stats.damage = 47
	self.x_rota.stats.concealment = 13

	--x_basset / Grimm 12G
	self.x_basset.rays = 12
	self.x_basset.use_shotgun_reload = false
	self.x_basset.CLIP_AMMO_MAX = 16
	self.x_basset.NR_CLIPS_MAX = 6
	self.x_basset.AMMO_MAX = self.x_basset.CLIP_AMMO_MAX * self.x_basset.NR_CLIPS_MAX
	self.x_basset.AMMO_PICKUP = {2, 12} --self:_pickup_chance(self.x_basset.AMMO_MAX, 4)
	self.x_basset.stats.damage = 30
	self.x_basset.stats.concealment = 21

	--Shotgun
	--Primary
	--boot / Breaker 12G
	self.boot.rays = 12
	self.boot.CLIP_AMMO_MAX = 7
	self.boot.NR_CLIPS_MAX = 3
	self.boot.AMMO_MAX = self.boot.CLIP_AMMO_MAX * self.boot.NR_CLIPS_MAX
	self.boot.AMMO_PICKUP = {0.2, 1} --self:_pickup_chance(self.boot.AMMO_MAX, PICKUP.OTHER)
	self.boot.stats.damage = 156
	self.boot.stats.concealment = 20
	self.boot.stats_modifiers = { damage = 1 }

	--huntsman / Mosconi 12G
	self.huntsman.rays = 12
	self.huntsman.CLIP_AMMO_MAX = 2
	self.huntsman.NR_CLIPS_MAX = 16
	self.huntsman.AMMO_MAX = self.huntsman.CLIP_AMMO_MAX * self.huntsman.NR_CLIPS_MAX
	self.huntsman.AMMO_PICKUP = {0.2, 1.4} --self:_pickup_chance(self.huntsman.AMMO_MAX, PICKUP.OTHER)
	self.huntsman.stats.damage = 156
	self.huntsman.stats.recoil = 10
	self.huntsman.stats.concealment = 7
	self.huntsman.stats_modifiers.damage = 1

	--b682 / Joceline O/U 12G
	self.b682.rays = 12
	self.b682.CLIP_AMMO_MAX = 2
	self.b682.NR_CLIPS_MAX = 14
	self.b682.AMMO_MAX = self.b682.CLIP_AMMO_MAX * self.b682.NR_CLIPS_MAX
	self.b682.AMMO_PICKUP = {0.22, 1.4} --self:_pickup_chance(self.b682.AMMO_MAX, PICKUP.OTHER)
	self.b682.stats.damage = 156
	self.b682.stats.recoil = 8
	self.b682.stats.concealment = 5
	self.b682.stats_modifiers.damage = 1

	--Secondary
	--judge / The Judge
	self.judge.rays = 12
	self.judge.CLIP_AMMO_MAX = 5
	self.judge.NR_CLIPS_MAX = 7
	self.judge.AMMO_MAX = self.judge.CLIP_AMMO_MAX * self.judge.NR_CLIPS_MAX
	self.judge.AMMO_PICKUP = {0.2, 1.5} --self:_pickup_chance(self.judge.AMMO_MAX, PICKUP.SNIPER_HIGH_DAMAGE)
	self.judge.stats.damage = 155
	self.judge.stats.concealment = 29

	--m37 / GSPS 12G
	self.m37.rays = 12
	self.m37.CLIP_AMMO_MAX = 7
	self.m37.NR_CLIPS_MAX = 4
	self.m37.AMMO_MAX = self.m37.CLIP_AMMO_MAX * self.m37.NR_CLIPS_MAX
	self.m37.AMMO_PICKUP = {0.2, 1.7} --self:_pickup_chance(self.m37.AMMO_MAX, PICKUP.OTHER)
	self.m37.stats.damage = 155
	self.m37.stats.spread = 12
	self.m37.stats.recoil = 14
	self.m37.stats.concealment = 22

	--coach / Claire 12G
	self.coach.rays = 12
	self.coach.CLIP_AMMO_MAX = 2
	self.coach.NR_CLIPS_MAX = 22
	self.coach.AMMO_MAX = self.coach.CLIP_AMMO_MAX * self.coach.NR_CLIPS_MAX
	self.coach.AMMO_PICKUP = {0.25, 1.85} --self:_pickup_chance(self.coach.AMMO_MAX, PICKUP.SNIPER_HIGH_DAMAGE)
	self.coach.stats.damage = 155
	self.coach.stats.spread = 15
	self.coach.stats.recoil = 12
	self.coach.stats.concealment = 10

	--Mid Damage Shotgun
	--Primary
	--ksg / Raven
	self.ksg.rays = 12
	self.ksg.CLIP_AMMO_MAX = 14
	self.ksg.NR_CLIPS_MAX = 3
	self.ksg.AMMO_MAX = self.ksg.CLIP_AMMO_MAX * self.ksg.NR_CLIPS_MAX
	self.ksg.AMMO_PICKUP = {0.4, 2} --self:_pickup_chance(self.ksg.AMMO_MAX, PICKUP.OTHER)
	self.ksg.stats.damage = 90
	self.ksg.stats.concealment = 22

	--r870 / Reinfield 880
	self.r870.rays = 12
	self.r870.CLIP_AMMO_MAX = 6
	self.r870.NR_CLIPS_MAX = 7
	self.r870.AMMO_MAX = self.r870.CLIP_AMMO_MAX * self.r870.NR_CLIPS_MAX
	self.r870.AMMO_PICKUP = {0.4, 2.5} --self:_pickup_chance(self.r870.AMMO_MAX, PICKUP.OTHER)
	self.r870.stats.damage = 90
	self.r870.stats.concealment = 11

	--Secondary
	--serbu / Locomotive 12G
	self.serbu.rays = 12
	self.serbu.CLIP_AMMO_MAX = 6
	self.serbu.NR_CLIPS_MAX = 7
	self.serbu.AMMO_MAX = self.serbu.CLIP_AMMO_MAX * self.serbu.NR_CLIPS_MAX
	self.serbu.AMMO_PICKUP = {0.43, 2} --self:_pickup_chance(self.serbu.AMMO_MAX, PICKUP.OTHER)
	self.serbu.stats.damage = 90

	--Low Damage Shotgun
	--Primary
	--spas12 / Predator 12G
	self.spas12.rays = 12
	self.spas12.CLIP_AMMO_MAX = 6
	self.spas12.NR_CLIPS_MAX = 11
	self.spas12.AMMO_MAX = self.spas12.CLIP_AMMO_MAX * self.spas12.NR_CLIPS_MAX
	self.spas12.AMMO_PICKUP = {2, 4.5} --self:_pickup_chance(self.spas12.AMMO_MAX, PICKUP.SHOTGUN_HIGH_CAPACITY)
	self.spas12.stats.damage = 60
	self.spas12.stats.concealment = 14

	--saiga / IZHMA
	self.saiga.rays = 12
	self.saiga.CLIP_AMMO_MAX = 7
	self.saiga.NR_CLIPS_MAX = 10
	self.saiga.AMMO_MAX = self.saiga.CLIP_AMMO_MAX * self.saiga.NR_CLIPS_MAX
	self.saiga.AMMO_PICKUP = {2.2, 4.7} --self:_pickup_chance(self.saiga.AMMO_MAX, PICKUP.SHOTGUN_HIGH_CAPACITY)
	self.saiga.stats.damage = 47
	self.saiga.stats.concealment = 13

	--benelli / M1014
	self.benelli.rays = 12
	self.benelli.CLIP_AMMO_MAX = 8
	self.benelli.NR_CLIPS_MAX = 8
	self.benelli.AMMO_MAX = self.benelli.CLIP_AMMO_MAX * self.benelli.NR_CLIPS_MAX
	self.benelli.AMMO_PICKUP = {2.5, 5} --self:_pickup_chance(self.benelli.AMMO_MAX, PICKUP.SHOTGUN_HIGH_CAPACITY)
	self.benelli.stats.damage = 60
	self.benelli.stats.concealment = 12

	--aa12 / Steakout
	self.aa12.rays = 12
	self.aa12.CLIP_AMMO_MAX = 8
	self.aa12.NR_CLIPS_MAX = 9
	self.aa12.AMMO_MAX = self.aa12.CLIP_AMMO_MAX * self.aa12.NR_CLIPS_MAX
	self.aa12.AMMO_PICKUP = {3, 5} --self:_pickup_chance(self.aa12.AMMO_MAX, PICKUP.SHOTGUN_HIGH_CAPACITY)
	self.aa12.stats.damage = 47
	self.aa12.stats.concealment = 9

	--Secondary
	--stiker / Street Sweeper
	self.striker.rays = 12
	self.striker.CLIP_AMMO_MAX = 12
	self.striker.NR_CLIPS_MAX = 6
	self.striker.AMMO_MAX = self.striker.CLIP_AMMO_MAX * self.striker.NR_CLIPS_MAX
	self.striker.AMMO_PICKUP = {3, 5} --self:_pickup_chance(self.striker.AMMO_MAX, PICKUP.SHOTGUN_HIGH_CAPACITY)
	self.striker.stats.damage = 47
	self.striker.stats.concealment = 21

	--rota / Goliath
	self.rota.rays = 12
	self.rota.CLIP_AMMO_MAX = 6
	self.rota.NR_CLIPS_MAX = 9
	self.rota.AMMO_MAX = self.rota.CLIP_AMMO_MAX * self.rota.NR_CLIPS_MAX
	self.rota.AMMO_PICKUP = {2, 6} --self:_pickup_chance(self.rota.AMMO_MAX, PICKUP.SHOTGUN_HIGH_CAPACITY)
	self.rota.stats.damage = 47
	self.rota.stats.concealment = 13

	--basset / Grimm
	self.basset.rays = 12
	self.basset.CLIP_AMMO_MAX = 8
	self.basset.NR_CLIPS_MAX = 13
	self.basset.AMMO_MAX = self.basset.CLIP_AMMO_MAX * self.basset.NR_CLIPS_MAX
	self.basset.AMMO_PICKUP = {2, 7.7} --self:_pickup_chance(self.basset.AMMO_MAX, 4)
	self.basset.stats.damage = 30
	self.basset.stats.concealment = 21

	--Revolver
	--PEACEMAKER
	self.peacemaker.CLIP_AMMO_MAX = 6
	self.peacemaker.NR_CLIPS_MAX = 9
	self.peacemaker.AMMO_MAX = self.peacemaker.CLIP_AMMO_MAX * self.peacemaker.NR_CLIPS_MAX
	self.peacemaker.AMMO_PICKUP = {0.25, 2.25} --self:_pickup_chance(self.peacemaker.AMMO_MAX, PICKUP.OTHER)
	self.peacemaker.panic_suppression_chance = 0.2
	self.peacemaker.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 190, --180
		alert_size = 7,
		spread = 22,
		spread_moving = 22,
		recoil = 4,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 5,
		concealment = 26
	}
	self.peacemaker.stats_modifiers = {
		damage = 1
	}

	--mateba / Matever
	self.mateba.CLIP_AMMO_MAX = 6
	self.mateba.NR_CLIPS_MAX = 9
	self.mateba.AMMO_MAX = self.mateba.CLIP_AMMO_MAX * self.mateba.NR_CLIPS_MAX
	self.mateba.AMMO_PICKUP = {0.25, 2.5} --self:_pickup_chance(self.mateba.AMMO_MAX, PICKUP.OTHER)
	self.mateba.panic_suppression_chance = 0.2
	self.mateba.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 185, --180
		alert_size = 7,
		spread = 22,
		spread_moving = 22,
		recoil = 4,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 7,
		concealment = 20
	}

	--chinchilla / Castigo
	self.chinchilla.CLIP_AMMO_MAX = 6
	self.chinchilla.NR_CLIPS_MAX = 9
	self.chinchilla.AMMO_MAX = self.chinchilla.CLIP_AMMO_MAX * self.chinchilla.NR_CLIPS_MAX
	self.chinchilla.AMMO_PICKUP = {0.25, 2} --self:_pickup_chance(self.chinchilla.AMMO_MAX, PICKUP.OTHER)
	self.chinchilla.panic_suppression_chance = 0.2
	self.chinchilla.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 180,
		alert_size = 7,
		spread = 20,
		spread_moving = 5,
		recoil = 2,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 7,
		concealment = 28
	}

	--new_raging_bull / Bronco
	self.new_raging_bull.CLIP_AMMO_MAX = 6
	self.new_raging_bull.NR_CLIPS_MAX = 9
	self.new_raging_bull.AMMO_MAX = self.new_raging_bull.CLIP_AMMO_MAX * self.new_raging_bull.NR_CLIPS_MAX
	self.new_raging_bull.AMMO_PICKUP = {0.25, 2.75} --self:_pickup_chance(self.new_raging_bull.AMMO_MAX, PICKUP.OTHER)
	self.new_raging_bull.panic_suppression_chance = 0.2
	self.new_raging_bull.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 180, --175
		alert_size = 7,
		spread = 20,
		spread_moving = 5,
		recoil = 2,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 7,
		concealment = 26
	}

	--model3 / Frenchman model 87
	self.model3.CLIP_AMMO_MAX = 6
	self.model3.NR_CLIPS_MAX = 11
	self.model3.AMMO_MAX = self.model3.CLIP_AMMO_MAX * self.model3.NR_CLIPS_MAX
	self.model3.AMMO_PICKUP = {0.25, 3} --self:_pickup_chance(self.model3.AMMO_MAX, PICKUP.OTHER)
	self.model3.panic_suppression_chance = 0.2
	self.model3.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 135, --130
		alert_size = 8,
		spread = 20,
		spread_moving = 5,
		recoil = 8,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 8,
		concealment = 26
	}

	--Pistol
	--pl14 / White Streak
	self.pl14.CLIP_AMMO_MAX = 12
	self.pl14.NR_CLIPS_MAX = 5
	self.pl14.AMMO_MAX = self.pl14.CLIP_AMMO_MAX * self.pl14.NR_CLIPS_MAX
	self.pl14.AMMO_PICKUP = {0.3, 2.25} --self:_pickup_chance(self.pl14.AMMO_MAX, PICKUP.OTHER)
	self.pl14.panic_suppression_chance = 0.2
	self.pl14.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 120,
		alert_size = 7,
		spread = 18,
		spread_moving = 18,
		recoil = 9,
		value = 4,
		extra_ammo = 51,
		reload = 11,
		suppression = 15,
		concealment = 29
	}

	--sparrow / Baby Deagle
	self.sparrow.CLIP_AMMO_MAX = 12
	self.sparrow.NR_CLIPS_MAX = 5
	self.sparrow.AMMO_MAX = self.sparrow.CLIP_AMMO_MAX * self.sparrow.NR_CLIPS_MAX
	self.sparrow.AMMO_PICKUP = {0.4, 2.25} --self:_pickup_chance(self.sparrow.AMMO_MAX, PICKUP.OTHER)
	self.sparrow.panic_suppression_chance = 0.2
	self.sparrow.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 120,
		alert_size = 7,
		spread = 18,
		spread_moving = 18,
		recoil = 9,
		value = 4,
		extra_ammo = 51,
		reload = 11,
		suppression = 15,
		concealment = 29
	}

	--DEAGLE
	self.deagle.CLIP_AMMO_MAX = 10
	self.deagle.NR_CLIPS_MAX = 5
	self.deagle.AMMO_MAX = self.deagle.CLIP_AMMO_MAX * self.deagle.NR_CLIPS_MAX
	self.deagle.AMMO_PICKUP = {0.4, 2.5} --self:_pickup_chance(self.deagle.AMMO_MAX, PICKUP.OTHER)
	self.deagle.panic_suppression_chance = 0.2
	self.deagle.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 120,
		alert_size = 7,
		spread = 20,
		spread_moving = 20,
		recoil = 8,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 7,
		concealment = 28
	}

	--packrat / Contractor
	self.packrat.CLIP_AMMO_MAX = 15
	self.packrat.NR_CLIPS_MAX = 6
	self.packrat.AMMO_MAX = self.packrat.CLIP_AMMO_MAX * self.packrat.NR_CLIPS_MAX
	self.packrat.AMMO_PICKUP = {1.2, 3.5} --self:_pickup_chance(self.packrat.AMMO_MAX, PICKUP.OTHER)
	self.packrat.panic_suppression_chance = 0.2
	self.packrat.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 66,
		alert_size = 7,
		spread = 18,
		spread_moving = 18,
		recoil = 16,
		value = 4,
		extra_ammo = 51,
		reload = 11,
		suppression = 15,
		concealment = 29
	}

	--hs2000 / LEO
	self.hs2000.CLIP_AMMO_MAX = 19
	self.hs2000.NR_CLIPS_MAX = 5
	self.hs2000.AMMO_MAX = self.hs2000.CLIP_AMMO_MAX * self.hs2000.NR_CLIPS_MAX
	self.hs2000.AMMO_PICKUP = {1.25, 3.75} --self:_pickup_chance(self.hs2000.AMMO_MAX, PICKUP.OTHER)
	self.hs2000.panic_suppression_chance = 0.2
	self.hs2000.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 65,
		alert_size = 7,
		spread = 17, -- 18
		spread_moving = 18,
		recoil = 15, -- 14
		value = 4,
		extra_ammo = 51,
		reload = 11,
		suppression = 15,
		concealment = 29
	}

	--p226 / Signature
	self.p226.CLIP_AMMO_MAX = 12
	self.p226.NR_CLIPS_MAX = 7
	self.p226.AMMO_MAX = self.p226.CLIP_AMMO_MAX * self.p226.NR_CLIPS_MAX
	self.p226.AMMO_PICKUP = {1.25, 3.75} --self:_pickup_chance(self.p226.AMMO_MAX, PICKUP.OTHER)
	self.p226.panic_suppression_chance = 0.2
	self.p226.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 65,
		alert_size = 7,
		spread = 18,
		spread_moving = 18,
		recoil = 14,
		value = 4,
		extra_ammo = 51,
		reload = 11,
		suppression = 15,
		concealment = 29
	}

	--colt_1911 / Crosskill
	self.colt_1911.CLIP_AMMO_MAX = 10
	self.colt_1911.NR_CLIPS_MAX = 9
	self.colt_1911.AMMO_MAX = self.colt_1911.CLIP_AMMO_MAX * self.colt_1911.NR_CLIPS_MAX
	self.colt_1911.AMMO_PICKUP = {1.2, 3.5} --self:_pickup_chance(self.colt_1911.AMMO_MAX, PICKUP.OTHER)
	self.colt_1911.panic_suppression_chance = 0.2
	self.colt_1911.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 65,
		alert_size = 7,
		spread = 18,
		spread_moving = 18,
		recoil = 14,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 29
	}

	--g22c / Chimano Custom
	self.g22c.CLIP_AMMO_MAX = 16
	self.g22c.NR_CLIPS_MAX = 6
	self.g22c.AMMO_MAX = self.g22c.CLIP_AMMO_MAX * self.g22c.NR_CLIPS_MAX
	self.g22c.AMMO_PICKUP = {1.2, 3.7} --self:_pickup_chance(self.g22c.AMMO_MAX, PICKUP.OTHER)
	self.g22c.panic_suppression_chance = 0.2
	self.g22c.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 65,
		alert_size = 7,
		spread = 18,
		spread_moving = 18,
		recoil = 14,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 15,
		concealment = 29
	}

	--usp / Interceptor
	self.usp.CLIP_AMMO_MAX = 12
	self.usp.NR_CLIPS_MAX = 8
	self.usp.AMMO_MAX = self.usp.CLIP_AMMO_MAX * self.usp.NR_CLIPS_MAX
	self.usp.AMMO_PICKUP = {1.2, 3.75} --self:_pickup_chance(self.usp.AMMO_MAX, PICKUP.OTHER)
	self.usp.panic_suppression_chance = 0.2
	self.usp.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 65,
		alert_size = 7,
		spread = 18,
		spread_moving = 18,
		recoil = 14,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 16,
		concealment = 29
	}

	--c96 / Broomstick
	self.c96.CLIP_AMMO_MAX = 10
	self.c96.NR_CLIPS_MAX = 9
	self.c96.AMMO_MAX = self.c96.CLIP_AMMO_MAX * self.c96.NR_CLIPS_MAX
	self.c96.AMMO_PICKUP = {2, 4} --self:_pickup_chance(self.c96.AMMO_MAX, PICKUP.OTHER)
	self.c96.panic_suppression_chance = 0.2
	self.c96.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 65,
		alert_size = 7,
		spread = 21,
		spread_moving = 12,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 28
	}

	--HOLT
	self.holt.CLIP_AMMO_MAX = 15
	self.holt.NR_CLIPS_MAX = 6
	self.holt.AMMO_MAX = self.holt.CLIP_AMMO_MAX * self.holt.NR_CLIPS_MAX
	self.holt.AMMO_PICKUP = {1.25, 4} --self:_pickup_chance(self.holt.AMMO_MAX, PICKUP.OTHER)
	self.holt.panic_suppression_chance = 0.2
	self.holt.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 65,
		alert_size = 7,
		spread = 16,
		spread_moving = 16,
		recoil = 18,
		value = 4,
		extra_ammo = 51,
		reload = 11,
		suppression = 15,
		concealment = 28
	}

	--shrew / Crosskill Guard
	self.shrew.CLIP_AMMO_MAX = 17
	self.shrew.NR_CLIPS_MAX = 9
	self.shrew.AMMO_MAX = self.shrew.CLIP_AMMO_MAX * self.shrew.NR_CLIPS_MAX
	self.shrew.AMMO_PICKUP = {2, 6.5} --self:_pickup_chance(self.shrew.AMMO_MAX, 1)
	self.shrew.transition_duration = 0
	self.shrew.panic_suppression_chance = 0.2
	self.shrew.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 37,
		alert_size = 7,
		spread = 17,
		spread_moving = 14,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 16,
		concealment = 30
	}

	--ppk / Gruber Kurz
	self.ppk.CLIP_AMMO_MAX = 14
	self.ppk.NR_CLIPS_MAX = 11
	self.ppk.AMMO_MAX = self.ppk.CLIP_AMMO_MAX * self.ppk.NR_CLIPS_MAX
	self.ppk.AMMO_PICKUP = {2, 6.8} --self:_pickup_chance(self.ppk.AMMO_MAX, PICKUP.OTHER)
	self.ppk.panic_suppression_chance = 0.2
	self.ppk.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 37,
		alert_size = 7,
		spread = 12,
		spread_moving = 12,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 18,
		concealment = 30
	}

	--legacy / M13
	self.legacy.CLIP_AMMO_MAX = 13
	self.legacy.NR_CLIPS_MAX = 12
	self.legacy.AMMO_MAX = self.legacy.CLIP_AMMO_MAX * self.legacy.NR_CLIPS_MAX
	self.legacy.AMMO_PICKUP = {2, 6.8} --self:_pickup_chance(self.legacy.AMMO_MAX, PICKUP.OTHER)
	self.legacy.panic_suppression_chance = 0.2
	self.legacy.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 37,
		alert_size = 7,
		spread = 12,
		spread_moving = 12,
		recoil = 13,
		value = 4,
		extra_ammo = 51,
		reload = 11,
		suppression = 15,
		concealment = 30
	}

	--b92fs / Bernetti 9
	self.b92fs.CLIP_AMMO_MAX = 14
	self.b92fs.NR_CLIPS_MAX = 11
	self.b92fs.AMMO_MAX = self.b92fs.CLIP_AMMO_MAX * self.b92fs.NR_CLIPS_MAX
	self.b92fs.AMMO_PICKUP = {2, 6.8} --self:_pickup_chance(self.b92fs.AMMO_MAX, PICKUP.OTHER)
	self.b92fs.panic_suppression_chance = 0.2
	self.b92fs.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 37,
		alert_size = 7,
		spread = 15,
		spread_moving = 15,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 17,
		concealment = 30
	}

	--g26 / Chimano Compact
	self.g26.CLIP_AMMO_MAX = 10
	self.g26.NR_CLIPS_MAX = 15
	self.g26.AMMO_MAX = self.g26.CLIP_AMMO_MAX * self.g26.NR_CLIPS_MAX
	self.g26.AMMO_PICKUP = {1, 7} --self:_pickup_chance(self.g26.AMMO_MAX, PICKUP.OTHER)
	self.g26.panic_suppression_chance = 0.2
	self.g26.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 37,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 18,
		concealment = 30
	}

	--glock_17 / Chimano
	self.glock_17.CLIP_AMMO_MAX = 17
	self.glock_17.NR_CLIPS_MAX = 9
	self.glock_17.AMMO_MAX = self.glock_17.CLIP_AMMO_MAX * self.glock_17.NR_CLIPS_MAX
	self.glock_17.AMMO_PICKUP = {2, 7} --self:_pickup_chance(self.glock_17.AMMO_MAX, PICKUP.OTHER)
	self.glock_17.transition_duration = 0
	self.glock_17.panic_suppression_chance = 0.2
	self.glock_17.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 35,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 16,
		concealment = 30
	}

	--Auto Pistol
	--stech / Igor Automatik
	self.stech.CLIP_AMMO_MAX = 20
	self.stech.NR_CLIPS_MAX = 4
	self.stech.AMMO_MAX = self.stech.CLIP_AMMO_MAX * self.stech.NR_CLIPS_MAX
	self.stech.AMMO_PICKUP = {1.15, 3.2} --self:_pickup_chance(self.stech.AMMO_MAX, PICKUP.OTHER)
	self.stech.transition_duration = 0
	self.stech.panic_suppression_chance = 0.2
	self.stech.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 65,
		alert_size = 7,
		spread = 15,
		spread_moving = 7,
		recoil = 8,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 16,
		concealment = 25
	}

	--CZECH
	self.czech.CLIP_AMMO_MAX = 15
	self.czech.NR_CLIPS_MAX = 10
	self.czech.AMMO_MAX = self.czech.CLIP_AMMO_MAX * self.czech.NR_CLIPS_MAX
	self.czech.AMMO_PICKUP = {2, 6} --self:_pickup_chance(self.czech.AMMO_MAX, PICKUP.OTHER)
	self.czech.transition_duration = 0
	self.czech.panic_suppression_chance = 0.2
	self.czech.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 38,
		alert_size = 7,
		spread = 16,
		spread_moving = 14,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 26
	}

	--glock_18c / STRYK
	self.glock_18c.CLIP_AMMO_MAX = 20
	self.glock_18c.NR_CLIPS_MAX = 8
	self.glock_18c.AMMO_MAX = self.glock_18c.CLIP_AMMO_MAX * self.glock_18c.NR_CLIPS_MAX
	self.glock_18c.AMMO_PICKUP = {2, 6.25} --self:_pickup_chance(self.glock_18c.AMMO_MAX, PICKUP.OTHER)
	self.glock_18c.transition_duration = 0
	self.glock_18c.panic_suppression_chance = 0.2
	self.glock_18c.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 35,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 15,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 29
	}

	--Bernetti Auto
	self.beer.CLIP_AMMO_MAX = 15
	self.beer.NR_CLIPS_MAX = 13
	self.beer.AMMO_MAX = self.beer.CLIP_AMMO_MAX * self.beer.NR_CLIPS_MAX
	self.beer.AMMO_PICKUP = {2, 7} --self:_pickup_chance(self.beer.AMMO_MAX, PICKUP.OTHER)
	self.beer.transition_duration = 0
	self.beer.panic_suppression_chance = 0.2
	self.beer.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 25,
		alert_size = 7,
		spread = 11,
		spread_moving = 11,
		recoil = 17,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 28
	}

	--SMG
	--m45 / Swedish K
	self.m45.CLIP_AMMO_MAX = 40
	self.m45.NR_CLIPS_MAX = 3
	self.m45.AMMO_MAX = self.m45.CLIP_AMMO_MAX * self.m45.NR_CLIPS_MAX
	self.m45.AMMO_PICKUP = {0.4, 3.6} --self:_pickup_chance(self.m45.AMMO_MAX, PICKUP.OTHER)
	self.m45.panic_suppression_chance = 0.2
	self.m45.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 94, --99
		alert_size = 7,
		spread = 18,
		spread_moving = 18,
		recoil = 12,
		value = 5,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 24
	}

	--akmsu / Krinkov
	self.akmsu.CLIP_AMMO_MAX = 30
	self.akmsu.NR_CLIPS_MAX = 3
	self.akmsu.AMMO_MAX = self.akmsu.CLIP_AMMO_MAX * self.akmsu.NR_CLIPS_MAX
	self.akmsu.AMMO_PICKUP = {0.4, 3.75} --self:_pickup_chance(self.akmsu.AMMO_MAX, PICKUP.OTHER)
	self.akmsu.panic_suppression_chance = 0.2
	self.akmsu.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 94, --99
		alert_size = 7,
		spread = 16,
		spread_moving = 16,
		recoil = 12,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 8,
		concealment = 21
	}

	--hajk / CR 805B
	self.hajk.CLIP_AMMO_MAX = 30
	self.hajk.NR_CLIPS_MAX = 3
	self.hajk.AMMO_MAX = self.hajk.CLIP_AMMO_MAX * self.hajk.NR_CLIPS_MAX
	self.hajk.AMMO_PICKUP = {0.4, 3.9} --self:_pickup_chance(self.hajk.AMMO_MAX, PICKUP.OTHER)
	self.hajk.panic_suppression_chance = 0.2
	self.hajk.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 94, --99
		alert_size = 7,
		spread = 19,
		spread_moving = 15,
		recoil = 18,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 18
	}

	--sr2 / Heater
	self.sr2.CLIP_AMMO_MAX = 32
	self.sr2.NR_CLIPS_MAX = 5
	self.sr2.AMMO_MAX = self.cobray.CLIP_AMMO_MAX * self.cobray.NR_CLIPS_MAX
	self.sr2.AMMO_PICKUP = {4, 8.2} --self:_pickup_chance(self.cobray.AMMO_MAX, PICKUP.AR_MED_CAPACITY)
	self.sr2.panic_suppression_chance = 0.2
	self.sr2.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 58,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 14,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 28
	}

	--mac10 / Mark10
	self.mac10.CLIP_AMMO_MAX = 40
	self.mac10.NR_CLIPS_MAX = 4
	self.mac10.AMMO_MAX = self.mac10.CLIP_AMMO_MAX * self.mac10.NR_CLIPS_MAX
	self.mac10.AMMO_PICKUP = {4, 8.5} --self:_pickup_chance(self.mac10.AMMO_MAX, PICKUP.AR_MED_CAPACITY)
	self.mac10.panic_suppression_chance = 0.2
	self.mac10.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 58,
		alert_size = 7,
		spread = 13,
		spread_moving = 13,
		recoil = 17,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 27
	}

	--mp7 / SpecOps
	self.mp7.CLIP_AMMO_MAX = 20
	self.mp7.NR_CLIPS_MAX = 8
	self.mp7.AMMO_MAX = self.mp7.CLIP_AMMO_MAX * self.mp7.NR_CLIPS_MAX
	self.mp7.AMMO_PICKUP = {4, 8.8} --self:_pickup_chance(self.mp7.AMMO_MAX, PICKUP.AR_MED_CAPACITY)
	self.mp7.panic_suppression_chance = 0.2
	self.mp7.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 58,
		alert_size = 7,
		spread = 17,
		spread_moving = 17,
		recoil = 18,
		value = 7,
		extra_ammo = 51,
		reload = 11,
		suppression = 16,
		concealment = 23
	}

	--polymer / Kross Vertex
	self.polymer.CLIP_AMMO_MAX = 30
	self.polymer.NR_CLIPS_MAX = 5
	self.polymer.AMMO_MAX = self.polymer.CLIP_AMMO_MAX * self.polymer.NR_CLIPS_MAX
	self.polymer.AMMO_PICKUP = {4, 9} --self:_pickup_chance(self.polymer.AMMO_MAX, PICKUP.AR_MED_CAPACITY)
	self.polymer.panic_suppression_chance = 0.2
	self.polymer.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 58,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 20,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 20
	}

	--m1928 / Chicago Typewriter
	self.m1928.CLIP_AMMO_MAX = 50
	self.m1928.NR_CLIPS_MAX = 3
	self.m1928.AMMO_MAX = self.m1928.CLIP_AMMO_MAX * self.m1928.NR_CLIPS_MAX
	self.m1928.AMMO_PICKUP = {4, 9.25} --self:_pickup_chance(self.m1928.AMMO_MAX, PICKUP.AR_MED_CAPACITY)
	self.m1928.panic_suppression_chance = 0.2
	self.m1928.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 58,
		alert_size = 8,
		spread = 13,
		spread_moving = 13,
		recoil = 18,
		value = 9,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 18
	}
	
	--cobray / Jacket's Piece
	self.cobray.timers = {
		reload_not_empty = 2.05,
		reload_empty = 4.35,
		unequip = 0.55,
		equip = 0.5
	}
	self.cobray.CLIP_AMMO_MAX = 32
	self.cobray.NR_CLIPS_MAX = 5
	self.cobray.AMMO_MAX = self.cobray.CLIP_AMMO_MAX * self.cobray.NR_CLIPS_MAX
	self.cobray.AMMO_PICKUP = {4, 9.5} --self:_pickup_chance(self.cobray.AMMO_MAX, PICKUP.AR_MED_CAPACITY)
	self.cobray.panic_suppression_chance = 0.2
	self.cobray.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 57,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 18,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 25
	}

	--p90 / Kobus
	self.p90.CLIP_AMMO_MAX = 50
	self.p90.NR_CLIPS_MAX = 3
	self.p90.AMMO_MAX = self.p90.CLIP_AMMO_MAX * self.p90.NR_CLIPS_MAX
	self.p90.AMMO_PICKUP = {4, 9.75} --self:_pickup_chance(self.p90.AMMO_MAX, PICKUP.AR_MED_CAPACITY)
	self.p90.panic_suppression_chance = 0.2
	self.p90.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 56,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 16,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 25
	}

	--olympic / PARA
	self.olympic.CLIP_AMMO_MAX = 25
	self.olympic.NR_CLIPS_MAX = 6
	self.olympic.AMMO_MAX = self.olympic.CLIP_AMMO_MAX * self.olympic.NR_CLIPS_MAX
	self.olympic.AMMO_PICKUP = {4, 10} --self:_pickup_chance(self.olympic.AMMO_MAX, PICKUP.AR_MED_CAPACITY)
	self.olympic.panic_suppression_chance = 0.2
	self.olympic.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 55,
		alert_size = 7,
		spread = 12,
		spread_moving = 11,
		recoil = 17,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 10,
		concealment = 24
	}

	--baka / Micro Uzi
	self.baka.timers = {
		reload_not_empty = 1.85,
		reload_empty = 2.6,
		unequip = 0.7,
		equip = 0.5
	}
	self.baka.CLIP_AMMO_MAX = 32
	self.baka.NR_CLIPS_MAX = 7
	self.baka.AMMO_MAX = self.baka.CLIP_AMMO_MAX * self.baka.NR_CLIPS_MAX
	self.baka.AMMO_PICKUP = {6, 11.25} --self:_pickup_chance(self.baka.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.baka.panic_suppression_chance = 0.2
	self.baka.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 44,
		alert_size = 7,
		spread = 8,
		spread_moving = 4,
		recoil = 20,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 14,
		concealment = 29
	}

	--scorpion / Cobra
	self.scorpion.CLIP_AMMO_MAX = 20
	self.scorpion.NR_CLIPS_MAX = 11
	self.scorpion.AMMO_MAX = self.scorpion.CLIP_AMMO_MAX * self.scorpion.NR_CLIPS_MAX
	self.scorpion.AMMO_PICKUP = {6, 11.5} --self:_pickup_chance(self.scorpion.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.scorpion.panic_suppression_chance = 0.2
	self.scorpion.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 44,
		alert_size = 7,
		spread = 8,
		spread_moving = 8,
		recoil = 18,
		value = 7,
		extra_ammo = 51,
		reload = 11,
		suppression = 17,
		concealment = 28
	}

	--tec9 / blaster 9mm
	self.tec9.CLIP_AMMO_MAX = 20
	self.tec9.NR_CLIPS_MAX = 11
	self.tec9.AMMO_MAX = self.tec9.CLIP_AMMO_MAX * self.tec9.NR_CLIPS_MAX
	self.tec9.AMMO_PICKUP = {6, 11.75} --self:_pickup_chance(self.tec9.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.tec9.panic_suppression_chance = 0.2
	self.tec9.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 44,
		alert_size = 7,
		spread = 8,
		spread_moving = 8,
		recoil = 20,
		value = 7,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 27
	}

	--mp9 / CMP
	self.mp9.CLIP_AMMO_MAX = 30
	self.mp9.NR_CLIPS_MAX = 7
	self.mp9.AMMO_MAX = self.mp9.CLIP_AMMO_MAX * self.mp9.NR_CLIPS_MAX
	self.mp9.AMMO_PICKUP = {6, 12} --self:_pickup_chance(self.mp9.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.mp9.panic_suppression_chance = 0.2
	self.mp9.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 44,
		alert_size = 7,
		spread = 8,
		spread_moving = 8,
		recoil = 20,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 16,
		concealment = 26
	}

	--new_mp5 / Compact-5
	self.new_mp5.CLIP_AMMO_MAX = 30
	self.new_mp5.NR_CLIPS_MAX = 7
	self.new_mp5.AMMO_MAX = self.new_mp5.CLIP_AMMO_MAX * self.new_mp5.NR_CLIPS_MAX
	self.new_mp5.AMMO_PICKUP = {6.5, 12} --self:_pickup_chance(self.new_mp5.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.new_mp5.panic_suppression_chance = 0.2
	self.new_mp5.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 44,
		alert_size = 7,
		spread = 12,
		spread_moving = 8,
		recoil = 21,
		value = 1,
		extra_ammo = 51,
		reload = 11,
		suppression = 17,
		concealment = 24
	}

	--UZI
	self.uzi.timers = {
		reload_not_empty = 2.45,
		reload_empty = 3.52,
		unequip = 0.55,
		equip = 0.6
	}
	self.uzi.CLIP_AMMO_MAX = 40
	self.uzi.NR_CLIPS_MAX = 5
	self.uzi.AMMO_MAX = self.uzi.CLIP_AMMO_MAX * self.uzi.NR_CLIPS_MAX
	self.uzi.AMMO_PICKUP = {6.5, 12} --self:_pickup_chance(self.uzi.AMMO_MAX, PICKUP.AR_MED_CAPACITY)
	self.uzi.panic_suppression_chance = 0.2
	self.uzi.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 44,
		alert_size = 7,
		spread = 14,
		spread_moving = 14,
		recoil = 18,
		value = 7,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 24
	}

	--sterling / Patchett L2A1
	self.sterling.CLIP_AMMO_MAX = 20
	self.sterling.NR_CLIPS_MAX = 11
	self.sterling.AMMO_MAX = self.sterling.CLIP_AMMO_MAX * self.sterling.NR_CLIPS_MAX
	self.sterling.AMMO_PICKUP = {7, 12} --self:_pickup_chance(self.sterling.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.sterling.panic_suppression_chance = 0.2
	self.sterling.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 42,
		alert_size = 7,
		spread = 8,
		spread_moving = 8,
		recoil = 20,
		value = 7,
		extra_ammo = 51,
		reload = 11,
		suppression = 12,
		concealment = 20
	}

	--LMG
	--LMG HIGH DAMAGE
	--M60
	self.m60.CLIP_AMMO_MAX = 200
	self.m60.NR_CLIPS_MAX = 2
	self.m60.AMMO_MAX = self.m60.CLIP_AMMO_MAX * self.m60.NR_CLIPS_MAX
	self.m60.AMMO_PICKUP = {0.28, 11} --self:_pickup_chance(self.m60.AMMO_MAX, PICKUP.OTHER)
	self.m60.stats.damage = 125

	--RPK
	self.rpk.CLIP_AMMO_MAX = 100
	self.rpk.NR_CLIPS_MAX = 3
	self.rpk.AMMO_MAX = self.rpk.CLIP_AMMO_MAX * self.rpk.NR_CLIPS_MAX
	self.rpk.AMMO_PICKUP = {0.35, 12} --self:_pickup_chance(self.rpk.AMMO_MAX, PICKUP.OTHER)
	self.rpk.stats.damage = 120

	--hk21 / Brenner-21
	self.hk21.CLIP_AMMO_MAX = 150
	self.hk21.NR_CLIPS_MAX = 2
	self.hk21.AMMO_MAX = self.hk21.CLIP_AMMO_MAX * self.hk21.NR_CLIPS_MAX
	self.hk21.AMMO_PICKUP = {0.35, 12} --self:_pickup_chance(self.hk21.AMMO_MAX, PICKUP.OTHER)
	self.hk21.stats.damage = 120

	--LMG FAST ROF
	--mg42 / Buzzsaw 42
	self.mg42.CLIP_AMMO_MAX = 150
	self.mg42.NR_CLIPS_MAX = 3
	self.mg42.AMMO_MAX = self.mg42.CLIP_AMMO_MAX * self.mg42.NR_CLIPS_MAX
	self.mg42.AMMO_PICKUP = {4, 22} --self:_pickup_chance(self.mg42.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.mg42.stats.damage = 80

	--m249 / KSP
	self.m249.CLIP_AMMO_MAX = 200
	self.m249.NR_CLIPS_MAX = 2
	self.m249.AMMO_MAX = self.m249.CLIP_AMMO_MAX * self.m249.NR_CLIPS_MAX
	self.m249.AMMO_PICKUP = {6, 20} --self:_pickup_chance(self.m249.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.m249.stats.damage = 80

	--par / KSP 58
	self.par.CLIP_AMMO_MAX = 200
	self.par.NR_CLIPS_MAX = 2
	self.par.AMMO_MAX = self.par.CLIP_AMMO_MAX * self.par.NR_CLIPS_MAX
	self.par.AMMO_PICKUP = {6, 20} --self:_pickup_chance(self.par.AMMO_MAX, PICKUP.AR_HIGH_CAPACITY)
	self.par.stats.damage = 80

	--MG
	--shuno / XL 5.56 Microgun
	self.shuno.CLIP_AMMO_MAX = 800
	self.shuno.NR_CLIPS_MAX = 1
	self.shuno.AMMO_MAX = self.shuno.CLIP_AMMO_MAX * self.shuno.NR_CLIPS_MAX
	self.shuno.AMMO_PICKUP = {6, 27} --self:_pickup_chance(self.shuno.CLIP_AMMO_MAX, PICKUP.OTHER)
	self.shuno.stats.damage = 37
	self.m95.armor_piercing_chance = 0.25

	--m134 / "Vulcan" Minigun
	self.m134.CLIP_AMMO_MAX = 800
	self.m134.NR_CLIPS_MAX = 1
	self.m134.AMMO_MAX = self.m134.CLIP_AMMO_MAX * self.m134.NR_CLIPS_MAX
	self.m134.AMMO_PICKUP = {5, 27} --self:_pickup_chance(self.m134.CLIP_AMMO_MAX, PICKUP.OTHER)
	self.m134.stats.damage = 28
	self.m95.armor_piercing_chance = 0.5

	--GL
	--m32 / Piglet
	self.m32.CLIP_AMMO_MAX = 6
	self.m32.NR_CLIPS_MAX = 3
	self.m32.AMMO_MAX = self.m32.CLIP_AMMO_MAX * self.m32.NR_CLIPS_MAX
	self.m32.AMMO_PICKUP = { 0.05, 0.8 }

	--gre_m79 / GL40
	self.gre_m79.CLIP_AMMO_MAX = 1
	self.gre_m79.NR_CLIPS_MAX = 8 --math.round(weapon_data.total_damage_primary / 50 / self.gre_m79.CLIP_AMMO_MAX)
	self.gre_m79.AMMO_MAX = self.gre_m79.CLIP_AMMO_MAX * self.gre_m79.NR_CLIPS_MAX
	self.gre_m79.AMMO_PICKUP = { 0.05, 0.8 }

	--slap / Compact 40mm GL
	self.slap.CLIP_AMMO_MAX = 1
	self.slap.NR_CLIPS_MAX = 7 --math.round(weapon_data.total_damage_primary / 50 / self.slap.CLIP_AMMO_MAX)
	self.slap.AMMO_MAX = self.slap.CLIP_AMMO_MAX * self.slap.NR_CLIPS_MAX
	self.slap.AMMO_PICKUP = { 0.05, 0.8 }

	--china / China Puff 40mm GL
	self.china.CLIP_AMMO_MAX = 3
	self.china.NR_CLIPS_MAX = 3
	self.china.AMMO_MAX = (self.china.CLIP_AMMO_MAX * self.china.NR_CLIPS_MAX) + 1
	self.china.AMMO_PICKUP = { 0.05, 0.8 }

	--arbiter / Arbiter GL
	self.arbiter.CLIP_AMMO_MAX = 5
	self.arbiter.NR_CLIPS_MAX = 4
	self.arbiter.AMMO_MAX = self.arbiter.CLIP_AMMO_MAX * self.arbiter.NR_CLIPS_MAX
	self.arbiter.AMMO_PICKUP = { 0.05, 0.8 }

	--Saw
	self.saw.timers = {
		reload_not_empty = 3.7,
		reload_empty = 3.7,
		unequip = 0.8,
		equip = 0.8
	}
	self.saw.CLIP_AMMO_MAX = 150
	self.saw.NR_CLIPS_MAX = 3
	self.saw.AMMO_MAX = self.saw.CLIP_AMMO_MAX * self.saw.NR_CLIPS_MAX
	self.saw.AMMO_PICKUP = {
		0,
		0
	}
	self.saw.FIRE_MODE = "auto"
	self.saw.fire_mode_data = {
		fire_rate = 0.175
	}
	self.saw.auto = {
		fire_rate = 0.175
	}
	self.saw.panic_suppression_chance = 0.2
	self.saw.stats.damage = 102
	self.saw.hit_alert_size_increase = 4
	self.saw_secondary.timers = {
		reload_not_empty = 3.7,
		reload_empty = 3.7,
		unequip = 0.8,
		equip = 0.8
	}
	self.saw_secondary.CLIP_AMMO_MAX = 150
	self.saw_secondary.NR_CLIPS_MAX = 3
	self.saw_secondary.AMMO_MAX = self.saw_secondary.CLIP_AMMO_MAX * self.saw_secondary.NR_CLIPS_MAX
	self.saw_secondary.AMMO_PICKUP = {
		0,
		0
	}
	self.saw_secondary.FIRE_MODE = "auto"
	self.saw_secondary.fire_mode_data = {
		fire_rate = 0.175
	}
	self.saw_secondary.auto = {
		fire_rate = 0.175
	}
	self.saw_secondary.panic_suppression_chance = 0.2
	self.saw_secondary.stats.damage = 102
	self.saw_secondary.hit_alert_size_increase = 4

	--Flamethrower
	--Flamethrower mk2
	self.flamethrower_mk2.stats.damage = 18
	--Flamethrower smoll
	self.system.stats.damage = 14
end

--Trip Mine
Hooks:PostHook(WeaponTweakData, "_init_data_player_weapons", "RaID_WeaponTweakData_init_data_player_weapons", function(self, weapon_data)
	self.trip_mines = {
		delay = 0.25,
		damage = 100,
		player_damage = 5,
		damage_size = 300,
		alert_radius = 2000
	}
end)