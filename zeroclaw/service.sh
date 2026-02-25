#!/system/bin/sh
# 请不要硬编码/magisk/modname/...;相反，请使用$MODDIR/...
# 这将使您的脚本兼容，即使Magisk以后改变挂载点
MODDIR=${0%/*}

# 该脚本将在设备开机后作为延迟服务启动
sleep 10
chmod +x "$MODDIR/bin/zeroclaw"
chmod +x "$MODDIR/tool.sh"
"$MODDIR/tool.sh" start
