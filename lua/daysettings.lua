PLUGIN.Title = "daysettings"
PLUGIN.Description = "Set the time of day and length of the day"
PLUGIN.Version = "1.8"
PLUGIN.Author = "rexas  http://rexas.net"

PLUGIN.GetTime = util.GetStaticPropertyGetter( UnityEngine.Time, "realtimeSinceStartup" )


print(PLUGIN.Title .. " plugin loaded")
print("-----------------------")

function PLUGIN:Init()
	self.daysettingsDataFile = util.GetDatafile( "daysettings" )
	local txt = self.daysettingsDataFile:GetText()
	if (txt ~= "") then
		self.daysettings = json.decode( txt )
	else
		self.daysettings = {
			["DayRcon"] = {},
			["NightRcon"] = {}
		};
		-- We run the save to create the save files.
		self:Save();
	end
	
	-- We have to wait for the world to be loaded before we can get the Env Singleon.
	timer.Once( 15, function()
		self.Env = util.GetStaticFieldGetter( Rust.EnvironmentControlCenter, "Singleton" )
	end )
	
	-- We wait 30 sec before we start our timer, give the server time to load all settings.
	timer.Once( 30, function() self.myTimer = timer.Repeat( 1, 0, function() self:CheckTime() end ) end )
end

function PLUGIN:Unload()
	self.myTimer:Destroy()
end

PLUGIN.lastChange = 0

function PLUGIN:CheckTime(forceUpdate)
	if not self.Env():IsNight()
	then
		-- day
		if self.itIsNow == nil or self.itIsNow == "night" or forceUpdate == true
		then
			--print("It's day, last change was " .. self.GetTime() - self.lastChange .. "s ago")
			
			if self.daysettings["DayRcon"] ~= nil
			then
				for k,commandToRun in pairs(self.daysettings["DayRcon"])
				do
					--print("[Day RCON] " .. commandToRun)
					rust.RunServerCommand(commandToRun)
				end
			end
			self.itIsNow = "day"
			self.lastChange = self.GetTime()
		end
	else
		-- night
		if self.itIsNow == nil or self.itIsNow == "day" or forceUpdate == true
		then
			--print("It's night, last change was " .. self.GetTime() - self.lastChange .. "s ago")
			
			if self.daysettings["NightRcon"] ~= nil
			then
				for k,commandToRun in pairs(self.daysettings["NightRcon"])
				do
					--print("[Night RCON] " .. commandToRun)
					rust.RunServerCommand(commandToRun)
				end
			end
			self.itIsNow = "night"
			self.lastChange = self.GetTime()
		end
	end
end

function PLUGIN:Save()
	self.daysettingsDataFile:SetText( json.encode( self.daysettings ) )
	self.daysettingsDataFile:Save()
end