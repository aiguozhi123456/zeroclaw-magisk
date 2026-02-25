#!/system/bin/sh
# ZeroClaw Magisk Module Installation Script
# This script runs in Magisk/KernelSU BusyBox ash shell

MODPATH="${0%/*}"

ui_print "=========================================="
ui_print "  ZeroClaw AI Assistant Module"
ui_print "  Version: v0.1.7"
ui_print "=========================================="

ui_print ""
ui_print "Setting permissions..."
chmod 755 "$MODPATH/bin"
chmod 755 "$MODPATH/bin/zeroclaw" 2>/dev/null
chmod 755 "$MODPATH/tool.sh"
chmod 755 "$MODPATH/service.sh"
chmod 755 "$MODPATH/action.sh"

ui_print "=========================================="
ui_print "  Installation complete!"
ui_print "=========================================="
