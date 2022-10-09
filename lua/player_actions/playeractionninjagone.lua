PlayerAction.NinjaGone = {
	Priority = 1,
	Function = function (player_manager, n_hud, player)
		local co = coroutine.running()

		local last_sus = player:_get_sus_rat()

		local interact_string = managers.localization:text("hud_int_ninja_escape", {
			BTN_GADGET = managers.localization:btn_macro("weapon_gadget", false)
		})
		
		local sus_rat = type(player:_get_sus_rat())=="number" and player:_get_sus_rat() > 0 or type(player:_get_sus_rat())=="boolean" and tostring(player:_get_sus_rat()) == "true" and (type(last_sus)=="number" and last_sus < 1 or not last_sus)
		local controller = player_manager:player_unit():base():controller()
		local whisper = managers.groupai and managers.groupai:state():whisper_mode()
		

		while true do
			local current_time = Application:time()
			local button_pressed = controller:get_input_pressed("weapon_gadget")
			local carry = player_manager:current_state() == "carry" or player_manager:get_my_carry_data() or player_manager:is_carrying()
			local is_pass = player_manager:current_state() == "standard" and not carry and sus_rat and whisper

			if not whisper then
				break
			end

			if not is_pass then
				break
			end

			if type(last_sus)=="number" and last_sus < 1 and player:_get_sus_rat() == true then
				break
			end

			if type(last_sus)=="number" and last_sus > 0 and player:_get_sus_rat() == false then
				break
			end

			if player._ninja_gone.hud_t and player._ninja_gone.hud_t < current_time then
				if type(last_sus) == "boolean" and player:ninja_escape_hud() then
					break
				end
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
				player:ninja_escape_t(Application:time() + 2.25)
				player:ninja_escape_cd(Application:time() + 20)
				if player:current_state():_do_mover() then
					player:current_state():_do_mover()
				end
				player._ninja_gone.hud_after_gone = Application:time() + 1
				break
			end

			last_sus = player:_get_sus_rat()
			coroutine.yield(co)
		end	
		
		if player:ninja_escape_hud() and not managers.interaction:active_unit() then
			n_hud:remove_interact()		
		end
		player._ninja_gone.is_hud_on = false
		player._ninja_gone.hud_t = nil
		--[[if player_manager._coroutine_mgr:is_running("ninja_gone") then
			player_manager._coroutine_mgr:remove_coroutine("ninja_gone")
		end]]
	end
}
