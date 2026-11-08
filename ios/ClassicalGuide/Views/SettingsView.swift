import SwiftUI
import UniformTypeIdentifiers

struct LearningBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw BackupError.invalid }
        self.data = data
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: data) }
}

struct SettingsView: View {
    @Environment(LearningStore.self) private var store
    @State private var exportDocument = LearningBackupDocument(data: Data())
    @State private var exporting = false
    @State private var importing = false
    @State private var confirmingReset = false
    @State private var message: String?
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("古典指南").font(.system(.title, design: .serif, weight: .semibold))
                    Text("给每一次聆听，一个新的起点。").font(.subheadline).foregroundStyle(.secondary)
                    Text("版本 \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0") · Zhu Hong")
                        .font(.caption).foregroundStyle(.secondary)
                }.padding(.vertical, 8)
            }.listRowBackground(Color.clear)
            Section {
                if store.needsRecovery {
                    Label("记录需要恢复。原始数据仍保留，可先导出。", systemImage: "exclamationmark.triangle").foregroundStyle(.orange)
                }
                Button {
                    do { exportDocument = LearningBackupDocument(data: try store.exportData()); exporting = true }
                    catch { message = error.localizedDescription }
                } label: { Label("导出学习记录", systemImage: "square.and.arrow.up") }
                Button { importing = true } label: { Label("导入备份", systemImage: "square.and.arrow.down") }
                Button(role: .destructive) { confirmingReset = true } label: { Label("清除本机学习记录", systemImage: "trash") }
            } header: { Text("学习记录") } footer: {
                Text("收藏、已听与笔记保存在本机。换机或卸载前请导出备份；导入会合并记录，并保留本机已有的同曲笔记。App 不提供账号或云同步。")
            }
            Section("关于与支持") {
                NavigationLink { PrivacyView() } label: { Label("隐私政策", systemImage: "hand.raised") }
                Link(destination: URL(string: "mailto:zivzhu@gmail.com?subject=Classical%20Guide%20Support")!) { Label("联系开发者", systemImage: "envelope") }
                Link(destination: URL(string: "https://zhuhong.me")!) { Label("访问官网", systemImage: "globe") }
                NavigationLink { CreditsView() } label: { Label("内容与版权说明", systemImage: "text.book.closed") }
            }
        }.navigationTitle("设置").navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden).background(GuideTheme.paper)
            .fileExporter(isPresented: $exporting, document: exportDocument, contentType: .json, defaultFilename: "古典指南-学习备份") { result in
                if case .failure(let error) = result { message = error.localizedDescription }
            }
            .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
                do {
                    let url = try result.get()
                    let access = url.startAccessingSecurityScopedResource()
                    defer { if access { url.stopAccessingSecurityScopedResource() } }
                    if let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize, size > 2_000_000 { throw BackupError.oversized }
                    try store.importData(Data(contentsOf: url, options: .mappedIfSafe))
                    message = "备份已合并，学习记录已恢复。"
                } catch { message = error.localizedDescription }
            }
            .confirmationDialog("清除全部收藏、已听记录和笔记？此操作无法撤销。", isPresented: $confirmingReset, titleVisibility: .visible) {
                Button("清除全部记录", role: .destructive) { store.reset() }
                Button("取消", role: .cancel) {}
            }
            .alert("学习备份", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
                Button("好", role: .cancel) { message = nil }
            } message: { Text(message ?? "") }
    }
}

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("你的聆听，只属于你。").font(.system(.title2, design: .serif, weight: .semibold))
                privacySection("收集与使用", "古典指南由 Zhu Hong 提供。App 无需账号，不含广告、统计分析或追踪 SDK，不向开发者服务器发送个人信息、收藏、已听记录或笔记。")
                privacySection("本机记录与备份", "学习记录保存在 App 的本机存储中，直至你在设置中清除或卸载 App。系统设备备份可能包含这些记录，取决于你的系统设置。导出的 JSON 文件由你选择存放位置，可能包含私人笔记，请自行保管；清除 App 数据不会删除你导出的文件。")
                privacySection("外部服务", "只有当你主动打开 Apple Music、官网或邮件链接时，才会离开 App。音乐搜索链接只携带曲目关键词，不附带笔记、收藏或用户标识。外部服务依照各自隐私政策处理网络请求及你在其服务中的行为。")
                privacySection("支持联系", "你主动发邮件联系 zivzhu@gmail.com 时，开发者会收到你提供的邮箱地址和邮件内容，仅用于回复与处理支持请求。你可以通过同一邮箱请求删除支持邮件；已解决请求的邮件将在 90 天内删除，法律另有要求的除外。")
                Link("Apple 隐私政策", destination: URL(string: "https://www.apple.com/legal/privacy/")!)
                Link("在线隐私政策", destination: URL(string: "https://zhuhong.me/classical-guide/privacy/")!)
                Text("开发者：Zhu Hong\n联系：zivzhu@gmail.com\n更新日期：2026 年 11 月 8 日").font(.caption).foregroundStyle(.secondary)
            }.padding(24).frame(maxWidth: 720).frame(maxWidth: .infinity)
        }.background(GuideTheme.paper).navigationTitle("隐私政策").navigationBarTitleDisplayMode(.inline)
    }
    private func privacySection(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) { Text(title).font(.headline); Text(text).lineSpacing(5) }
    }
}

struct CreditsView: View {
    var body: some View {
        List {
            Section("内容") {
                Text("本 App 基于 Zhu Hong 的 classical-music-guide 项目整理，收录 28 首作品的中文导览，并加入聆听提示、个人笔记与学习记录。作品时长为约数；版本推荐是编辑选择，不代表唯一或官方推荐。")
                Link("查看项目", destination: URL(string: "https://github.com/Mlikeason/classical-music-guide")!)
            }
            Section("音乐与图像") {
                Text("App 不内置音频、乐谱或第三方专辑封面，也不提供音乐下载。作品名称与作曲家资料用于介绍与检索。收听通过外部音乐服务进行，其录音权利与使用条件由对应服务管理。")
                Text("作曲家字母图形与装饰线条为本 App 绘制。原网页的肖像未打包进 App。Apple Music 名称归其权利人所有；本 App 与 Apple 不存在赞助或授权合作关系。")
            }
            Section("纠错与建议") {
                Link("zivzhu@gmail.com", destination: URL(string: "mailto:zivzhu@gmail.com")!)
            }
        }.navigationTitle("内容与版权").navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden).background(GuideTheme.paper)
    }
}
