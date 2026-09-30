local helpers = require("tests.helpers")

describe("BuildItems", function()
	local ns = helpers.load_ns({ "Snapshot.lua" })

	local function reader(slots)
		return function(slot)
			local s = slots[slot]
			if s then
				return s[1], s[2]
			end
		end
	end

	it("returns nothing for an empty bank", function()
		assert.same({}, ns.BuildItems(reader({}), 28))
	end)

	it("maps 1-based bank slots to 0-based slot_number, in order", function()
		local items = ns.BuildItems(reader({ [1] = { 19019, 1 }, [16] = { 2589, 1232 }, [28] = { 6948, 20 } }), 28)
		assert.same({
			{ slot_number = 0, item_id = 19019, quantity = 1 },
			{ slot_number = 15, item_id = 2589, quantity = 1232 },
			{ slot_number = 27, item_id = 6948, quantity = 20 },
		}, items)
	end)

	it("defaults a missing or invalid count to 1 and skips invalid item ids", function()
		local items = ns.BuildItems(reader({ [1] = { 5, nil }, [2] = { 6, 0 }, [3] = { 0, 4 }, [4] = { "x", 2 } }), 28)
		assert.same({
			{ slot_number = 0, item_id = 5, quantity = 1 },
			{ slot_number = 1, item_id = 6, quantity = 1 },
		}, items)
	end)

	it("never reads beyond the 28 slots the web app models", function()
		local seen = 0
		ns.BuildItems(function()
			seen = seen + 1
		end, 40)
		assert.equals(28, seen)
	end)
end)
