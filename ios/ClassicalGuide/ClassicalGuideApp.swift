import SwiftUI

@main struct ClassicalGuideApp: App {
    private let catalogResult = Result { try Catalog.load() }
    var body: some Scene {
        WindowGroup {
            switch catalogResult {
            case .success(let catalog): AppRoot(catalog: catalog)
            case .failure(let error):
                ContentUnavailableView("曲库暂时无法打开", systemImage: "music.note.list", description: Text(error.localizedDescription))
            }
        }
    }
}

struct AppRoot: View {
    let catalog: Catalog
    @State private var store: LearningStore
    init(catalog: Catalog) {
        self.catalog = catalog
        var defaults = UserDefaults.standard
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-ui-testing") {
            let suite = "me.zhuhong.classicalguide.ui-testing"
            defaults = UserDefaults(suiteName: suite) ?? .standard
            if ProcessInfo.processInfo.arguments.contains("-reset-ui-testing") { defaults.removePersistentDomain(forName: suite) }
        }
        #endif
        _store = State(initialValue: LearningStore(catalog: catalog, defaults: defaults))
    }
    var body: some View {
        TabView {
            NavigationStack { JourneyView(catalog: catalog) }
                .tabItem { Label("听见", systemImage: "sparkles") }
            NavigationStack { LibraryView(catalog: catalog) }
                .tabItem { Label("曲库", systemImage: "music.note.list") }
            NavigationStack { CollectionView(catalog: catalog) }
                .tabItem { Label("我的", systemImage: "bookmark") }
        }
        .tint(GuideTheme.accent)
        .environment(store)
        .alert("学习记录", isPresented: Binding(get: { store.errorMessage != nil }, set: { if !$0 { store.errorMessage = nil } })) {
            Button("知道了", role: .cancel) { store.errorMessage = nil }
        } message: { Text(store.errorMessage ?? "") }
    }
}
