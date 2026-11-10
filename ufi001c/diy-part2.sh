#!/bin/bash
# diy-part2.sh —— 在 ./scripts/feeds install 之后、make defconfig 之前执行
set -u

# 1) 排除短信转发组件
for p in \
  DbusSmsForwardCPlus DbusSmsForward smsmanager \
  smstools3 sms-tool luci-app-sms-tool-js luci-app-smstools3 \
  luci-app-smsforward luci-app-smsmodem
do
  sed -i -E "s|^CONFIG_PACKAGE_${p}=y$|# CONFIG_PACKAGE_${p} is not set|" .config 2>/dev/null || true
  grep -q "^# CONFIG_PACKAGE_${p} is not set$" .config || echo "# CONFIG_PACKAGE_${p} is not set" >> .config
done
echo "[diy2] 已排除短信转发组件"

# 2) 机型兜底：确保选中的是 ufi001c
if ! grep -q '^CONFIG_TARGET_msm89xx_msm8916_DEVICE_openstick-ufi001c=y$' .config; then
  echo "[diy2] 修正机型为 openstick-ufi001c"
  {
    echo "CONFIG_TARGET_msm89xx=y"
    echo "CONFIG_TARGET_msm89xx_msm8916=y"
    echo "CONFIG_TARGET_msm89xx_msm8916_DEVICE_openstick-ufi001c=y"
    echo 'CONFIG_TARGET_PROFILE="DEVICE_openstick-ufi001c"'
  } >> .config
fi

# 3) 补上 openstick-tweaks（源码里 DEVICE_PACKAGES 写成了 openstick_tweaks 下划线笔误）
grep -q '^CONFIG_PACKAGE_openstick-tweaks=y$' .config || echo 'CONFIG_PACKAGE_openstick-tweaks=y' >> .config
echo "[diy2] openstick-tweaks 已启用"

# 4) 40MHz 禁用补丁：装进 msm89xx 的所有 patches-* 目录
KSRC_DIR="target/linux/msm89xx"
PATCH_SRC_DIR="${HT20_PATCH_DIR:-patches-ht20}"
if [ -d "$PATCH_SRC_DIR" ]; then
  installed=""
  for d in "$KSRC_DIR"/patches-*; do
    [ -d "$d" ] || continue
    for pf in "$PATCH_SRC_DIR"/*.patch; do
      [ -f "$pf" ] || continue
      base="$(basename "$pf")"
      cp "$pf" "$d/$base"
      installed="$installed $(basename "$d")/$base"
    done
  done
  if [ -n "$installed" ]; then
    echo "[diy2] 已安装禁 40MHz 补丁:$installed"
  fi
else
  echo "[diy2] 未找到补丁目录"
fi

# 5) uci-defaults 覆盖层
if [ -f files/etc/uci-defaults/99-ht20-default ]; then
  chmod +x files/etc/uci-defaults/99-ht20-default
  echo "[diy2] 99-ht20-default 就绪"
fi
