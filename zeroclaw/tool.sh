#!/system/bin/sh
MODDIR=${0%/*}
export HOME="/storage/emulated/0/Android"

show_help() {
  echo "ZeroClaw Control Panel"
  echo "======================"
  echo "  1 - start      (Start service)"
  echo "  2 - stop       (Stop service)"
  echo "  3 - restart    (Restart service)"
  echo "  4 - status     (Check status via program)"
  echo "  5 - status_grep(Check status via grep)"
  echo "  0 - exit       (Exit this tool)"
  echo "======================"
}

run_cmd() {
  case "$1" in
    1|start)
      chmod +x "$MODDIR/bin/zeroclaw"
      nohup "$MODDIR/bin/zeroclaw" daemon > "$MODDIR/zeroclaw.log" 2>&1 &
      echo "Started"
      ;;
    2|stop)
      pkill zeroclaw
      echo "Stopped"
      ;;
    3|restart)
      pkill zeroclaw
      sleep 1
      nohup "$MODDIR/bin/zeroclaw" daemon > "$MODDIR/zeroclaw.log" 2>&1 &
      echo "Restarted"
      ;;
    4|status)
      "$MODDIR/bin/zeroclaw" status
      ;;
    5|status_grep)
      if ps -A 2>/dev/null | grep -q "[z]eroclaw"; then
        echo "Running"
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
