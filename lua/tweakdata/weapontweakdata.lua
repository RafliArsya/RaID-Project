local initw_pd2 = WeaponTweakData.init
local pcw_pd2 = WeaponTweakData._pickup_chance
local PICKUP = {
	AR_LOW_CAPACITY = 7,
	SHOTGUN_HIGH_CAPACITY = 4,
	OTHER = 1,
	LMG_CAPACITY = 9,
	AR_MED_CAPACITY = 3,
	SNIPER_HIGH_DAMAGE = 6,
	AR_HIGH_CAPACITY = 2,
	SNIPER_LOW_DAMAGE = 5,
	AR_DMR_CAPACITY = 8,
    SPECIAL = 10,
    MINIGUN = 11
}

function WeaponTweakData:_pickup_chance(max_ammo, selection_index)
	local low, high = nil

	if _G.IS_VR then
		return pcw_pd2(self, max_ammo, selection_index)
	elseif selection_index == PICKUP.AR_HIGH_CAPACITY then
		low = 0.03
		high = 0.055
	elseif selection_index == PICKUP.AR_MED_CAPACITY then
		low = 0.03
		high = 0.055
	elseif selection_index == PICKUP.AR_LOW_CAPACITY then
		low = 0.03
		high = 0.045
	elseif selection_index == PICKUP.AR_DMR_CAPACITY then
		low = 0.018
		high = 0.04
	elseif selection_index == PICKUP.PISTOL_HIGH_CAPACITY then
		low = 0.025
		high = 0.035
	elseif selection_index == PICKUP.PISTOL_LOW_CAPACITY then
		low = 0.025
		high = 0.038
	elseif selection_index == PICKUP.LMG_CAPACITY then
		low = 0.025
		high = 0.03
	elseif selection_index == PICKUP.LMG_HIGH_CAPACITY then
		low = 0.02
		high = 0.024
	elseif selection_index == PICKUP.SHOTGUN_HIGH_CAPACITY then
		low = 0.05
		high = 0.075
	elseif selection_index == PICKUP.SHOTGUN_SECOND_CAPACITY then
		low = 0.03
		high = 0.055
	elseif selection_index == PICKUP.SNIPER_LOW_DAMAGE then
		low = 0.05
		high = 0.075
	elseif selection_index == PICKUP.SNIPER_HIGH_DAMAGE then
		low = 0.005
		high = 0.015
    elseif selection_index == PICKUP.FLAMETHROWER_LOW then
        low = 0.015
		high = 0.03
    elseif selection_index == PICKUP.FLAMETHROWER_HIGH then
        low = 0.005
		high = 0.02
    elseif selection_index == PICKUP.SPECIAL then
        low = 0.005
		high = 0.025
    elseif selection_index == PICKUP.MINIGUN then
        low = 0.015
		high = 0.035
	else
		low = 0.01
		high = 0.035
	end

	return {
		max_ammo * low,
		max_ammo * high
	}
end

function WeaponTweakData:init(tweak_data)
	initw_pd2(self, tweak_data)
 
    self.basset.rays = 12
    self.basset.stats.damage = 12

    self.x_basset.rays = 8
    self.x_basset.stats.damage = 16

    self.boot.rays = 12
    self.boot.stats.damage = 39

    self.ultima.rays = 10
    self.ultima.stats.damage = 37

    self.coach.rays = 12
    self.coach.stats.damage = 39
    
    self.judge.rays = 10
    self.judge.stats.damage = 52

    self.x_judge.rays = 10
    self.x_judge.stats.damage = 51

    self.m1897.rays = 10
    self.m1897.stats.damage = 40

    self.serbu.rays = 12
    self.serbu.stats.damage = 23
    
    self.striker.rays = 9
    self.striker.stats.damage = 14

    self.x_type54_underbarrel.rays = 8
    self.x_type54_underbarrel.stats.damage = 28
    self.x_type54_underbarrel.stats_modifiers.damage = 10
    self.x_type54_underbarrel.CLIP_AMMO_MAX = 2
	self.x_type54_underbarrel.NR_CLIPS_MAX = 4
	self.x_type54_underbarrel.AMMO_MAX = self.x_type54_underbarrel.CLIP_AMMO_MAX * self.x_type54_underbarrel.NR_CLIPS_MAX

    self.type54_underbarrel.CLIP_AMMO_MAX = 1
	self.type54_underbarrel.NR_CLIPS_MAX = 5
	self.type54_underbarrel.AMMO_MAX = self.type54_underbarrel.CLIP_AMMO_MAX * self.type54_underbarrel.NR_CLIPS_MAX
    self.type54_underbarrel.rays = 8
    self.type54_underbarrel.stats.damage = 29
    self.type54_underbarrel.stats_modifiers.damage = 10

    self.rota.rays = 12
    self.rota.stats.damage = 14

    self.x_rota.rays = 8
	self.x_rota.stats.damage = 14
    
    self.benelli.rays = 9
    self.benelli.stats.damage = 18

    self.m590.rays = 12
    self.m590.stats.damage = 28
    
    self.ksg.rays = 9
    self.ksg.stats.damage = 30
    
    self.aa12.rays = 12
    self.aa12.stats.damage = 11
    
    self.b682.rays = 12
    self.b682.stats.damage = 39
    self.b682.stats_modifiers.damage = 1
    
    self.m37.rays = 12
    self.m37.stats.damage = 39

    self.spas12.rays = 12
    self.spas12.stats.damage = 14
    
    self.saiga.rays = 12
    self.saiga.stats.damage = 11

    self.sko12.rays = 12
    self.sko12.stats.damage = 17

    self.x_sko12.rays = 8
    self.x_sko12.stats.damage = 16
    
    self.huntsman.rays = 12
    self.huntsman.stats.damage = 39
    self.huntsman.stats_modifiers.damage = 1
    
    self.r870.rays = 10
    self.r870.stats.damage = 30

    self.hailstorm.AMMO_PICKUP = self:_pickup_chance(self.hailstorm.AMMO_MAX, PICKUP.SPECIAL)
    self.hailstorm.fire_mode_data.volley.damage_mul = 5
    self.hailstorm.fire_mode_data.volley.rays = 18
	self.hailstorm.fire_mode_data.volley.can_shoot_through_wall = true
	self.hailstorm.fire_mode_data.volley.can_shoot_through_shield = true
	self.hailstorm.fire_mode_data.volley.can_shoot_through_enemy = true
    self.hailstorm.charge_data = {
		max_t = 0.5,
		cooldown_t = 0.2
	}

    self.m134.AMMO_PICKUP = self:_pickup_chance(self.m134.CLIP_AMMO_MAX, PICKUP.MINIGUN)
    self.shuno.AMMO_PICKUP = self:_pickup_chance(self.shuno.CLIP_AMMO_MAX, PICKUP.MINIGUN)
end