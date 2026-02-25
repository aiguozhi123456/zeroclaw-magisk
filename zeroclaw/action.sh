#!/system/bin/sh
MODDIR=${0%/*}
export HOME="/storage/emulated/0/Android"

if ps -A 2>/dev/null | grep -q "[z]eroclaw"; then
  pkill zeroclaw
  echo "Stopped"
else
  chmod +x "$MODDIR/tool.sh"
  "$MODDIR/tool.sh" start
  echo "Started"
fi
