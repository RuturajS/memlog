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
# Memlog automatic logging hook (using DEBUG trap)
shopt -s extdebug
memlog_last_cmd=""

memlog_preexec() {
    local cmd="$BASH_COMMAND"
    
    # Skip memlog commands, internal bash commands, and duplicates
    if [[ "$cmd" != memlog* ]] && [[ "$cmd" != "memlog_"* ]] && \
       [[ "$cmd" != *"PROMPT_COMMAND"* ]] && [[ "$cmd" != "trap"* ]]; then
        if [ "$cmd" != "$memlog_last_cmd" ]; then
            memlog_last_cmd="$cmd"
            # Run in background to avoid blocking
            (nohup memlog exec "$cmd" &>/dev/null &)
        fi
    fi
}

trap memlog_preexec DEBUG
'
elif [ "$SHELL_NAME" = "zsh" ]; then
    SHELL_RC="$HOME/.zshrc"
    HOOK_CODE='
# Memlog automatic logging hook (using preexec)
preexec() {
    local cmd="$1"
    
    # Skip memlog commands
    if [[ "$cmd" != memlog* ]]; then
        # Run in background to avoid blocking
        (nohup memlog exec "$cmd" &>/dev/null &)
    fi
}
'
else
    echo "❌ Unsupported shell: $SHELL_NAME"
    echo "Memlog auto-logging works with bash and zsh"
    exit 1
fi

# Check if already installed
if grep -q "memlog_preexec\|Memlog automatic logging" "$SHELL_RC" 2>/dev/null; then
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
echo "  - Uses DEBUG trap (bash) or preexec (zsh) for reliable capture"
echo ""
echo "🔄 Restart your shell or run:"
echo "  source $SHELL_RC"
echo ""
echo "🧪 Test it:"
echo "  ls -la"
echo "  echo 'Hello Memlog!'"
echo "  pwd"
echo "  memlog logs --last 5"
echo ""
echo "💡 Tip: Create an alias for quick manual logging:"
echo "  echo 'alias m=\"memlog exec\"' >> $SHELL_RC"
echo ""
