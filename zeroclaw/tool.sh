#!/system/bin/sh

MODDIR=${0%/*}
. "$MODDIR/env.sh"

mkdir -p "$ZEROCLAW_RUN_DIR" 2>/dev/null
PIDFILE="$ZEROCLAW_RUN_DIR/zeroclaw.pid"
LOGFILE="$ZEROCLAW_RUN_DIR/zeroclaw.log"

# 配置
MAX_LOG_SIZE=10485760  # 10MB
MAX_LOG_FILES=5

# 日志函数
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

log_info() {
  log "[INFO] $1"
}

log_error() {
  log "[ERROR] $1"
}

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
  echo "Invalid subcommand '$cmd'. Usage: $0 {${allowed// /|}}" >&2
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
  [ -n "$pid" ] || return 1
  kill -0 "$pid" 2>/dev/null || return 1
  # PID 复用防护：确认该进程确实是 zeroclaw
  tr '\0' '\n' < "/proc/$pid/cmdline" 2>/dev/null | grep -q "zeroclaw" || return 1
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

# 更新 module.prop 的 description
update_description() {
  local status="$1"
  local pid="$2"
  local base_desc="Fast, small, and fully autonomous AI assistant infrastructure for Android. Built-in WebUI chat at http://127.0.0.1:42617."
  
  case "$status" in
    running)
      sed -i "s|^description=.*|description=$base_desc Status: Running (PID: $pid)|" "$MODDIR/module.prop"
      ;;
    stopped)
      sed -i "s|^description=.*|description=$base_desc Status: Stopped|" "$MODDIR/module.prop"
      ;;
  esac
}

# 启动守护进程（提取公共函数）
start_daemon() {
  rotate_logs
  chmod +x "$MODDIR/bin/zeroclaw"
  # 追加写入日志，保留历史日志（避免每次启动清空日志，导致日志轮转形同虚设）
  nohup "$MODDIR/bin/zeroclaw" daemon >> "$LOGFILE" 2>&1 &
  local pid=$!
  
  # 等待并验证启动
  sleep 2
  if kill -0 "$pid" 2>/dev/null; then
    echo "$pid" > "$PIDFILE"
    update_description running "$pid"
    return 0
  else
    return 1
  fi
}

# 停止守护进程（提取公共函数）
stop_daemon() {
  local pid
  pid=$(get_pid)
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
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
  update_description stopped
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
  6 - quickstart   (Initialize workspace/config; replaces deprecated 'onboard')
  7 - agent        (Run interactive chat)
  8 - gateway      (Gateway control: start/restart/get-paircode)
  9 - service      (Manage OS service: start/stop/restart/status/install/uninstall/logs)
 10 - doctor       (Run diagnostics)
 11 - estop        (Emergency stop: estop [resume])
 12 - cron         (Manage scheduled tasks: list/add/add-at/add-every/once/remove/pause/resume/update)
 13 - models       (Refresh model catalogs)
 14 - providers    (Manage providers: list/create/rename/delete)
 15 - channel      (Manage channels: list/start/doctor/bind-telegram/add/remove/send)
 16 - integrations (Inspect integration details)
 17 - skills       (Skill management: list/audit/install/remove/add/edit/bundle/test)
 18 - migrate      (Import from external runtimes)
 19 - config       (Manage config: list/get/set/init/migrate/patch/docs/generate/schema)
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
      shift
      "$MODDIR/bin/zeroclaw" status "$@"
      ;;
    5|status_pid)
      cleanup_pidfile
      if is_running; then
        echo "Running (PID: $(get_pid))"
      else
        echo "Not running"
      fi
      ;;
    6|onboard|quickstart)
      shift
      "$MODDIR/bin/zeroclaw" quickstart "$@"
      ;;
    7|agent)
      shift
      "$MODDIR/bin/zeroclaw" agent "$@"
      ;;
    8|gateway)
      shift
      "$MODDIR/bin/zeroclaw" gateway "$@"
      ;;
    9|service)
      shift
      validate_subcmd "$1" "install start stop restart status uninstall logs" && \
        "$MODDIR/bin/zeroclaw" service "$@"
      ;;
    10|doctor)
      shift
      "$MODDIR/bin/zeroclaw" doctor "$@"
      ;;
    11|estop)
      shift
      "$MODDIR/bin/zeroclaw" estop "$@"
      ;;
    12|cron)
      shift
      validate_subcmd "$1" "list add add-at add-every once remove pause resume update" && \
        "$MODDIR/bin/zeroclaw" cron "$@"
      ;;
    13|models)
      shift
      "$MODDIR/bin/zeroclaw" models "$@"
      ;;
    14|providers)
      shift
      if [ -z "$1" ]; then
        "$MODDIR/bin/zeroclaw" providers
      else
        validate_subcmd "$1" "list create rename delete" && \
          "$MODDIR/bin/zeroclaw" providers "$@"
      fi
      ;;
    15|channel)
      shift
      validate_subcmd "$1" "list start doctor bind-telegram add remove send" && \
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
      validate_subcmd "$1" "list audit install remove add edit bundle test" && \
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
      shift
      if [ -z "$1" ]; then
        "$MODDIR/bin/zeroclaw" config schema
      else
        validate_subcmd "$1" "list get set init migrate patch docs generate schema" && \
          "$MODDIR/bin/zeroclaw" config "$@"
      fi
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

# 如果是被 source 引入，只定义函数，不执行主逻辑
if [ "${0##*/}" != "tool.sh" ]; then
  return 0 2>/dev/null || true
fi

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
