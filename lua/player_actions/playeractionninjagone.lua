PlayerAction.NinjaGone = {
	Priority = 1,
	Function = function (player_manager, n_hud, player)
		local co = coroutine.running()

		local interact_string = managers.localization:text("hud_int_ninja_escape", {
			BTN_GADGET = managers.localization:btn_macro("weapon_gadget", false)
		})
		
		local sus_rat = type(player:_get_sus_rat())=="number" and player:_get_sus_rat() > 0 or type(player:_get_sus_rat())=="boolean" and tostring(player:_get_sus_rat()) == "true"
		local controller = player_manager:player_unit():base():controller()
		local whisper = managers.groupai and managers.groupai:state():whisper_mode()
		local is_pass = player_manager:current_state() == "standard" and player_manager:current_state() ~= "carry" and sus_rat and whisper

		while is_pass do
			local break_rules = type(player:_get_sus_rat())=="number" and (player:_get_sus_rat() == 0 or player:_get_sus_rat() == 1) or type(player:_get_sus_rat())=="boolean" and tostring(player:_get_sus_rat())=="false"
			local current_time = Application:time()
			local button_pressed = controller:get_input_pressed("weapon_gadget")

			if not whisper or break_rules then
				break
			end

			if not player:ninja_escape_hud() then
				n_hud:show_interact({
					icon = "mugshot_electrified",
					text = interact_string
				})
				player._ninja_gone.is_hud_on = true
			end

			if player:ninja_escape_hud() and not managers.interaction:active_unit() then
				n_hud:show_interact({
					icon = "mugshot_electrified",
					text = interact_string
				})
			end

			if button_pressed then
				player:set_attention_settings({
					"pl_civilian"
				})
				player:ninja_escape_t(current_time + 2)
				player:ninja_escape_cd(current_time + 20)
				if player:current_state():_do_mover() then
					player:current_state():_do_mover()
				end
				n_hud:remove_interact()
				player._ninja_gone.is_hud_on = false
				break
			end

			coroutine.yield(co)
		end	
		
		if player:ninja_escape_hud() and not managers.interaction:active_unit() then
			n_hud:remove_interact()		
		end
		player._ninja_gone.is_hud_on = false
		if player_manager._coroutine_mgr:is_running("ninja_gone") then
			player_manager._coroutine_mgr:remove_coroutine("ninja_gone")
		end
	end
}
