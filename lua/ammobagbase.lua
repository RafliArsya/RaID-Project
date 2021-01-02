AmmoBagBase.List = {}
function AmmoBagBase.Add(obj, pos, min_distance)
	table.insert(AmmoBagBase.List, {
		obj = obj,
		pos = pos,
		min_distance = min_distance
	})
end

function AmmoBagBase.Remove(obj)
	if not AmmoBagBase.List then
		return
	end
	for i, o in pairs(AmmoBagBase.List) do
		if obj == o.obj then
			table.remove(AmmoBagBase.List, i)

			return
		end
	end
end

function AmmoBagBase.GetAmmoBag(pos)
	if not AmmoBagBase.List then
		return false
	end
	for i, o in pairs(AmmoBagBase.List) do
		local dst = mvector3.distance(pos, o.pos)

		if dst <= o.min_distance then
			return true
		end
	end

	return nil
end

function AmmoBagBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit
	self._is_attachable = true
	self._bullet_storm_level = 0
	self._max_ammo_amount = tweak_data.upgrades.ammo_bag_base + managers.player:upgrade_value_by_level("ammo_bag", "ammo_increase", 1)

	self._unit:sound_source():post_event("ammo_bag_drop")

	if Network:is_client() then
		self._validate_clbk_id = "ammo_bag_validate" .. tostring(unit:key())

		managers.enemy:add_delayed_clbk(self._validate_clbk_id, callback(self, self, "_clbk_validate"), Application:time() + 60)
	end
	
	AmmoBagBase.Add(self._unit, self._unit:position(), 401)
end


function AmmoBagBase:destroy()
	AmmoBagBase.Remove(self._unit)
	
	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end
end
--[[Hooks:PostHook(AmmoBagBase, "init", "RaID_AmmoBagBase_Init", function(self, unit)
	if managers.player:has_category_upgrade("player", "no_ammo_cost_mk2") then
		self._no_ammo_cost_mk2_inc = 0
	end
end)

Hooks:PostHook(AmmoBagBase, "update", "RaID_AmmoBagBase_Update", function(self, unit, t, dt)
	if self._unit and not self._empty and managers.player:has_category_upgrade("player", "no_ammo_cost_mk2")  then
		local pm = managers.player:local_player()
		local data = managers.player:upgrade_value("player", "no_ammo_cost_mk2")
		if pm and mvector3.distance(pm:position(), self._unit:position()) <= 600 and not self._no_ammo_cost_mk2_delay then
			pass = data.chance + (self._no_ammo_cost_mk2_inc / 100)
			log("no ammo cost mk2 : "..pass)
			if not self._no_ammo_cost_mk2_delay and pass >= math.random() then
				self._no_ammo_cost_mk2_delay = math.random(data.delay * 0.5, data.delay)
				self._no_ammo_cost_mk2_inc = 0
				managers.player:add_to_temporary_property("bullet_storm", math.random(data.duration, data.duration * 2), 1)
			else
				self._no_ammo_cost_mk2_delay = data.delay/2
				self._no_ammo_cost_mk2_inc = self._no_ammo_cost_mk2_inc + math.random(data.inc)
			end
		end
		if self._no_ammo_cost_mk2_delay then
			self._no_ammo_cost_mk2_delay = self._no_ammo_cost_mk2_delay - dt
			if self._no_ammo_cost_mk2_delay <= 0 then
				self._no_ammo_cost_mk2_delay = nil
			end
		end
	end
end)]]