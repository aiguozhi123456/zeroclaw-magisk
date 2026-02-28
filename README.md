# ZeroClaw Magisk Module

快速、小巧、完全自主的 AI 助手基础设施。在 Android 设备上运行，RAM 消耗 <20MB，支持 WebUI 聊天界面。

## 功能特性

- 轻量级 AI 助手服务，可在 Android 设备上运行
- RAM 占用 <5MB
- 提供 WebUI 聊天界面（端口 42617）
- 支持开机自启动
- 通过 Magisk 模块方式安装

## 安装

1. 在 Magisk/KernelSU 中下载并安装本模块
2. 重启设备
3. 模块将在开机后自动启动服务

## 使用方法

通过 Magisk 模块目录中的 `tool.sh` 脚本控制服务：

```bash
# 进入模块目录
cd /data/adb/modules/zeroclaw

# 启动服务
./tool.sh start

# 停止服务
./tool.sh stop

# 重启服务
./tool.sh restart

# 查看状态
./tool.sh status
```

或使用交互模式：

```bash
./tool.sh
```

## Web 界面

服务启动后，访问以下地址进入管理界面：

```
http://127.0.0.1:42617/
```

## 文件结构

```
zeroclaw/
├── bin/                    # 二进制程序
│   └── zeroclaw           # AI 助手主程序
├── webroot/               # Web 界面资源
│   └── index.html         # 引导页面
├── META-INF/              # Magisk 安装脚本
│   ├── update-binary
│   └── updater-script
├── customize.sh           # 模块安装脚本
├── service.sh            # 开机启动服务脚本
├── tool.sh               # 控制工具脚本
├── action.sh             # 动作脚本
├── module.prop           # 模块信息
└── updateJson.json       # 更新配置
```

## 文件结构
