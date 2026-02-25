#!/system/bin/sh
MODDIR=${0%/*}
export HOME="/storage/emulated/0/Android/"

if ps -A 2>/dev/null | grep -q "zeroclaw"; then
  pkill zeroclaw
  echo "Stopped"
else
  nohup "$MODDIR/bin/zeroclaw" daemon > "$MODDIR/zeroclaw.log" 2>&1 &
  echo "Started"
fi
