# =============================================================================
# UFI003 精简种子配置（lean）
# =============================================================================

# ---- 机型 ----
CONFIG_TARGET_msm89xx=y
CONFIG_TARGET_msm89xx_msm8916=y
CONFIG_TARGET_msm89xx_msm8916_DEVICE_openstick-ufi003=y
CONFIG_TARGET_BOARD="msm89xx"
CONFIG_TARGET_SUBTARGET="msm8916"
CONFIG_TARGET_PROFILE="DEVICE_openstick-ufi003"

# ---- 内核/镜像 ----
CONFIG_LINUX_6_1=y
CONFIG_TARGET_ROOTFS_EXT4FS=y
# 只产 ext4 镜像，不出 squashfs（内核侧 SQUASHFS 驱动本就未启用）
# CONFIG_TARGET_ROOTFS_SQUASHFS is not set
CONFIG_TARGET_EXT4_RESERVED_PCT=0
CONFIG_TARGET_EXT4_BLOCKSIZE_4K=y
CONFIG_TARGET_EXT4_BLOCKSIZE=4096
CONFIG_TARGET_EXT4_JOURNAL=y
CONFIG_TARGET_KERNEL_PARTSIZE=32
CONFIG_TARGET_ROOTFS_PARTSIZE=1024

# ---- 系统基础 ----
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y
CONFIG_LUCI_LANG_zh_Hans=y
CONFIG_PACKAGE_default-settings-chn=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-firewall=y
CONFIG_PACKAGE_luci-app-opkg=y
CONFIG_PACKAGE_luci-app-uhttpd=y
CONFIG_PACKAGE_ca-bundle=y
CONFIG_PACKAGE_ca-certificates=y
CONFIG_PACKAGE_dnsmasq-full=y
CONFIG_PACKAGE_firewall4=y
CONFIG_PACKAGE_ip-full=y
CONFIG_PACKAGE_cgi-io=y
CONFIG_PACKAGE_zram-swap=y
CONFIG_PACKAGE_opkg=y

# ---- 4G基带必需 ----
CONFIG_PACKAGE_openstick-tweaks=y
CONFIG_PACKAGE_modemmanager=y
CONFIG_PACKAGE_luci-proto-modemmanager=y
CONFIG_PACKAGE_qmi-utils=y
CONFIG_PACKAGE_libqmi=y
CONFIG_PACKAGE_libmbim=y
CONFIG_PACKAGE_libqrtr=y
CONFIG_PACKAGE_qrtr-ns=y
CONFIG_PACKAGE_rmtfs=y
CONFIG_PACKAGE_gc=y
CONFIG_PACKAGE_rootfs-resizer=y
CONFIG_PACKAGE_android-tools-adbd=y
CONFIG_PACKAGE_adb=y
CONFIG_PACKAGE_iwinfo=y
CONFIG_PACKAGE_wireless-regdb=y
CONFIG_PACKAGE_wpad-basic-wolfssl=y
CONFIG_PACKAGE_comgt=y
CONFIG_PACKAGE_chat=y
CONFIG_PACKAGE_ppp=y

# ---- 常用工具 ----
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_wget-ssl=y
CONFIG_PACKAGE_openssh-sftp-server=y
CONFIG_PACKAGE_bash=y
CONFIG_PACKAGE_nano-full=y
CONFIG_PACKAGE_tar=y
CONFIG_PACKAGE_unzip=y
CONFIG_PACKAGE_bzip2=y
CONFIG_PACKAGE_xz-utils=y
CONFIG_PACKAGE_jq=y
CONFIG_PACKAGE_file=y
CONFIG_PACKAGE_smartmontools=y
CONFIG_PACKAGE_tcping=y
CONFIG_PACKAGE_ttyd=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_watchcat=y
CONFIG_PACKAGE_luci-app-watchcat=y
CONFIG_PACKAGE_miniupnpd-nftables=y
CONFIG_PACKAGE_luci-app-upnp=y
CONFIG_PACKAGE_luci-app-cpu-status=y
CONFIG_PACKAGE_luci-app-temp-status=y
CONFIG_PACKAGE_zoneinfo-asia=y

# ---- 网络服务 / 应用 ----
# ZeroTier（后台 zerotier + LuCI；简中随 LUCI_LANG_zh_Hans 自动安装）
CONFIG_PACKAGE_zerotier=y
CONFIG_PACKAGE_luci-app-zerotier=y
# Cloudflared 隧道（后台 cloudflared + LuCI；简中随 LUCI_LANG_zh_Hans 自动安装）
CONFIG_PACKAGE_cloudflared=y
CONFIG_PACKAGE_luci-app-cloudflared=y
# 文件助手（第三方 feed: kenzok8/small-package，自带中文）
CONFIG_PACKAGE_luci-app-fileassistant=y

# ---- glib2 依赖（libffi 由套件补回源码树 package/libs/libffi）----
CONFIG_PACKAGE_libffi=y
CONFIG_PACKAGE_libpcre2=y

# ---- 底层依赖钉选（这些库自身默认关闭，仅靠上层 select 易在 defconfig 时被连带摘除，显式钉选）----
# ttyd 依赖
CONFIG_PACKAGE_libcap=y
CONFIG_PACKAGE_libuv=y
CONFIG_PACKAGE_libwebsockets-full=y
# bash 依赖
CONFIG_PACKAGE_libncurses=y
CONFIG_PACKAGE_libreadline=y
CONFIG_PACKAGE_terminfo=y
# curl 依赖
CONFIG_PACKAGE_libcurl=y
CONFIG_PACKAGE_libnghttp2=y
# zerotier 依赖
CONFIG_PACKAGE_libstdcpp=y
CONFIG_PACKAGE_kmod-tun=y
CONFIG_PACKAGE_libminiupnpc=y
CONFIG_PACKAGE_libnatpmp=y
CONFIG_PACKAGE_libatomic=y
# argon 主题依赖
CONFIG_PACKAGE_ucode-mod-math=y

# ---- 关闭短信转发 ----
# CONFIG_PACKAGE_smstools3 is not set
# CONFIG_PACKAGE_sms-tool is not set
