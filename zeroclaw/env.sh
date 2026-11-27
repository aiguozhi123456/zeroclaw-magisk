#!/system/bin/sh
# ZeroClaw 模块公共环境变量（单一来源，各脚本通过 . "$MODDIR/env.sh" 引入）
# 数据目录对齐上游约定，使用 /data 私有分区：
# 共享 FUSE 存储（/storage/emulated/0）存在 chmod 无效、SQLite WAL 锁不可靠、
# 无 exec、多用户/USB 直连模式下路径消失等问题。
# ZEROCLAW_CONFIG_DIR 是上游最高优先级的配置目录环境变量。

export ZEROCLAW_HOME="/data/adb/zeroclaw"
export ZEROCLAW_CONFIG_DIR="$ZEROCLAW_HOME"
export HOME="$ZEROCLAW_HOME"

# 运行时文件（pid/日志）随数据目录存放，保持 Magisk 模块目录不可变
export ZEROCLAW_RUN_DIR="$ZEROCLAW_HOME/runtime"
