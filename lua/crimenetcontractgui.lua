function CrimeNetContractGui:mouse_pressed(o, button, x, y)
	if alive(self._briefing_len_panel) and self._briefing_len_panel:visible() and self._step > 2 and self._briefing_len_panel:child("button_text"):inside(x, y) then
		self:toggle_post_event()
	end

	if alive(self._potential_rewards_title) and self._potential_rewards_title:visible() and self._potential_rewards_title:inside(x, y) then
		self:_toggle_potential_rewards()
	end

	if self._active_page and button == Idstring("0") then
		for k, tab_item in pairs(self._tabs) do
			if not tab_item:is_active() and tab_item:inside(x, y) then
				self:set_active_page(tab_item:index())
			end
		end
	end

	if self._mod_items and self._mods_tab and self._mods_tab:is_active() and button == Idstring("0") then
		for _, item in ipairs(self._mod_items) do
			if item[1]:inside(x, y) then
			
				local mod_name = item[1]:name()
				local search = ""

				for substring in mod_name:gmatch("%S+") do
					if search ~= '' then
						search = search.."+"..substring
					else
						search = search..substring
					end
				end
				
				Steam:overlay_activate("url", "https://www.google.com/search?q=payday+2+" .. search )

				break
			end
		end
	end
end