# Contributing

## Setup

```sh
brew install luajit luarocks stylua
luarocks --lua-version 5.1 --lua-dir "$(brew --prefix luajit)" --tree .luarocks install busted
luarocks --lua-version 5.1 --lua-dir "$(brew --prefix luajit)" --tree .luarocks install luacheck
export PATH="$PWD/.luarocks/bin:$PATH" \
  LUA_PATH="./?.lua;$PWD/.luarocks/share/lua/5.1/?.lua;$PWD/.luarocks/share/lua/5.1/?/init.lua;;" \
  LUA_CPATH="$PWD/.luarocks/lib/lua/5.1/?.so;;"
```

## Check

```sh
stylua --check .   # formatting (run `stylua .` to fix)
luacheck .         # lint
busted --lua=luajit # unit tests (LuaJIT matches WoW's Lua 5.1)
```

`Encode.lua` and `Snapshot.lua` must stay free of WoW API calls so they can be tested outside the game.

## Try it in game

Symlink the repo as the addon folder, then `/reload` after edits (enable `/console scriptErrors 1`):

```sh
ln -s "$PWD" "/Applications/World of Warcraft/_classic_era_/Interface/AddOns/GuildBankViewer"
```

Smoke test: empty bank, full bank, stack > 1, close the bank then `/gbv` (cached snapshot), `/reload`.
Paste the string into the web app's Import dialog and compare slots, icons and quantities.

## Commits and releases

[Conventional commits](https://www.conventionalcommits.org/). `release-please` opens a release PR; merging it
tags `vX.Y.Z` and the packager uploads to CurseForge and Wago.

## Patch day

Bump `## Interface` in `GuildBankViewer.toc` (check the PTR), test in game, release a `fix:` or `chore:`.
