function NewRaycastWeaponBase:init(unit)
	NewRaycastWeaponBase.super.init(self, unit)

	self._property_mgr = PropertyManager:new()
	self._gadgets = nil
	self._armor_piercing_chance = self:weapon_tweak_data().armor_piercing_chance or 0
	self._use_shotgun_reload = self:weapon_tweak_data().use_shotgun_reload
	self._movement_penalty = tweak_data.upgrades.weapon_movement_penalty[self:weapon_tweak_data().categories[1]] or 1
	self._deploy_speed_multiplier = 1
	self._textures = {}
	self._cosmetics_data = nil
	self._materials = nil
	self._use_armor_piercing = managers.player:has_category_upgrade("player", "ap_bullets")
	self._shield_knock = managers.player:has_category_upgrade("player", "shield_knock") and true or false
	self._knock_down = managers.player:upgrade_value("weapon", "knock_down", nil)
	self._stagger = false
	self._fire_mode_category = self:weapon_tweak_data().FIRE_MODE

	self._weapon_knockback_inc = 0
	
	self._weapon_knockdown_inc = 0

	if managers.player:has_category_upgrade("player", "armor_depleted_stagger_shot") then
		local function clbk(value)
			self:set_stagger(value)
		end
		local function reset()
			self:set_stagger(false)
		end

		managers.player:register_message(Message.SetWeaponStagger, self, clbk)
		managers.player:register_message(Message.ResetStagger, self, reset)
	end

	if self:weapon_tweak_data().bipod_deploy_multiplier then
		self._property_mgr:set_property("bipod_deploy_multiplier", self:weapon_tweak_data().bipod_deploy_multiplier)
	end

	self._bloodthist_value_during_reload = 0
	self._reload_objects = {}
end

function NewRaycastWeaponBase:KNOCK_DOWN_CHANCE(value)
	if value and value == 0 then
		self._weapon_knockdown_inc = 0
		return
	elseif value and value > 0 then
		self._weapon_knockdown_inc = self._weapon_knockdown_inc + value
		return
	else
		return self._weapon_knockdown_inc
	end
end

function NewRaycastWeaponBase:KNOCK_BACK_CHANCE(value)
	if value then
		if value == 0 then
			self._weapon_knockback_inc = 0
		else
			self._weapon_knockback_inc = self._weapon_knockback_inc + value
		end
	else
		return self._weapon_knockback_inc
	end
end

function NewRaycastWeaponBase:reload_speed_multiplier()
	if self._current_reload_speed_multiplier then
		return self._current_reload_speed_multiplier
	end

	local multiplier = 1

	for _, category in ipairs(self:weapon_tweak_data().categories) do
		multiplier = multiplier + 1 - managers.player:upgrade_value(category, "reload_speed_multiplier", 1)
	end

	multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "passive_reload_speed_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value(self._name_id, "reload_speed_multiplier", 1)

	if self._setup and alive(self._setup.user_unit) and self._setup.user_unit:movement() then
		local morale_boost_bonus = self._setup.user_unit:movement():morale_boost()

		if morale_boost_bonus then
			multiplier = multiplier + 1 - morale_boost_bonus.reload_speed_bonus
		end

		if self._setup.user_unit:movement():next_reload_speed_multiplier() then
			multiplier = multiplier + 1 - self._setup.user_unit:movement():next_reload_speed_multiplier()
		end
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "reload_weapon_faster") then
		multiplier = multiplier + 1 - managers.player:temporary_upgrade_value("temporary", "reload_weapon_faster", 1)
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "reload_weapon_faster_second") then
		multiplier = multiplier + 1 - managers.player:temporary_upgrade_value("temporary", "reload_weapon_faster_second", 1)
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "single_shot_fast_reload") then
		multiplier = multiplier + 1 - managers.player:temporary_upgrade_value("temporary", "single_shot_fast_reload", 1)
	end

	multiplier = multiplier + 1 - managers.player:get_property("shock_and_awe_reload_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:get_temporary_property("bloodthirst_reload_speed", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value("team", "crew_faster_reload", 1)
	multiplier = self:_convert_add_to_mul(multiplier)
	multiplier = multiplier * self:reload_speed_stat()
	multiplier = managers.modifiers:modify_value("WeaponBase:GetReloadSpeedMultiplier", multiplier)

	return multiplier
end