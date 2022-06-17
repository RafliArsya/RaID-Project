Drill.jammed_drills = Drill.jammed_drills or 0

function Drill:is_drill_saw(drill_unit)
	local is_drill = drill_unit:base() and drill_unit:base().is_drill
	local is_saw = drill_unit:base() and drill_unit:base().is_saw
	return is_drill or is_saw
end

function Drill:_count_jammed_drill()
	return Drill.jammed_drills
end