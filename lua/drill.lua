function Drill:is_drill_saw(drill_unit)
	local is_drill = drill_unit:base() and drill_unit:base().is_drill
	local is_saw = drill_unit:base() and drill_unit:base().is_saw
	return is_drill or is_saw
	--[[if is_drill or is_saw then
		return true
	end
	return false]]
end