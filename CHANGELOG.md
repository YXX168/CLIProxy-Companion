# Changelog

此文件从首个正式版本开始记录发布变化。

## [1.1.0] - 2026-07-19

### Changed

- 在 v0.6.2 视觉基线上加入低饱和青、紫、洋红极光雾化背景与轻微暗角。
- 为请求曲线和失败节点增加克制的柔光层，保留原有线型和信息层级。
- 账号卡片增加轻量按压反馈，控制台卡片进入详情页时使用 Hero 转场。
- 新增首页、控制台账号卡片和能量核心账号卡片的视觉回归基准。

### Quality

- 固定 420 × 960 手机画布进行视觉回归，防止背景或渐变再次压过内容。

## [1.0.1] - 2026-07-19

### Changed

- 恢复 v0.6.2 的原始背景、卡片、图标和状态区域视觉设计。
- 移除 v1.0.0 新增的氛围网格、斜向光束、粒子和重渐变效果。
- 保留 `CLIProxy` 安装名称与 v1 正式发布体系。

## [1.0.0] - 2026-07-18

### 正式发布

- CLIProxy Android 仪表盘进入正式维护阶段。
- 支持 Codex OAuth 账号状态、额度窗口、重置时间和请求活动展示。
- 提供深海控制台与能量核心两种视觉模式。
- 完成暗色霓虹玻璃拟态、氛围网格、状态光效与加载动效的视觉收口。
- 安装后的应用名称精简为 `CLIProxy`。
- Management API 地址和管理密钥保存在 Android 安全存储中。
- 提供 ARM64 APK 与 SHA-256 完整性校验文件。

[1.0.0]: https://github.com/YXX168/CLIProxy-Companion/releases/tag/v1.0.0
[1.0.1]: https://github.com/YXX168/CLIProxy-Companion/releases/tag/v1.0.1
[1.1.0]: https://github.com/YXX168/CLIProxy-Companion/releases/tag/v1.1.0
