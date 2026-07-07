import Foundation

struct BreathReading: Identifiable, Codable, Equatable {
    let id: UUID
    var createdAt: Date
    var petName: String
    var breathCount: Double
    var takenAt: Date
    var notes: String

    init(id: UUID = UUID(), createdAt: Date = Date(), petName: String = "", breathCount: Double = 0, takenAt: Date = Date(), notes: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.petName = petName
        self.breathCount = breathCount
        self.takenAt = takenAt
        self.notes = notes
    }
}
