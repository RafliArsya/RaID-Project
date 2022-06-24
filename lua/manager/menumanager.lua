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

                if true then
                    break
                end

				table.insert(mods, data)
			end
		end
	end

	return mods
end