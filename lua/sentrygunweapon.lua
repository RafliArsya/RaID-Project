--[[Hooks:PostHook(SentryGunWeapon, "setup", "RaID_SentryGunWeapon_setup", function(self, setup_data)
	if managers.player:has_category_upgrade("sentry_gun", "damage_explosion") then
		self._damage_explode_t =  self._damage_explode_t or {}
	else
		self._damage_explode_t = nil
	end
	if self._unit:base():is_owner() and managers.player:has_category_upgrade("sentry_gun", "damage_explosion") and self._damage_explode_t and not self._damage_explode_t[self._unit:key()] then
		log("setuppp")
		local data = managers.player:upgrade_value("sentry_gun", "damage_explosion")
		self._damage_explode_t[self._unit:key()] = TimerManager:game():time() + data.interval
	end
end)]]

local orig_fire_raycast = SentryGunWeapon._fire_raycast
function SentryGunWeapon:_fire_raycast(from_pos, direction, shoot_player, target_unit)
    if managers.player:has_category_upgrade("sentry_gun", "special_mark") and managers.groupai:state():is_enemy_special(target_unit) and self._unit:base():is_owner() then
        if managers.player:has_category_upgrade("sentry_gun", "mark_boost") then
			target_unit:contour():add("mark_enemy_damage_bonus", RaID:get_data("toggle_sync_sentry_mark"), 1)
        else
			target_unit:contour():add("mark_enemy", RaID:get_data("toggle_sync_sentry_mark"), 1)
        end
    end
	
	local function unit_stance(unit_key)
		if alive(unit_key) and unit_key:character_damage() and not unit_key:character_damage():dead() then
			local is_civ = CopDamage.is_civilian(unit_key:base()._tweak_table)
			local is_sentry = unit_key:base() and unit_key:base().sentry_gun and (unit_key:base():get_type() == "sentry_gun" or unit_key:base():get_type() == "sentry_gun_silent")
			local is_enemy = unit_key:base() and unit_key:base()._tweak_table and managers.enemy:is_enemy(unit_key)
			local is_converted = unit_key:brain() and unit_key:brain()._logic_data and unit_key:brain()._logic_data.is_converted
			local is_enggage = unit_key:brain() and unit_key:brain():is_hostile() 
			local is_human = (is_civ or is_enemy) and true or false
			local unit_mov = unit_key:movement()
			local unit_enggage = unit_mov and not is_sentry and is_human and not unit_mov:cool()
			local unit_hostile = unit_mov and not is_sentry and is_human and unit_mov:stance_name() == "hos"
			local unit_cbt = unit_mov and not is_sentry and is_human and unit_mov:stance_name() == "cbt"
			local unit_sentry_enemy = is_sentry and unit_mov and unit_mov:team().foes[tweak_data.levels:get_default_team_ID("player")]
			local unit_dmg = unit_key:character_damage()
			if is_civ and (unit_enggage or unit_hostile) then
				return true, false, false
			end
			if is_civ and (unit_enggage or unit_hostile) then
				return true, false, false
			end
			if not is_civ and not is_converted and is_enggage and unit_enggage and (unit_hostile or unit_cbt) then
				return false, true, false
			end
			if unit_sentry and unit_sentry_enemy then
				if unit_dmg then
					return false, false, true
				end
			end
		end
		return false, false, false
	end	
	
	local _t = TimerManager:game():time()
	local pm = managers.player
	local player = pm:player_unit()

	if pm:has_category_upgrade("sentry_gun", "damage_explosion") and self._unit:base():is_owner() then
		local data = pm:upgrade_value("sentry_gun", "damage_explosion")	
		if self._damage_explode_t and not self._damage_explode_t[self._unit:key()] then
			local e_pos = target_unit:position()
			local bodies = World:find_units_quick("sphere", e_pos, data.radius, managers.slot:get_mask(data.slotmask))
			local col_ray = { }
			col_ray.ray = Vector3(1, 0, 0)
			col_ray.position = e_pos
			local interval = data.interval * math.min((math.floor(math.random()*100)/100)+0.1,1)
			interval = math.clamp(interval, data.min_interval, data.interval)
			self._damage_explode_t[self._unit:key()] = _t + interval
			local action_data = {
				variant = "bullet" or "light",
				damage = data.damage,
				weapon_unit = self._unit,
				attacker_unit = RaID:get_data("toggle_sentry_skill_is_player") and player or self._unit,
				col_ray = col_ray,
				armor_piercing = false,
				shield_knock = false,
				origin = self._unit:position(),
				knock_down = false,
				stagger = false
			}
			log("Sentry Gun Damage Explode = "..tonumber(self._damage_explode_t[self._unit:key()]))
			for _, hit_unit in pairs(bodies) do
				local civs, enemies, sentry = unit_stance(hit_unit)

				action_data.col_ray = {
					body = hit_unit:body("body"),
					position = hit_unit:position() + math.UP * 100, 
					ray = hit_unit:body("body") and hit_unit:center_of_mass() or alive(hit_unit) and hit_unit:position()
				}

				if hit_unit:character_damage() and (enemies or civs or sentry) then
					hit_unit:character_damage():damage_bullet(action_data)
				end
			end
            --[[local action_data = {
				variant = "explosion",
				damage = data.damage,
				attacker_unit = RaID:get_data("toggle_sentry_skill_is_player") and player or self._unit,
				weapon_unit = self._unit, --player:base().sentry_gun, self._unit, player:inventory():equipped_unit(),
				col_ray = col_ray
			}
			--log("Sentry Gun Damage Explode = "..self._damage_explode_t)
			for _, hit_unit in pairs(bodies) do
				local civs, enemies, sentry = unit_stance(hit_unit)
				if hit_unit:character_damage() and (enemies or civs or sentry) then
					hit_unit:character_damage():damage_explosion(action_data)
				end
			end]]
		end
	end
	
    return orig_fire_raycast(self, from_pos, direction, shoot_player, target_unit)
end

Hooks:PostHook(SentryGunWeapon, "init", "RaID_SentryGunWeapon", function(self)
	self._damage_explode_t = self._damage_explode_t or {}
	if not managers.player:has_category_upgrade("sentry_gun", "damage_explosion") then
		self._damage_explode_t = nil
	end
end)

Hooks:PostHook(SentryGunWeapon, "update", "RaID_SentryGunWeapon", function(self, unit, t, dt)
	if self._damage_explode_t then
		if self._damage_explode_t[self._unit:key()] and self._damage_explode_t[self._unit:key()] < t or self._damage_explode_t[self._unit:key()] and (not alive(self._unit) or not self._unit:key()) then
			self._damage_explode_t[self._unit:key()] = nil
		end
	end
end)

--[[Hooks:PostHook(SentryGunWeapon, "_fire_raycast", "RaID_fire_raycast", function(self, from_pos, direction, target_unit, ...)
	if managers.player:has_category_upgrade("sentry_gun", "tower_explosion") and self._unit:base():is_owner() then
		local data = managers.player:upgrade_value("sentry_gun", "tower_explosion")
		local player = managers.player:player_unit()
		local _t = math.round(TimerManager:game():time())
		if _t >= self._tower_explode_t then
			--log("SENTRY FIRE")
			local e_pos = self._unit:position()
			local bodies = World:find_units_quick("sphere", e_pos, data.radius, managers.slot:get_mask("enemies"))
			local col_ray = { }
			col_ray.ray = Vector3(1, 0, 0)
			col_ray.position = e_pos
			local interval = data.max_interval * math.random()
			if interval < data.interval then
				interval = data.interval
			end
			self._tower_explode_t = _t + interval
			local action_data = {
				variant = "explosion",
				damage = data.damage,
				attacker_unit = player,
				weapon_unit = player:base().sentry_gun,
				col_ray = col_ray
			}
			--log("Sentry Gun Damage Explode = "..self._tower_explode_t)
			for _, hit_unit in ipairs(bodies) do
				if hit_unit:character_damage() then
					hit_unit:character_damage():damage_explosion(action_data)
				end
			end
		end
	end
end)]]