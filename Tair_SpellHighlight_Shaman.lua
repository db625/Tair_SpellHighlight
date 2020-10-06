---------------------------------------------
--
--
-- Tair_SpellHighlight_Paladin.lua
--
--
---------------------------------------------

local name,addon=...;

local ActiveHighlight_Enhancement

---------------------------------------------
--
-- Events
--
---------------------------------------------

if UnitClass("player") == "Shaman" then
	addon.EventFrame:HookScript("OnEvent", function(self, event, ...)
		---------------------------------------------
		-- PLAYER_ENTERING_WORLD
		---------------------------------------------
		if event == "PLAYER_ENTERING_WORLD" then
			ActiveHighlight_Enhancement = false;
		end
		-- END PLAYER_ENTERING_WORLD
		---------------------------------------------
		-- PLAYER_REGEN_DISABLED
		---------------------------------------------
		-- Trigger a enchantment reminder if entering combat with no enchantment
		if event == "PLAYER_REGEN_DISABLED" and not Tair_Shaman_EnhancementActive() then
			Tair_Shaman_HighlightEnhancement();
		end
		-- END PLAYER_REGEN_DISABLED
		---------------------------------------------
		-- PLAYER_REGEN_ENABLED
		---------------------------------------------
		-- Deactivate enchantment reminder when leaving combat
		if event == "PLAYER_REGEN_ENABLED" then
			Tair_Shaman_UnHighlightEnhancement();
		end
		-- END PLAYER_REGEN_ENABLED
		---------------------------------------------
		-- UNIT_SPELLCAST_SUCCEEDED
		---------------------------------------------
		-- Deactivate enchantment reminder
		if event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" then
		end
		-- END UNIT_SPELLCAST_SUCCEEDED
		---------------------------------------------
		-- UNIT_AURA
		---------------------------------------------
		if event == "UNIT_AURA" then
			local unit = ...
			if unit == "player" then
				if Tair_Shaman_EnhancementActive() then
					Tair_Shaman_UnHighlightEnhancement();
				end
			end
			if unit == "target" then
			end
		end
		-- END UNIT_AURA
		---------------------------------------------
		-- PLAYER_TARGET_CHANGED
		---------------------------------------------
		if event == "PLAYER_TARGET_CHANGED" then
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
-- Enhancement Check
-- Returns true if the player has an active weapon enhancement
---------------------------------------------

function Tair_Shaman_EnhancementActive()
	local Tair_Shaman_IsWeaponEnchanted = GetWeaponEnchantInfo()
	return Tair_Shaman_IsWeaponEnchanted
end

---------------------------------------------
-- Enhancement Highlight
---------------------------------------------

function Tair_Shaman_HighlightEnhancement()
	Tair_Shaman_UnHighlightEnhancement()
	addon.Tair_SpellHighlight_Start("Rockbiter Weapon")
end

---------------------------------------------
-- Deactivate Enhancement Highlight
---------------------------------------------

function Tair_Shaman_UnHighlightEnhancement()
	addon.Tair_SpellHighlight_End("Rockbiter Weapon")
end