#!/system/bin/sh
MODDIR=${0%/*}
export HOME="/storage/emulated/0/Android"

PIDFILE="$MODDIR/zeroclaw.pid"

check_binary() {
  if [ ! -x "$MODDIR/bin/zeroclaw" ]; then
    echo "Error: zeroclaw binary not found or not executable" >&2
    return 1
  fi
  return 0
}

validate_subcmd() {
  local cmd="$1"
  local allowed="$2"
  for sub in $allowed; do
    [ "$cmd" = "$sub" ] && return 0
  done
  echo "Usage: $0 $cmd {${allowed// /|}}" >&2
  return 1
}

show_help() {
  echo "ZeroClaw Control Panel"
  echo "======================"
  echo "  1 - start        (Start daemon service)"
  echo "  2 - stop         (Stop daemon service)"
  echo "  3 - restart      (Restart daemon service)"
  echo "  4 - status       (Check status via program)"
  echo "  5 - status_pid   (Check status via pid file)"
  echo "  6 - onboard      (Initialize workspace/config)"
  echo "  7 - agent        (Run interactive chat)"
  echo "  8 - gateway      (Start webhook/gateway)"
  echo "  9 - service      (Manage OS service: start/stop/restart/status/install/uninstall)"
  echo " 10 - doctor       (Run diagnostics)"
  echo " 11 - estop        (Emergency stop: estop [resume])"
  echo " 12 - cron         (Manage scheduled tasks: list/add/add-at/add-every/once/remove/pause/resume)"
  echo " 13 - models       (Refresh model catalogs)"
  echo " 14 - providers    (List provider IDs and aliases)"
  echo " 15 - channel      (Manage channels: list/start/doctor/bind-telegram/add/remove)"
  echo " 16 - integrations (Inspect integration details)"
  echo " 17 - skills       (Skill management: list/audit/install/remove)"
  echo " 18 - migrate      (Import from external runtimes)"
  echo " 19 - config       (Show config schema)"
  echo " 20 - completions  (Generate shell completions: bash/fish/zsh/powershell/elvish)"
  echo " 21 - hardware     (Discover/inspect USB hardware)"
  echo " 22 - peripheral   (Configure and flash peripherals)"
  echo " 23 - log          (View zeroclaw.log file)"
  echo "  0 - exit         (Exit this tool)"
  echo "======================"
}

run_cmd() {
  check_binary || return 1
  
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
    6|onboard)
      "$MODDIR/bin/zeroclaw" "$@"
      ;;
    7|agent)
      "$MODDIR/bin/zeroclaw" "$@"
      ;;
    8|gateway)
      "$MODDIR/bin/zeroclaw" "$@"
      ;;
    9|service)
      shift
      validate_subcmd "$1" "install start stop restart status uninstall" && \
        "$MODDIR/bin/zeroclaw" service "$@"
      ;;
    10|doctor)
      "$MODDIR/bin/zeroclaw" "$@"
      ;;
    11|estop)
      "$MODDIR/bin/zeroclaw" "$@"
      ;;
    12|cron)
      shift
      validate_subcmd "$1" "list add add-at add-every once remove pause resume" && \
        "$MODDIR/bin/zeroclaw" cron "$@"
      ;;
    13|models)
      "$MODDIR/bin/zeroclaw" "$@"
      ;;
    14|providers)
      "$MODDIR/bin/zeroclaw" providers
      ;;
    15|channel)
      shift
      validate_subcmd "$1" "list start doctor bind-telegram add remove" && \
        "$MODDIR/bin/zeroclaw" channel "$@"
      ;;
    16|integrations)
      shift
      if [ -z "$1" ]; then
        echo "Usage: integrations info <name>" >&2
        return 1
      fi
      "$MODDIR/bin/zeroclaw" integrations "$@"
      ;;
    17|skills)
      shift
      validate_subcmd "$1" "list audit install remove" && \
        "$MODDIR/bin/zeroclaw" skills "$@"
      ;;
    18|migrate)
      shift
      case "$1" in
        openclaw)
          "$MODDIR/bin/zeroclaw" migrate "$@"
          ;;
        *)
          echo "Usage: migrate openclaw [--source <path>] [--dry-run]" >&2
          return 1
          ;;
      esac
      ;;
    19|config)
      "$MODDIR/bin/zeroclaw" config schema
      ;;
    20|completions)
      shift
      validate_subcmd "$1" "bash fish zsh powershell elvish" && \
        "$MODDIR/bin/zeroclaw" completions "$@"
      ;;
    21|hardware)
      shift
      validate_subcmd "$1" "discover introspect info" && \
        "$MODDIR/bin/zeroclaw" hardware "$@"
      ;;
    22|peripheral)
      shift
      validate_subcmd "$1" "list add flash setup-uno-q flash-nucleo" && \
        "$MODDIR/bin/zeroclaw" peripheral "$@"
      ;;
    23|log)
      local logfile="$MODDIR/zeroclaw.log"
      if [ ! -f "$logfile" ]; then
        echo "Log file not found"
        return 1
      fi
      case "$2" in
        tail|t)
          tail -f "$logfile"
          ;;
        clear)
          : > "$logfile"
          echo "Log cleared"
          ;;
        *)
          cat "$logfile"
          ;;
      esac
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
    read -r cmd args || cleanup
    case "$cmd" in
      0|exit|quit)
        echo "Goodbye"
        cleanup
        ;;
      *)
        [ -n "$cmd" ] && run_cmd "$cmd $args"
        ;;
    esac
  done
else
  run_cmd "$1"
fi
