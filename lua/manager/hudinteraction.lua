function HUDInteraction:remove_interact()
	if not alive(self._hud_panel) then
		return
	end

	local pm = managers.player and managers.player
	if pm then
		local pu = pm and pm:player_unit()
		local nhud = pu and pu:movement():ninja_escape_hud()

    	if nhud == true then
        	pu:movement():ninja_escape_hud(false)
    	end
	end
	
	self._hud_panel:child(self._child_name_text):set_visible(false)
	self._hud_panel:child(self._child_ivalid_name_text):set_visible(false)
end