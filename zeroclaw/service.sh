#!/system/bin/sh
# 请不要硬编码/magisk/modname/...;相反，请使用$MODDIR/...
# 这将使您的脚本兼容，即使Magisk以后改变挂载点

MODDIR=${0%/*}

# 配置
MAX_RETRIES=3
RETRY_DELAY=5

# 日志函数
log_info() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$MODDIR/service.log"
}

log_error() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$MODDIR/service.log"
}

# 等待系统就绪
wait_for_system() {
  local timeout=60
  local count=0
  
  log_info "Waiting for system to be ready..."
  
  # 等待 /system/bin 可用
  while [ ! -d "/system/bin" ] && [ $count -lt $timeout ]; do
    sleep 1
    count=$((count + 1))
  done
  
  # 等待存储可用
  count=0
  while [ ! -d "/storage/emulated/0" ] && [ $count -lt $timeout ]; do
    sleep 1
    count=$((count + 1))
  done
  
  # 等待网络就绪（可选）
  count=0
  while [ $count -lt 10 ]; do
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
      log_info "Network is ready"
      break
    fi
    sleep 1
    count=$((count + 1))
  done
  
  log_info "System is ready"
}

# 启动服务（带重试）
start_service() {
  local retry=0
  
  while [ $retry -lt $MAX_RETRIES ]; do
    log_info "Starting ZeroClaw service (attempt $((retry + 1))/$MAX_RETRIES)..."
    
    chmod +x "$MODDIR/bin/zeroclaw"
    chmod +x "$MODDIR/tool.sh"
    
    if "$MODDIR/tool.sh" start; then
      # 验证启动是否成功
      sleep 2
      if "$MODDIR/tool.sh" status_pid | grep -q "Running"; then
        log_info "ZeroClaw service started successfully"
        return 0
      fi
    fi
    
    retry=$((retry + 1))
    log_error "Failed to start service, retrying in ${RETRY_DELAY}s..."
    sleep $RETRY_DELAY
  done
  
  log_error "Failed to start ZeroClaw service after $MAX_RETRIES attempts"
  return 1
}

# 主逻辑
log_info "=== ZeroClaw Service Starting ==="

# 等待系统就绪
wait_for_system

# 启动服务
if start_service; then
  log_info "Service startup completed successfully"
else
  log_error "Service startup failed"
  exit 1
fi
