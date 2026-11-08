import Foundation
import Observation

struct LearningSnapshot: Codable, Equatable {
    var schemaVersion = 1
    var favorites: Set<String> = []
    var listened: Set<String> = []
    var notes: [String: String] = [:]
    var completedAt: [String: Date] = [:]
    var lastOpenedID: String?

    func validated(validIDs: Set<String>) throws -> Self {
        guard schemaVersion == 1, favorites.isSubset(of: validIDs), listened.isSubset(of: validIDs),
              Set(notes.keys).isSubset(of: validIDs), Set(completedAt.keys).isSubset(of: validIDs),
              Set(completedAt.keys).isSubset(of: listened),
              notes.values.allSatisfy({ $0.count <= 10_000 }),
              lastOpenedID.map({ validIDs.contains($0) }) ?? true else { throw BackupError.invalid }
        return self
    }
}

enum BackupError: LocalizedError {
    case invalid, oversized
    var errorDescription: String? {
        switch self {
        case .invalid: return "这不是兼容的古典指南备份，或其中包含无效曲目。现有记录未改变。"
        case .oversized: return "备份文件过大。请选择小于 2 MB 的古典指南 JSON 备份。"
        }
    }
}

@MainActor @Observable final class LearningStore {
    private(set) var snapshot = LearningSnapshot()
    var errorMessage: String?
    private(set) var needsRecovery = false
    private let defaults: UserDefaults
    private let validIDs: Set<String>
    private let key = "classicalGuide.learning.v1"

    init(catalog: Catalog, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        validIDs = Set(catalog.works.map(\.id))
        guard let data = defaults.data(forKey: key) else { return }
        do { snapshot = try JSONDecoder().decode(LearningSnapshot.self, from: data).validated(validIDs: validIDs) }
        catch {
            needsRecovery = true
            errorMessage = "本机学习记录无法读取，原始数据已保留。请在设置中导入备份，或确认清除后重新开始。"
        }
    }

    private func update(_ mutation: (inout LearningSnapshot) -> Void) {
        guard !needsRecovery else {
            errorMessage = "请先在设置中恢复备份或清除损坏的记录，以免覆盖原始数据。"
            return
        }
        var next = snapshot
        mutation(&next)
        do {
            let data = try JSONEncoder().encode(next.validated(validIDs: validIDs))
            defaults.set(data, forKey: key)
            snapshot = next
        } catch { errorMessage = error.localizedDescription }
    }

    func toggleFavorite(_ id: String) {
        guard validIDs.contains(id) else { return }
        update { state in
            if state.favorites.contains(id) { state.favorites.remove(id) }
            else { state.favorites.insert(id) }
        }
    }

    func toggleListened(_ id: String, now: Date = .now) {
        guard validIDs.contains(id) else { return }
        update { state in
            if state.listened.contains(id) {
                state.listened.remove(id)
                state.completedAt.removeValue(forKey: id)
            } else {
                state.listened.insert(id)
                state.completedAt[id] = now
            }
        }
    }

    func setNote(_ note: String, for id: String) {
        guard validIDs.contains(id) else { return }
        update { state in
            let text = String(note.prefix(10_000))
            if text.isEmpty { state.notes.removeValue(forKey: id) }
            else { state.notes[id] = text }
        }
    }

    func open(_ id: String) {
        guard validIDs.contains(id), !needsRecovery else { return }
        update { $0.lastOpenedID = id }
    }

    func exportData() throws -> Data {
        // A recovery export preserves the original bytes, instead of exporting an empty state.
        if needsRecovery, let original = defaults.data(forKey: key) { return original }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(snapshot)
    }

    func importData(_ data: Data) throws {
        guard data.count <= 2_000_000 else { throw BackupError.oversized }
        let incoming: LearningSnapshot
        do { incoming = try JSONDecoder().decode(LearningSnapshot.self, from: data).validated(validIDs: validIDs) }
        catch { throw BackupError.invalid }
        var merged = snapshot
        merged.favorites.formUnion(incoming.favorites)
        merged.listened.formUnion(incoming.listened)
        // Preserve existing notes if both copies contain a note for the same work.
        merged.notes.merge(incoming.notes) { current, _ in current }
        merged.completedAt.merge(incoming.completedAt) { current, restored in min(current, restored) }
        if merged.lastOpenedID == nil { merged.lastOpenedID = incoming.lastOpenedID }
        defaults.set(try JSONEncoder().encode(merged), forKey: key)
        snapshot = merged
        needsRecovery = false
        errorMessage = nil
    }

    func reset() {
        defaults.removeObject(forKey: key)
        snapshot = LearningSnapshot()
        needsRecovery = false
        errorMessage = nil
    }
}
