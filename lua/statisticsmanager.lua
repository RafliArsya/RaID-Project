function StatisticsManager:killed_by_anyone(data)
	local name_id = alive(data.weapon_unit) and data.weapon_unit:base():get_name_id()

	managers.achievment:set_script_data("pacifist_fail", true)

	if name_id ~= "m79" and name_id ~= "m79_crew" then
		managers.achievment:set_script_data("blow_out_fail", true)
	end

	local kills_table = self._global.session.killed_by_anyone
	local by_bullet = data.variant == "bullet"
	local by_melee = data.variant == "melee" or (data.name_id or data.name) and tweak_data.blackmarket.melee_weapons[data.name_id or data.name]
	local by_explosion = data.variant == "explosion"
	local by_other_variant = not by_bullet and not by_melee and not by_explosion
	local is_molotov = data.is_molotov

	if by_bullet then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)
		
		if throwable_id then
			kills_table.killed_by_grenade[throwable_id] = (kills_table.killed_by_grenade[throwable_id] or 0) + 1
			--log("by_bullet throwable")
		else
			self:_add_to_killed_by_weapon(kills_table, name_id, data, false)
			--log("by_bullet weapon")
		end
	elseif by_melee then
		local name_id = data.name_id or data.name or "unknown"

		if name_id then
			kills_table.killed_by_melee[name_id] = (kills_table.killed_by_melee[name_id] or 0) + 1
		end
	elseif by_explosion then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		if throwable_id then
			kills_table.killed_by_grenade[throwable_id] = (kills_table.killed_by_grenade[throwable_id] or 0) + 1
			--log("explosion throwable")
		else
			--log("explosion")
		end
		--log("name_id = "..tostring(name_id))
		--log("name_id = "..tostring(throwable_id))
		if name_id and table.contains(self:_get_boom_guns(), name_id) then
			self:_add_to_killed_by_weapon(kills_table, name_id, data, false)
		end
	elseif by_other_variant then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		if throwable_id then
			kills_table.killed_by_grenade[throwable_id] = (kills_table.killed_by_grenade[throwable_id] or 0) + 1
		elseif is_molotov then
			if type(is_molotov) == "boolean" then
				kills_table.killed_by_grenade.molotov = (kills_table.killed_by_grenade.molotov or 0) + 1
			else
				kills_table.killed_by_grenade[is_molotov] = (kills_table.killed_by_grenade[is_molotov] or 0) + 1
			end
		else
			self:_add_to_killed_by_weapon(kills_table, name_id, data, false)
		end
	end
end

function StatisticsManager:_get_name_id_and_throwable_id(weapon_unit)
	if not alive(weapon_unit) then
		return nil, nil
	end

	if weapon_unit:base().projectile_entry then
		local projectile_data = tweak_data.blackmarket.projectiles[weapon_unit:base():projectile_entry()]
		local name_id = projectile_data.weapon_id
		local throwable_id = projectile_data.throwable and weapon_unit:base():projectile_entry()

		return name_id, throwable_id
	elseif weapon_unit:base().get_name_id then
		local name_id = weapon_unit:base():get_name_id()
		--log("Weapon "..tostring(weapon_unit:base():get_name_id()))

		return name_id, nil
	end
end