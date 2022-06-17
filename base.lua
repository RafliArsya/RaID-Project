_G.RaID = _G.RaID or {}
RaID._path = ModPath
--RaID._menu = RaID._path .. "menu/"
--RaID._loc = RaID._path .. "localization/"
RaID._data_path = SavePath .. "RaID_settings.txt"
RaID._settings = {}
RaID._data = {}

function MenuCallbackHandler:is_modded_client()
	return rawget(_G, "BLT") ~= nil
end

function MenuCallbackHandler:is_not_modded_client()
	return not MenuCallbackHandler:is_modded_client()
end

function MenuCallbackHandler:build_mods_list()
	local mods = {}

	if self:is_modded_client() then
		local BLT = rawget(_G, "BLT")

		if BLT and BLT.Mods and BLT.Mods then
			for _, mod in ipairs(BLT.Mods:Mods()) do
				local data = {
					mod:GetName(),
					mod:GetId()
				}

				table.insert(mods, data)
			end
		end
	end

	return mods
end