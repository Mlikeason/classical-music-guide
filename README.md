# 古典指南 · Classical Guide

中文古典音乐入门 App：28 首作品、5 段学习路径、20 位作曲家。基于原静态网页，以 SwiftUI 实现原生 iPhone / iPad 体验。

## 运行

打开 `ios/ClassicalGuide.xcodeproj`，选择 `ClassicalGuide` scheme 与一个 iOS 模拟器，Run。最低支持 iOS / iPadOS 17，无第三方依赖，无需安装包管理器。

真机运行时，在 Signing & Capabilities 中选择自己的 Apple Developer Team。当前验证使用开发团队 `KW9NTQUH4T`，Bundle ID 为 `me.zhuhong.classicalguide`。个人 Apple 登录邮箱、密码和私钥不在仓库中。

```sh
xcodebuild -project ios/ClassicalGuide.xcodeproj -scheme ClassicalGuide \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_UDID>' \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO test
```

项目文件已提交。增减 Swift 源文件后，可用 `python3 scripts/generate-xcode-project.py` 重新生成项目与共享 scheme；生成器不需要 XcodeGen。

App 图标沿用原项目的 `apple-touch-icon.png`（红底白色三行乐谱）。使用 `sh scripts/prepare-app-icon.sh` 可将原图导出为 iOS 所需的 1024×1024 不透明 PNG，保留原有配色与构图。仓库现有源图为 180×180，放大不会增加原图细节；后续如有更高分辨率原稿，可替换源图后重新导出。

支持、隐私和内容版权页在 `website/classical-guide/` 维护。运行 `python3 scripts/sync-support-website.py /path/to/Web-V2` 同步到 Web V2 的 `classical-guide/` 子目录，并追加该目录的 Vercel 上传规则。App 的设置入口分别指向 `https://zhuhong.me/classical-guide/`、`privacy/` 与 `credits/`；这些页面在浏览器打开，需要联网。部署时应基于线上最新文件，仅更新该子目录，以保留其他 App 的页面。

## 已实现

- 原生学习路径、下一首推荐、按阶段进度；全部内容离线可读。
- 中文／英文／演奏者多关键词搜索，作曲家与时长筛选、未听筛选。
- 作品导览、每首三条聆听提示、作曲家介绍、版本探索、速度术语手册。
- 收藏、已听、完成日期、最近浏览、个人笔记；应用重启后保留。
- JSON 备份导出与合并导入、文件大小与内容校验、损坏数据保护、清除确认。
- 通过 HTTPS 跳转 Apple Music 搜索，不内置录音或下载服务。
- 系统分享、深色模式、动态字体、VoiceOver 标签与原生导航。
- App 图标、隐私清单、中文商店文案与官网支持／隐私页面源文件。

## 目录

| 路径 | 用途 |
| --- | --- |
| `index.html`、`classical-music-guide-images/` | 完整保留的原网页及图片 |
| `ios/ClassicalGuide/Models/` | 可校验的曲库、稳定 ID、学习记录与备份 |
| `ios/ClassicalGuide/Views/` | SwiftUI 页面 |
| `ios/ClassicalGuide/Resources/catalog.json` | 原生 App 的内容源 |
| `ios/ClassicalGuideTests/` | 数据与持久化测试 |
| `ios/ClassicalGuideUITests/` | 搜索、收藏、笔记、重启恢复及阅读布局测试 |
| `website/classical-guide/` | 供 zhuhong.me 部署的支持页与隐私页 |
| `docs/REVIEW.md` | 原项目审查与改造说明 |
| `docs/RELEASE.md` | 发布状态、签名与上架步骤 |
| `docs/app-store-zh-Hans.txt` | 可填写到 App Store Connect 的文案草稿 |

## 内容维护

编辑 `catalog.json`。每首作品的 `id` 是持久化主键，发布后不得重用或随排序改变；增加曲目时保持唯一 ID、合法的 `composerID` / `stageID`、正数时长和聆听提示。备份含 schemaVersion，未来改变格式需要迁移器。

`scripts/import-original-catalog.mjs` 和 `scripts/enrich-catalog.py` 记录初次迁移过程，重新运行会覆盖现有曲库，日常编辑无需运行。`legacyID` 保存原网页 t1…t28 的对应关系；App 不会读取或自动迁移 Safari 的 localStorage。

App 使用独立绘制的字母与线条图形。原网页的肖像无来源／许可记录，保留在仓库中但未打包到 iOS。新增录音、图片、谱例或专辑封面前，请记录具体来源和适用许可。

开发者：Zhu Hong · 支持：zivzhu@gmail.com · 官网：https://zhuhong.me
