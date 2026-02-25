#!/system/bin/sh
MODDIR=${0%/*}
export HOME="/storage/emulated/0/Android"

PIDFILE="$MODDIR/zeroclaw.pid"

show_help() {
  echo "ZeroClaw Control Panel"
  echo "======================"
  echo "  1 - start      (Start service)"
  echo "  2 - stop       (Stop service)"
  echo "  3 - restart    (Restart service)"
  echo "  4 - status     (Check status via program)"
  echo "  5 - status_pid (Check status via pid)"
  echo "  0 - exit       (Exit this tool)"
  echo "======================"
}

run_cmd() {
  case "$1" in
    1|start)
      chmod +x "$MODDIR/bin/zeroclaw"
      nohup "$MODDIR/bin/zeroclaw" daemon > "$MODDIR/zeroclaw.log" 2>&1 &
      echo $! > "$PIDFILE"
      echo "Started"
      ;;
    2|stop)
      if [ -f "$PIDFILE" ]; then
        kill $(cat "$PIDFILE") 2>/dev/null
        rm -f "$PIDFILE"
      fi
      echo "Stopped"
      ;;
    3|restart)
      if [ -f "$PIDFILE" ]; then
        kill $(cat "$PIDFILE") 2>/dev/null
        rm -f "$PIDFILE"
      fi
      sleep 1
      chmod +x "$MODDIR/bin/zeroclaw"
      nohup "$MODDIR/bin/zeroclaw" daemon > "$MODDIR/zeroclaw.log" 2>&1 &
      echo $! > "$PIDFILE"
      echo "Restarted"
      ;;
    4|status)
      "$MODDIR/bin/zeroclaw" status
      ;;
    5|status_pid)
      if [ -f "$PIDFILE" ]; then
        pid=$(cat "$PIDFILE")
        if kill -0 $pid 2>/dev/null; then
          echo "Running"
        else
          echo "Not running"
          rm -f "$PIDFILE"
        fi
      else
        echo "Not running"
      fi
      ;;
    help|h|?)
      show_help
      ;;
    *)
      echo "Unknown command: $1"
      ;;
  esac
}

cleanup() {
  exit 0
}

trap cleanup HUP INT TERM

if [ -z "$1" ]; then
  show_help
  while true; do
    echo -n "zeroclaw> "
    read cmd || cleanup
    case "$cmd" in
      0|exit|quit)
        echo "Goodbye"
        cleanup
        ;;
      *)
        run_cmd "$cmd"
        ;;
    esac
  done
else
  run_cmd "$1"
fi
