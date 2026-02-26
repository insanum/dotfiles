#!/usr/bin/env bash

tmpfile=$(mktemp /tmp/kitty_scrollback.XXXXXX)
trap 'rm -f "$tmpfile"' EXIT

cat > "$tmpfile"

/opt/homebrew/bin/nvim \
    -c 'luafile ~/.config/kitty/kitty_scrollback_pager.lua' "$tmpfile"

