#!/bin/bash

CONFIG_DIR="/etc/pve/lxc"

# Check passing of ctid as cmd args
if [ "$#" -lt 1 ]; then
  echo "❌ Usage: $0 <CTID1> <CTID2> ..."
  exit 1
fi

# Adds lines to configs
echo " Enter the configuration lines to add (one per line)."
echo "Press ctrl+D to exit."
CONF_LINES=()
while IFS= read -r line; do
  CONF_LINES+=("$line")
done

# gets containner id
for CTID in "$@"; do
  CONF_FILE="$CONFIG_DIR/$CTID.conf"

#Backup conf
  cp "$CONF_FILE" "$CONF_FILE.bak"
  echo "Backup created at $CONF_FILE.bak"

  if [ ! -f "$CONF_FILE" ]; then
    echo "Container $CTID does not exist. Skipping."
    continue
  fi

  echo "Updating container $CTID..."

  UPDATED=0

  for LINE in "${CONF_LINES[@]}"; do
    if grep -Fxq "$LINE" "$CONF_FILE"; then
      echo "Already exists: $LINE"
    else
      echo "$LINE" >> "$CONF_FILE"
      echo "   ➕ Added: $LINE"
      UPDATED=1
    fi
  done

  if [ "$UPDATED" -eq 1 ]; then
    echo "Restarting container $CTID..."
    pct restart "$CTID"
  else
    echo "No changes. Container $CTID not restarted."
  fi
done

echo "Done."
