PLUGIN.Title = "ping"
PLUGIN.Description = "Let a user get their server ping"
PLUGIN.Version = "1.16.4"
PLUGIN.Author = "rexas  http://rexas.net"

local L;

function PLUGIN:Init()
	L = plugins.Find( "localization" )
	self:AddChatCommand( "ping", self.cmdPing )
	if L ~= nil
	then
		L:AddString("ping", "en", "help", "Use /ping to get your current ping to the server.")
	end
end

function PLUGIN:cmdPing(netUser, cmd, args)
	rust.RunClientCommand(netUser, "notice.inventory " .. netUser.networkPlayer.lastPing .. "ms (".. netUser.networkPlayer.averagePing ..")")
end

function PLUGIN:SendHelpText( netUser )
	if L == nil
	then
		rust.SendChatToUser( netUser, "Use /ping to get your current ping to the server." )
	else
		rust.SendChatToUser( netUser, L:GetUserString(netUser, "ping", "help") )
	end
end