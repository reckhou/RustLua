-- Define plugin variables
PLUGIN.Title = "Cheat Punch & VAC Ban Checker"
PLUGIN.Description = "Dont allow cheaters"
PLUGIN.AUTHOR = "Feramor"
PLUGIN.Version     = "1.1"
print( "Loading " .. PLUGIN.Title .. " .. " .. PLUGIN.Version .. " ..." )

-- Base 64 Encoding & Decoding

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- Encoding
function PLUGIN:Base64Enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- Decoding
function PLUGIN:Base64Dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- Base 64 Encoding & Decoding

function PLUGIN:Init()
	self.RawData = util.GetDatafile( "cfg_CheatPunch" )
	if (self.RawData:GetText() == "") then
		error( "No cfg_CheatPunch.txt found...Reseting to defaults" )
		self:SetDefault()
	else
		self.Data = json.decode( self.RawData:GetText() )
		if (not self.Data) then
			error( "json decode error in cfg_CheatPunch.txt...Reseting to defaults" )
			self:SetDefault()
		end
	end
end

function PLUGIN:GetResponse(HTTPResponse, Response)
	local Test = self:Base64Dec(Response)
	Test = json.decode( Test )
	if (Test["Status"] == true) then
		for key,value in pairs(rust.GetAllNetUsers()) do
			local sid = self:CommunityIDToSteamID( tonumber( rust.GetUserID( value ) ) )
			if ( sid == Test["SteamID"]) then
				if ((self.Data["Config"]["WhiteList"] == true) and (self.Data["WhiteList"][tostring(Test["SteamID64"])]) and (self.Data["WhiteList"][tostring(Test["SteamID64"])] == true)) then
					print ( value.displayName .. " (".. Test["SteamID64"] ..") is banned for " .. Test["Type"] .. " but not kicked due to Whiltelist")
					print ( json.encode ( Test["Message"] ) )
					return
				end
				value:Kick( NetError.Facepunch_Kick_RCON, true )
				print ( value.displayName .. " (".. Test["SteamID64"] ..") has been kicked due to his ban by " .. Test["Type"])
				print ( json.encode ( Test["Message"] ) )
				if self.Data["Config"]["Broadcast"] == true then
					rust.BroadcastChat( "CheatPunch", value.displayName .. " has been kicked due to his ban by " .. Test["Type"])
				end
			end
		end
	end
end

function PLUGIN:OnUserConnect( netuser )
	local sid = self:CommunityIDToSteamID( tonumber( rust.GetUserID( netuser ) ) )
	local Req = {}
	Req["Type"] = "BanCheck" 
	Req["SteamID"] = sid
	Req = json.encode( Req )
	Req = self:Base64Enc(Req)
	local test = function(a,b) self:GetResponse(a, b) end 
	local url = "http://rust.feramor.gen.tr/RustApi.php?Q=" .. Req
	local Ger = webrequest.Send( url, test)
end

function PLUGIN:CommunityIDToSteamID( id )
	return "STEAM_0:" .. (math.ceil((id /2) % 1)) .. ":" .. math.floor( id / 2 )
end

function PLUGIN:SetDefault()

	self.Data = {}

	--------------
	-- Settings --
	--------------

	self.Data["Config"] = {}
	self.Data["Config"]["WhiteList"] = true -- Even they got banned from CheatPunch let them in
	self.Data["Config"]["Broadcast"] = true -- Broadcast The Name of Cheater to Server

	--------------
	-- Settings --
	--------------

	self.Data["WhiteList"] = {}
	self.RawData:SetText( json.encode( self.Data ) )
	self.RawData:Save()

end