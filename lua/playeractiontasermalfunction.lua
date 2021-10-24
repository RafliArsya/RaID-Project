PlayerAction.TaserMalfunction = {}
PlayerAction.TaserMalfunction.Priority = 1

-- Lines: 6 to 20
PlayerAction.TaserMalfunction.Function = function (player_manager, interval, chance_to_trigger)
	local co = coroutine.running()
	local elapsed = 0
	local target_elapsed = Application:time() + interval
	
	while player_manager:current_state() == "tased" do
		elapsed = Application:time()

		if target_elapsed <= elapsed then
			local total = chance_to_trigger
			local chance_to_incr = player_manager:_taser_mal_incr()
			total = total + chance_to_incr
			if math.random() <= total then
				player_manager:_taser_mal_incr(0)
				player_manager:send_message(Message.SendTaserMalfunction, nil, nil)
			else
				if not player_manager:_taser_mal_incr_cd() then
					local chance_inc = math.random(1, 5) * 0.01
					player_manager:_taser_mal_incr(chance_inc)
					player_manager:_taser_mal_incr_cd(Application:time() + math.random(3))
					--log("Malfunction = "..chance_to_incr)
				end
			end

			target_elapsed = Application:time() + interval
		end

		coroutine.yield(co)
	end
	
end

