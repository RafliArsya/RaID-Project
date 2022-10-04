function CustomSafehouseManager:can_progress_trophies(id)
	if not self:unlocked() then
		return false
	end

	local result = true

	if managers.mutators:are_trophies_disabled() then
		for i, achivement_category in ipairs(self._mutator_achievement_categories) do
			local achievements = tweak_data.achievement[achivement_category]

			if achievements then
				for _, achievement_data in pairs(achievements) do
					if achievement_data.trophy_stat == id then
						result = achievement_data.mutators or true
						return result
					end
				end
			end
		end

		return result
	end

	return result
end

function CustomSafehouseManager:_update_trophy_progress(trophy, key, id, amount, complete_func)
	if trophy.completed then
		return
	end

	for obj_idx, objective in ipairs(trophy.objectives) do
		if not objective.completed and objective[key] == id then
			local pass = true

			if objective.verify then
				pass = tweak_data.safehouse[objective.verify](tweak_data.safehouse, objective)
			end

			if pass then
				--[[local inc = math.random(100, 500)
				local incd = inc
				log("increase by "..tostring(incd))]]
				objective.progress = math.floor(math.min((objective.progress or 0) + amount, objective.max_progress))
				objective.completed = objective.max_progress <= objective.progress

				for _, objective in ipairs(trophy.objectives) do
					if not objective.completed then
						pass = false

						break
					end
				end

				if pass then
					complete_func(self, trophy)

					if managers.hud then
						managers.hud:post_event("Achievement_challenge")
					end
				end

				break
			end
		end
	end
end