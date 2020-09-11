---------------------------------------------
--
--
-- Tair_SpellHighlight.lua
--
--
---------------------------------------------

local name,addon=...;

---------------------------------------------
--
-- Config
--
---------------------------------------------

---------------------------------------------
-- Create Frame
---------------------------------------------

addon.EventFrame = CreateFrame("Frame")
addon.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
addon.EventFrame:RegisterEvent("UNIT_AURA")
addon.EventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
addon.EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
addon.EventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

---------------------------------------------
-- Get Action Bars
---------------------------------------------

-- Blizzard
local ActionBars = { "Action", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight", "MultiBarLeft" }

-- ElvUI
if IsAddOnLoaded("ElvUI") then
	ActionBars = { "ElvUI_Bar1", "ElvUI_Bar2", "ElvUI_Bar3", "ElvUI_Bar4", "ElvUI_Bar5", "ElvUI_Bar6" }
end

---------------------------------------------
--
-- Functions
--
---------------------------------------------

---------------------------------------------
-- Start Spell Highlight
---------------------------------------------

function addon.Tair_SpellHighlight_Start(searchName)
	if not IsAddOnLoaded("ElvUI") and not IsAddOnLoaded("AzeriteUI") then
		for _, barName in pairs(ActionBars) do
			for i = 1, 12 do
				local buttonName = barName .. "Button" .. i
				local button = _G[buttonName]
				local slot = ActionButton_GetPagedID(button) or ActionButton_CalculateAction(button) or button:GetAttribute("action") or 0
				if HasAction(slot) then
					local actionType, id, _, actionName = GetActionInfo(slot)
					if actionType == "macro" then
						local macroSpellId = GetMacroSpell(id)
						actionName = GetSpellInfo(macroSpellId)
					elseif actionType == "item" then
						actionName = GetItemInfo(id)
					elseif actionType == "spell" then
						actionName = GetSpellInfo(id)
					end
					if actionName and string.match(string.lower(actionName), string.lower(searchName)) then
						LibStub("LibButtonGlow-1.0").ShowOverlayGlow(button)
						return button
					end
				end
			end
		end
	end
	if IsAddOnLoaded("ElvUI") then
		for _, barName in pairs(ActionBars) do
			for i = 1, 12 do
				local buttonName = barName .. "Button" .. i
				local button = _G[buttonName]
				local type = button:GetAttribute('type')
				if type == 'action' then
					local slot = button:GetAttribute('action')
					local actionType, id, actionName = GetActionInfo(slot)
					if actionType == "macro" then
						local macroSpellId = GetMacroSpell(id)
						actionName = GetSpellInfo(macroSpellId)
					elseif actionType == "item" then
						actionName = GetItemInfo(id)
					elseif actionType == "spell" then
						actionName = GetSpellInfo(id)
					end
					if actionName and string.match(string.lower(actionName), string.lower(searchName)) then
						LibStub("LibButtonGlow-1.0").ShowOverlayGlow(button)
						return button
					end
				end
			end
		end
	end
end

---------------------------------------------
-- End Spell Highlight
---------------------------------------------

function addon.Tair_SpellHighlight_End(searchName)
	if not IsAddOnLoaded("ElvUI") and not IsAddOnLoaded("AzeriteUI") then
		for _, barName in pairs(ActionBars) do
			for i = 1, 12 do
				local buttonName = barName .. "Button" .. i
				local button = _G[buttonName]
				local slot = ActionButton_GetPagedID(button) or ActionButton_CalculateAction(button) or button:GetAttribute("action") or 0
				if HasAction(slot) then
					local actionType, id, _, actionName = GetActionInfo(slot)
					if actionType == "macro" then
						local macroSpellId = GetMacroSpell(id)
						actionName = GetSpellInfo(macroSpellId)
					elseif actionType == "item" then
						actionName = GetItemInfo(id)
					elseif actionType == "spell" then
						actionName = GetSpellInfo(id)
					end	
					if actionName and string.match(string.lower(actionName), string.lower(searchName)) then
						LibStub("LibButtonGlow-1.0").HideOverlayGlow(button)
						return button
					end
				end
			end
		end
	end 
	if IsAddOnLoaded("ElvUI") then
		for _, barName in pairs(ActionBars) do
			for i = 1, 12 do
				local buttonName = barName .. "Button" .. i
				local button = _G[buttonName]
				local type = button:GetAttribute('type')
				if type == 'action' then
					local slot = button:GetAttribute('action')
					local actionType, id, actionName = GetActionInfo(slot)
					if actionType == "macro" then
						local macroSpellId = GetMacroSpell(id)
						actionName = GetSpellInfo(macroSpellId)
					elseif actionType == "item" then
						actionName = GetItemInfo(id)
					elseif actionType == "spell" then
						actionName = GetSpellInfo(id)
					end
					if actionName and string.match(string.lower(actionName), string.lower(searchName)) then
						LibStub("LibButtonGlow-1.0").HideOverlayGlow(button)
						return button
					end
				end
			end
		end
	end
end

-- End Action Bar Functions

---------------------------------------------
--
-- Chat Commmand Config
--
---------------------------------------------

SLASH_TAIRPALADIN1 = '/tair';
function SlashCmdList.TAIRPALADIN(msg, editbox)
	print("Hello")
end