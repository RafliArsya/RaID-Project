function ArrowBase:_setup_from_tweak_data(arrow_entry)
	local arrow_entry = self._tweak_projectile_entry or "west_arrow"
	local tweak_entry = tweak_data.projectiles[arrow_entry]
	self._damage_class_string = tweak_data.projectiles[self._tweak_projectile_entry].bullet_class or "InstantBulletBase"
	self._damage_class = CoreSerialize.string_to_classtable(self._damage_class_string)
	self._mass_look_up_modifier = tweak_entry.mass_look_up_modifier
	self._damage = tweak_entry.damage or 1
	self._slot_mask = managers.slot:get_mask("arrow_impact_targets")
	self._damage = self._damage * 2.5
end

function ArrowBase:set_weapon_unit(weapon_unit)
	ArrowBase.super.set_weapon_unit(self, weapon_unit)

	self._weapon_damage_mult = weapon_unit and weapon_unit:base().projectile_damage_multiplier and weapon_unit:base():projectile_damage_multiplier() or 1
	self._weapon_charge_value = weapon_unit and weapon_unit:base().projectile_charge_value and weapon_unit:base():projectile_charge_value() or 1
	self._weapon_speed_mult = weapon_unit and weapon_unit:base().projectile_speed_multiplier and weapon_unit:base():projectile_speed_multiplier() or 1
	self._weapon_charge_fail = weapon_unit and weapon_unit:base().charge_fail and weapon_unit:base():charge_fail() or false

	if not self._weapon_charge_fail then
		self:add_trail_effect()
	end
end