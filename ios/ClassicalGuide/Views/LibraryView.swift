import SwiftUI

struct LibraryView: View {
    let catalog: Catalog
    @Environment(LearningStore.self) private var store
    @State private var query = ""
    @State private var filter = WorkFilter.all
    @State private var composerID: String?
    private var filtered: [Work] {
        catalog.works.filter {
            catalog.matches($0, query: query) && filter.includes($0, listened: store.snapshot.listened)
            && (composerID == nil || $0.composerID == composerID)
        }
    }
    var body: some View {
        List {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(WorkFilter.allCases) { item in
                            Button { filter = item } label: {
                                Text(item.rawValue).font(.subheadline.weight(.medium))
                                    .padding(.horizontal, 14).padding(.vertical, 10)
                                    .background(filter == item ? GuideTheme.accent : GuideTheme.card, in: Capsule())
                                    .foregroundStyle(filter == item ? Color("ButtonText") : Color.primary)
                            }.buttonStyle(.plain)
                                .accessibilityAddTraits(filter == item ? [.isSelected] : [])
                        }
                    }.padding(.vertical, 4)
                }
                HStack {
                    Text("\(filtered.count) 首作品").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Menu {
                        Button("全部作曲家") { composerID = nil }
                        ForEach(catalog.composers.sorted { $0.latinName < $1.latinName }) { composer in
                            Button(composer.name) { composerID = composer.id }
                        }
                    } label: {
                        Label(catalog.composers.first { $0.id == composerID }?.name ?? "作曲家", systemImage: "line.3.horizontal.decrease")
                            .font(.subheadline)
                    }
                }
            }.listRowBackground(Color.clear).listRowSeparator(.hidden)
            if filtered.isEmpty {
                ContentUnavailableView {
                    Label("没有找到作品", systemImage: "magnifyingglass")
                } description: { Text("试试作品名、作曲家、英文标题或演奏者。") }
                actions: { Button("清除筛选") { query = ""; filter = .all; composerID = nil } }
                    .listRowBackground(Color.clear)
            } else {
                ForEach(filtered) { WorkLink(work: $0, catalog: catalog) }
            }
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "作品、作曲家、演奏者")
        .scrollContentBackground(.hidden).background(GuideTheme.paper)
        .navigationTitle("曲库")
        .toolbar { ToolbarItem(placement: .topBarTrailing) {
            NavigationLink { ComposersView(catalog: catalog) } label: { Image(systemName: "person.2").accessibilityLabel("作曲家索引") }
        } }
    }
}

struct ComposersView: View {
    let catalog: Catalog
    var body: some View {
        List(catalog.composers.sorted { $0.latinName < $1.latinName }) { composer in
            NavigationLink { ComposerView(composer: composer, catalog: catalog) } label: {
                HStack(spacing: 16) {
                    ComposerMark(composer: composer)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(composer.name).font(.headline)
                        Text("\(composer.latinName) · \(composer.era)").font(.caption).foregroundStyle(.secondary)
                    }
                }.padding(.vertical, 5)
            }
        }.navigationTitle("作曲家").scrollContentBackground(.hidden).background(GuideTheme.paper)
    }
}

struct ComposerView: View {
    let composer: Composer
    let catalog: Catalog
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    ComposerMark(composer: composer, size: 88)
                    Text(composer.latinName).font(.system(.title2, design: .serif))
                    Text(composer.era).font(.caption).foregroundStyle(GuideTheme.accent)
                    Text(composer.biography).font(.body).lineSpacing(6)
                }.padding(.vertical, 12)
            }.listRowBackground(Color.clear)
            Section("从这些作品开始") {
                ForEach(catalog.works.filter { $0.composerID == composer.id }) { WorkLink(work: $0, catalog: catalog) }
            }
        }.navigationTitle(composer.name).navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden).background(GuideTheme.paper)
    }
}
