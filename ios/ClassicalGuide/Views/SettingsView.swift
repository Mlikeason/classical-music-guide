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
                Link(destination: URL(string: "https://zhuhong.me/classical-guide/privacy/")!) { Label("隐私政策", systemImage: "hand.raised") }
                Link(destination: URL(string: "mailto:zivzhu@gmail.com?subject=Classical%20Guide%20Support")!) { Label("联系开发者", systemImage: "envelope") }
                Link(destination: URL(string: "https://zhuhong.me/classical-guide/")!) { Label("支持与帮助", systemImage: "globe") }
                Link(destination: URL(string: "https://zhuhong.me/classical-guide/credits/")!) { Label("内容与版权说明", systemImage: "text.book.closed") }
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
