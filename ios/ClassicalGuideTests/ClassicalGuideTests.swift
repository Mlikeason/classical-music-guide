import XCTest
@testable import ClassicalGuide

@MainActor final class ClassicalGuideTests: XCTestCase {
    private var catalog: Catalog!
    private var defaults: UserDefaults!
    private var suite: String!

    override func setUp() async throws {
        try await MainActor.run {
            catalog = try Catalog.load()
            suite = "ClassicalGuideTests.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }
    }
    override func tearDown() async throws {
        await MainActor.run { defaults.removePersistentDomain(forName: suite) }
    }
    func testCompleteCatalogAndStableIDs() throws {
        XCTAssertEqual(catalog.works.count, 28)
        XCTAssertEqual(catalog.composers.count, 20)
        XCTAssertEqual(catalog.stages.map { catalog.works(in: $0).count }, [6,6,6,6,4])
        XCTAssertEqual(Set(catalog.works.map(\.legacyID)).count, 28)
        XCTAssertTrue(catalog.works.allSatisfy { $0.listeningGuide.count == 3 })
        let changedOrder = Catalog(schemaVersion: 1, stages: catalog.stages, composers: catalog.composers, works: catalog.works.reversed())
        XCTAssertEqual(Set(changedOrder.works.map(\.id)), Set(catalog.works.map(\.id)))
    }
    func testSearchInChineseEnglishAndMultipleTokens() {
        XCTAssertEqual(catalog.works.filter { catalog.matches($0, query: "月光") }.count, 2)
        XCTAssertEqual(catalog.works.filter { catalog.matches($0, query: "  BEETHOVEN   Moonlight ") }.map(\.id), ["beethoven-moonlight"])
        XCTAssertFalse(catalog.works.contains { catalog.matches($0, query: "不存在的曲目") })
        XCTAssertEqual(catalog.works.filter { catalog.matches($0, query: "巴赫") }.count, 2)
    }
    func testFilterBoundaries() {
        let ten = catalog.works.first { $0.minutes == 10 }!
        XCTAssertFalse(WorkFilter.short.includes(ten, listened: []))
        XCTAssertTrue(catalog.works.filter { WorkFilter.short.includes($0, listened: []) }.allSatisfy { $0.minutes < 10 })
        XCTAssertTrue(catalog.works.filter { WorkFilter.long.includes($0, listened: []) }.allSatisfy { $0.minutes >= 30 })
        XCTAssertFalse(WorkFilter.unlistened.includes(ten, listened: [ten.id]))
    }
    func testPersistenceAndUndoAcrossLaunches() throws {
        let store = LearningStore(catalog: catalog, defaults: defaults)
        store.toggleFavorite("bach-air")
        store.toggleListened("bach-air", now: Date(timeIntervalSince1970: 1000))
        store.setNote("第二遍听低音。", for: "bach-air")
        store.open("bach-air")
        let restored = LearningStore(catalog: catalog, defaults: defaults)
        XCTAssertEqual(store.snapshot, restored.snapshot)
        restored.toggleListened("bach-air")
        XCTAssertFalse(restored.snapshot.listened.contains("bach-air"))
        XCTAssertNil(restored.snapshot.completedAt["bach-air"])
        XCTAssertEqual(restored.snapshot.notes["bach-air"], "第二遍听低音。")
    }
    func testBackupRoundTripAndNonDestructiveMerge() throws {
        let store = LearningStore(catalog: catalog, defaults: defaults)
        store.setNote("保留本机笔记", for: "bach-air")
        store.toggleFavorite("bach-air")
        var incoming = LearningSnapshot()
        incoming.notes = ["bach-air":"较旧笔记", "bach-cello-prelude":"新笔记"]
        incoming.listened = ["bach-cello-prelude"]
        incoming.completedAt = ["bach-cello-prelude": Date(timeIntervalSince1970: 100)]
        try store.importData(JSONEncoder().encode(incoming))
        XCTAssertEqual(store.snapshot.notes["bach-air"], "保留本机笔记")
        XCTAssertEqual(store.snapshot.notes["bach-cello-prelude"], "新笔记")
        XCTAssertTrue(store.snapshot.favorites.contains("bach-air"))
        let exported = try JSONDecoder().decode(LearningSnapshot.self, from: store.exportData())
        XCTAssertEqual(exported, store.snapshot)
    }
    func testInvalidImportIsAtomic() throws {
        let store = LearningStore(catalog: catalog, defaults: defaults)
        store.toggleFavorite("bach-air")
        let before = store.snapshot
        var invalid = LearningSnapshot()
        invalid.favorites = ["unknown-work"]
        XCTAssertThrowsError(try store.importData(JSONEncoder().encode(invalid)))
        XCTAssertThrowsError(try store.importData(Data("not json".utf8)))
        XCTAssertThrowsError(try store.importData(Data(repeating: 32, count: 2_000_001)))
        XCTAssertEqual(before, store.snapshot)
    }
    func testCorruptLocalDataIsPreservedUntilRecovery() throws {
        let data = Data("corrupt but preserved".utf8)
        defaults.set(data, forKey: "classicalGuide.learning.v1")
        let store = LearningStore(catalog: catalog, defaults: defaults)
        XCTAssertTrue(store.needsRecovery)
        store.toggleFavorite("bach-air")
        XCTAssertTrue(store.snapshot.favorites.isEmpty)
        XCTAssertEqual(try store.exportData(), data)
        try store.importData(JSONEncoder().encode(LearningSnapshot()))
        XCTAssertFalse(store.needsRecovery)
        store.toggleFavorite("bach-air")
        XCTAssertTrue(store.snapshot.favorites.contains("bach-air"))
    }
    func testResetRemovesEveryPersonalField() {
        let store = LearningStore(catalog: catalog, defaults: defaults)
        store.toggleFavorite("bach-air"); store.toggleListened("bach-air")
        store.setNote("note", for: "bach-air"); store.open("bach-air")
        store.reset()
        XCTAssertEqual(store.snapshot, LearningSnapshot())
        XCTAssertNil(defaults.data(forKey: "classicalGuide.learning.v1"))
    }
    func testURLsCarryOnlySearchKeywords() {
        for work in catalog.works {
            let components = URLComponents(url: work.musicURL!, resolvingAgainstBaseURL: false)!
            XCTAssertEqual(components.host, "music.apple.com")
            XCTAssertEqual(components.queryItems, [URLQueryItem(name: "term", value: work.searchTerm)])
        }
    }
}
