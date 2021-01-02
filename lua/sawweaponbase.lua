local tank_server_names = {
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
}
local diff_mult = {
    easy = 1.5,
    normal = 2.5,
    hard = 2.75,
    overkill = 4,
    overkill_145 = 6,
    easy_wish = 8,
    overkill_290 = 12,
    sm_wish = 16
}

function SawHit:on_collision(col_ray, weapon_unit, user_unit, damage)
    local diff = Global.game_settings and Global.game_settings.difficulty or "normal"
	local hit_unit = col_ray.unit

	if hit_unit and (table.contains(tank_server_names, hit_unit:name()) or table.contains(tank_client_names, hit_unit:name())) then
		damage = 50
    end

	local result = InstantBulletBase.on_collision(self, col_ray, weapon_unit, user_unit, damage * diff_mult[diff])

	if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
		damage = math.clamp(damage * managers.player:upgrade_value("saw", "lock_damage_multiplier", 1) * 4, 0, 300)

		col_ray.body:extension().damage:damage_lock(user_unit, col_ray.normal, col_ray.position, col_ray.direction, damage)

		if hit_unit:id() ~= -1 then
			managers.network:session():send_to_peers_synched("sync_body_damage_lock", col_ray.body, damage)
		end
	end

	return result
end