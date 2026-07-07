import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var entries: [BreathReading] = []
    @Published var isPro: Bool = false

    /// Free-tier cap. Kept comfortably above seed count so a fresh install
    /// never hits the paywall on first launch.
    let freeLimit = 30

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("pantpace_entries.json")
        load()
    }

    var canAddMore: Bool {
        isPro || entries.count < freeLimit
    }

    func add(_ entry: BreathReading) {
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: BreathReading) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: BreathReading) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([BreathReading].self, from: data) {
            entries = decoded
        } else {
            entries = Store.seedData
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    static var seedData: [BreathReading] {
        [
        BreathReading(petName: "Pet Name 1", breathCount: 1.0, takenAt: Date().addingTimeInterval(-86400), notes: "Notes 1"),
        BreathReading(petName: "Pet Name 2", breathCount: 2.0, takenAt: Date().addingTimeInterval(-172800), notes: "Notes 2"),
        BreathReading(petName: "Pet Name 3", breathCount: 3.0, takenAt: Date().addingTimeInterval(-259200), notes: "Notes 3"),
        BreathReading(petName: "Pet Name 4", breathCount: 4.0, takenAt: Date().addingTimeInterval(-345600), notes: "Notes 4"),
        BreathReading(petName: "Pet Name 5", breathCount: 5.0, takenAt: Date().addingTimeInterval(-432000), notes: "Notes 5"),
        BreathReading(petName: "Pet Name 6", breathCount: 6.0, takenAt: Date().addingTimeInterval(-518400), notes: "Notes 6")
        ]
    }
}
