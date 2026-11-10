# UFI001C · ImmortalWrt 云编译套件

针对 **高通410（MSM8916）随身WiFi UFI001C**，源码用 <https://github.com/lkiuyu/immortalwrt>（master，自带 `target/linux/msm89xx/msm8916`）。

两条硬要求都已做进构建里：

- **不带任何短信转发组件**（`DbusSmsForward*` / `smstools3` / `sms-tool` 等）
- **驱动层禁用 WiFi 40MHz**，BSS 宽度锁死 20MHz（802.11n MCS0-7 @20MHz 保留）

## 文件

```
.github/workflows/ufi001c-immortalwrt.yml   ← Action 主文件
ufi001c/config.lean      精简种子配置（默认）：只显式列机型 + 基础 + 4G 基带 + 少量小工具
ufi001c/config.full      社区实测完整配置：所有选项展开钉死；同样不含短信转发
ufi001c/patches/010-wcn36xx-ht20-only.patch  ← 禁 40MHz 的内核补丁
ufi001c/files/etc/uci-defaults/99-ht20-default ← 首启把 htmode 钉成 HT20（第二层保险）
ufi001c/diy-part1.sh     feeds 处理（默认只用官方 feed + openstick feed）
ufi001c/diy-part2.sh     机型兜底 + 屏蔽短信转发 + 安装补丁 + openstick-tweaks 笔误补偿
```

## 用法 A：fork 他的 immortalwrt（推荐）

```bash
git clone --depth 1 https://github.com/<你的用户名>/immortalwrt && cd immortalwrt
git remote add up https://github.com/lkiuyu/immortalwrt && git fetch --depth 1 up master
git checkout -b my-ufi001c up/master          # 基于最新源码，避开 fork 里落后的 master
# 把本套件的 .github/ 和 ufi001c/ 两个目录拷进来
git add -A && git commit -m "ufi001c kit: no sms forward, no 40MHz" && git push -u origin my-ufi001c
```

然后仓库 **Actions** → **Build ImmortalWrt · UFI001C** → **Run workflow** → 选 `lean` / `full`。

## 产物

Artifacts：`ImmortalWrt_ufi001c_<variant>_<时间戳>`，含 `boot.img`、`system.img`、`sha256sums`、`.manifest`、`config.used`。
