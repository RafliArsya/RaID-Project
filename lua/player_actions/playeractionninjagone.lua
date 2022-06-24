PlayerAction.NinjaGone = {
	Priority = 1,
	Function = function (player_manager, n_hud, player)
		local co = coroutine.running()
		local current_time = Application:time()

		local interact_string = managers.localization:text("hud_int_ninja_escape", {
			BTN_INTERACT = managers.localization:btn_macro("interact", false)
		})

		n_hud:show_interact({
			icon = "mugshot_electrified",
			text = interact_string
		})

		player:ninja_escape_hud(true)

		local is_pass = player_manager:current_state() == "standard" and player_manager:current_state() ~= "carry"
		local controller = player_manager:player_unit():base():controller()

		while is_pass do
			local button_pressed = controller:get_input_pressed("interact")
			local break_rules = not player:_get_sus_rat() or player:ninja_escape_hot()

			if break_rules then
				break
			end

			if button_pressed then
				player:set_attention_settings({
					"pl_civilian"
				})
				player:ninja_escape_t(current_time + 2)
				player:ninja_escape_cd(current_time + 10)
				if player:current_state():_do_mover() then
					player:current_state():_do_mover()
				end
				player:ninja_escape_hud(false)
				n_hud:remove_interact()
			end

			coroutine.yield(co)
		end	
		player:ninja_escape_hud(false)
		n_hud:remove_interact()
	end
}
