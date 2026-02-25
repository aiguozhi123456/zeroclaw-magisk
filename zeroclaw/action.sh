#!/system/bin/sh
MODDIR=${0%/*}
export HOME="/storage/emulated/0/Android"

PIDFILE="$MODDIR/zeroclaw.pid"

if [ -f "$PIDFILE" ]; then
  pid=$(cat "$PIDFILE")
  if kill -0 $pid 2>/dev/null; then
    "$MODDIR/tool.sh" stop
    echo "Stopped"
  else
    rm -f "$PIDFILE"
    chmod +x "$MODDIR/tool.sh"
    "$MODDIR/tool.sh" start
    echo "Started"
  fi
else
  chmod +x "$MODDIR/tool.sh"
  "$MODDIR/tool.sh" start
  echo "Started"
fi
