#!/bin/bash
# Setup Claude Code statusline from this repo

set -e

echo "Setting up Claude Code statusline..."

# Create .claude directory if it doesn't exist
mkdir -p ~/.claude

# Copy statusline files
cp statusline-command.sh ~/.claude/
cp monthly-spend.json ~/.claude/

# Create settings entry if it doesn't exist
if ! grep -q "statusLine" ~/.claude/settings.json 2>/dev/null; then
  echo "Adding statusLine to settings.json..."
  # Add statusLine config to settings.json (simplified insert)
  if [ -f ~/.claude/settings.json ]; then
    # Insert before the last closing brace
    sed -i '' '$ s/}/,\n  "statusLine": "~\/.claude\/statusline-command.sh"\n}/' ~/.claude/settings.json
  fi
fi

# Update config values (prompt user)
echo ""
echo "Update these values in ~/.claude/statusline-command.sh (lines 7-8):"
echo "  MONTHLY_BUDGET=150.00"
echo "  ACCOUNT_BALANCE=24.91"
echo ""
echo "✓ Statusline setup complete!"
