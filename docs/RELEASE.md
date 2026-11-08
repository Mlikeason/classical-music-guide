# 发布交付记录

日期：2026-11-08。产品：古典指南 1.0.0 (1)。开发者署名：Zhu Hong。支持邮箱：zivzhu@gmail.com。用户确认：免费、无广告、无内购；目标包含中国大陆的尽可能全球发行。

## 构建与验证

- Xcode 27.2 (27B52)，iOS 27.2 SDK；最低部署 iOS / iPadOS 17。
- Bundle ID：`me.zhuhong.classicalguide`，签名 Team：`KW9NTQUH4T`。使用本机匹配 Hong Zhu 的证书和已配置的 Xcode 开发者账号完成自动签名。
- 已完成 Debug 模拟器构建、Release 真机架构签名归档与 App Store 分发方式的 IPA 导出。
- iPhone 18 Pro / iOS 27.2：9 项单元测试 + 2 项完整界面流程测试通过。可审查结果：`build/Tests-SearchFix.xcresult`。
- 通过的 UI 流程：搜索空态与恢复；搜索 Moonlight → 作品 → 收藏 → 标记已听 → 写笔记 → 重启 → 我的笔记。
- 此后修正阶段分隔线与深色按钮文字，并增加阅读布局测试。最终完整回归因本机负载接近 1000、模拟器启动超时而中断，不计为通过。
- iPad、大字体、深色模式及 6.9 英寸商店截图尚未完成最终验证；iOS 17 真机测试尚未进行。
- HTML 本地链接、plist、工程格式与 Git 空白检查通过。官网配套页未完成浏览器预览或公开部署验证。
- App Store Connect 网页打开多次超时，未创建或修改商店应用记录，未上传、提交审核或发布。

当前成功测试截图在本机 `docs/screenshots/`，为 1206×2622 的 QA 实拍。截图包含早期视觉状态，不能作为已完成的 6.9 英寸／iPad 商店截图交付。截图和构建产物不纳入 Git。

## 本地产物

- `ios/ClassicalGuide.xcodeproj`：可直接打开的 Xcode 工程。
- `build/ClassicalGuide.xcarchive`：已成功生成的签名归档。
- `build/AppStore/ClassicalGuide.ipa`：已通过 Xcode 本地导出的 App Store 分发包，未上传 Apple；后续最终视觉修复需使用最终归档重新导出。
- `ios/ExportOptions.plist`：分发导出设置，仅导出到本地。
- `docs/app-store-zh-Hans.txt`：中文商店资料与英文审核备注。
- `website/classical-guide/`：官网支持页与隐私页的完整静态源文件。

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

1. 在稳定的机器上完成最终 iPhone / iPad / Dynamic Type / 深色模式与真机回归，核验 28 条音乐搜索链接的实际打开行为。
2. 拍摄最终界面的 6.9 英寸 iPhone 与 13 英寸 iPad 截图；建议使用模拟器原生 1320×2868 和 2064×2752 输出，不缩放伪造设备图。
3. 将 `website/classical-guide/` 复制到现有 `Mlikeason/zhuhong-me` 网站仓库根目录的 `classical-guide/`，通过其既有部署流程发布。验证两个公开 URL 能返回实际内容：`https://zhuhong.me/classical-guide/` 和 `https://zhuhong.me/classical-guide/privacy/`。
4. 开发者确认隐私政策与实际运营相符，尤其是支持邮件“问题解决后 90 天内删除”的承诺。当前 App 不向开发者发送学习数据；如今后加入分析、云同步、账号等，必须同步更新声明和政策。
5. 在 App Store Connect 创建 iOS App（主语言简体中文、Bundle ID 如上、SKU 可用 `classical-guide-ios`），检查“古典指南”名称可用性。Apple 显示的销售者姓名由开发者账号法定信息决定，不能由 App 内署名覆盖。
6. 上传最终 IPA 或通过 Xcode Organizer 上传归档，先走 TestFlight 真机验收；填写内容权利、隐私、年龄分级、审核联系人电话与免费发行地区。年龄分级以问卷的实际计算结果为准。
7. 中国大陆：核对 App Store Connect 对本 App 的备案要求，如需备案则提供对应 App 的有效 ICP 备案号，确保简体中文名称等元数据与备案一致。当前没有用户提供的 App 备案号，不能假设网站已有备案可用于此 App。
8. 审核材料完整后再提交 Apple 审核。尚未获得审核通过，不能将本地构建成功等同于可直接公开发行。

## 官方依据（2026-11-08 核对）

- [App Review Guidelines：完整性、最低功能与隐私政策](https://developer.apple.com/app-store/review/guidelines/)
- [App 隐私披露：仅在本机处理的数据与可选支持请求](https://developer.apple.com/app-store/app-privacy-details/)
- [SDK 最低要求](https://developer.apple.com/news/upcoming-requirements/?id=04282026a)
- [截屏规范](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
- [中国大陆供应与 App 信息要求](https://developer.apple.com/cn/help/app-store-connect/reference/app-information/app-information)

本次原生功能与资料准备降低了常见技术问题；内容分类、地区资质及最终接受与否仍须由实际审核确认。
