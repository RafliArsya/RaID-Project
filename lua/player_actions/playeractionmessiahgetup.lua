PlayerAction.MessiahGetUp = {
	Priority = 1,
	Function = function (player_manager, state)
		local hint = "skill_messiah_get_up"

		if _G.IS_VR then
			hint = "skill_messiah_get_up_vr"
		end

		managers.hint:show_hint(hint)

		local controller = player_manager:player_unit():base():controller()
		local co = coroutine.running()

		if player_manager:current_state() == "bleed_out" then
			state = state + 1
		end

		while state > 0 do
			local button_pressed = controller:get_input_pressed("jump")
			local state_a = player_manager:current_state() == "bleed_out"
			local state_b = player_manager:current_state() == "fatal"
			local is_in_state = player_manager:current_state() == "bleed_out" or player_manager:current_state() == "fatal"

			if _G.IS_VR then
				button_pressed = controller:get_input_pressed("warp")
			end

			state = state - (is_in_state and 0 or 1)

			if state <= 0 then
				break
			end

			if button_pressed then
				player_manager:use_messiah_charge()
				player_manager:send_message(Message.RevivePlayer, nil, nil)

				break
			end

			coroutine.yield(co)
		end
	end
}
