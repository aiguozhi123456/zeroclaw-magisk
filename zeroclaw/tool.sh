#!/system/bin/sh

MODDIR=${0%/*}
export HOME="/storage/emulated/0/Android"

PIDFILE="$MODDIR/zeroclaw.pid"
LOGFILE="$MODDIR/zeroclaw.log"

# 配置
MAX_LOG_SIZE=10485760  # 10MB
MAX_LOG_FILES=5

# 检查二进制文件
check_binary() {
  if [ ! -x "$MODDIR/bin/zeroclaw" ]; then
    echo "Error: zeroclaw binary not found or not executable" >&2
    return 1
  fi
  return 0
}

# 验证子命令
validate_subcmd() {
  local cmd="$1"
  local allowed="$2"
  for sub in $allowed; do
    [ "$cmd" = "$sub" ] && return 0
  done
  echo "Usage: $0 $cmd {${allowed// /|}}" >&2
  return 1
}

# 日志轮转
rotate_logs() {
  if [ -f "$LOGFILE" ]; then
    local size
    size=$(stat -c%s "$LOGFILE" 2>/dev/null || echo "0")
    if [ "$size" -gt "$MAX_LOG_SIZE" ]; then
      # 轮转日志
      for i in $(seq $((MAX_LOG_FILES - 1)) -1 1); do
        if [ -f "$LOGFILE.$i" ]; then
          mv "$LOGFILE.$i" "$LOGFILE.$((i + 1))"
        fi
      done
      mv "$LOGFILE" "$LOGFILE.1"
      touch "$LOGFILE"
    fi
  fi
}

# 获取 PID
get_pid() {
  if [ -f "$PIDFILE" ]; then
    cat "$PIDFILE" 2>/dev/null
  fi
}

# 检查进程是否运行
is_running() {
  local pid
  pid=$(get_pid)
  if [ -n "$pid" ]; then
    kill -0 "$pid" 2>/dev/null
    return $?
  fi
  return 1
}

# 清理 PID 文件
cleanup_pidfile() {
  if [ -f "$PIDFILE" ]; then
    local pid
    pid=$(get_pid)
    if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then
      rm -f "$PIDFILE"
    fi
  fi
}

# 启动守护进程（提取公共函数）
start_daemon() {
  rotate_logs
  chmod +x "$MODDIR/bin/zeroclaw"
  nohup "$MODDIR/bin/zeroclaw" daemon > "$LOGFILE" 2>&1 &
  local pid=$!
  
  # 等待并验证启动
  sleep 2
  if kill -0 "$pid" 2>/dev/null; then
    echo "$pid" > "$PIDFILE"
    return 0
  else
    return 1
  fi
}

# 停止守护进程（提取公共函数）
stop_daemon() {
  cleanup_pidfile
  if [ -f "$PIDFILE" ]; then
    local pid
    pid=$(get_pid)
    if [ -n "$pid" ]; then
      # 优雅终止
      kill "$pid" 2>/dev/null
      # 等待进程结束
      local count=0
      while kill -0 "$pid" 2>/dev/null && [ $count -lt 10 ]; do
        sleep 1
        count=$((count + 1))
      done
      # 强制终止（如果还在运行）
      if kill -0 "$pid" 2>/dev/null; then
        kill -9 "$pid" 2>/dev/null
      fi
    fi
    rm -f "$PIDFILE"
  fi
}

# 显示帮助
show_help() {
  cat << 'EOF'
ZeroClaw Control Panel
======================
  1 - start        (Start daemon service)
  2 - stop         (Stop daemon service)
  3 - restart      (Restart daemon service)
  4 - status       (Check status via program)
  5 - status_pid   (Check status via pid file)
  6 - onboard      (Initialize workspace/config)
  7 - agent        (Run interactive chat)
  8 - gateway      (Start webhook/gateway)
  9 - service      (Manage OS service: start/stop/restart/status/install/uninstall)
 10 - doctor       (Run diagnostics)
 11 - estop        (Emergency stop: estop [resume])
 12 - cron         (Manage scheduled tasks: list/add/add-at/add-every/once/remove/pause/resume)
 13 - models       (Refresh model catalogs)
 14 - providers    (List provider IDs and aliases)
 15 - channel      (Manage channels: list/start/doctor/bind-telegram/add/remove)
 16 - integrations (Inspect integration details)
 17 - skills       (Skill management: list/audit/install/remove)
 18 - migrate      (Import from external runtimes)
 19 - config       (Show config schema)
 20 - completions  (Generate shell completions: bash/fish/zsh/powershell/elvish)
 21 - hardware     (Discover/inspect USB hardware)
 22 - peripheral   (Configure and flash peripherals)
 23 - log          (View zeroclaw.log file)
  0 - exit         (Exit this tool)
======================
EOF
}

# 运行命令
run_cmd() {
  check_binary || return 1
  
  case "$1" in
    1|start)
      if is_running; then
        echo "Already running (PID: $(get_pid))"
        return 0
      fi
      if start_daemon; then
        echo "Started (PID: $(get_pid))"
      else
        echo "Failed to start" >&2
        return 1
      fi
      ;;
    2|stop)
      if ! is_running; then
        echo "Not running"
        cleanup_pidfile
        return 0
      fi
      stop_daemon
      echo "Stopped"
      ;;
    3|restart)
      stop_daemon
      sleep 1
      if start_daemon; then
        echo "Restarted (PID: $(get_pid))"
      else
        echo "Failed to restart" >&2
        return 1
      fi
      ;;
    4|status)
      "$MODDIR/bin/zeroclaw" status
      ;;
    5|status_pid)
      cleanup_pidfile
      if is_running; then
        echo "Running (PID: $(get_pid))"
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
      if [ ! -f "$LOGFILE" ]; then
        echo "Log file not found"
        return 1
      fi
      case "$2" in
        tail|t)
          tail -f "$LOGFILE"
          ;;
        clear)
          : > "$LOGFILE"
          echo "Log cleared"
          ;;
        rotate|r)
          rotate_logs
          echo "Log rotated"
          ;;
        *)
          cat "$LOGFILE"
          ;;
      esac
      ;;
    help|h|?)
      show_help
      ;;
    *)
      echo "Unknown command: $1"
      return 1
      ;;
  esac
}

# 清理函数
cleanup() {
  exit 0
}

trap cleanup HUP INT TERM

# 主逻辑
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
      "")
        # 空输入，继续循环
        ;;
      *)
        run_cmd "$cmd" $args
        ;;
    esac
  done
else
  run_cmd "$@"
fi
