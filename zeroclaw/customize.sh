#!/system/bin/sh
# ZeroClaw Magisk Module Installation Script
# This script runs in Magisk/KernelSU BusyBox ash shell

MODPATH="${0%/*}"

# 错误处理
set -e

# 日志函数
log_info() {
  ui_print "  [INFO] $1"
}

log_warn() {
  ui_print "  [WARN] $1"
}

log_error() {
  ui_print "  [ERROR] $1"
}

ui_print "=========================================="
ui_print "  ZeroClaw AI Assistant Module"
ui_print "  Version: {{VERSION}}"
ui_print "=========================================="
ui_print ""

# 检查架构兼容性
log_info "Checking architecture..."
ARCH=$(getprop ro.product.cpu.abi)
case "$ARCH" in
  arm64-v8a|aarch64)
    log_info "Architecture: ARM64 ($ARCH)"
    ;;
  armeabi-v7a|armeabi)
    log_info "Architecture: ARMv7 ($ARCH)"
    ;;
  *)
    log_warn "Untested architecture: $ARCH"
    log_warn "Module may not work correctly"
    ;;
esac

# 设置权限
ui_print ""
log_info "Setting permissions..."

# 确保目录存在
mkdir -p "$MODPATH/bin" 2>/dev/null || true

# 设置文件权限
chmod 755 "$MODPATH/bin" 2>/dev/null || log_warn "Failed to set bin directory permissions"

if [ -f "$MODPATH/bin/zeroclaw" ]; then
  chmod 755 "$MODPATH/bin/zeroclaw" || log_warn "Failed to set zeroclaw binary permissions"
else
  log_warn "zeroclaw binary not found, will be installed on first run"
fi

for script in tool.sh service.sh action.sh; do
  if [ -f "$MODPATH/$script" ]; then
    chmod 755 "$MODPATH/$script" || log_warn "Failed to set $script permissions"
  else
    log_warn "$script not found"
  fi
done

# 设置 webroot 权限
if [ -d "$MODPATH/webroot" ]; then
  chmod -R 755 "$MODPATH/webroot" 2>/dev/null || log_warn "Failed to set webroot permissions"
fi

# 创建初始日志文件
touch "$MODPATH/zeroclaw.log" 2>/dev/null || log_warn "Failed to create log file"
chmod 644 "$MODPATH/zeroclaw.log" 2>/dev/null || true

ui_print ""
ui_print "=========================================="
ui_print "  Installation complete!"
ui_print ""
ui_print "  Usage:"
ui_print "    cd /data/adb/modules/zeroclaw"
ui_print "    ./tool.sh start"
ui_print ""
ui_print "  WebUI: http://127.0.0.1:42617/"
ui_print "=========================================="
