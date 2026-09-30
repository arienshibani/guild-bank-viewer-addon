-- Export window: a read-only box with the string selected for Ctrl+C.
local _, ns = ...

local frame

local function Create()
	frame = CreateFrame("Frame", "GuildBankViewerFrame", UIParent, "BackdropTemplate")
	frame:SetSize(520, 150)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 8, right = 8, top = 8, bottom = 8 },
	})
	frame:Hide()
	tinsert(UISpecialFrames, "GuildBankViewerFrame") -- close with Escape

	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	frame.title:SetPoint("TOP", 0, -18)
	frame.title:SetText("Guild Bank Viewer")

	frame.info = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	frame.info:SetPoint("TOP", frame.title, "BOTTOM", 0, -8)
	frame.info:SetWidth(470)

	local box = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	box:SetSize(460, 24)
	box:SetPoint("TOP", frame.info, "BOTTOM", 0, -12)
	box:SetAutoFocus(false)
	box:SetMaxLetters(0)
	box:SetScript("OnEscapePressed", function()
		frame:Hide()
	end)
	box:SetScript("OnEditFocusGained", box.HighlightText)
	-- Read-only: restore the string if someone types into it.
	box:SetScript("OnTextChanged", function(self, userInput)
		if userInput and frame.text then
			self:SetText(frame.text)
			self:HighlightText()
		end
	end)
	frame.box = box

	frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	frame.hint:SetPoint("TOP", box, "BOTTOM", 0, -8)
	frame.hint:SetText("Ctrl+C to copy, then paste into Import on guildbankviewer.com")

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
end

--- Show the window with `text` selected and an `info` line above it.
function ns.ShowExport(text, info)
	if not frame then
		Create()
	end
	frame.text = text
	frame.info:SetText(info)
	frame.box:SetText(text)
	frame:Show()
	frame.box:SetFocus()
	frame.box:HighlightText()
end
