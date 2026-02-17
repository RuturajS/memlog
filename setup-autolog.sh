#!/bin/bash

# Memlog Auto-Logging Setup Script
# This adds hooks to your shell to automatically log ALL commands

echo "🔧 Setting up automatic command logging..."
echo ""

# Detect shell
SHELL_NAME=$(basename "$SHELL")

if [ "$SHELL_NAME" = "bash" ]; then
    SHELL_RC="$HOME/.bashrc"
    HOOK_CODE='
# Memlog automatic logging hook
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'"'"'\n'"'"'}history -a; memlog_auto_log"

memlog_auto_log() {
    local last_cmd=$(history 1 | sed "s/^[ ]*[0-9]*[ ]*//")
    if [ -n "$last_cmd" ] && [ "$last_cmd" != "memlog_auto_log" ]; then
        (memlog exec "$last_cmd" &>/dev/null &)
    fi
}
'
elif [ "$SHELL_NAME" = "zsh" ]; then
    SHELL_RC="$HOME/.zshrc"
    HOOK_CODE='
# Memlog automatic logging hook
preexec() {
    if [ -n "$1" ] && [[ "$1" != memlog* ]]; then
        (memlog exec "$1" &>/dev/null &)
    fi
}
'
else
    echo "❌ Unsupported shell: $SHELL_NAME"
    echo "Memlog auto-logging works with bash and zsh"
    exit 1
fi

# Check if already installed
if grep -q "memlog_auto_log\|Memlog automatic logging" "$SHELL_RC" 2>/dev/null; then
    echo "⚠️  Memlog auto-logging is already set up in $SHELL_RC"
    echo ""
    echo "To reinstall, remove the existing hook first:"
    echo "  nano $SHELL_RC"
    echo "  (Remove the Memlog automatic logging section)"
    exit 0
fi

# Add hook
echo "$HOOK_CODE" >> "$SHELL_RC"

echo "✅ Auto-logging hook added to $SHELL_RC"
echo ""
echo "📝 How it works:"
echo "  - Every command you run will be automatically logged"
echo "  - No need to type 'memlog exec' anymore"
echo "  - Logging happens in the background (no slowdown)"
echo ""
echo "🔄 Restart your shell or run:"
echo "  source $SHELL_RC"
echo ""
echo "🧪 Test it:"
echo "  echo 'Hello Memlog!'"
echo "  memlog logs --last 1"
echo ""
