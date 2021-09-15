local armor_init = tweak_data.player.damage.ARMOR_INIT
function PlayerCarry:_get_max_walk_speed(...)
	local multiplier = tweak_data.carry.types[self._tweak_data_name].move_speed_modifier
	multiplier = managers.player:has_category_upgrade("carry", "movement_penalty_nullifier") and 1 or math.clamp(multiplier * managers.player:upgrade_value("carry", "movement_speed_multiplier", 1), 0, 1)

	if managers.player:has_category_upgrade("player", "armor_carry_bonus") then
		local base_max_armor = armor_init + managers.player:body_armor_value("armor") + managers.player:body_armor_skill_addend()
		local mul = managers.player:upgrade_value("player", "armor_carry_bonus", 1)
        base_max_armor = base_max_armor * 10

        local target_loop = 8
		for i = 1, base_max_armor do
            if i % target_loop == 0 then
                multiplier = multiplier * mul
            end
		end

		multiplier = math.clamp(multiplier, 0, 1)
	end

	return PlayerCarry.super._get_max_walk_speed(self, ...) * multiplier
end