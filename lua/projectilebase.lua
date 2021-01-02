function ProjectileBase:set_weapon_unit(weapon_unit)
	self._weapon_unit = weapon_unit
	self._weapon_id = weapon_unit and weapon_unit:base():get_name_id()
	self._weapon_damage_mult = weapon_unit and weapon_unit:base().projectile_damage_multiplier and weapon_unit:base():projectile_damage_multiplier() or 1
	self._shield_knock = managers.player:has_category_upgrade("player", "shield_knock") and true or false
	self._knock_down = managers.player:upgrade_value("weapon", "knock_down", nil)
end