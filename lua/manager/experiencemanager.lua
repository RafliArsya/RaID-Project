function ExperienceManager:set_current_prestige_xp(value)
    self._global.prestige_xp_gained = Application:digest_value(math.min(value, self:get_max_prestige_xp() * 100), true)
end