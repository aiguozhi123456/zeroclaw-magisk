#!/system/bin/sh
# ZeroClaw 模块卸载脚本

MODDIR=${0%/*}

# 停止服务
if [ -f "$MODDIR/tool.sh" ]; then
  "$MODDIR/tool.sh" stop 2>/dev/null
fi

# 清理外部数据目录
rm -rf "/storage/emulated/0/Android/.zeroclaw"

# 清理 PID 文件
rm -f "$MODDIR/zeroclaw.pid"
