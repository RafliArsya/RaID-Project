function TripMineBase:__raycast()
	local from_pos = self._unit:position() + self._unit:rotation():y() * 10
	local to_pos = from_pos + self._unit:rotation():y() * 800
	local ray = self._unit:raycast("ray", from_pos, to_pos, "slot_mask", managers.slot:get_mask("world_geometry"))
	local length = math.clamp(ray and ray.distance + 10 or 800, 0, 900)

	local ray_to_pos = Vector3()
	mvector3.set(ray_to_pos, self._forward)
	mvector3.multiply(ray_to_pos, length)
	mvector3.add(ray_to_pos, self._ray_from_pos)
	return self._unit:raycast("ray", self._ray_from_pos, ray_to_pos, "slot_mask", self._slotmask, "ray_type", "trip_mine body")
end

function TripMineBase:_sensor(t)
	local ray = self:__raycast()

	if ray and ray.unit and not tweak_data.character[ray.unit:base()._tweak_table].is_escort then
		self._sensor_units_detected = self._sensor_units_detected or {}

		if not self._sensor_units_detected[ray.unit:key()] then
			self._sensor_units_detected[ray.unit:key()] = true

			if managers.player:has_category_upgrade("trip_mine", "sensor_highlight") and (managers.groupai:state():whisper_mode() and tweak_data.character[ray.unit:base()._tweak_table].silent_priority_shout or tweak_data.character[ray.unit:base()._tweak_table].priority_shout) then
				managers.game_play_central:auto_highlight_enemy(ray.unit, true)
				self:_emit_sensor_sound_and_effect()

				if managers.network:session() then
					managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", TripMineBase.EVENT_IDS.sensor_beep)
				end
			end

			self._sensor_last_unit_time = t + 5
		end
	end
end