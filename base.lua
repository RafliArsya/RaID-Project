_G.RaID = _G.RaID or {}
RaID._path = ModPath
RaID._save = SavePath
RaID._loc = RaID._path .. "localization/"
RaID._settings = {}
RaID._data = {}

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_RaID", function(loc)
	for _, filename in pairs(file.GetFiles(RaID._loc)) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(RaID._loc .. filename)
			break
		end
	end
	loc:load_localization_file(RaID._loc .. "english.txt", false)
end)