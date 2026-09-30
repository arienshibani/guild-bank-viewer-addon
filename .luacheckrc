std = "lua51"
max_line_length = false
exclude_files = { ".luarocks" }

-- The addon namespace and WoW globals it touches.
globals = { "GuildBankViewerDB", "SlashCmdList", "SLASH_GUILDBANKVIEWER1", "SLASH_GUILDBANKVIEWER2" }
read_globals = {
	"BANK_CONTAINER", "BankFrame", "C_Container", "CreateFrame", "GetContainerItemInfo",
	"GetContainerNumSlots", "GetRealmName", "UIParent", "UISpecialFrames", "UnitName",
	"date", "print", "time", "tinsert",
}

files["tests/"] = { std = "+busted" }
