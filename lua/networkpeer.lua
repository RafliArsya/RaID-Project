function NetworkPeer:mark_cheater(reason, auto_kick)
	if Application:editor() or SystemInfo:platform() ~= Idstring("WIN32") then
		return
	end

	self._cheater = true
	if self._cheater then
		log("CHEATER TAG")
	end
	managers.chat:feed_system_message(ChatManager.GAME, managers.localization:text(managers.vote:kick_reason_to_string(reason), {
		name = self:name()
	}))

	if auto_kick and Global.game_settings.auto_kick then
		managers.vote:kick_auto(reason, self, self._begin_ticket_session_called)
	elseif managers.hud then
		managers.hud:mark_cheater(self._id)
	end
end