#!/system/bin/sh
# ZeroClaw Magisk Module Installation Script

ui_print "=========================================="
ui_print "  ZeroClaw AI Assistant Module"
ui_print "  Version: {{VERSION}}"
ui_print "=========================================="

ARCH=$(getprop ro.product.cpu.abi)
ui_print "  Architecture: $ARCH"

# 本模块仅提供 ARM64 二进制，拒绝在其它架构上安装
case "$ARCH" in
  arm64-v8a)
    ;;
  *)
    ui_print "  ERROR: This module requires an ARM64 (arm64-v8a) device."
    ui_print "  Your device ABI is: $ARCH"
    abort "Unsupported ABI: $ARCH"
    ;;
esac

# ---- 存量数据迁移：旧布局在共享存储，新布局在 /data/adb/zeroclaw ----
NEW_DATA_DIR="/data/adb/zeroclaw"
OLD_DATA_DIR="/storage/emulated/0/Android/.zeroclaw"
OLD_MODULE_DIR="/data/adb/modules/zeroclaw"

# 更新安装：先停掉仍在运行的旧版守护进程
if [ -f "$OLD_MODULE_DIR/tool.sh" ] && [ -d "$OLD_MODULE_DIR/bin" ]; then
  ui_print "  Stopping old ZeroClaw daemon (if running)..."
  "$OLD_MODULE_DIR/tool.sh" stop >/dev/null 2>&1
fi

if [ -d "$OLD_DATA_DIR" ] && [ ! -e "$NEW_DATA_DIR/config.toml" ]; then
  ui_print "  Migrating data from $OLD_DATA_DIR to $NEW_DATA_DIR ..."
  mkdir -p "$NEW_DATA_DIR"
  if cp -a "$OLD_DATA_DIR/." "$NEW_DATA_DIR/" 2>/dev/null; then
    ui_print "  Data migrated. Old copy kept at $OLD_DATA_DIR,"
    ui_print "  remove it manually after verifying."
  else
    ui_print "  WARNING: migration failed; old data left untouched."
    ui_print "  Service will start fresh at $NEW_DATA_DIR."
  fi
fi

# 迁移旧版本残留在模块目录里的运行时文件
if [ -f "$OLD_MODULE_DIR/zeroclaw.log" ]; then
  mkdir -p "$NEW_DATA_DIR/runtime"
  mv -f "$OLD_MODULE_DIR/zeroclaw.log" "$NEW_DATA_DIR/runtime/zeroclaw.log" 2>/dev/null
fi
if [ -f "$OLD_MODULE_DIR/zeroclaw.pid" ]; then
  mkdir -p "$NEW_DATA_DIR/runtime"
  mv -f "$OLD_MODULE_DIR/zeroclaw.pid" "$NEW_DATA_DIR/runtime/zeroclaw.pid" 2>/dev/null
fi

ui_print ""
ui_print "  Installation complete!"
ui_print "  Usage: ./tool.sh start"
ui_print "  WebUI: http://127.0.0.1:42617/"
ui_print "=========================================="
