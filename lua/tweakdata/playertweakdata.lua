local set_playertweakdata_original = PlayerTweakData.init
local set_playertweakdata_ezwish_original = PlayerTweakData._set_easy_wish
local set_playertweakdata_OVK290_original = PlayerTweakData._set_overkill_290
local set_playertweakdata_smwish_original = PlayerTweakData._set_sm_wish

function PlayerTweakData:_set_easy_wish(...)
	set_playertweakdata_ezwish_original(self, ...)

	self.damage.MIN_DAMAGE_INTERVAL = 0.45
	self.damage.REVIVE_HEALTH_STEPS = {0.3}
end

function PlayerTweakData:_set_overkill_290(...)
	set_playertweakdata_OVK290_original(self, ...)
	
	self.damage.MIN_DAMAGE_INTERVAL = 0.4
	self.damage.REVIVE_HEALTH_STEPS = {0.2}
end

function PlayerTweakData:_set_sm_wish(...)
	set_playertweakdata_smwish_original(self, ...)

	self.damage.MIN_DAMAGE_INTERVAL = 0.35
	self.damage.REVIVE_HEALTH_STEPS = {0.1}
end

function PlayerTweakData:init(...)
	set_playertweakdata_original(self, ...)
	
	self.put_on_mask_time = 1

	if not is_console then
		self.damage.ARMOR_INIT = 3.2
	end

	if not is_vr then
		self.damage.HEALTH_INIT = 24
	end
	
	self.damage.REVIVE_HEALTH_STEPS = {0.5}
	
	self.damage.TASED_RECOVER_TIME = 1
	
	self.damage.BLEED_OUT_HEALTH_INIT = 16
	
	self.damage.MIN_DAMAGE_INTERVAL = 0.5
	
	self.damage.respawn_time_penalty = 25
	self.damage.base_respawn_time_penalty = 5
	
	self.long_dis_interaction = {
		intimidate_range_enemies = 1200,
		highlight_range = 4000,
		intimidate_range_civilians = 1500,
		intimidate_range_teammates = 150000,
		intimidate_strength = 0.5
	}
	
	self.suppression = {
		receive_mul = 10,
		decay_start_delay = 5,
		spread_mul = 1,
		tolerance = 1,
		max_value = 20,
		autohit_chance_mul = 1
	}
		
	self.alarm_pager = {
		first_call_delay = {
			2,
			4
		},
		call_duration = {
			{
				6,
				8
			},
			{
				8,
				10
			}
		},
		nr_of_calls = {
			2,
			2
		},
		bluff_success_chance = {
			1,
			1,
			1,
			1,
			0.9,
			0.8,
			0.7,
			0.6,
			0.5
		},
		bluff_success_chance_w_skill = {
			1,
			1,
			1,
			1,
			0.9,
			0.8,
			0.7,
			0.6,
			0.5
		}
	}
	
	self.movement_state.standard.movement.speed.STANDARD_MAX = 375
	self.movement_state.standard.movement.speed.RUNNING_MAX = 600
	self.movement_state.standard.movement.speed.CROUCHING_MAX = 250
	self.movement_state.standard.movement.speed.STEELSIGHT_MAX = 200
	self.movement_state.standard.movement.speed.INAIR_MAX = 400
	self.movement_state.standard.movement.speed.CLIMBING_MAX = 275
	self.movement_state.standard.movement.jump_velocity.z = 525
	self.movement_state.standard.movement.jump_velocity.xy.run = self.movement_state.standard.movement.speed.RUNNING_MAX + 400
	self.movement_state.standard.movement.jump_velocity.xy.walk = self.movement_state.standard.movement.speed.STANDARD_MAX + 425

	self.movement_state.interaction_delay = 1.25
	
	if not is_vr then
		self.movement_state.stamina.STAMINA_INIT = 70
	end
	
	self.omniscience = {
		start_t = 3,
		interval_t = 1.5,
		sense_radius = 1250,
		target_resense_t = 15
	}
	
end