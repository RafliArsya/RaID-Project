Hooks:PostHook(SentryGunBrain, "init", "RaID_SentryGunBrain_init", function(self, unit)
	self._tower_explode_t = self._tower_explode_t or {}
	self._tower_explode_t = managers.player:has_category_upgrade("sentry_gun", "tower_explosion") and (self._tower_explode_t or {}) or nil
	if self._unit:base():is_owner() and self._active and not self._tower_explode_t[self._unit:key()] and managers.player:has_category_upgrade("sentry_gun", "tower_explosion") then
		local data = managers.player:upgrade_value("sentry_gun", "tower_explosion")
		self._tower_explode_t[self._unit:key()] = TimerManager:game():time() + data.interval
	end
end)

Hooks:PostHook(SentryGunBrain, "update", "RaID_SentryGunBrain_Update", function(self, unit, t, dt)
	if self._tower_explode_t then
		if self._tower_explode_t[self._unit:key()] and self._tower_explode_t[self._unit:key()] < t or self._tower_explode_t[self._unit:key()] and (not alive(self._unit) or not self._unit:key()) then
			self._tower_explode_t[self._unit:key()] = nil
		end
	end
end)

Hooks:PostHook(SentryGunBrain, "_upd_fire", "RaID_SentryGunBrain__upd_fire", function(self, t)
	local _t = TimerManager:game():time()
	local pm = managers.player
	local player = pm:player_unit()
	
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
	
	if pm:has_category_upgrade("sentry_gun", "tower_explosion") and self._unit:base():is_owner() then
		local data = pm:upgrade_value("sentry_gun", "tower_explosion")
		if not self._tower_explode_t[self._unit:key()] then
			local s_pos = self._unit:position()
			local bodies = World:find_units_quick("sphere", s_pos, data.radius, managers.slot:get_mask(data.slotmask))
			local col_ray = { }
			--col_ray.ray = Vector3(1, 0, 0)
			--col_ray.position = e_pos
			local interval = data.interval * math.min((math.floor(math.random()*100)*0.01)+0.1,1)
			interval = math.clamp(interval, data.min_interval, data.interval)
			self._tower_explode_t[self._unit:key()] = _t + interval
			--log(tonumber(self._tower_explode_t[self._unit:key()]))
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
			for _, hit_unit in pairs(bodies) do
				local civs, enemies, sentry = unit_stance(hit_unit)
				action_data.col_ray = {
					body = hit_unit:body("body"),
					position = hit_unit:position() + math.UP * 100, 
					ray = hit_unit:body("body") and hit_unit:center_of_mass() or alive(hit_unit) and hit_unit:position()
				}
				if hit_unit:character_damage() and enemies then
					local attacker = RaID:get_data("toggle_sentry_skill_is_player") and player or self._unit
					local weapon = RaID:get_data("toggle_sentry_skill_is_player") and player:inventory():equipped_unit() or self._unit
					hit_unit:character_damage():damage_bullet(action_data)
					--managers.fire:add_doted_enemy( hit_unit , _t , weapon , math.random(2, 7) , data.damage, attacker, true )
				end
			end
		end
	end
end)