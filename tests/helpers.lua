-- Loads an addon file the way WoW does: `local addonName, ns = ...`.
local M = {}

function M.load_ns(files)
	local ns = {}
	for _, file in ipairs(files) do
		local chunk = assert(loadfile(file))
		chunk("GuildBankViewer", ns)
	end
	return ns
end

--- Minimal JSON reader for the fixtures (arrays/objects/strings/integers only).
function M.read_json(path)
	local f = assert(io.open(path, "r"))
	local text = f:read("*a")
	f:close()
	local pos = 1
	local function ws()
		pos = text:find("%S", pos) or #text + 1
	end
	local value
	local function str()
		local s, e = text:find('^"[^"]*"', pos)
		pos = e + 1
		return text:sub(s + 1, e - 1)
	end
	function value()
		ws()
		local c = text:sub(pos, pos)
		if c == "{" then
			local t = {}
			pos = pos + 1
			ws()
			if text:sub(pos, pos) == "}" then
				pos = pos + 1
				return t
			end
			repeat
				ws()
				local k = str()
				ws()
				pos = pos + 1 -- :
				t[k] = value()
				ws()
				local sep = text:sub(pos, pos)
				pos = pos + 1
			until sep == "}"
			return t
		elseif c == "[" then
			local t = {}
			pos = pos + 1
			ws()
			if text:sub(pos, pos) == "]" then
				pos = pos + 1
				return t
			end
			repeat
				t[#t + 1] = value()
				ws()
				local sep = text:sub(pos, pos)
				pos = pos + 1
			until sep == "]"
			return t
		elseif c == '"' then
			return str()
		else
			local s, e = text:find("^-?%d+", pos)
			pos = e + 1
			return tonumber(text:sub(s, e))
		end
	end
	return value()
end

return M
