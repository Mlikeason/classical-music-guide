# 发布交付记录

日期：2026-11-08。产品：古典指南 1.0.0。开发者署名：Zhu Hong。支持邮箱：zivzhu@gmail.com。用户确认：免费、无广告、无内购；目标包含中国大陆的尽可能全球发行。

## 当前版本与图标

- Build 2 按用户要求改回原项目的红底白色三行乐谱图标，源文件为 `apple-touch-icon.png`。使用 `sh scripts/prepare-app-icon.sh` 导出 1024×1024 不透明 PNG，原图配色与构图保持不变。现有源图为 180×180，导出不会增加细节。
- Build 2 已通过 Release 真机构建，核对编译后的图标与版本信息，并成功覆盖安装、启动到 iPhone Duo。未卸载 App 或更改学习数据存储格式。
- Build 1 已完成 iPhone Duo 真机安装、启动与进程确认；包含旧图标的 Build 1 已上传 Apple，尚未提交审核。
- 下文 `ClassicalGuide-Final.xcarchive`、`AppStore-Final/ClassicalGuide.ipa` 与旧交付 ZIP 均对应 Build 1，不能用于发布本次图标修订。上架前必须上传并选用 Build 2 或后续版本。

## 构建与验证

- Xcode 27.2 (27B52)，iOS 27.2 SDK；最低部署 iOS / iPadOS 17。
- Bundle ID：`me.zhuhong.classicalguide`，签名 Team：`KW9NTQUH4T`。使用本机匹配 Hong Zhu 的证书和已配置的 Xcode 开发者账号完成自动签名。
- 已完成 Debug 模拟器构建、Release 真机架构签名归档与 App Store 分发方式的 IPA 导出。
- iPhone 18 Pro / iOS 27.2：9 项单元测试 + 2 项完整界面流程测试通过。可审查结果：`build/Tests-SearchFix.xcresult`。
- 通过的 UI 流程：搜索空态与恢复；搜索 Moonlight → 作品 → 收藏 → 标记已听 → 写笔记 → 重启 → 我的笔记。
- 此后修正阶段分隔线与深色按钮文字，并增加阅读布局测试。本机回归因高负载、模拟器启动超时而中断；转由 GitHub Actions 完成。[运行 42463955865](https://github.com/Mlikeason/classical-music-guide/actions/runs/42463955865) 的 iPhone 17 Pro Max 和 iPad Pro 13-inch (M5) 两个任务全部成功：9 项单元测试、3 项 iPhone UI 测试、1 项 iPad 阅读测试，共 13 项。
- 最终 App 源码来自 `258c8d3`，后续提交仅更改测试、CI 与交付文档。[补充运行 42465859803](https://github.com/Mlikeason/classical-music-guide/actions/runs/42465859803) 的三个任务全部成功：9 项单元测试、3 项 iPhone UI 测试、1 项 iPad 阅读测试、1 项深色模式与最大辅助字号阅读测试，共 14 次测试执行。阅读测试验证滚动后能操作“已听”和“写笔记”，并能进入笔记编辑器与访问保存按钮。
- 已人工检查最大辅助字号下的深色首页、作品操作、笔记区域和编辑器截图：文字可换行、按钮可见，深色主按钮对比度正常。证据在 `build/ci-accessibility/Screenshots/`；这不是对所有页面或 VoiceOver 的完整无障碍审计。
- iOS 17 真机测试、VoiceOver 手动朗读验收尚未进行。
- 全部 28 条 Apple Music 搜索 URL 的 HTTP 请求经重定向后均返回 200，结果保存在 `build/music-link-check.json`。这不代表每个地区都存在推荐录音，也不代替真机外部 App 跳转与播放验收。
- HTML 本地链接、plist、工程格式与 Git 空白检查通过。官网配套页未完成浏览器预览或公开部署验证。
- App Store Connect 已创建“古典指南”（Apple ID `6832264137`），保存中文商店文案、审核联系人、音乐／教育分类与手动发布设置。Build 1 上传成功，Apple 处理结果尚待核对；未提交审核或发布。
- 截图、隐私、价格与销售地区尚待完成；年龄分级问卷尚未保存完成。用户已确认原项目中文介绍与推荐文字为其原创，内容版权声明仍需在 App Store Connect 完成。

最终截图从上述成功 CI 的测试附件原样导出，已经人工检查。未缩放、未拼接；截图和构建产物不纳入 Git。

| 设备尺寸 | 截图 | 原始分辨率 |
| --- | --- | --- |
| iPhone 6.9 英寸 | `docs/screenshots/iphone-6.9-journey.png`、`iphone-6.9-work.png`、`iphone-6.9-collection.png` | 1320×2868 |
| iPad 13 英寸 | `docs/screenshots/ipad-13-journey.png`、`ipad-13-work.png` | 2064×2752 |

笔记页面中的英文句子是 UI 测试写入的示例内容，不是用户私人笔记。

## 本地产物

- `ios/ClassicalGuide.xcodeproj`：可直接打开的 Xcode 工程。
- `build/ClassicalGuide-Final.xcarchive`：包含最终视觉修复的签名归档。
- `build/AppStore-Final/ClassicalGuide.ipa`：Build 1 的 App Store 分发包，约 442 KB，使用 Cloud Managed Apple Distribution 签名，`get-task-allow=false`，已上传 Apple。它包含旧图标，用于 App Store Connect 上传，不能当作开发包直接安装。
- IPA SHA-256：`9e0cdff0fe327054688940887c62f08c7c3e5f5d95fcf79bdb9b3c7128ffdade`。
- `ios/ExportOptions.plist`：分发导出设置，仅导出到本地。
- `docs/app-store-zh-Hans.txt`：中文商店资料与英文审核备注。
- `website/classical-guide/`：官网支持页与隐私页的完整静态源文件。
- `build/ClassicalGuide-AppStore-Package.zip`：iOS 工程、分发 IPA、五张商店尺寸截图、发布说明与官网页面草稿的本地交付包。它不是已发布或已通过审核的版本。

代码草稿 PR：[classical-music-guide #1](https://github.com/Mlikeason/classical-music-guide/pull/1)，尚未合并。官网配套页 [zhuhong-me #1](https://github.com/Mlikeason/zhuhong-me/pull/1) 已获批准并合并，但实际域名由另一 Vercel 项目 `finding-m` 托管；包含新页面的预览部署已就绪，生产发布与公开 URL 验证尚未完成。

## 构建命令

限制编译并发可以降低本机负载；以下命令不上传或发布。

```sh
xcodebuild -jobs 2 -project ios/ClassicalGuide.xcodeproj -scheme ClassicalGuide \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath build/ClassicalGuide-Final.xcarchive -allowProvisioningUpdates archive

xcodebuild -exportArchive -archivePath build/ClassicalGuide-Final.xcarchive \
  -exportPath build/AppStore-Final -exportOptionsPlist ios/ExportOptions.plist \
  -allowProvisioningUpdates
```

## 上架前的实际待办

1. 完成 TestFlight 真机验收、VoiceOver 手动检查及外部 Apple Music 跳转。模拟器自动测试不能替代真机使用验证。
2. 在商店资料中上传已经准备的 6.9 英寸 iPhone 与 13 英寸 iPad 原生截图。
3. 官网与隐私政策已获开发者批准。通过实际托管网站的 `finding-m` 项目发布，保留其他现有页面，并验证 `https://zhuhong.me/classical-guide/` 和 `https://zhuhong.me/classical-guide/privacy/`。
4. 开发者已确认支持邮件“问题解决后 90 天内删除”的承诺。当前 App 不向开发者发送学习数据；如今后加入分析、云同步、账号等，必须同步更新声明和政策。
5. 核对已创建的 App 记录（主语言简体中文、Bundle ID 如上、SKU `classical-guide-ios`）。Apple 显示的销售者姓名由开发者账号法定信息决定，不能由 App 内署名覆盖。
6. 上传采用原图标的 Build 2 或后续归档，核对 Apple 处理结果并完成 TestFlight 真机验收；完成内容权利、隐私、年龄分级与免费发行地区。审核联系人已保存，年龄分级以问卷的实际计算结果为准。
7. 中国大陆：核对 App Store Connect 对本 App 的备案要求，如需备案则提供对应 App 的有效 ICP 备案号，确保简体中文名称等元数据与备案一致。当前没有用户提供的 App 备案号，不能假设网站已有备案可用于此 App。
8. 审核材料完整后再提交 Apple 审核。尚未获得审核通过，不能将本地构建成功等同于可直接公开发行。

## 官方依据（2026-11-08 核对）

- [App Review Guidelines：完整性、最低功能与隐私政策](https://developer.apple.com/app-store/review/guidelines/)
- [App 隐私披露：仅在本机处理的数据与可选支持请求](https://developer.apple.com/app-store/app-privacy-details/)
- [SDK 最低要求](https://developer.apple.com/news/upcoming-requirements/?id=04282026a)
- [截屏规范](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
- [中国大陆供应与 App 信息要求](https://developer.apple.com/cn/help/app-store-connect/reference/app-information/app-information)

本次原生功能与资料准备降低了常见技术问题；内容分类、地区资质及最终接受与否仍须由实际审核确认。
