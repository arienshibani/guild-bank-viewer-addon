-- Turns raw bank slot reads into the items list. No WoW API calls.
local _, ns = ...

-- The web app models the 28 main bank slots (slot_number 0..27).
ns.SLOT_COUNT = 28

--- Build the items list from a reader.
-- readSlot(slot) takes a 1-based bank slot and returns itemID, count (or nil for empty).
-- Stable order: ascending slot. slot_number is 0-based to match the web app.
function ns.BuildItems(readSlot, slotCount)
	local items = {}
	for slot = 1, math.min(slotCount or ns.SLOT_COUNT, ns.SLOT_COUNT) do
		local itemID, count = readSlot(slot)
		if type(itemID) == "number" and itemID > 0 then
			items[#items + 1] = {
				slot_number = slot - 1,
				item_id = itemID,
				quantity = (type(count) == "number" and count > 0) and count or 1,
			}
		end
	end
	return items
end
