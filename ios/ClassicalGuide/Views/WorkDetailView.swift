import SwiftUI

struct WorkDetailView: View {
    let work: Work
    let catalog: Catalog
    @Environment(LearningStore.self) private var store
    @Environment(\.openURL) private var openURL
    @State private var editingNote = false
    @State private var linkFailed = false
    private var composer: Composer? { catalog.composer(for: work) }
    private var listened: Bool { store.snapshot.listened.contains(work.id) }
    private var favorite: Bool { store.snapshot.favorites.contains(work.id) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        ComposerMark(composer: composer, size: 88)
                        Spacer()
                        Text("约 \(work.minutes) 分钟\n\(work.genre)")
                            .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.trailing).lineSpacing(5)
                    }
                    Text(work.title).font(.system(.largeTitle, design: .serif, weight: .semibold)).fixedSize(horizontal: false, vertical: true)
                    Text(work.subtitle).font(.subheadline).foregroundStyle(.secondary)
                    Text(work.summary).font(.body).lineSpacing(5)
                }
                VStack(spacing: 12) {
                    Button {
                        guard let url = work.musicURL else { linkFailed = true; return }
                        openURL(url) { accepted in if !accepted { linkFailed = true } }
                    } label: {
                        Label("在 Apple Music 搜索", systemImage: "arrow.up.right.square")
                            .font(.headline).foregroundStyle(Color("ButtonText")).frame(maxWidth: .infinity).padding(.vertical, 9)
                    }.buttonStyle(.borderedProminent).clipShape(RoundedRectangle(cornerRadius: 14))
                    Text("将在音乐 App 或浏览器中打开。播放条件与曲目供应以当地音乐服务为准。")
                        .font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)
                    Button { store.toggleListened(work.id) } label: {
                        Label(listened ? "已听过 · 点击撤销" : "标记为已听过", systemImage: listened ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.subheadline.weight(.medium)).frame(maxWidth: .infinity).padding(.vertical, 9)
                    }.buttonStyle(.bordered).accessibilityIdentifier("toggleListened")
                }
                VStack(alignment: .leading, spacing: 20) {
                    SectionEyebrow(title: "这一首，听什么")
                    ForEach(Array(work.listeningGuide.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: 14) {
                            Text(String(format: "%02d", index + 1)).font(.system(.title3, design: .serif)).foregroundStyle(GuideTheme.accent)
                            Text(item).font(.body).lineSpacing(5).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }.padding(22).background(GuideTheme.card, in: RoundedRectangle(cornerRadius: 20))
                if let composer {
                    NavigationLink { ComposerView(composer: composer, catalog: catalog) } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                SectionEyebrow(title: "认识作曲家")
                                Text("\(composer.name) · \(composer.latinName)").font(.headline).foregroundStyle(.primary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.secondary)
                        }
                    }.buttonStyle(.plain)
                }
                VStack(alignment: .leading, spacing: 12) {
                    SectionEyebrow(title: "版本探索")
                    Text(work.recommendation).font(.headline)
                    Text(work.performerNote).font(.subheadline).foregroundStyle(.secondary).lineSpacing(4)
                    Text("以上是寻找录音的起点；搜索结果不会固定到某一张专辑，时长也会因演绎而异。")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("我的聆听笔记").font(.headline)
                        Spacer()
                        Button(store.snapshot.notes[work.id] == nil ? "写笔记" : "编辑") { editingNote = true }
                            .accessibilityIdentifier("editNote")
                    }
                    Text(store.snapshot.notes[work.id] ?? "哪个瞬间让你停下来？留下一个意象、一种情绪，或下次想再听的片段。")
                        .font(.body).foregroundStyle(store.snapshot.notes[work.id] == nil ? .secondary : .primary)
                        .lineSpacing(5).textSelection(.enabled)
                    if let date = store.snapshot.completedAt[work.id] {
                        Text("已听记录：\(date.formatted(date: .abbreviated, time: .omitted))").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }.padding(24).frame(maxWidth: 720).frame(maxWidth: .infinity)
        }.background(GuideTheme.paper)
            .navigationTitle(composer?.name ?? "作品导览").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { store.toggleFavorite(work.id) } label: { Image(systemName: favorite ? "bookmark.fill" : "bookmark") }
                        .accessibilityLabel(favorite ? "取消收藏" : "收藏作品").accessibilityIdentifier("toggleFavorite")
                    ShareLink(item: "\(work.title) — \(composer?.name ?? "")\n\(work.summary)\n\(work.musicURL?.absoluteString ?? "https://zhuhong.me")")
                        .accessibilityLabel("分享作品")
                }
            }
            .onAppear { store.open(work.id) }
            .sheet(isPresented: $editingNote) { NoteEditor(work: work) }
            .alert("暂时无法打开音乐服务", isPresented: $linkFailed) {
                Button("好", role: .cancel) {}
            } message: { Text("可以在音乐 App 中搜索：\(work.searchTerm)") }
    }
}

struct NoteEditor: View {
    let work: Work
    @Environment(LearningStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var original = ""
    @State private var discard = false
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(work.title).font(.headline)
                Text("记下你听见的细节，或此刻的感受。").font(.subheadline).foregroundStyle(.secondary)
                TextEditor(text: $text).font(.body).accessibilityLabel("聆听笔记内容")
                    .accessibilityIdentifier("noteText").scrollContentBackground(.hidden)
                Text("\(text.count) / 10000 字 · 仅保存在本机").font(.caption).foregroundStyle(.secondary)
            }.padding(20).background(GuideTheme.paper)
                .navigationTitle("聆听笔记").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("取消") { if text != original { discard = true } else { dismiss() } } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存") { store.setNote(text, for: work.id); if !store.needsRecovery { dismiss() } }
                            .disabled(text.count > 10_000).accessibilityIdentifier("saveNote")
                    }
                }
                .confirmationDialog("放弃这次修改？", isPresented: $discard, titleVisibility: .visible) {
                    Button("放弃修改", role: .destructive) { dismiss() }
                }
        }
        .interactiveDismissDisabled(text != original)
        .onAppear { text = store.snapshot.notes[work.id] ?? ""; original = text }
    }
}
