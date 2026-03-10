#!/system/bin/sh
# ZeroClaw Magisk Module Installation Script

MODPATH="${0%/*}"

ui_print "=========================================="
ui_print "  ZeroClaw AI Assistant Module"
ui_print "  Version: v0.1.7"
ui_print "=========================================="

ARCH=$(getprop ro.product.cpu.abi)
ui_print "  Architecture: $ARCH"

ui_print ""
ui_print "  Installation complete!"
ui_print "  Usage: ./tool.sh start"
ui_print "  WebUI: http://127.0.0.1:42617/"
ui_print "=========================================="
