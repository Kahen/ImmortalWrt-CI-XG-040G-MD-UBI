# ImmortalWrt-CI-XG-040G-MD-UBI

简体中文 | [English](README.md)

为 **Nokia XG-040G-MD** 云编译的 ImmortalWrt 固件，目标为 **Airoha AN7581 all-in-UBI 布局**。

本项目适用于已经迁移到主线/OpenWrt U-Boot UBI 布局的 XG-040G-MD，例如已经完整执行 **MedveFlasher** 安装流程的设备。

## 编译目标

- 源码：`immortalwrt/immortalwrt`
- 分支：`master`
- Target：`airoha`
- Subtarget：`an7581`
- Device：`nokia_xg-040g-md-ubi`
- 正常升级镜像：`*-nokia_xg-040g-md-ubi-squashfs-sysupgrade.itb`

ImmortalWrt 中这个设备被定义为 UBI 版本，Kernel 和 U-Boot environment 都按 UBI 架构管理，日常系统升级使用 `sysupgrade.itb`。

## 重要安全提示

本仓库生成的固件 **只适用于 `nokia_xg-040g-md-ubi` 布局**。

以下情况不要直接刷本项目生成的 `.itb`：

- 完全原厂 Nokia 固件；
- 旧的 `nokia_xg-040g-md` 非 UBI 布局；
- 尚未迁移成 `nokia_xg-040g-md-ubi` 的 tcboot / factory 布局；
- 无法确认当前 board/layout 的设备。

正常系统升级时，不要使用 `mtd write` 强行写入本项目生成的 sysupgrade 镜像，也不要重复覆盖 BL2、FIP、preloader。

# MedveFlasher 刷完后，怎么刷本项目固件

如果 MedveFlasher 已经完整执行成功，设备本身已经拥有可启动的 permanent OpenWrt 和 all-in-UBI 布局。

此后刷本项目固件属于 **普通 sysupgrade**，不需要再次刷 U-Boot，也不需要重新跑 MedveFlasher。

## 1. 先确认已经是 UBI 布局

SSH 登录路由器：

```sh
ssh root@192.168.1.1
```

运行：

```sh
ubus call system board
```

确认设备是 XG-040G-MD 的 **UBI variant**，board name 应对应：

```text
nokia,xg-040g-md-ubi
```

建议再看一下：

```sh
cat /proc/mtd
ubinfo -a
```

如果仍然显示旧的非 UBI profile，或者无法确认当前分区架构，**不要继续刷这个 `.itb`**。

## 2. 下载 GitHub Actions 编译产物

进入本仓库的 **Actions** 页面，打开成功完成的：

```text
Build ImmortalWrt XG-040G-MD UBI
```

在页面底部下载 Artifact：

```text
ImmortalWrt-XG-040G-MD-UBI
```

解压后应看到类似：

```text
immortalwrt-airoha-an7581-nokia_xg-040g-md-ubi-squashfs-sysupgrade.itb
```

以及：

```text
SHA256SUMS
```

建议先在电脑上核对 SHA256，再上传到路由器。

## 3. 上传固件到 `/tmp`

例如：

```sh
scp immortalwrt-*-nokia_xg-040g-md-ubi-squashfs-sysupgrade.itb \
  root@192.168.1.1:/tmp/firmware.itb
```

然后 SSH 登录：

```sh
ssh root@192.168.1.1
```

## 4. 刷之前先做镜像兼容性检查

先运行：

```sh
sysupgrade -T /tmp/firmware.itb
```

只有在检查通过后才继续。

如果这里提示设备不匹配、镜像不兼容或校验失败，**停止操作，不要使用 force 强刷**。

## 5. 第一次从 MedveFlasher 自带系统切换到本项目 ImmortalWrt

第一次建议不保留配置：

```sh
sysupgrade -v -n /tmp/firmware.itb
```

参数说明：

```text
-v   输出详细升级日志
-n   不保留当前配置
```

之所以第一次推荐 `-n`，是因为 MedveFlasher 自带的 permanent OpenWrt 与本项目的 ImmortalWrt 属于不同构建来源，干净升级可以避免旧配置、旧 package 状态带来的兼容问题。

执行后设备会自动写入固件并重启。

**升级过程中不要断电。**

## 6. 以后使用本项目生成的新版本升级

如果以后一直使用本仓库的 CI 固件，通常可以保留配置：

```sh
sysupgrade -v /tmp/firmware.itb
```

以下情况仍建议用 `-n` 做干净升级：

- ImmortalWrt 出现较大的版本/架构变化；
- 大规模修改 package 集合；
- 从其他固件项目切回本项目；
- 出现无法解释的网络、LuCI、overlay 或 package 异常。

# 不要刷错文件

日常升级应该使用：

```text
*-nokia_xg-040g-md-ubi-squashfs-sysupgrade.itb
```

不要把以下文件当普通系统升级包使用：

```text
preloader.bin
bl31-uboot.fip
recovery.itb
factory.bin
其他非 UBI profile 的 sysupgrade.bin
```

对于已经经过 MedveFlasher 迁移完成的设备，平时只需要维护 `sysupgrade.itb`，不要反复重刷底层 Bootloader。

# 云编译

进入：

```text
Actions
→ Build ImmortalWrt XG-040G-MD UBI
→ Run workflow
```

CI 会自动完成：

1. 拉取最新 ImmortalWrt `master`；
2. 更新并安装 feeds；
3. 应用 `config/xg040g-md-ubi.config`；
4. 执行 `make defconfig`；
5. 完整编译固件；
6. 只收集 XG-040G-MD UBI 的 `sysupgrade.itb` 和 SHA256 校验文件。

# 项目结构

```text
.github/workflows/build.yml
config/xg040g-md-ubi.config
scripts/customize.sh
README.md
README_CN.md
```

# 自定义固件

普通 package 建议直接加入：

```text
config/xg040g-md-ubi.config
```

需要修改源码树、增加第三方 feed、应用 patch、修改默认设置时，可以放到：

```text
scripts/customize.sh
```

当前第一版有意尽量贴近 ImmortalWrt 上游，先验证 XG-040G-MD UBI、NAND 和长期运行稳定性，再逐步加入 OpenClash、HomeProxy、主题、Samba 等第三方组件。

# 相关项目

- ImmortalWrt: https://github.com/immortalwrt/immortalwrt
- MedveFlasher: https://github.com/Medvedolog/nokia-router-medveflasher

# 风险说明

刷写路由器固件始终存在数据丢失或设备无法启动的风险。

在修改 NAND 布局或 Bootloader 前，请保留经过校验的本机完整备份。设备相关的 RI、BOSA、MAC、序列号等数据不要与另一台 XG-040G-MD 混用。