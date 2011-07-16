local addonName = ...

local dataobj
local prefs = {}
local forcedEnable = nil
local forcedDisable = nil

local menuFrame
local menuTable = {
	{ text = addonName, isTitle = true, notCheckable = true },
	{
		text = "Recording",
		isNotRadio = true,
		checked = function() return LoggingCombat() end,
		func = function() return dataobj:Toggle() end,
	},
	{
		text = "In raid instance",
		isNotRadio = true,
		checked = function() return prefs.raidAuto end,
		func = function()
			prefs.raidAuto = not prefs.raidAuto
			return dataobj:UpdateState() 
		end,
	},
	{
		text = "Minimap icon",
		isNotRadio = true,
		checked = function() return not prefs.icon.hide end, 
		func = function()
			prefs.icon.hide = not prefs.icon.hide
			LibStub('LibDBIcon-1.0'):Refresh(addonName)
		end,
	},
	{ text = CLOSE, func = function() return CloseDropDownMenus() end, notCheckable = 1 },
}

dataobj = LibStub('LibDataBroker-1.1'):NewDataObject('Broker_CombatLog', {
	type = 'data source',
	icon = [[Interface\OptionsFrame\VoiceChat-Record]],
	label = "CombatLog",
	OnClick = function(frame, button)
		if button == 'RightButton' then
			if not menuFrame then
				menuFrame = CreateFrame("Frame", addonName.."_DropDown", UIParent, "UIDropDownMenuTemplate")
			end
			return EasyMenu(menuTable, menuFrame, frame, 0, 0, nil)
		else
			return dataobj:Toggle()
		end
	end,
	GetWantedState = function(self)
		if prefs.raidAuto then
			return forcedEnable or (not forcedDisable and select(2, IsInInstance()) == "raid")
		else
			return forcedEnable
		end
	end,
	UpdateState = function(self)
		LoggingCombat(self:GetWantedState())
	end,
	Toggle = function(self)
		if self:GetWantedState() then
			forcedEnable = false
			forcedDisable = self:GetWantedState()
		else
			forcedDisable = false
			forcedEnable = not self:GetWantedState()
		end
		return self:UpdateState()
	end,
	UpdateText = function(self)
		if LoggingCombat() then
			self.text = "Rec."
			self.iconR, self.iconG, self.iconB = 1, 0 ,0
		else
			self.text = "Off"
			self.iconR, self.iconG, self.iconB = 0.5, 0.5, 0.5
		end
	end,
})

local frame = CreateFrame("Frame")
frame:SetScript('OnEvent', function(self, event, ...) return self[event](self, event, ...) end)
frame:RegisterEvent('ADDON_LOADED')

function frame:ADDON_LOADED(_, name)
	if name ~= addonName then return end
	frame:UnregisterEvent('ADDON_LOADED')
	frame:RegisterEvent('PLAYER_ENTERING_WORLD')
	frame:RegisterEvent('PLAYER_LEAVING_WORLD')
	
	if not _G.BrokerCombatLogSV then
		_G.BrokerCombatLogSV = { raidAuto = true, icon = {} }
	end
	prefs = _G.BrokerCombatLogSV
	
	LibStub('LibDBIcon-1.0'):Register(addonName, dataobj, prefs.icon)
	
	dataobj:UpdateState()
end
function frame:PLAYER_ENTERING_WORLD() return dataobj:UpdateState() end
function frame:PLAYER_LEAVING_WORLD() return LoggingCombat(false) end

local currentState = not not LoggingCombat()
hooksecurefunc('LoggingCombat', function(...)
	if select('#', ...) == 0 then return end
	local newState = not not ...
	if currentState ~= newState then
		currentState = newState
		if currentState then
			print('Combat log recording started.')
		else
			print('Combat log recording stopped.')
		end
	end
	dataobj:UpdateText()
end)

