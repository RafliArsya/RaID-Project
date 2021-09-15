--[[local tank_server_names = {
	Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
	Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
	Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
	Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4")
}

local tank_client_names = {
	Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1_husk"),
	Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2_husk"),
	Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3_husk"),
	Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4_husk")
}]]

function SawHit:on_collision(col_ray, weapon_unit, user_unit, damage)
	local hit_unit = col_ray.unit

	if hit_unit:base() and hit_unit:base().has_tag and hit_unit:base():has_tag("tank") then
		damage = math.max(damage or 10, math.random(50, 80))
	end

	local result = InstantBulletBase.on_collision(self, col_ray, weapon_unit, user_unit, damage)

	if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
		damage = math.clamp(damage * managers.player:upgrade_value("saw", "lock_damage_multiplier", 1) * 4, 0, 300)

		col_ray.body:extension().damage:damage_lock(user_unit, col_ray.normal, col_ray.position, col_ray.direction, damage)

		if hit_unit:id() ~= -1 then
			managers.network:session():send_to_peers_synched("sync_body_damage_lock", col_ray.body, damage)
		end
	end

	return result
end