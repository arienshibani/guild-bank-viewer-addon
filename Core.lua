-- Reads the bank, caches the last snapshot, and wires up /gbv and the bank button.
local _, ns = ...

local BANK = BANK_CONTAINER or -1
local bankOpen = false
local db

local function NumSlots()
	if C_Container and C_Container.GetContainerNumSlots then
		return C_Container.GetContainerNumSlots(BANK)
	end
	return GetContainerNumSlots(BANK)
end

-- Returns itemID, count for a 1-based bank slot (nil when empty).
local function ReadSlot(slot)
	if C_Container and C_Container.GetContainerItemInfo then
		local info = C_Container.GetContainerItemInfo(BANK, slot)
		if info then
			return info.itemID, info.stackCount
		end
		return nil
	end
	local _, count, _, _, _, _, _, _, _, itemID = GetContainerItemInfo(BANK, slot)
	return itemID, count
end

local function CharacterKey()
	return UnitName("player") .. "-" .. GetRealmName()
end

local function Capture()
	local items = ns.BuildItems(ReadSlot, NumSlots())
	db.last = {
		items = items,
		character = CharacterKey(),
		capturedAt = time(),
	}
	return db.last
end

local function Print(msg)
	print("|cffffd100Guild Bank Viewer:|r " .. msg)
end

local function Export()
	-- Live data while the bank is open, otherwise the last cached snapshot.
	local snapshot = bankOpen and Capture() or db.last
	if not snapshot then
		Print("No bank data yet. Open your bank once, then run /gbv.")
		return
	end
	if #snapshot.items == 0 then
		Print("Your bank looks empty, so there is nothing to import.")
		return
	end
	local info = string.format(
		"%d item stacks from %s, %s",
		#snapshot.items,
		snapshot.character,
		bankOpen and "captured just now" or ("captured " .. date("%Y-%m-%d %H:%M", snapshot.capturedAt))
	)
	ns.ShowExport(ns.EncodeItems(snapshot.items), info)
end

local function AddBankButton()
	if ns.button or not BankFrame then
		return
	end
	local button = CreateFrame("Button", nil, BankFrame, "UIPanelButtonTemplate")
	button:SetSize(90, 22)
	button:SetPoint("TOPRIGHT", BankFrame, "TOPRIGHT", -30, -14)
	button:SetText("Export")
	button:SetScript("OnClick", Export)
	ns.button = button
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("BANKFRAME_OPENED")
events:RegisterEvent("BANKFRAME_CLOSED")
events:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
events:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 ~= "GuildBankViewer" then
			return
		end
		GuildBankViewerDB = GuildBankViewerDB or { version = 1 }
		db = GuildBankViewerDB
	elseif event == "BANKFRAME_OPENED" then
		bankOpen = true
		AddBankButton()
		Capture()
	elseif event == "BANKFRAME_CLOSED" then
		bankOpen = false
	elseif event == "PLAYERBANKSLOTS_CHANGED" and bankOpen then
		Capture()
	end
end)

SLASH_GUILDBANKVIEWER1 = "/gbv"
SLASH_GUILDBANKVIEWER2 = "/guildbankviewer"
SlashCmdList["GUILDBANKVIEWER"] = Export
