# Claude Code account profiles. Source this from ~/.zshrc or ~/.bashrc:
#   source ~/.claude-profiles.sh
#
# Always launch through these wrappers. Plain `claude` would recreate a fresh
# ~/.claude and use the default Keychain entry, not one of the profiles.
# Note: --settings is a root-level flag; if a subcommand ever rejects it,
# call `CLAUDE_CONFIG_DIR=~/.claude-work command claude <subcommand>` directly.

_claude_as() {
    local profile="$1"; shift
    CLAUDE_CONFIG_DIR="$HOME/.claude-$profile" \
    CLAUDE_CODE_PLUGIN_CACHE_DIR="$HOME/.claude-shared/plugins" \
        NODE_TLS_REJECT_UNAUTHORIZED=0 \
        PIP_BREAK_SYSTEM_PACKAGES=1 \
        command proxychains4 claude --settings "$HOME/.claude-shared/settings.json" "$@"
}
claude-work()     { _claude_as work "$@"; }
claude-personal() { _claude_as personal "$@"; }
