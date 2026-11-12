#!/bin/bash
# UFI001C 现场诊断 v2：进 CI 后由 workflow 「现场诊断采集」步骤调用。
# 输出全部进 Actions 日志，不挂起、不依赖外部中继。
set +e
cd "$(dirname "$0")/../openwrt" 2>/dev/null || cd /workdir/openwrt
PIN=tmp/.packageinfo; IN=tmp/.config-package.in

DROP="ttyd luci-app-ttyd luci-theme-argon zerotier luci-app-zerotier cloudflared luci-app-cloudflared luci-app-fileassistant curl wget-ssl bash jq libuv libwebsockets-full libminiupnpc libnatpmp libnghttp2"
KEEP="cgi-io libqmi libmbim glib2 libdbus libudev-zero luci-base libexpat libattr libconfig coreutils"

state_of(){
  local p="$1"
  if grep -q "^CONFIG_PACKAGE_${p}=y" .config; then echo y
  elif grep -q "^# CONFIG_PACKAGE_${p} is not set" .config; then echo OFF
  else echo NONE; fi
}

echo "================ 0. 全局架构/工具链 ================"
grep -E '^CONFIG_(TARGET_BOARD|TARGET_SUBTARGET|TARGET_PROFILE|TARGET_ARCH_PACKAGES|ARCH|ARCH_64BIT|USE_MUSL|LIBC|LINUX_6)' .config

echo
echo "================ 1. feeds.conf.default 与各 feed 链接计数 ================"
cat feeds.conf.default 2>/dev/null
for f in openstick packages luci routing telephony video smpackage store; do
  if [ -d "feeds/$f" ]; then
    echo "  feed $f: $(ls -1 feeds/$f 2>/dev/null | wc -l) 项, package/feeds 链接 $(find package/feeds/$f -maxdepth 2 -type l 2>/dev/null | wc -l)"
  fi
done

echo
echo "================ 2. 目标包：真实路径 / Makefile DEPENDS 逐依赖状态（找链条断点）================"
for p in $DROP; do
  link=$(find package/feeds -maxdepth 3 -name "$p" -type l 2>/dev/null | head -1)
  real=$( [ -n "$link" ] && readlink -f "$link" )
  st=$(state_of "$p")
  echo "--- $p [$st]  link=${link:-<无链接>}"
  [ -n "$real" ] && echo "    real: $real"
  mf="${real}/Makefile"
  if [ -f "$mf" ]; then
    deps=$(grep -hE '^\s*DEPENDS' "$mf" | sed -E 's/^\s*DEPENDS(:=|\+=)//' | tr '\n' ' ')
    echo "    DEPENDS(raw): $deps"
    for tok in $deps; do
      tok=${tok#+}
      cond=""; dep="$tok"
      case "$tok" in *:*) cond=${tok%%:*}; dep=${tok#*:};; esac
      [ -z "$dep" ] && continue
      [ "$dep" = "libc" ] && continue
      dst=$(state_of "$dep")
      flag=""; [ "$dst" != "y" ] && flag="   <<< 断点"
      echo "      dep $dep [$dst]${cond:+  cond=$cond}$flag"
    done
  else
    echo "    Makefile: 缺失"
  fi
done

echo
echo "================ 3. .in 符号块是否存在 ================"
for p in $DROP; do
  ln=$(grep -nE "^[[:space:]]*config PACKAGE_${p}\$" "$IN" | head -1 | cut -d: -f1)
  echo "--- $p  in行=${ln:-无}"
done

echo
echo "================ 4. DUMP=1 完整原始输出（前 20 行，不过滤）================"
for p in $DROP; do
  link=$(find package/feeds -maxdepth 3 -name "$p" -type l 2>/dev/null | head -1)
  if [ -z "$link" ]; then echo "=== $p: 无 package/feeds 链接, 跳过"; continue; fi
  real=$(readlink -f "$link")
  echo "=== $p  ($real)"
  ( cd "$real" && make DUMP=1 2>&1 | head -20 )
  echo "    (DUMP 结束)"
done

echo
echo "================ 5. .packageinfo 按真实 Source-Makefile 反查 ================"
for p in $DROP; do
  link=$(find package/feeds -maxdepth 3 -name "$p" -type l 2>/dev/null | head -1)
  [ -z "$link" ] && { echo "--- $p 无链接"; continue; }
  real=$(readlink -f "$link"); rel=${real#$PWD/}
  echo "--- $p  Source=$rel"
  awk -v S="$rel" '$0=="Source-Makefile: "S{f=1;next} /^Package: /{f=0} f&&/^(Arch|Default|Section|Provides|Conflicts|Repository): /{print "    "$0}' "$PIN"
done

echo
echo "================ 6. 保住基线包状态对照 ================"
for p in $KEEP; do
  echo "--- $p [$(state_of "$p")]"
done

echo
echo "================ 7. 种子原始行核对 ================"
SEED="$GITHUB_WORKSPACE/ufi001c/config.lean"
echo "SEED=$SEED"
for p in $DROP; do grep -q "CONFIG_PACKAGE_$p=y" "$SEED" && echo "  种子有 $p"; done
