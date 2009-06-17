
local dataobj = LibStub('LibDataBroker-1.1'):NewDataObject('Broker_CombatLog', {
	type = 'data source',
	icon = [[Interface\OptionsFrame\VoiceChat-Record]],
	label = "CombatLog",
	OnClick = function()
		if LoggingCombat() then
			LoggingCombat(false)
			print('Combat log recording stop.')
		else
			LoggingCombat(true)
			print('Combat log recording started.')
		end
	end,	
})

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

