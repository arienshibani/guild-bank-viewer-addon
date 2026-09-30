# Import string format

The contract between this addon and the [Guild Bank Viewer](https://guildbankviewer.com) web app
(`lib/bank-items.ts`: `exportItems` / `parseImport`).

```
string = base64( JSON array of items )
item   = { "slot_number": 0..27, "item_id": > 0, "quantity": > 0 }
```

- `slot_number` is **0-based**: bank slot 1 in game is `0`, slot 28 is `27`.
- Only the 28 main bank slots are exported (not bank bags). Empty slots are omitted.
- Output must be byte-identical to `btoa(JSON.stringify(items))`: keys in the order above, no whitespace,
  standard base64 alphabet with `=` padding, items in ascending slot order.
- The web app drops entries outside these ranges and rejects the string if none are valid.

## Golden strings

`fixtures/import-strings.json` holds items and the expected string. It is generated with Node
(`Buffer.from(JSON.stringify(items)).toString("base64")`) and copied into the web app repo, where a test
asserts `parseImport` accepts every string. Both repos must keep the file identical. Changing the format
means a PR in each repo; the web app must keep accepting the plain array above.
