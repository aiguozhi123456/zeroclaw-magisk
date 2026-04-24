<div align="center">

# ⚙️ ZeroClaw Magisk Module

[![](https://img.shields.io/badge/platform-Android-green?logo=android)](https://github.com/aiguozhi123456/zeroclaw-magisk)
[![](https://img.shields.io/badge/arch-ARM64%20(aarch64)-blue)](https://github.com/aiguozhi123456/zeroclaw-magisk/releases)
[![](https://img.shields.io/badge/core-zeroclaw--labs%2Fzeroclaw-purple)](https://github.com/zeroclaw-labs/zeroclaw)

Lightweight AI assistant infrastructure for Android.  
Runs via Magisk / KernelSU / APatch with **<20MB RAM** and a built-in WebUI chat interface.

**[English](#features)** · **[中文](#功能特性)**

</div>

---

## Features

- **System-level service** — runs as a Magisk module, auto-starts on boot
- **ARM64 only** — aarch64 package built via GitHub Actions
- **Upstream tracking** — automatically mirrors releases from [zeroclaw-labs/zeroclaw](https://github.com/zeroclaw-labs/zeroclaw) every 6 hours
- **WebUI chat** — built-in web interface at `http://127.0.0.1:42617/`
- **Low footprint** — <20MB RAM, <5MB base

### How It Works

This module **does not compile from source**. The CI workflow:

1. Polls [zeroclaw-labs/zeroclaw](https://github.com/zeroclaw-labs/zeroclaw) for new releases
2. Downloads the pre-built `zeroclaw` binary (ARM64)
3. Packages it into a Magisk-compatible zip with module metadata
4. Publishes a GitHub Release with checksums

The `zeroclaw` binary is the core engine — an autonomous AI assistant runtime designed for resource-constrained environments.

### Installation

1. Download the ARM64 zip from [Releases](https://github.com/aiguozhi123456/zeroclaw-magisk/releases)
2. Install via Magisk / KernelSU / APatch
3. Reboot — the service starts automatically

### Usage

```bash
# Enter module directory
cd /data/adb/modules/zeroclaw

# Start / Stop / Restart / Status
./tool.sh start
./tool.sh stop
./tool.sh restart
./tool.sh status

# Or use interactive mode
./tool.sh
```

Then open `http://127.0.0.1:42617/` in any browser on the device.

### File Structure

```
zeroclaw/
├── bin/zeroclaw          # Core AI assistant binary
├── webroot/index.html    # WebUI redirect page
├── META-INF/com/google/android/
│   ├── update-binary     # Magisk installer
│   └── updater-script
├── customize.sh          # Module install script
├── service.sh            # Boot service script
├── tool.sh               # CLI control tool
├── action.sh             # Action script
├── uninstall.sh          # Cleanup on removal
├── module.prop           # Module metadata
└── updateJson.json       # Magisk update channel
```

---

## 功能特性

- **系统级服务** — 以 Magisk 模块运行，开机自启动
- **ARM64 支持** — aarch64 架构包通过 GitHub Actions 构建
- **上游自动追踪** — 每 6 小时自动同步 [zeroclaw-labs/zeroclaw](https://github.com/zeroclaw-labs/zeroclaw) 的新版本
- **WebUI 聊天** — 内置 Web 界面，访问 `http://127.0.0.1:42617/`
- **低资源占用** — RAM <20MB，基础占用 <5MB

### 工作原理

本模块**不从源码编译**。CI 工作流程：

1. 轮询 [zeroclaw-labs/zeroclaw](https://github.com/zeroclaw-labs/zeroclaw) 获取新版本
2. 下载预编译的 `zeroclaw` 二进制文件（ARM64）
3. 打包为 Magisk 兼容的 zip 模块
4. 发布 GitHub Release 并附带校验和

核心引擎 `zeroclaw` 是一个面向资源受限环境的自主 AI 助手运行时。

### 安装

1. 从 [Releases](https://github.com/aiguozhi123456/zeroclaw-magisk/releases) 下载 ARM64 zip
2. 通过 Magisk / KernelSU / APatch 安装
3. 重启设备，服务自动启动

### 使用方法

```bash
cd /data/adb/modules/zeroclaw

./tool.sh start     # 启动
./tool.sh stop      # 停止
./tool.sh restart   # 重启
./tool.sh status    # 查看状态

./tool.sh           # 交互模式
```

启动后访问 `http://127.0.0.1:42617/` 即可使用 Web 界面。

---

## License

This module packages binaries from [zeroclaw-labs/zeroclaw](https://github.com/zeroclaw-labs/zeroclaw).  
Module scripts and CI configuration are maintained by [wuyiyi](https://github.com/aiguozhi123456).
