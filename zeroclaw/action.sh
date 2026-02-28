#!/system/bin/sh

MODDIR=${0%/*}
export HOME="/storage/emulated/0/Android"

# 引入公共函数
. "$MODDIR/tool.sh"

# 主逻辑
main() {
  # 清理过期的 PID 文件
  cleanup_pidfile
  
  if is_running; then
    # 服务正在运行，停止它
    log_info "Stopping ZeroClaw service..."
    if "$MODDIR/tool.sh" stop; then
      log_info "Stopped successfully"
    else
      log_error "Stop command failed"
    fi
  else
    # 服务未运行，启动它
    log_info "Starting ZeroClaw service..."
    if "$MODDIR/tool.sh" start; then
      # 验证启动
      sleep 2
      if is_running; then
        log_info "Started successfully (PID: $(get_pid))"
      else
        log_error "Service failed to start"
        exit 1
      fi
    else
      log_error "Start command failed"
      exit 1
    fi
  fi
}

main
