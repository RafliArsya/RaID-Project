local old_td_init = TweakData.init
function TweakData:init(...)
	old_td_init(self, ...)
	
	self.experience_manager.stage_failed_multiplier = 0.01
	self.experience_manager.in_custody_multiplier = 0.75
	self.experience_manager.pro_job_multiplier = 1.25
	self.experience_manager.difficulty_multiplier = {
		2,
		5,
		10,
		12,
		13,
		16
	}
	self.experience_manager.alive_humans_multiplier = {
		[0] = 1,
		1.05,
		1.1,
		1.2,
		1.3,
		1.4,
		1.5,
		1.6
	}
	self.experience_manager.limited_bonus_multiplier = 1
	self.experience_manager.level_limit = {
		low_cap_level = -1,
		low_cap_multiplier = 0.75,
		pc_difference_multipliers = {
			0.975,
			0.85,
			0.725,
			0.675,
			0.55,
			0.425,
			0.375,
			0.25,
			0.125,
			0.01
		}
	}
	self.experience_manager.day_multiplier = {
		1,
		1,
		2,
		3,
		4,
		5,
		7
	}
	
end