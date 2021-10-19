--[[local tank_server_names = {
	Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
	Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
	Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
	Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4")
}

local tank_client_names = {
	Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1_husk"),
	Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2_husk"),
	Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3_husk"),
	Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4_husk")
}]]

function SawWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	if self:get_ammo_remaining_in_clip() == 0 then
		return
	end

	local user_unit = self._setup.user_unit
	local ray_res, hit_something = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	local function randomFloat(min, max, precision)
		local range = max - min
		local offset = range * math.random()
		local unrounded = min + offset
	
		if not precision then
			return unrounded
		end
	
		local powerOfTen = 10 ^ precision
		return math.floor(unrounded * powerOfTen + 0.5) / powerOfTen
	end

	if hit_something then
		self:_start_sawing_effect()

		local ammo_usage = 5

		if ray_res.hit_enemy then
			if managers.player:has_category_upgrade("saw", "enemy_slicer") then
				ammo_usage = managers.player:upgrade_value("saw", "enemy_slicer", 10)
			else
				ammo_usage = 15
			end
		end

		--[[if ray_res.hit_enemy then
			if managers.player:has_category_upgrade("saw", "enemy_slicer") then
				ammo_usage = ammo_usage + math.min(randomFloat(10), managers.player:upgrade_value("saw", "enemy_slicer", 10))
			end
		else
			ammo_usage = ammo_usage + randomFloat(10)
		end]]

		ammo_usage = ammo_usage + randomFloat(1,10,0)
		if managers.player:has_category_upgrade("saw", "consume_no_ammo_chance") then
			local roll = math.rand(1)
			local chance = managers.player:upgrade_value("saw", "consume_no_ammo_chance", 0)

			if roll < chance then
				ammo_usage = 0
			end
		end

		local no_ammo_use = managers.player:has_active_temporary_property("bullet_storm") or (managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier") and managers.player:has_category_upgrade("player", "berserker_no_ammo_cost")) or managers.player:has_activate_temporary_upgrade("temporary", "no_ammo_revenge")

		if no_ammo_use then
			ammo_usage = 0
		end

		ammo_usage = math.min(ammo_usage, self:get_ammo_remaining_in_clip())

		self:set_ammo_remaining_in_clip(math.max(self:get_ammo_remaining_in_clip() - ammo_usage, 0))
		self:set_ammo_total(math.max(self:get_ammo_total() - ammo_usage, 0))
		self:_check_ammo_total(user_unit)
	else
		self:_stop_sawing_effect()
	end

	if self._alert_events and ray_res.rays then
		if hit_something then
			self._alert_size = self._hit_alert_size
		else
			self._alert_size = self._no_hit_alert_size
		end

		self._current_stats.alert_size = self._alert_size

		self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
	end

	return ray_res
end

function SawHit:on_collision(col_ray, weapon_unit, user_unit, damage)
	local hit_unit = col_ray.unit

	if hit_unit:base() and hit_unit:base().has_tag and hit_unit:base():has_tag("tank") then
		damage = math.max(damage or 10, math.random(50, 80))
	elseif hit_unit:base() and hit_unit:base().has_tag and not hit_unit:base():has_tag("tank") and hit_unit:character_damage() ~= nil and not CopDamage.is_civilian(hit_unit:base()._tweak_table) and managers.player:has_category_upgrade("saw", "enemy_slicer") and managers.player:upgrade_value("saw", "enemy_slicer", 10) == 5 then
		damage = math.max(damage or 10, 40)
	else
		damage = damage or 10
	end

	local result = InstantBulletBase.on_collision(self, col_ray, weapon_unit, user_unit, damage)

	if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
		damage = math.clamp(damage * managers.player:upgrade_value("saw", "lock_damage_multiplier", 1) * 4, 0, 300)

		col_ray.body:extension().damage:damage_lock(user_unit, col_ray.normal, col_ray.position, col_ray.direction, damage)

		if hit_unit:id() ~= -1 then
			managers.network:session():send_to_peers_synched("sync_body_damage_lock", col_ray.body, damage)
		end
	end

	return result
end