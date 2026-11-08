import SwiftUI

struct JourneyView: View {
    let catalog: Catalog
    @Environment(LearningStore.self) private var store
    private var nextWork: Work? {
        catalog.works.first { !store.snapshot.listened.contains($0.id) } ?? catalog.works.first
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                VStack(alignment: .leading, spacing: 12) {
                    SectionEyebrow(title: "A LITTLE CLASSICAL, EVERY DAY")
                    Text("从一首喜欢的旋律，\n听见更大的世界。")
                        .font(.system(.largeTitle, design: .serif, weight: .medium)).lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("28 首作品 · 5 段旅程 · 从容开始")
                        .font(.subheadline).foregroundStyle(.secondary)
                    MusicStaff().padding(.top, 4)
                }.padding(.top, 12)

                if let work = nextWork {
                    NavigationLink { WorkDetailView(work: work, catalog: catalog) } label: {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                SectionEyebrow(title: store.snapshot.listened.count == catalog.works.count ? "再听一遍" : "下一首，听这个")
                                Spacer()
                                Image(systemName: "arrow.up.right").foregroundStyle(GuideTheme.accent)
                            }
                            HStack(spacing: 16) {
                                ComposerMark(composer: catalog.composer(for: work), size: 68)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(work.title).font(.title3.weight(.semibold)).foregroundStyle(.primary)
                                    Text("\(catalog.composer(for: work)?.name ?? "") · 约 \(work.minutes) 分钟")
                                        .font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                            Text(work.summary).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                        }
                        .padding(22).background(GuideTheme.card, in: RoundedRectangle(cornerRadius: 22))
                    }.buttonStyle(.plain).accessibilityIdentifier("nextWork")
                }

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("你的聆听旅程").font(.title2.weight(.semibold))
                        Spacer()
                        Text("\(store.snapshot.listened.count) / \(catalog.works.count)").font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
                    }
                    ProgressView(value: Double(store.snapshot.listened.count), total: Double(catalog.works.count))
                        .accessibilityLabel("已听过 \(store.snapshot.listened.count) 首，共 \(catalog.works.count) 首")
                    ForEach(catalog.stages) { stage in
                        NavigationLink { StageView(stage: stage, catalog: catalog) } label: {
                            StageCard(stage: stage, catalog: catalog)
                        }.buttonStyle(.plain)
                    }
                }
                NavigationLink { ListeningGuideView() } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "book.closed").font(.title2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("不懂乐理，也能开始").font(.headline)
                            Text("聆听建议与速度术语").font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption)
                    }.padding(20).background(GuideTheme.card, in: RoundedRectangle(cornerRadius: 18))
                }.buttonStyle(.plain)
                Text("不用急着听懂。\n先找到让你想再听一遍的声音。")
                    .font(.system(.body, design: .serif)).foregroundStyle(.secondary).lineSpacing(5)
                    .frame(maxWidth: .infinity).multilineTextAlignment(.center).padding(.vertical, 14)
            }.padding(.horizontal, 22).padding(.bottom, 24).frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
        }
        .background(GuideTheme.paper)
        .navigationTitle("古典指南").navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarTrailing) {
            NavigationLink { SettingsView() } label: { Image(systemName: "gearshape").accessibilityLabel("设置") }
        } }
    }
}

struct StageCard: View {
    let stage: LearningStage
    let catalog: Catalog
    @Environment(LearningStore.self) private var store
    private var works: [Work] { catalog.works(in: stage) }
    private var count: Int { works.filter { store.snapshot.listened.contains($0.id) }.count }
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(String(format: "%02d", stage.id))
                .font(.system(.title, design: .serif)).foregroundStyle(GuideTheme.accent.opacity(0.7)).frame(width: 40)
            VStack(alignment: .leading, spacing: 7) {
                Text(stage.title).font(.headline).foregroundStyle(.primary)
                Text(stage.subtitle).font(.caption).foregroundStyle(.secondary)
                Text(count == works.count ? "已完成这一段旅程" : "\(works.count) 首作品 · 已听 \(count) 首")
                    .font(.caption).foregroundStyle(GuideTheme.accent)
            }
            Spacer(minLength: 0)
            Image(systemName: count == works.count ? "checkmark.circle.fill" : "chevron.right")
                .font(.caption).foregroundStyle(GuideTheme.accent).padding(.top, 7)
        }.padding(.vertical, 18).frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .bottom) { Rectangle().fill(Color.primary.opacity(0.10)).frame(height: 0.5) }
    }
}

struct StageView: View {
    let stage: LearningStage
    let catalog: Catalog
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    SectionEyebrow(title: String(format: "CHAPTER %02d", stage.id))
                    Text(stage.title).font(.system(.title, design: .serif, weight: .semibold))
                    Text(stage.subtitle).font(.body).foregroundStyle(.secondary)
                }.padding(.vertical, 14)
            }.listRowBackground(Color.clear)
            Section("按自己的节奏，一首一首听") {
                ForEach(catalog.works(in: stage)) { WorkLink(work: $0, catalog: catalog) }
            }
        }.scrollContentBackground(.hidden).background(GuideTheme.paper)
            .navigationTitle("第 \(stage.id) 段旅程").navigationBarTitleDisplayMode(.inline)
    }
}
