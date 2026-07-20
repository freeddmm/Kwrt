#!/bin/bash

SHELL_FOLDER=$(dirname $(readlink -f "$0"))

# ===========================
# 1. 编译优化
# ===========================
sed -i 's/Os/O2/g' include/target.mk

# ===========================
# 2. 引入 Lede 的 x86 补丁
# ===========================
git_clone_path master https://github.com/coolsnowwolf/lede \
    target/linux/x86/files \
    target/linux/x86/patches-6.12

# ===========================
# 3. 扩展默认包（保持你的原样）
# ===========================
sed -i 's/DEFAULT_PACKAGES +=/DEFAULT_PACKAGES += kmod-fs-f2fs kmod-mmc kmod-sdhci kmod-usb-hid amd64-microcode intel-microcode usbutils pciutils lm-sensors-detect kmod-alx kmod-vmxnet3 kmod-igbvf kmod-iavf kmod-bnx2x kmod-pcnet32 kmod-tulip kmod-r8125 kmod-r8126 kmod-r8101 kmod-8139cp kmod-8139too kmod-i40e kmod-i40evf kmod-mlx4-core kmod-mlx5-core fdisk lsblk/' \
    target/linux/x86/Makefile

# ===========================
# 4. 强制使用 r8168 驱动
# ===========================
sed -i 's/kmod-r8169/kmod-r8168/' target/linux/x86/image/generic.mk

# ===========================
# 5. 扩容 rootfs 分区到 1024MB
# ===========================
sed -i 's/256/1024/g' target/linux/x86/image/Makefile

# ===========================
# 6. 修改设备型号（保持你的原样）
# ===========================
sed -i "s/DEVICE_MODEL := x86/DEVICE_MODEL := x86\/32/" \
    target/linux/x86/image/generic.mk

# ===========================
# 7. 删除不需要的网卡驱动（最优版）
# ===========================
REMOVE_PKGS="
kmod-e1000 kmod-e1000e kmod-igb kmod-igc kmod-i40e kmod-ixgbe kmod-ixgbevf
kmod-dwmac-intel kmod-bnx2 kmod-bnx2x kmod-phy-broadcom kmod-mlx4-core kmod-mlx5-core
kmod-vmxnet3 kmod-amazon-ena kmod-atlantic kmod-amd-xgbe
kmod-r8101 kmod-r8125 kmod-r8126 kmod-rtl8150 kmod-8139cp kmod-8139too
kmod-forcedeth kmod-tulip kmod-pcnet32 kmod-tg3
kmod-usb-net-aqc111 kmod-usb-net-asix kmod-usb-net-cdc-ncm kmod-usb-net-huawei-cdc-ncm
kmod-usb-net-rndis kmod-usb-net-lan78xx kmod-usb-net-smsc95xx kmod-usb-net-smsc75xx
kmod-usb-net-sr9700 kmod-usb-net-pegasus kmod-usb-net-kaweth kmod-usb-net-mcs7830
kmod-usb-net-sierrawireless
"

for pkg in $REMOVE_PKGS; do
    sed -i "/$pkg/d" .config
done

# 保留你的设备需要的驱动：
# kmod-r8168（PCIe）
# kmod-usb-net-asix-ax88179（USB）
