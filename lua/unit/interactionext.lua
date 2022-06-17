function AmmoBagInteractionExt:interact(player)
	AmmoBagInteractionExt.super.super.interact(self, player)

	local interacted, bullet_storm = self._unit:base():take_ammo(player)

	for id, weapon in pairs(player:inventory():available_selections()) do
		managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
	end

	if bullet_storm and bullet_storm ~= false then
		managers.player:set_bulletstorm(bullet_storm) --managers.player:add_to_temporary_property("bullet_storm", bullet_storm, 1)
	end

	return interacted
end