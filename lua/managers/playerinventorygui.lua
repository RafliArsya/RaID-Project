function PlayerInventoryGui:_update_info_deployable(name, slot)
	local deployable_id = managers.blackmarket:equipped_deployable(slot)
	local equipment_data = deployable_id and tweak_data.equipments[deployable_id]
	local deployable_data = deployable_id and tweak_data.blackmarket.deployables[deployable_id]
	local text_string = ""

	if deployable_data and equipment_data then
		local amount = equipment_data.quantity[1] or 1

		if deployable_id == "sentry_gun_silent" then
			deployable_id = "sentry_gun"
		end

		amount = amount + (managers.player:equiptment_upgrade_value(deployable_id, "quantity") or 0)

		if slot and slot > 1 then
			amount = math.ceil(amount * managers.player:upgrade_value("player", "second_deployable_mul", 0.5))
		end

		text_string = text_string .. managers.localization:text(deployable_data.name_id) .. " (x" .. tostring(amount) .. ")" .. "\n\n"

		if self:_should_show_description() then
			text_string = text_string .. managers.localization:text(deployable_data.desc_id, {
				BTN_INTERACT = managers.localization:btn_macro("interact", true),
				BTN_USE_ITEM = managers.localization:btn_macro("use_item", true)
			}) .. "\n"
		end
	end

	self:set_info_text(text_string)
end