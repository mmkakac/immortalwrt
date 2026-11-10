# UFI001C · ImmortalWrt 云编译套件

针对 **高通410（MSM8916）随身WiFi UFI001C**，源码用 <https://github.com/lkiuyu/immortalwrt>。

两条硬要求：
- 不带任何短信转发组件
- 驱动层禁用 WiFi 40MHz（锁死 20MHz）

## lean vs full

| | lean（默认） | full |
|---|---|---|
| 写法 | 种子配置，57个包 | 完整展开，8186行、225包 |
| 内核 | 6.1 | 6.12 |
| 适合 | 首次编译、快、小 | 社区验证过的固定配置 |

两边都不含短信转发，都会装禁40MHz补丁。
