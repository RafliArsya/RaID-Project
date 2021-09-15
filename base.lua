_G.RaID = _G.RaID or {}
RaID._path = ModPath
RaID._menu = RaID._path .. "menu/"
RaID._loc = RaID._path .. "localization/"
RaID._data_path = SavePath .. "RaID_settings.txt"
RaID._settings = {}
RaID._data = {}

function RaID:Load()
	if not SystemFS:exists(self._data_path) then
		self:FirstLoad()
	end
	
	local file = io.open(self._data_path, "r")
    if (file) then
        for k, v in pairs(json.decode(file:read("*all"))) do
            self._settings[k] = v
			self._data[k] = v
        end
		file:close()
    end
end

function RaID:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._settings ) )
		file:close()
	end
end

function RaID:DefSet()
	self._settings["toggle_sync_sentry_mark"] = true
	self:settings_data("toggle_sync_sentry_mark")
	self._settings["toggle_feign_death_plus"] = true
	self:settings_data("toggle_feign_death_plus")
	self._settings["toggle_send_feign_death_info"] = false
	self:settings_data("toggle_send_feign_death_info")
	self._settings["toggle_sentry_skill_is_player"] = true
	self:settings_data("toggle_sentry_skill_is_player")
	self._settings["toggle_heavy_armor_drop"] = false
	self:settings_data("toggle_toggle_heavy_armor_drop")
	self._settings["toggle_caps_npc_weapon_rays"] = false
	self:settings_data("toggle_caps_npc_weapon_rays")
	self._settings["value_caps_npc_weapon_rays"] = 4
	self:settings_data("value_caps_npc_weapon_rays")
	
	self:Save()
end

function RaID:FirstLoad()
	self:DefSet()
end

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

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_RaID", function( menu_manager )
	
	MenuCallbackHandler.callback_select = function(self, item)
		RaID._settings[item:name()] = item:value()
		RaID:Save()
		RaID:Load()
	end
	MenuCallbackHandler.RaID_callback_close = function(self)
        RaID:Save()
    end
	
	MenuCallbackHandler.RaID_sync_sentry_mark = function(self, item)
		RaID._settings.toggle_sync_sentry_mark = (item:value() == "on" and true or false)
		RaID:Save()
		RaID:settings_data("toggle_sync_sentry_mark")
	end
	
	MenuCallbackHandler.RaID_feign_death_plus = function(self, item)
		RaID._settings.toggle_feign_death_plus = (item:value() == "on" and true or false)
		RaID:Save()
		RaID:settings_data("toggle_feign_death_plus")
	end
	
	MenuCallbackHandler.RaID_send_feign_death_info = function(self, item)
		RaID._settings.toggle_send_feign_death_info = (item:value() == "on" and true or false)
		RaID:Save()
		RaID:settings_data("toggle_send_feign_death_info")
	end

	MenuCallbackHandler.RaID_sentry_skill_is_player = function(self, item)
		RaID._settings.toggle_sentry_skill_is_player = (item:value() == "on" and true or false)
		RaID:Save()
		RaID:settings_data("toggle_sentry_skill_is_player")
	end

	MenuCallbackHandler.RaID_heavy_armor_drop = function(self, item)
		RaID._settings.toggle_heavy_armor_drop = (item:value() == "on" and true or false)
		RaID:Save()
		RaID:settings_data("toggle_heavy_armor_drop")
	end
	
	MenuCallbackHandler.RaID_toggle_caps_npc_weapon_rays = function(self, item)
		RaID._settings.toggle_caps_npc_weapon_rays = (item:value() == "on" and true or false)
		RaID:Save()
		RaID:settings_data("toggle_caps_npc_weapon_rays")
	end
	
	MenuCallbackHandler.RaID_caps_npc_weapon_rays = function(self, item)
		local get_value = item:value() - math.floor(item:value())
		get_value = get_value >= 0.5 and math.ceil(item:value()) or math.floor(item:value())
		RaID._settings.value_caps_npc_weapon_rays = get_value
		RaID:Save()
		RaID:settings_data("value_caps_npc_weapon_rays")
	end
	
	MenuCallbackHandler.RaID_updatesetting = function(self, item)
		RaID:update_settings(item)
	end
	
	MenuCallbackHandler.RaID_resetsettings = function(self, item)
		RaID:DefSet()
		RaID:update_settings(item)
    end
	
	RaID:Load()
	MenuHelper:LoadFromJsonFile( RaID._menu .. "main.txt", RaID, RaID._settings )
end )

function RaID:get_data(name)
	return RaID._settings[name]
end

function RaID:settings_data(name)
	if not RaID._data[name] then
		RaID._data[name] = {}
	end
	RaID._data[name] = RaID._settings[name]
end

function RaID:settings_now(name)
	return RaID._data[name]
end

function RaID:update_settings(item)
	MenuHelper:ResetItemsToDefaultValue(item, {["op_toggle_sync_sentry_mark"] = true}, RaID:settings_now("toggle_sync_sentry_mark"))
	MenuHelper:ResetItemsToDefaultValue(item, {["op_toggle_feign_death_plus"] = true}, RaID:settings_now("toggle_feign_death_plus"))
	
	MenuHelper:ResetItemsToDefaultValue(item, {["op_toggle_send_feign_death_info"] = true}, RaID:settings_now("toggle_send_feign_death_info"))
	MenuHelper:ResetItemsToDefaultValue(item, {["op_toggle_sentry_skill_is_player"] = true}, RaID:settings_now("toggle_sentry_skill_is_player"))
	MenuHelper:ResetItemsToDefaultValue(item, {["op_toggle_heavy_armor_drop"] = true}, RaID:settings_now("toggle_heavy_armor_drop"))
	MenuHelper:ResetItemsToDefaultValue(item, {["op_toggle_caps_npc_weapon_rays"] = true}, RaID:settings_now("toggle_caps_npc_weapon_rays"))
	
	MenuHelper:ResetItemsToDefaultValue(item, {["op_slider_value_caps_npc_weapon_rays"] = true}, RaID:settings_now("value_caps_npc_weapon_rays"))
end