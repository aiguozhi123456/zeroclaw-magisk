#!/system/bin/sh

MODDIR=${0%/*}
export HOME="/storage/emulated/0/Android"

PIDFILE="$MODDIR/zeroclaw.pid"

# 日志函数
log() {
  echo "[$(date '+%H:%M:%S')] $1"
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

# 主逻辑
main() {
  # 确保 tool.sh 可执行
  if [ ! -f "$MODDIR/tool.sh" ]; then
    log "Error: tool.sh not found"
    exit 1
  fi
  
  chmod +x "$MODDIR/tool.sh"
  
  # 清理过期的 PID 文件
  cleanup_pidfile
  
  if is_running; then
    # 服务正在运行，停止它
    log "Stopping ZeroClaw service..."
    if "$MODDIR/tool.sh" stop; then
      log "Stopped successfully"
    else
      log "Warning: Stop command failed"
    fi
  else
    # 服务未运行，启动它
    log "Starting ZeroClaw service..."
    if "$MODDIR/tool.sh" start; then
      # 验证启动
      sleep 2
      if is_running; then
        log "Started successfully (PID: $(get_pid))"
      else
        log "Error: Service failed to start"
        exit 1
      fi
    else
      log "Error: Start command failed"
      exit 1
    fi
  fi
}

main
