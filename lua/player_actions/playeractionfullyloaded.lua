local function on_ammo_pickup(unit, pickup_chance, increase, player_manager)
	local gained_throwable = false
	local chance = pickup_chance
	local reserv = player_manager._fully_loaded_reserv
	log(tostring(reserv))
	local max_grenade = player_manager:got_max_grenades()
	local maxed = max_grenade and reserv == 1
	
	if unit == managers.player:player_unit() then
		local random = math.random()

		if maxed then
			return gained_throwable, chance, maxed
		end

		if player_manager._fully_loaded_reserv == 1 then
			player_manager._fully_loaded_reserv = 0
			gained_throwable = true
		end

		if not gained_throwable then
			if random < chance then
				gained_throwable = true
			else
				chance = chance + increase
			end
		end

		if gained_throwable then
			if max_grenade then
				managers.player._fully_loaded_reserv = 1
			else
				managers.player:add_grenade_amount(1, true)
			end
		end
		
	end

	return gained_throwable, chance, maxed
end

PlayerAction.FullyLoaded = {
	Priority = 1,
	Function = function (player_manager, pickup_chance, increase)
		local co = coroutine.running()
		local gained_throwable = false
		local chance = pickup_chance
		local maxed = false

		local function on_ammo_pickup_message(unit)
			gained_throwable, chance, maxed = on_ammo_pickup(unit, chance, increase, player_manager)
		end

		player_manager:register_message(Message.OnAmmoPickup, co, on_ammo_pickup_message)
		player_manager:register_message(Message.OnAmmoPickup, co, on_ammo_pickup)

		while not gained_throwable do
			if maxed then
				break
			end
			coroutine.yield(co)
		end

		player_manager:unregister_message(Message.OnAmmoPickup, co)
	end
}