Hooks:PostHook(PoisonGasEffect, 'init', 'RaIDPost_PoisonGasEffect_Init', function(self, position, normal, projectile_tweak, grenade_unit)
    self._unit_list_t = {}
    self._dot_timer = TimerManager:game():time() + 4
end)

function PoisonGasEffect:update(t, dt)
	if self._timer then
		self._timer = self._timer - dt

		if not self._started_fading and self._timer <= self._fade_time then
			World:effect_manager():fade_kill(self._effect)

			self._started_fading = true
		end

		if self._timer <= 0 then
			self._timer = nil
            self._dot_timer = nil

			if alive(self._grenade_unit) and Network:is_server() then
				managers.enemy:add_delayed_clbk("PoisonGasEffect", callback(PoisonGasEffect, PoisonGasEffect, "remove_grenade_unit"), TimerManager:game():time() + self._dot_data.dot_length)
			end
		end

		if self._is_local_player then
			self._damage_tick_timer = self._damage_tick_timer - dt

			if self._damage_tick_timer <= 0 then
				self._damage_tick_timer = self._tweak_data.poison_gas_tick_time or 0.1
				local nearby_units = World:find_units_quick("sphere", self._position, self._range, managers.slot:get_mask("enemies"))

				for _, unit in ipairs(nearby_units) do
					if not table.contains(self._unit_list, unit) then
						local hurt_animation = not self._dot_data.hurt_animation_chance or math.rand(1) < self._dot_data.hurt_animation_chance

						managers.dot:add_doted_enemy(unit, TimerManager:game():time(), self._grenade_unit, self._dot_data.dot_length, self._dot_data.dot_damage, hurt_animation, "poison", self._grenade_id, true)
						table.insert(self._unit_list, unit)
                        --log("unit = "..tostring(unit:key()))
                        self._unit_list_t[unit] = TimerManager:game():time() + (self._dot_data.dot_length * self._dot_data.dot_tick_period)
					end
				end
			end

            if self._dot_timer and type(self._dot_timer)=="number" and self._dot_timer < TimerManager:game():time() then
                self._dot_timer = TimerManager:game():time() + 2
                
                for key, val in pairs(self._unit_list_t) do
                    local enemy_alive = alive(key) and key:character_damage() and not key:character_damage():dead()
                    if not enemy_alive or self._unit_list_t[key] < TimerManager:game():time() then
                        self._unit_list_t[key] = nil
                        table.delete(self._unit_list, key)
                    end
                end
            end
		end 
	end
end
