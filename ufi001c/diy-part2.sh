#!/bin/bash
set -u

# 1) 排除短信转发
for p in DbusSmsForwardCPlus DbusSmsForward smsmanager smstools3 sms-tool; do
  echo "# CONFIG_PACKAGE_${p} is not set" >> .config
done

# 2) openstick-tweaks 笔误修正
grep -q '^CONFIG_PACKAGE_openstick-tweaks=y$' .config || echo 'CONFIG_PACKAGE_openstick-tweaks=y' >> .config

# 3) 安装40MHz补丁
#    关键：wcn36xx.ko 由 mac80211 backports 包编译，补丁必须打进
#    package/kernel/mac80211/patches/ath/ 才会作用于实际固件；
#    另拷一份到 target/linux/msm89xx/patches-* 作为内核树备份。
PATCH_SRC_DIR="${HT20_PATCH_DIR:-patches-ht20}"
if [ -d "$PATCH_SRC_DIR" ]; then
  mkdir -p package/kernel/mac80211/patches/ath
  cp "$PATCH_SRC_DIR"/*.patch package/kernel/mac80211/patches/ath/ 2>/dev/null || true
  for d in target/linux/msm89xx/patches-*; do
    [ -d "$d" ] && cp "$PATCH_SRC_DIR"/*.patch "$d/" 2>/dev/null || true
  done
  echo "补丁已安装到 backports patches/ath 与内核 patches-*"
fi

# 4) uci-defaults
[ -f files/etc/uci-defaults/99-ht20-default ] && chmod +x files/etc/uci-defaults/99-ht20-default
