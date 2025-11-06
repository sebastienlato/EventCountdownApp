import Foundation

struct CountdownEvent: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var date: Date
    var emoji: String
    
    init(id: UUID = UUID(), title: String, date: Date, emoji: String) {
        self.id = id
        self.title = title
        self.date = date
        self.emoji = emoji
    }
}
