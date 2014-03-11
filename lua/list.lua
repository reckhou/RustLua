PLUGIN.Title = "List"
PLUGIN.Description = "Lists connected players"
PLUGIN.Version = "0.2.9.2"
PLUGIN.Author = "greyhawk"

local alternate = true

function PLUGIN:Init()
	self:AddChatCommand("list", self.cmdList)
end

function PLUGIN:cmdList( netuser, cmd, args )
    local pclist = rust.GetAllNetUsers()
    local count = 0
    for key,value in pairs(pclist) do
        count = count + 1
        --print("key " .. key)
        --print("value" .. value)
    end
    
    rust.SendChatToUser( netuser, tostring(count) .. " Connected Players:")
    if ((count > 20) and (alternate)) then
        local j = 1
        for i=1, count - 1, 2 do
            j = j + 2
            rust.SendChatToUser( netuser, util.QuoteSafe(pclist[i].displayName) .. " , " .. util.QuoteSafe(pclist[i+1].displayName))
        end
        if (j <= count) then
            rust.SendChatToUser( netuser, util.QuoteSafe(pclist[j].displayName))
        end
    else
        for i=1, count do
            rust.SendChatToUser( netuser, util.QuoteSafe(pclist[i].displayName))
        end
    end
    
end

function PLUGIN:SendHelpText( netuser )
	rust.SendChatToUser( netuser, "Use /list to list connected players." )
end
