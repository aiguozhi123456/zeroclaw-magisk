#!/system/bin/sh
# ZeroClaw 模块卸载脚本

MODDIR=${0%/*}

# 引入公共环境（HOME / 数据目录的单一来源）
if [ -f "$MODDIR/env.sh" ]; then
  . "$MODDIR/env.sh"
else
  ZEROCLAW_HOME="/data/adb/zeroclaw"
fi

# 停止服务
if [ -f "$MODDIR/tool.sh" ]; then
  "$MODDIR/tool.sh" stop 2>/dev/null
fi

# 清理数据目录（新布局），以及迁移前旧布局的遗留副本
rm -rf "$ZEROCLAW_HOME"
rm -rf "/storage/emulated/0/Android/.zeroclaw" 2>/dev/null

# 清理旧版本残留在模块目录内的运行时文件
rm -f "$MODDIR/zeroclaw.pid" "$MODDIR/zeroclaw.log" 2>/dev/null