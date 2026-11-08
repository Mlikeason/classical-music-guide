import SwiftUI

enum CollectionSection: String, CaseIterable, Identifiable {
    case favorites = "收藏", listened = "已听", notes = "笔记"
    var id: String { rawValue }
}

struct CollectionView: View {
    let catalog: Catalog
    @Environment(LearningStore.self) private var store
    @State private var section = CollectionSection.favorites
    private var works: [Work] {
        catalog.works.filter { work in
            switch section {
            case .favorites: return store.snapshot.favorites.contains(work.id)
            case .listened: return store.snapshot.listened.contains(work.id)
            case .notes: return store.snapshot.notes[work.id] != nil
            }
        }
    }
    var body: some View {
        List {
            Section {
                HStack(spacing: 0) {
                    stat(store.snapshot.listened.count, title: "已听作品")
                    stat(store.snapshot.favorites.count, title: "心动收藏")
                    stat(store.snapshot.notes.count, title: "聆听笔记")
                }.padding(.vertical, 16)
                ProgressView(value: Double(store.snapshot.listened.count), total: Double(catalog.works.count))
                    .accessibilityLabel("已听过 \(store.snapshot.listened.count) 首，共 \(catalog.works.count) 首")
                Text("每一次认真聆听，都算数。").font(.subheadline).foregroundStyle(.secondary).padding(.vertical, 8)
            }.listRowBackground(Color.clear).listRowSeparator(.hidden)
            if let id = store.snapshot.lastOpenedID, let work = catalog.works.first(where: { $0.id == id }) {
                Section("最近浏览") { WorkLink(work: work, catalog: catalog) }
            }
            Section {
                Picker("我的记录", selection: $section) {
                    ForEach(CollectionSection.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented).listRowBackground(Color.clear)
                if works.isEmpty {
                    ContentUnavailableView {
                        Label(emptyTitle, systemImage: section == .notes ? "square.and.pencil" : "bookmark")
                    } description: { Text("打开一首作品，收藏、标记已听或写下感受，记录就会出现在这里。") }
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(works) { work in
                        NavigationLink { WorkDetailView(work: work, catalog: catalog) } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                WorkRow(work: work, catalog: catalog)
                                if section == .notes, let note = store.snapshot.notes[work.id] {
                                    Text(note).font(.subheadline).foregroundStyle(.secondary).lineLimit(3).padding(.bottom, 8)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("我的聆听")
        .scrollContentBackground(.hidden).background(GuideTheme.paper)
        .toolbar { ToolbarItem(placement: .topBarTrailing) {
            NavigationLink { SettingsView() } label: { Image(systemName: "gearshape").accessibilityLabel("设置") }
        } }
    }
    private var emptyTitle: String {
        switch section {
        case .favorites: return "收藏下一次想听的作品"
        case .listened: return "从第一首开始"
        case .notes: return "为听见的声音留个位置"
        }
    }
    private func stat(_ value: Int, title: String) -> some View {
        VStack(spacing: 8) {
            Text(value.formatted()).font(.system(.largeTitle, design: .serif)).foregroundStyle(GuideTheme.accent)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity).accessibilityElement(children: .combine)
    }
}
