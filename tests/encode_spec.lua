local helpers = require("tests.helpers")

describe("Encode", function()
	local ns = helpers.load_ns({ "Encode.lua" })

	it("base64-encodes like RFC 4648, including padding", function()
		assert.equals("", ns.Base64Encode(""))
		assert.equals("Zg==", ns.Base64Encode("f"))
		assert.equals("Zm8=", ns.Base64Encode("fo"))
		assert.equals("Zm9v", ns.Base64Encode("foo"))
		assert.equals("Zm9vYg==", ns.Base64Encode("foob"))
		assert.equals("Zm9vYmFy", ns.Base64Encode("foobar"))
	end)

	it("round-trips through Base64Decode", function()
		for _, s in ipairs({ "", "a", "ab", "abc", '[{"slot_number":0}]' }) do
			assert.equals(s, ns.Base64Decode(ns.Base64Encode(s)))
		end
	end)

	it("writes JSON the way JSON.stringify would", function()
		assert.equals("[]", ns.ItemsToJson({}))
		assert.equals(
			'[{"slot_number":0,"item_id":19019,"quantity":1},{"slot_number":27,"item_id":6948,"quantity":20}]',
			ns.ItemsToJson({
				{ slot_number = 0, item_id = 19019, quantity = 1 },
				{ slot_number = 27, item_id = 6948, quantity = 20 },
			})
		)
	end)

	describe("golden import strings shared with the web app", function()
		for _, case in ipairs(helpers.read_json("fixtures/import-strings.json")) do
			it(case.name, function()
				assert.equals(case.string, ns.EncodeItems(case.items))
			end)
		end
	end)
end)
