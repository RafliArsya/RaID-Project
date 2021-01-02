SniperGrazeDamage = SniperGrazeDamage or {}

local TRAIL_EFFECT = Idstring("effects/particles/weapons/sniper_trail")
local idstr_trail = Idstring("trail")
local idstr_simulator_length = Idstring("simulator_length")
local idstr_size = Idstring("size")
local trail_length
local brush = Draw:brush(Color(0.2, 1, 0, 0), 1) 

function SniperGrazeDamage:on_weapon_fired(weapon_unit, result)
	if not weapon_unit:base():is_category("snp") then
		return
	end

	if weapon_unit ~= managers.player:equipped_weapon_unit() then
		return
	end

	if not result.hit_enemy then
		return
	end
	
	local upgrade_value = managers.player:upgrade_value("snp", "graze_damage")
	local enemies_hit = {}
	local best_damage = 0
	--local orig_damage = 0
	--local result_damage = 0
	local sentry_mask = managers.slot:get_mask("sentry_gun")
	local ally_mask = managers.slot:get_mask("all_criminals")
	local enemy_mask = managers.slot:get_mask("enemies")
	local radius = upgrade_value.radius
	local dmg_factor_hs = upgrade_value.damage_factor_headshot
	local dmg_factor = upgrade_value.damage_factor
	local dmg_factor_hs_lvl_2 = dmg_factor_hs * 100 >= 100 and true or false
	local dmg_factor_lvl_2 = dmg_factor * 100 >= 100 and true or false
	local aced = (dmg_factor_lvl_2 and dmg_factor_hs_lvl_2) and true or false

	for _, hit in ipairs(result.rays) do
		local is_turret = hit.unit:in_slot(sentry_mask)
		local is_ally = hit.unit:in_slot(ally_mask)
		local is_valid_hit = hit.damage_result and hit.damage_result.attack_data

		if not is_turret and not is_ally and is_valid_hit then
			local result = hit.damage_result
			local attack_data = result.attack_data
			local headshot_kill = attack_data.headshot and result.type == "death" or result.type == "healed"
			local damage_mul = headshot_kill and upgrade_value.damage_factor_headshot or upgrade_value.damage_factor
			--[[local damage_mul = 0
			local calc = math.min(math.random(dmg_factor * 100, dmg_factor_hs * 100), dmg_factor_hs * 100)
			calc = calc * 0.01
			
			--local body_calc = math.min(math.random((dmg_factor * 100) - 25, dmg_factor * 100), dmg_factor * 100)
			
			local headshot_dmg = aced and calc or dmg_factor_hs
			local body_dmg = aced and dmg_factor or calc
			
			damage_mul = headshot_kill and headshot_dmg or body_dmg
			orig_damage = orig_damage + attack_data.damage]]
			local _damage = attack_data.damage * damage_mul

			enemies_hit[hit.unit:key()] = {
				unit = hit.unit,
				position = hit.position
			}
			
			best_damage = best_damage < _damage and _damage or best_damage

		end
	end

	if best_damage == 0 then
		return
	end
	
	--result_damage = best_damage - orig_damage

	for _, hits in pairs(enemies_hit) do
		--brush:sphere(hits.position, radius)
		local hit_units = World:find_units_quick("sphere", hits.position, radius, enemy_mask)
		for _, unit in ipairs(hit_units) do
			local d_s = mvector3.distance_sq(hits.position, unit:movement():m_head_pos())
			if not enemies_hit[unit:key()] then
				local hit_pos = Vector3()
				mvector3.set(hit_pos, unit:movement():m_head_pos())
				
				if not trail_length then
					trail_length = World:effect_manager():get_initial_simulator_var_vector2(TRAIL_EFFECT, idstr_trail, idstr_simulator_length, idstr_size)
				end
				local trail = World:effect_manager():spawn({
					effect = Idstring("effects/particles/weapons/sniper_trail"),
					position = hits.position,
					normal = hit_pos - hits.position
				})
				mvector3.set_y(trail_length, math.sqrt(d_s))
				World:effect_manager():set_simulator_var_vector2(trail, idstr_trail, idstr_simulator_length, idstr_size, trail_length)
				
				unit:character_damage():damage_simple({
					variant = "graze",
					damage = best_damage,
					attacker_unit = managers.player:player_unit(),
					weapon_unit = weapon_unit,
					pos = hit_pos,
					attack_dir = hits.position - hit_pos
				})
			end
		end
    end

end
