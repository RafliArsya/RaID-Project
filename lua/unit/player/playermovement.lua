Hooks:PostHook(PlayerMovement, 'init', 'RaIDPost_PlayerMovement_Init', function(self, unit)
    if self._rally_skill_data then
        local data = managers.player:upgrade_value("cooldown", "long_dis_revive", nil)
        self._rally_skill_data = {
            range_sq = 810000,
            morale_boost_delay_t = managers.player:has_category_upgrade("player", "morale_boost") and 0 or nil,
            long_dis_revive = managers.player:has_category_upgrade("cooldown", "long_dis_revive"),
            revive_chance = data and type(data) ~= "number" and data[1] or 0,
            morale_boost_cooldown_t = tweak_data.upgrades.morale_boost_base_cooldown * managers.player:upgrade_value("player", "morale_boost_cooldown_multiplier", 1),
            revive_chance_inc = 0
        }
    end
end)