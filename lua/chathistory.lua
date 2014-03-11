PLUGIN.Title = "ChatHistory"
PLUGIN.Description = "Allows the player to see a chat history."
PLUGIN.Version = "1.4.1"
PLUGIN.Author = "D4K1NG"

function PLUGIN:Init()
	self.HistoryFile = util.GetDatafile( "chathistory" )
	local txt = self.HistoryFile:GetText()
	if ( txt ~= "" ) then
		self.History = json.decode( txt )
	else
		self.History = {}
	end
	self:AddChatCommand( "history", self.HistoryCmd )
	self:AddChatCommand( "h", self.HistoryCmd )	
	self:AddChatCommand( "historycleanup", self.HistoryCleanup )

	--Flags support
	flags_plugin = plugins.Find("flags")
  	if (not flags_plugin) then
  		print("ChatHistory loaded without Flags support!")
  	end
end
function PLUGIN:HistoryCleanup( netuser, cmd )
	--Check if Flags is available
	if (not flags_plugin) then
		if (not(netuser:CanAdmin())) then
        	rust.Notice( netuser, "Only admins can do this" )
        	return
    	end
    else
    	if ( not flags_plugin:HasFlag( netuser, "historycleanup" ) ) then
    		rust.Notice( netuser, "You dont have the permission to do that!" )
    		return
    	end
    end
	self.History = {}
	self:Save()
	rust.Notice( netuser, "History deleted" )
	return
end
function PLUGIN:HistoryCmd( netuser, cmd )
	rust.SendChatToUser( netuser, "Chat history:" )
	for key,value in pairs( self.History ) do
		rust.SendChatToUser( netuser, self.History[key]["name"] .. ": " .. util.QuoteSafe( tostring( self.History[key]["msg"] ) ) )			
	end
	return
end
function PLUGIN:HistoryInsert( netuser, msg )
	local history = self.History
	local newinsert = {}
	local count = #history
	newinsert["name"] = netuser.displayName
	newinsert["msg"] = msg
	if ( count >= 20 ) then
		table.remove( self.History, 1 )
	end
	table.insert( self.History, newinsert )
	self:Save()
	return
end
function PLUGIN:OnUserChat( netuser, name, msg )
	if (msg:sub( 1, 1 ) ~= "/") then
		self:HistoryInsert(netuser, msg)
	end
end
function PLUGIN:Save()
	self.HistoryFile:SetText( json.encode( self.History ) )
	self.HistoryFile:Save()
end
function PLUGIN:SendHelpText( netuser )
	rust.SendChatToUser( netuser, "Use /history for previous chat entries." )
end