# twrp-p80pro

TWRP 11 (Android 11) device tree for the droi **P80Pro+** clone phone
(MediaTek MT6768 `k69v1_64`, A/B slots, dynamic partitions).

一期目标：TWRP 能启动、能挂载 super 逻辑分区、能 adb sideload、能备份
boot/system；**不做 /data 解密（FBE）**。

## 目录

```
device/droi/p80pro/     TWRP 设备树
  prebuilt/kernel       gzip 内核（与 stock boot_a 相同）
  prebuilt/dtb          MTK dtb 容器（magic 0xd7b7ab1e）
  recovery.fstab        TWRP 挂载表（logical / A-B / emmc）
ci/build.sh             CI 内编译脚本（Ubuntu 20.04）
.github/workflows/      GitHub Actions 工作流
```

## 云端编译

1. 新建一个 GitHub 仓库，把本目录内容推上去（`prebuilt/kernel` 约 10 MB）。
2. 仓库 **Actions** 页运行 `Build TWRP boot image`（`workflow_dispatch`），
   或直接 push 到 `main`。
3. 构建完成后下载 artifact `twrp-p80pro-boot`，里面是 `boot.img`
   （本机是 recovery-as-boot，没有独立 recovery 分区，所以产物是 boot.img）。

首次构建包含 repo sync，约 1–2 小时；后续可用 Actions 缓存/重跑。

## 刷入

> 前提：vbmeta 校验已禁用（你已有的 `mtk-root-禁用校验/vbmeta*` 镜像）。

```bash
fastboot flash boot_a boot.img
fastboot reboot recovery
```

建议只刷 `boot_a`，保留 `boot_b`。若 TWRP 无法进入系统，可：

```bash
fastboot --set-active=b        # 用 b 槽的原始 boot 正常开机
# 或刷回可用的 stock/adb 授权 boot
fastboot flash boot_a boot_a_adbsec0_root.img
```

## 已知限制 / 可能需要微调

- `/data` 是 FBE 加密，本期不解密：TWRP 里 /data 不可用属预期。
- 显示：首版用 `TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"` +
  `TW_THEME := portrait_hdpi`。如果花屏/颜色反了，改 BoardConfig 里的
  pixel format（`BGRA_8888` / `ABGR_8888`）。
- 触摸：走内核 input 事件，若坐标不对需要加 `TW_INPUT_BLACKLIST` 或
  校准参数。
- 亮度节点按 MTK 常见路径
  `/sys/class/leds/lcd-backlight/brightness` 配置，若不存在改为
  `/sys/devices/platform/leds-mt65xx/leds/lcd-backlight/brightness`。
- recovery 内 adb 默认免授权：`ro.adb.secure=0`、`ro.debuggable=1`。

## 关键参数来源

从 stock `boot_a.bin` 解析：

| 项 | 值 |
| --- | --- |
| header version | 2 |
| page size | 2048 |
| kernel addr | 0x40080000 |
| ramdisk addr | 0x47c80000 |
| tags / dtb addr | 0x4bc80000 |
| dtb size | 100983 |
| boot 分区 | 32 MiB |

cmdline 保留 stock 的 `bootopt=64S3,32N2,64N2 ro.verified.status=verified
droi.magic=...`，构建时 AOSP 会追加 `buildvariant=eng`。