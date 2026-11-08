import Foundation

struct LearningStage: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
}

struct Composer: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let latinName: String
    let initial: String
    let colorHex: String
    let biography: String
    let era: String
}

struct Work: Codable, Identifiable, Hashable {
    let id: String
    let legacyID: String
    let stageID: Int
    let title: String
    let subtitle: String
    let composerID: String
    let minutes: Int
    let summary: String
    let searchTerm: String
    let recommendation: String
    let performerNote: String
    let genre: String
    let listeningGuide: [String]

    var musicURL: URL? {
        var url = URLComponents(string: "https://music.apple.com/search")
        url?.queryItems = [URLQueryItem(name: "term", value: searchTerm)]
        return url?.url
    }
}

struct Catalog: Codable {
    let schemaVersion: Int
    let stages: [LearningStage]
    let composers: [Composer]
    let works: [Work]

    static func load(bundle: Bundle = .main) throws -> Catalog {
        guard let url = bundle.url(forResource: "catalog", withExtension: "json") else {
            throw CatalogError.missingResource
        }
        return try decode(Data(contentsOf: url))
    }

    static func decode(_ data: Data) throws -> Catalog {
        let result = try JSONDecoder().decode(Catalog.self, from: data)
        let composerIDs = Set(result.composers.map(\.id))
        let stageIDs = Set(result.stages.map(\.id))
        guard result.schemaVersion == 1, !result.works.isEmpty,
              Set(result.works.map(\.id)).count == result.works.count,
              composerIDs.count == result.composers.count,
              stageIDs.count == result.stages.count,
              result.works.allSatisfy({ composerIDs.contains($0.composerID) && stageIDs.contains($0.stageID) && $0.minutes > 0 && !$0.listeningGuide.isEmpty && $0.musicURL?.scheme == "https" }) else {
            throw CatalogError.invalidCatalog
        }
        return result
    }

    func composer(for work: Work) -> Composer? { composers.first { $0.id == work.composerID } }
    func works(in stage: LearningStage) -> [Work] { works.filter { $0.stageID == stage.id } }
    func matches(_ work: Work, query: String) -> Bool {
        let words = query.split(whereSeparator: \.isWhitespace).map(String.init)
        let composer = composer(for: work)
        let haystack = [work.title, work.subtitle, work.searchTerm, work.genre, work.recommendation,
                        composer?.name ?? "", composer?.latinName ?? "", composer?.era ?? ""].joined(separator: " ")
        return words.allSatisfy { haystack.range(of: $0, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
    }
}

enum CatalogError: LocalizedError {
    case missingResource, invalidCatalog
    var errorDescription: String? { "曲库未能完整载入。请重新安装 App；你的导出备份可用于恢复学习记录。" }
}

enum WorkFilter: String, CaseIterable, Identifiable {
    case all = "全部", short = "不足 10 分钟", long = "30 分钟起", unlistened = "未听过"
    var id: String { rawValue }
    func includes(_ work: Work, listened: Set<String>) -> Bool {
        switch self {
        case .all: return true
        case .short: return work.minutes < 10
        case .long: return work.minutes >= 30
        case .unlistened: return !listened.contains(work.id)
        }
    }
}
