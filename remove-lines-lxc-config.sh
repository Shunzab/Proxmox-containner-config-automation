#!/bin/bash

CONFIG_DIR="/etc/pve/lxc"

# Check ctid as cmd args
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <CTID1> <CTID2> ..."
  exit 1
fi

# config exists
if [ ! -d "$CONFIG_DIR" ]; then
  echo "Config directory $CONFIG_DIR not found. Is this a Proxmox system?"
  exit 1
fi

# lines for remove
echo "Enter the configuration lines to REMOVE (exact match, one per line)."
echo "Press ctrl+D when done."
REMOVE_LINES=()
while IFS= read -r line; do
  REMOVE_LINES+=("$line")
done

# Process .conf
for CTID in "$@"; do
  CONF_FILE="$CONFIG_DIR/$CTID.conf"

  if [ ! -f "$CONF_FILE" ]; then
    echo "Container $CTID does not exist. Skipping."
    continue
  fi

  echo "Processing container $CTID..."

  # Backup conf
  cp "$CONF_FILE" "$CONF_FILE.bak"
  echo "Backup created at $CONF_FILE.bak"

  UPDATED=0

  for LINE in "${REMOVE_LINES[@]}"; do
    if grep -Fxq "$LINE" "$CONF_FILE"; then
      # Remove the exact matching line
      sed -i "\|^$LINE\$|d" "$CONF_FILE"
      echo "Removed: $LINE"
      UPDATED=1
    else
      echo "Not found: $LINE"
    fi
  done

  if [ "$UPDATED" -eq 1 ]; then
    echo "Restarting container $CTID..."
    pct restart "$CTID"
  else
    echo "No changes made to container $CTID."
  fi

done

echo "Done."
