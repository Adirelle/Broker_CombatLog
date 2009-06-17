
local forcedEnable = nil
local forcedDisable = nil

local dataobj = LibStub('LibDataBroker-1.1'):NewDataObject('Broker_CombatLog', {
	type = 'data source',
	icon = [[Interface\OptionsFrame\VoiceChat-Record]],
	label = "CombatLog",
	OnClick = function()
		if LoggingCombat() then
			if forcedEnable then
				forcedEnable = nil
				print('forcedEnable = nil')
			else
				forcedDisable = true
				print('forcedDisable = true')
			end
			LoggingCombat(false)
			print('Combat log recording stop.')
		else
			if forcedDisable then
				forcedDisable = nil
				print('forcedDisable = nil')
			else
				forcedEnable = true
				print('forcedEnable = true')
			end
			LoggingCombat(true)
			print('Combat log recording started.')
		end
	end,	
})

local frame = CreateFrame("Frame")
frame:SetScript('OnEvent', function(self, event, ...) return self[event](self, event, ...) end)

frame:RegisterEvent('PLAYER_ENTERING_WORLD')
function frame:PLAYER_ENTERING_WORLD()
	LoggingCombat(orcedEnable or (not forcedDisable and select(2, IsInInstance()) == "raid"))
end

frame:RegisterEvent('PLAYER_LEAVING_WORLD')
function frame:PLAYER_LEAVING_WORLD()
	LoggingCombat(false)
end

local LoggingCombat = LoggingCombat

function dataobj:Update()
	if LoggingCombat() then
		self.text = "On"
		self.iconR, self.iconG, self.iconB = 1, 0 ,0
	else
		self.text = "Off"
		self.iconR, self.iconG, self.iconB = 0.5, 0.5, 0.5
	end
end

hooksecurefunc('LoggingCombat', function(...)
	if select('#', ...) == 0 then return end
	dataobj:Update()
end)

dataobj:Update()
