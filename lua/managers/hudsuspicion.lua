function HUDSuspicion:hide()
	if self._eye_animation then
		self._eye_animation:stop()

		self._eye_animation = nil

		self._sound_source:post_event("hud_suspicion_end")
	end

	self._suspicion_value = 0
	self._discovered = nil
	self._back_to_stealth = nil

	if alive(self._misc_panel) then
		self._misc_panel:stop()
		self._misc_panel:child("hud_stealth_eye"):set_alpha(0)
		self._misc_panel:child("hud_stealth_exclam"):set_alpha(0)
		self._misc_panel:child("hud_stealthmeter_bg"):set_alpha(0)
	end

	if alive(self._suspicion_panel) then
		self._suspicion_panel:set_visible(false)
		self._suspicion_panel:child("suspicion_detected"):stop()
		self._suspicion_panel:child("suspicion_detected"):set_alpha(0)
	end

    --[[local pm = managers.player and managers.player
	local pu = pm and pm:player_unit()
	local nhud = pu and pu:movement():ninja_escape_hud()

    if nhud then
        if not managers.interaction:active_unit()then
            managers.hud:remove_interact()
        end
        pu:movement()._ninja_gone.is_hud_on = false
        pu:movement()._ninja_gone.should_off = true
    end]]

    --[[if pm._coroutine_mgr:is_running("ninja_gone") then
        pu:movement()._ninja_gone.is_hud_on = false
        pm._coroutine_mgr:remove_coroutine("ninja_gone")
    end]]
end