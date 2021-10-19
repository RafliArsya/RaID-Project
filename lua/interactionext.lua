function UseInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	UseInteractionExt.super.interact(self, player)

	if self._tweak_data.equipment_consume then
		managers.player:remove_special(self._tweak_data.special_equipment)

		if self._tweak_data.special_equipment == "planks" and Global.level_data.level_id == "secret_stash" then
			UseInteractionExt._saviour_count = (UseInteractionExt._saviour_count or 0) + 1
		end
	end

	if self._tweak_data.deployable_consume then
		if (self._tweak_data.required_deployable == "trip_mine" or self._tweak_data.required_deployable == "shaped_charge") and managers.player:interact_bp() then
		else
			managers.player:remove_equipment(self._tweak_data.required_deployable)
		end
	end

	if self._tweak_data.sound_event then
		player:sound():play(self._tweak_data.sound_event)
	end

	self:remove_interact()

	if managers.player:interact_bp() == true then
		managers.player:interact_bp(0)
	end

	if self._unit:damage() then
		self._unit:damage():run_sequence_simple("interact", {
			unit = player
		})
	end

	managers.network:session():send_to_peers_synched("sync_interacted", self._unit, -2, self.tweak_data, 1)

	if self._global_event then
		managers.mission:call_global_event(self._global_event, player)
	end

	if self._achievement_stat then
		managers.achievment:award_progress(self._achievement_stat)
	elseif self._achievement_id then
		managers.achievment:award(self._achievement_id)
	elseif self._challenge_stat then
		managers.challenge:award_progress(self._challenge_stat)
	elseif self._trophy_stat then
		managers.custom_safehouse:award(self._trophy_stat)
	elseif self._challenge_award then
		managers.challenge:award(self._challenge_award)
	elseif self._sidejob_award then
		managers.generic_side_jobs:award(self._sidejob_award)
	elseif self.award_blackmarket then
		local args = string.split(self.award_blackmarket, " ")

		managers.blackmarket:add_to_inventory(unpack(args))
	end

	print("Trying to OFF")

	if not self.keep_active_after_interaction then
		print("OFF")
		self:set_active(false)
	end

	return true
end

function MissionDoorDeviceInteractionExt:result_place_mission_door_device(placed)
	if placed then
		if self._tweak_data.equipment_consume then
			managers.player:remove_special(self._tweak_data.special_equipment)
		end

		if self._tweak_data.deployable_consume then
			if (self._tweak_data.required_deployable == "trip_mine" or self._tweak_data.required_deployable == "shaped_charge") and managers.player:interact_bp() then
			else
				managers.player:remove_equipment(self._tweak_data.required_deployable, self._tweak_data.slot or 1)
			end
		end
		if managers.player:interact_bp() == true then
			managers.player:interact_bp(0)
		end

		if self._tweak_data.deployable_consume and self._tweak_data.required_deployable then
			local equipment = managers.player:selected_equipment()

			if not equipment then
				managers.player:switch_equipment()
			end
		end
	end
end