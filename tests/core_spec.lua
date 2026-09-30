-- Smoke test of Core.lua + UI.lua against a stubbed WoW API: catches load-time
-- and runtime errors (nil calls, typos) that the pure-module tests cannot.
local helpers = require("tests.helpers")

local function stub_frame()
	local f = { scripts = {}, events = {} }
	return setmetatable(f, {
		__index = function(_, k)
			if k == "SetScript" then
				return function(self, name, fn)
					self.scripts[name] = fn
				end
			elseif k == "RegisterEvent" then
				return function(self, e)
					self.events[e] = true
				end
			elseif k == "CreateFontString" or k == "GetParent" then
				return function()
					return stub_frame()
				end
			elseif k == "GetText" then
				return function(self)
					return self.text
				end
			elseif k == "SetText" then
				return function(self, text)
					self.text = text
				end
			end
			return function() end
		end,
	})
end

describe("Core (stubbed WoW API)", function()
	local bank, frames, ns

	before_each(function()
		bank = {}
		frames = {}
		_G.BANK_CONTAINER = -1
		_G.BankFrame = stub_frame()
		_G.UIParent = stub_frame()
		_G.UISpecialFrames = {}
		_G.tinsert = table.insert
		_G.time = os.time
		_G.date = os.date
		_G.GuildBankViewerDB = nil
		_G.SlashCmdList = {}
		_G.UnitName = function()
			return "Bankalt"
		end
		_G.GetRealmName = function()
			return "Realm"
		end
		_G.C_Container = {
			GetContainerNumSlots = function()
				return 28
			end,
			GetContainerItemInfo = function(_, slot)
				return bank[slot]
			end,
		}
		_G.CreateFrame = function()
			local f = stub_frame()
			frames[#frames + 1] = f
			return f
		end
		_G.print = function() end

		ns = {}
		for _, file in ipairs({ "Encode.lua", "Snapshot.lua", "UI.lua", "Core.lua" }) do
			assert(loadfile(file))("GuildBankViewer", ns)
		end
		-- The event frame is the first frame Core.lua creates.
		local events
		for _, f in ipairs(frames) do
			if f.events.ADDON_LOADED then
				events = f
			end
		end
		ns.fire = events.scripts.OnEvent
	end)

	it("exports the open bank as the golden string", function()
		bank[2] = { itemID = 2589, stackCount = 1232 }
		bank[16] = { itemID = 19019, stackCount = 1 }
		bank[28] = { itemID = 6948, stackCount = 20 }

		local shown
		ns.ShowExport = function(text, info)
			shown = { text = text, info = info }
		end

		ns.fire(nil, "ADDON_LOADED", "GuildBankViewer")
		ns.fire(nil, "BANKFRAME_OPENED")
		_G.SlashCmdList.GUILDBANKVIEWER()

		local expected
		for _, case in ipairs(helpers.read_json("fixtures/import-strings.json")) do
			if case.name == "stacks_and_gaps" then
				expected = case.string
			end
		end
		assert.equals(expected, shown.text)
		assert.matches("3 item stacks from Bankalt%-Realm", shown.info)
	end)

	it("exports the cached snapshot after the bank is closed", function()
		bank[1] = { itemID = 19019, stackCount = 1 }
		local shown
		ns.ShowExport = function(text)
			shown = text
		end

		ns.fire(nil, "ADDON_LOADED", "GuildBankViewer")
		ns.fire(nil, "BANKFRAME_OPENED")
		ns.fire(nil, "BANKFRAME_CLOSED")
		bank[1] = nil -- reads now return nothing, as with a closed bank
		_G.SlashCmdList.GUILDBANKVIEWER()

		assert.equals(ns.EncodeItems({ { slot_number = 0, item_id = 19019, quantity = 1 } }), shown)
	end)

	it("tells the player to open the bank when there is no data", function()
		local printed
		_G.print = function(msg)
			printed = msg
		end
		ns.fire(nil, "ADDON_LOADED", "GuildBankViewer")
		_G.SlashCmdList.GUILDBANKVIEWER()
		assert.matches("Open your bank", printed)
	end)
end)
