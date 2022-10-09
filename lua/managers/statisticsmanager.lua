function StatisticsManager:killed(data)
	local stats_name = data.stats_name or data.name
	data.type = tweak_data.character[data.name] and tweak_data.character[data.name].challenges.type

	if not self._global.killed[stats_name] or not self._global.session.killed[stats_name] then
		Application:error("Bad name id applied to killed, " .. tostring(stats_name) .. ". Defaulting to 'other'")

		stats_name = "other"
	end

	local by_bullet = data.variant == "bullet"
	local by_melee = data.variant == "melee" or data.weapon_id and tweak_data.blackmarket.melee_weapons[data.weapon_id]
	local by_explosion = data.variant == "explosion"
	local by_other_variant = not by_bullet and not by_melee and not by_explosion
	local type = self._global.killed[stats_name]
	type.count = type.count + 1
	type.head_shots = type.head_shots + (data.head_shot and 1 or 0)
	type.melee = type.melee + (by_melee and 1 or 0)
	type.explosion = type.explosion + (by_explosion and 1 or 0)
	self._global.killed.total.count = self._global.killed.total.count + 1
	self._global.killed.total.head_shots = self._global.killed.total.head_shots + (data.head_shot and 1 or 0)
	self._global.killed.total.melee = self._global.killed.total.melee + (by_melee and 1 or 0)
	self._global.killed.total.explosion = self._global.killed.total.explosion + (by_explosion and 1 or 0)
	local type = self._global.session.killed[stats_name]
	type.count = type.count + 1
	type.head_shots = type.head_shots + (data.head_shot and 1 or 0)
	type.melee = type.melee + (by_melee and 1 or 0)
	type.explosion = type.explosion + (by_explosion and 1 or 0)
	self._global.session.killed.total.count = self._global.session.killed.total.count + 1
	self._global.session.killed.total.head_shots = self._global.session.killed.total.head_shots + (data.head_shot and 1 or 0)
	self._global.session.killed.total.melee = self._global.session.killed.total.melee + (by_melee and 1 or 0)
	self._global.session.killed.total.explosion = self._global.session.killed.total.explosion + (by_explosion and 1 or 0)

	if by_bullet then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		if throwable_id then
			self._global.session.killed_by_grenade[throwable_id] = (self._global.session.killed_by_grenade[throwable_id] or 0) + 1
			self._global.killed_by_grenade[throwable_id] = (self._global.killed_by_grenade[throwable_id] or 0) + 1
		else
			self:_add_to_killed_by_weapon(self._global.session, name_id, data, true)

			if self._global.session.killed_by_weapon[name_id] and self._global.session.killed_by_weapon[name_id].count == tweak_data.achievement.first_blood.count then
				local category = data.weapon_unit:base():weapon_tweak_data().categories[1]

				if category == tweak_data.achievement.first_blood.weapon_type then
					managers.achievment:award(tweak_data.achievement.first_blood.award)
				end
			end

			if data.name == "tank" then
				managers.achievment:set_script_data("dodge_this_active", true)
			end
		end
	elseif by_melee then
		local name_id = data.name or data.name_id

		log("killed by_melee(data): name_id = "..tostring(name_id))
		self._global.session.killed_by_melee[name_id] = (self._global.session.killed_by_melee[name_id] or 0) + 1
		self._global.killed_by_melee[name_id] = (self._global.killed_by_melee[name_id] or 0) + 1
	elseif by_explosion then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		if throwable_id then
			self._global.session.killed_by_grenade[throwable_id] = (self._global.session.killed_by_grenade[throwable_id] or 0) + 1
			self._global.killed_by_grenade[throwable_id] = (self._global.killed_by_grenade[throwable_id] or 0) + 1
		end

		if name_id and table.contains(self:_get_boom_guns(), name_id) then
			self:_add_to_killed_by_weapon(self._global.session, name_id, data, true)
		end
	elseif by_other_variant then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		log("killed by_other(data): name, throw = "..tostring(name_id)..", "..tostring(throwable_id))

		if throwable_id then
			self._global.session.killed_by_grenade[throwable_id] = (self._global.session.killed_by_grenade[throwable_id] or 0) + 1
			self._global.killed_by_grenade[throwable_id] = (self._global.killed_by_grenade[throwable_id] or 0) + 1
		else
			self:_add_to_killed_by_weapon(self._global.session, name_id, data, true)
		end
	end
end

function StatisticsManager:killed_by_anyone(data)
	local name_id = alive(data.weapon_unit) and data.weapon_unit:base():get_name_id()
	log("killed_by_anyone(data): name_id = "..tostring(name_id))

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

	if data.variant == "fire" then
		log("FIREEE")
	end

	if not by_melee then
		local name_id1, throwable_id1 = self:_get_name_id_and_throwable_id(data.weapon_unit)
		log("killed_by_anyone not by_melee(data) not melee: name, throw = "..tostring(name_id1)..", "..tostring(throwable_id1))
	end
	
	if by_bullet then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		if throwable_id then
			kills_table.killed_by_grenade[throwable_id] = (kills_table.killed_by_grenade[throwable_id] or 0) + 1
		else
			self:_add_to_killed_by_weapon(kills_table, name_id, data, false)
		end
	elseif by_melee then
		local name_id = data.name_id or data.name or "unknown"

		log("killed_by_anyone by_melee(data): name_id = "..tostring(name_id))

		if name_id then
			kills_table.killed_by_melee[name_id] = (kills_table.killed_by_melee[name_id] or 0) + 1
		end
	elseif by_explosion then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		if throwable_id then
			kills_table.killed_by_grenade[throwable_id] = (kills_table.killed_by_grenade[throwable_id] or 0) + 1
		end

		if name_id and table.contains(self:_get_boom_guns(), name_id) then
			self:_add_to_killed_by_weapon(kills_table, name_id, data, false)
		end
	elseif by_other_variant then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)
		log("killed_by_anyone by_other(data): name, throw = "..tostring(name_id)..", "..tostring(throwable_id))

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