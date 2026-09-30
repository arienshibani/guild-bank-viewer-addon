-- Pure string encoding, no WoW API. Output must stay byte-compatible with the
-- web app's `btoa(JSON.stringify(items))` (see FORMAT.md).
local _, ns = ...

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

--- Base64-encode a string (no bit library: WoW runs plain Lua 5.1).
function ns.Base64Encode(data)
	local out = {}
	for i = 1, #data, 3 do
		local a, b, c = data:byte(i, i + 2)
		local n = a * 65536 + (b or 0) * 256 + (c or 0)
		local c1 = math.floor(n / 262144) % 64
		local c2 = math.floor(n / 4096) % 64
		local c3 = math.floor(n / 64) % 64
		local c4 = n % 64
		out[#out + 1] = B64:sub(c1 + 1, c1 + 1)
			.. B64:sub(c2 + 1, c2 + 1)
			.. (b and B64:sub(c3 + 1, c3 + 1) or "=")
			.. (c and B64:sub(c4 + 1, c4 + 1) or "=")
	end
	return table.concat(out)
end

--- Base64-decode (used by tests to check round-trips).
function ns.Base64Decode(data)
	local lookup = {}
	for i = 1, #B64 do
		lookup[B64:byte(i)] = i - 1
	end
	local out = {}
	for i = 1, #data, 4 do
		local a, b, c, d = data:byte(i, i + 3)
		local n = lookup[a] * 262144 + lookup[b] * 4096 + (lookup[c] or 0) * 64 + (lookup[d] or 0)
		local chars = string.char(math.floor(n / 65536) % 256)
		if c ~= 61 then
			chars = chars .. string.char(math.floor(n / 256) % 256)
		end
		if d ~= 61 then
			chars = chars .. string.char(n % 256)
		end
		out[#out + 1] = chars
	end
	return table.concat(out)
end

--- JSON for a list of { slot_number, item_id, quantity }, same as JSON.stringify.
function ns.ItemsToJson(items)
	local parts = {}
	for i, item in ipairs(items) do
		parts[i] = string.format(
			'{"slot_number":%d,"item_id":%d,"quantity":%d}',
			item.slot_number,
			item.item_id,
			item.quantity
		)
	end
	return "[" .. table.concat(parts, ",") .. "]"
end

--- The import string the web app accepts.
function ns.EncodeItems(items)
	return ns.Base64Encode(ns.ItemsToJson(items))
end
