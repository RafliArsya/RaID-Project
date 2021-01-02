if RequiredScript == "lib/managers/explosionmanager" then
	
end

Hooks:PostHook(ExplosionManager, "init", "RaID_ExplosionManager_init", function(self)
	self._door_health_mul_diff = {
		easy = 1,
		normal = 1,
		hard = 1,
		overkill = 1,
		overkill_145 = 1,
		easy_wish = 1,
		overkill_290 = 1,
		sm_wish = 1
	}
	--[[self._door_health_mul_diff = {
		easy = 100,
		normal = 150,
		hard = 170,
		overkill = 175,
		overkill_145 = 200,
		easy_wish = 225,
		overkill_290 = 250,
		sm_wish = 325
	}]]
end)

Hooks:PostHook(ExplosionManager, "detect_and_give_dmg", "RaID_ExplosionManager_detect_and_give_dmg", function(self, params)
	log("Executed")
	local hit_pos = type(params) == "table" and params.hit_pos or nil
	local slotmask = params.collision_slotmask
	local dmg = params.damage or nil
	if hit_pos and dmg then
		local units = World:find_units("sphere", hit_pos, 300, slotmask or managers.slot:get_mask("bullet_impact_targets"))
		if type(units) == "table" and units[1] then
			for id, hit_unit in pairs(units) do
				if hit_unit:base() and type(hit_unit:base()._devices) == "table" and type(hit_unit:base()._devices.c4) == "table" and type(hit_unit:base()._devices.c4.amount) == "number" then
					if not hit_unit:base()._devices.c4.max_health then
						hit_unit:base()._devices.c4.max_health = 1
					end
					if hit_unit:base()._devices.c4.max_health then
						hit_unit:base()._devices.c4.max_health = hit_unit:base()._devices.c4.max_health - dmg
					end
					if hit_unit:base()._devices.c4.max_health <= 0 then
						for i=1, hit_unit:base()._devices.c4.amount, 1
						do
							hit_unit:base():device_completed("c4")
						end
						--[[hit_unit:base():device_completed("c4")
						hit_unit:base():_destroy_devices()
						hit_unit:base():_initiate_c4_sequence() work
						hit_unit:damage():run_sequence_simple("activate_explode_sequence")
						hit_unit:damage():run_sequence_simple("explode_door")]]
					end
					break
				end
			end
		end
	end
end)