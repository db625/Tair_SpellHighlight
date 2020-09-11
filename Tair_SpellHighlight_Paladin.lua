---------------------------------------------
--
--
-- Tair_SpellHighlight_Paladin.lua
--
--
---------------------------------------------

local name,addon=...;

local ActiveHighlight_Seals
local ActiveHighlight_Purify
local ActiveHighlight_Judgement

---------------------------------------------
--
-- Events
--
---------------------------------------------

if UnitClass("player") == "Paladin" then
	addon.EventFrame:HookScript("OnEvent", function(self, event, ...)
		---------------------------------------------
		-- PLAYER_ENTERING_WORLD
		---------------------------------------------
		if event == "PLAYER_ENTERING_WORLD" then
			ActiveHighlight_Seals = false;
			ActiveHighlight_Purify = false;
			ActiveHighlight_Judgement = false;
		end
		-- END PLAYER_ENTERING_WORLD
		---------------------------------------------
		-- PLAYER_REGEN_DISABLED
		---------------------------------------------
		-- Trigger a seal reminder if entering combat with no seal
		if event == "PLAYER_REGEN_DISABLED" and not Tair_Paladin_SealActive() then
			Tair_Paladin_HighlightSeals()
		end
		-- END PLAYER_REGEN_DISABLED
		---------------------------------------------
		-- PLAYER_REGEN_ENABLED
		---------------------------------------------
		-- Deactivate seal reminder when leaving combat
		if event == "PLAYER_REGEN_ENABLED" and not Tair_Paladin_SealActive() then
			Tair_Paladin_UnHighlightSeals();
		end
		-- END PLAYER_REGEN_ENABLED
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
					addon.Tair_SpellHighlight_End("Judgement")
				end
				-- Purify check
				Tair_Paladin_CheckPurify()
			end
			if unit == "target" then
				Tair_Paladin_CheckJudgement()
				Tair_Paladin_BuffExchange()
			end
		end
		-- END UNIT_AURA
		---------------------------------------------
		-- PLAYER_TARGET_CHANGED
		---------------------------------------------
		if event == "PLAYER_TARGET_CHANGED" then
			Tair_Paladin_BuffExchange()
		end -- end PLAYER_TARGET_CHANGED events
		-- END PLAYER_TARGET_CHANGED

	end) -- end SpellHighlight Events
end -- end Paladin

---------------------------------------------
--
-- Functions
--
---------------------------------------------

---------------------------------------------
-- Seal Check
-- Returns true if the player has an active seal
---------------------------------------------

local Tair_Paladin_Seals = {
	'Seal of Righteousness', 'Seal of the Crusader', 'Seal of Command', 'Seal of Light', 'Seal of Wisdom', 'Seal of Justice'
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
-- Seal Highlight
---------------------------------------------

function Tair_Paladin_HighlightSeals()
	Tair_Paladin_UnHighlightSeals()
	local mainSpeed, offSpeed = UnitAttackSpeed("player")
	if IsSpellKnown(20375) and (mainSpeed > 3.4) then
		addon.Tair_SpellHighlight_Start("Seal of Command")
	else
		addon.Tair_SpellHighlight_Start("Seal of Righteousness")
	end
end

---------------------------------------------
-- Deactivate Seal Highlight
---------------------------------------------

function Tair_Paladin_UnHighlightSeals()
	for i, seal in ipairs(Tair_Paladin_Seals) do
		addon.Tair_SpellHighlight_End(seal)
	end
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
	end
	if NeedPurify == true and not ActiveHighlight_Purify then
		addon.Tair_SpellHighlight_Start("Purify")
		ActiveHighlight_Purify = true;
	elseif NeedPurify == false then
		addon.Tair_SpellHighlight_End("Purify")
		ActiveHighlight_Purify = false;
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
		addon.Tair_SpellHighlight_Start("Judgement");
		ActiveHighlight_Judgement = true;
	else 
		addon.Tair_SpellHighlight_End("Judgement");
		ActiveHighlight_Judgement = false;
	end
end

---------------------------------------------
-- Blessing Exchange Highlight
---------------------------------------------

function Tair_Paladin_BuffExchange()
	if UnitExists("target") and UnitClass("target") == "Paladin" and UnitIsFriend("player", "target") and not (UnitIsUnit("player","target")) then
		-- Blessing of Might
		if not AuraUtil.FindAuraByName("Blessing of Might", "target") then
			addon.Tair_SpellHighlight_Start("Blessing of Might")
		elseif not AuraUtil.FindAuraByName("Blessing of Wisdom", "target") then
			addon.Tair_SpellHighlight_Start("Blessing of Wisdom")
		else
			Tair_Paladin_UnHighlightBlessings()
		end
	else
		Tair_Paladin_UnHighlightBlessings()
	end
end

---------------------------------------------
-- Deactivate Blessing Highlight
---------------------------------------------

function Tair_Paladin_UnHighlightBlessings()
	addon.Tair_SpellHighlight_End("Blessing of Might")
	addon.Tair_SpellHighlight_End("Blessing of Wisdom")
end
