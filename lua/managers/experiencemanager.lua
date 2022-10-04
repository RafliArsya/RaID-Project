function ExperienceManager:set_current_prestige_xp(value)
    local max_ranks = tweak_data.infamy.ranks
    local ranks = managers.experience:current_rank()
    local diff = max_ranks - ranks
    diff = math.max(diff - 1, 0)
    self._global.prestige_xp_gained = Application:digest_value(math.min(value, self:get_max_prestige_xp() * diff), true)
end