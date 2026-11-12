#!/bin/bash
# 进 tmate 容器后执行（在 openwrt 源码根目录）。
# 用法: bash ufi001c/debug-inspect.sh
set +e
cd "$(dirname "$0")/../openwrt" 2>/dev/null || cd /workdir/openwrt
PIN=tmp/.packageinfo; IN=tmp/.config-package.in

echo "================ 0. 全局架构/工具链 ================"
grep -E '^CONFIG_(TARGET_BOARD|TARGET_SUBTARGET|TARGET_PROFILE|TARGET_ARCH_PACKAGES|ARCH|ARCH_64BIT|USE_MUSL|LIBC|LINUX_6)' .config

DROP="ttyd luci-app-ttyd luci-theme-argon zerotier luci-app-zerotier cloudflared luci-app-cloudflared luci-app-fileassistant curl wget-ssl bash jq libuv libwebsockets-full libminiupnpc libnatpmp libnghttp2"
KEEP="cgi-io libqmi libmbim glib2 libdbus libudev-zero luci-base libexpat libattr libconfig coreutils"

echo
echo "================ 1. 被摘包：.config 原始行 / Arch / Repository / Depends ================"
for p in $DROP; do
  echo "--- $p"
  grep -nE "^(# )?CONFIG_PACKAGE_$p(=y|=m| is not set)" .config | head -2
  awk -v P="Package: $p" '
    $0==P{f=1;next} /^Package: /{f=0}
    f&&/^(Arch|Repository|Depends|Source-Makefile|Default|Section): /{print "    "$0}' "$PIN"
done

echo
echo "================ 2. 保住基线包对照（Arch / Repository / Source-Makefile）================"
for p in $KEEP; do
  echo "--- $p"
  awk -v P="Package: $p" '
    $0==P{f=1;next} /^Package: /{f=0}
    f&&/^(Arch|Repository|Depends|Source-Makefile): /{print "    "$0}' "$PIN"
done

echo
echo "================ 3. .in 符号块是否存在 / 外层 depends ================"
for p in $DROP; do
  ln=$(grep -nE "^[[:space:]]*config PACKAGE_${p}\$" "$IN" | head -1 | cut -d: -f1)
  echo "--- $p  in行=${ln:-无}"
  [ -n "$ln" ] && sed -n "${ln},$((ln+10))p" "$IN" | sed 's/^/    /'
done

echo
echo "================ 4. package/feeds 链接是否存在、指向哪里 ================"
for p in $DROP; do
  link=$(find package/feeds -maxdepth 3 -name "$p" -type l 2>/dev/null | head -1)
  echo "--- $p -> ${link:-<无链接>}"
  [ -n "$link" ] && readlink -f "$link"
done

echo
echo "================ 5. 直接 DUMP=1 抽元数据（看是否报错/Arch 判定）================"
for d in packages/utils/ttyd packages/net/zerotier packages/net/cloudflared packages/net/curl packages/utils/bash packages/utils/jq packages/libs/libuv; do
  echo "=== feeds/$d"
  make -C "feeds/$d" DUMP=1 FEED=packages 2>&1 | grep -E '^(Package|Arch|Depends|Category|Submenu|ERROR|Error|WARNING|broken)' | head -12
done

echo
echo "================ 6. 架构不匹配线索：被摘包 Arch 与 TARGET_ARCH_PACKAGES 比对 ================"
APKG=$(grep '^CONFIG_TARGET_ARCH_PACKAGES=' .config | cut -d'"' -f2)
echo "TARGET_ARCH_PACKAGES=$APKG"
for p in $DROP; do
  arch=$(awk -v P="Package: $p" '$0==P{f=1;next} /^Package: /{f=0} f&&/^Arch: /{print $2}' "$PIN")
  echo "  $p Arch=[$arch]"
done

echo
echo "================ 7. 种子原始行是否还在 .config 里 ================"
SEED="$GITHUB_WORKSPACE/ufi001c/config.lean"
echo "SEED=$SEED"
for p in $DROP; do
  grep -q "CONFIG_PACKAGE_$p=y" "$SEED" && echo "  种子有 $p"
done
