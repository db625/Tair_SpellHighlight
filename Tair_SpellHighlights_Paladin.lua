---------------------------------------------
--
-- Tair_SpellHighlights_Paladin.lua
--
-- Highlights relevant Paladin spells
-- under certin circumstances,
-- such as entering combat without a seal
-- or when the player needs Purify.
--
---------------------------------------------

---------------------------------------------
--
-- Setup
--
---------------------------------------------

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")

---------------------------------------------
--
-- Event Configuration
--
---------------------------------------------

frame:SetScript("OnEvent", function(self, event, ...)

	---------------------------------------------
	-- For Paladins only
	---------------------------------------------

	if UnitClass("player") == "Paladin" then

	---------------------------------------------
	-- Initialize highlights
	---------------------------------------------

		if event == "PLAYER_ENTERING_WORLD" then
			local ActiveHighlight_Seals = false;
			local ActiveHighlight_Purify = false;
			local ActiveHighlight_Judgement = false;
		end

	---------------------------------------------
	-- Debug event
	---------------------------------------------

		if event == "PLAYER_ENTERING_WORLD" then
			if IsAddOnLoaded("ElvUI") then
				-- print "ElvUI debug event";
			else
				-- print "Default debug event";
			end
		end

	---------------------------------------------
	-- Enter Combat
	---------------------------------------------

		-- Trigger a seal reminder if entering combat with no seal
		if event == "PLAYER_REGEN_DISABLED" and not Tair_Paladin_SealActive() then
			Tair_Paladin_HighlightSeals()
		end

	---------------------------------------------
	-- Leave Combat
	---------------------------------------------

		-- Deactivate seal reminder when leaving combat
		if event == "PLAYER_REGEN_ENABLED" and not Tair_Paladin_SealActive() then
			Tair_Paladin_UnHighlightSeals();
		end

	---------------------------------------------
	-- UNIT_AURA
	---------------------------------------------

		if event == "UNIT_AURA" then
			local unit = ...
			if unit == "player" then
				-- If a seal is active
				if Tair_Paladin_SealActive() then
					-- Deactivate seal reminder
					ActiveHighlight_Seals = false;
					Tair_Paladin_UnHighlightSeals()
				-- If player is in combat with no active seal
				elseif not Tair_Paladin_SealActive() and UnitAffectingCombat("player") and ActiveHighlight_Seals == false then
					-- Trigger a seal reminder
					ActiveHighlight_Seals = true;
					Tair_Paladin_HighlightSeals()
					-- De-highlight Judgement when no seal is active
					Tair_Paladin_UnHighlightActionByName("Judgement")
				end
				-- Purify check
				Tair_Paladin_CheckPurify()
			end
			if unit == "target" then
				Tair_Paladin_CheckJudgement()
				Tair_Paladin_BuffExchange()
			end
		end -- end UNIT_AURA events

	---------------------------------------------
	-- PLAYER_TARGET_CHANGED
	---------------------------------------------

		if event == "PLAYER_TARGET_CHANGED" then
			Tair_Paladin_BuffExchange()
		end -- end PLAYER_TARGET_CHANGED events

	---------------------------------------------
	-- End event configuration
	---------------------------------------------

	end -- end if UnitClass("player") == "Paladin"

end) -- end Events config

---------------------------------------------
--
-- Event Functions
--
---------------------------------------------

---------------------------------------------
-- Blessing Exchange Helper
-- Highlights an appropriate blessing when targeting a fellow paladin
---------------------------------------------

function Tair_Paladin_BuffExchange()
	if UnitExists("target") and UnitClass("target") == "Paladin" and UnitIsFriend("player", "target") and not (UnitIsUnit("player","target")) then
		-- Blessing of Might
		if not AuraUtil.FindAuraByName("Blessing of Might", "target") then
			Tair_Paladin_HighlightActionByName("Blessing of Might")
		elseif not AuraUtil.FindAuraByName("Blessing of Wisdom", "target") then
			Tair_Paladin_HighlightActionByName("Blessing of Wisdom")
		else
			Tair_Paladin_UnHighlightBlessings()
		end
	else
		Tair_Paladin_UnHighlightBlessings()
	end
end

---------------------------------------------
-- Check for active seal
-- Returns true if the player has an active seal
---------------------------------------------

-- Seals to check.

local Tair_Paladin_Seals = {
	'Seal of Righteousness',
	'Seal of the Crusader',
	'Seal of Command',
	'Seal of Light',
	'Seal of Wisdom',
	'Seal of Justice'
}

function Tair_Paladin_SealActive()
	local sealActive = false;
	for i, seal in ipairs(Tair_Paladin_Seals) do
		if AuraUtil.FindAuraByName(seal, "player") then
			sealActive = true
		end
	end
	if sealActive == true then
		return true
	else
		return false
	end
end

---------------------------------------------
-- Seal reminder
-- Highlights Seal of Command if it's learned
-- and the paladin's weapon speed is 3.5s
-- or slower. Otherwise, highlights
-- Seal of Righteousness.
---------------------------------------------

function Tair_Paladin_HighlightSeals()
	Tair_Paladin_UnHighlightSeals()
	local mainSpeed, offSpeed = UnitAttackSpeed("player")
	if IsSpellKnown(20375) and (mainSpeed > 3.4) then
		Tair_Paladin_HighlightActionByName("Seal of Command")
	else
		Tair_Paladin_HighlightActionByName("Seal of Righteousness")
	end
end

---------------------------------------------
-- Deactivate seal reminder
-- De-highlights seal action bar buttons
---------------------------------------------

function Tair_Paladin_UnHighlightSeals()
	for i, seal in ipairs(Tair_Paladin_Seals) do
		Tair_Paladin_UnHighlightActionByName(seal)
	end
end

---------------------------------------------
-- Deactivate blessing highlights
-- De-highlights blessing action bar buttons
---------------------------------------------

function Tair_Paladin_UnHighlightBlessings()
	Tair_Paladin_UnHighlightActionByName("Blessing of Might")
	Tair_Paladin_UnHighlightActionByName("Blessing of Wisdom")
end

---------------------------------------------
-- Purify Check
---------------------------------------------

function Tair_Paladin_CheckPurify()
	local NeedPurify = false;
	for i = 1, 16 do
	    local name, icon, count, debuffType = UnitDebuff("player", i);
	    if debuffType == "Disease" or debuffType == "Poison" then
			NeedPurify = true;
		end
		if NeedPurify ~= true then
			NeedPurify = false;
		end
	end
	if NeedPurify == true and ActiveHighlight_Purify == false then
		ActiveHighlight_Purify = true;
		Tair_Paladin_HighlightActionByName("Purify")
	elseif NeedPurify == false then
		ActiveHighlight_Purify = false;
		Tair_Paladin_UnHighlightActionByName("Purify")
	end
end

---------------------------------------------
-- Judgement Check
---------------------------------------------

function Tair_Paladin_TargetIsStunned()
	if UnitExists("target") then
		local stun = "Hammer of Justice";
		for i = 1, 16 do
			local name = UnitDebuff("target", i);
			if name == stun then
				return true
			end
		end
	end
end

function Tair_Paladin_CheckJudgement()
	if AuraUtil.FindAuraByName("Seal of Command", "player") and Tair_Paladin_TargetIsStunned() and IsUsableSpell("Judgement") and not ActiveHighlight_Judgement then
		Tair_Paladin_HighlightActionByName("Judgement");
		ActiveHighlight_Judgement = true;
	else 
		Tair_Paladin_UnHighlightActionByName("Judgement");
		ActiveHighlight_Judgement = false;
	end
end


---------------------------------------------
--
-- Action Bars
--
---------------------------------------------

---------------------------------------------
-- Set up action bars
---------------------------------------------

-- Blizzard action bars
local ActionBars = { "Action", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight", "MultiBarLeft" }

-- ElvUI action bars
if IsAddOnLoaded("ElvUI") then
	ActionBars = { "ElvUI_Bar1", "ElvUI_Bar2", "ElvUI_Bar3", "ElvUI_Bar4", "ElvUI_Bar5", "ElvUI_Bar6" }
end

---------------------------------------------
-- Highlight action bar button by name
---------------------------------------------

function Tair_Paladin_HighlightActionByName(searchName)
	-- Blizzard UI
	if not IsAddOnLoaded("ElvUI") and not IsAddOnLoaded("AzeriteUI") then
		for _, barName in pairs(ActionBars) do
			for i = 1, 12 do
				local buttonName = barName .. "Button" .. i
				local button = _G[buttonName]
				local slot = ActionButton_GetPagedID(button) or ActionButton_CalculateAction(button) or button:GetAttribute("action") or 0
				if HasAction(slot) then
					local actionType, id, _, actionName = GetActionInfo(slot)
					if actionType == "macro" then
						actionName, _, id = GetMacroSpell(id)
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
	-- End Blizzard UI
	-- ElvUI
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
						actionName, _, id = GetMacroSpell(id)
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
	-- End ElvUI
end

---------------------------------------------
-- De-highlight action button by name
---------------------------------------------

function Tair_Paladin_UnHighlightActionByName(searchName)
	-- Blizzard UI
	if not IsAddOnLoaded("ElvUI") and not IsAddOnLoaded("AzeriteUI") then
		for _, barName in pairs(ActionBars) do
			for i = 1, 12 do
				local buttonName = barName .. "Button" .. i
				local button = _G[buttonName]
				local slot = ActionButton_GetPagedID(button) or ActionButton_CalculateAction(button) or button:GetAttribute("action") or 0
				if HasAction(slot) then
					local actionType, id, _, actionName = GetActionInfo(slot)
					if actionType == "macro" then
						actionName, _, id = GetMacroSpell(id)
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
	-- End Blizzard UI
	-- ElvUI
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
						actionName, _, id = GetMacroSpell(id)
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
	-- End ElvUI
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