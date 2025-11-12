import Foundation

/// Plain model describing a countdown item that we can persist, render, or sync.
struct CountdownEvent: Identifiable, Codable, Hashable {
    /// Stable identifier used for persistence, notifications, and SwiftUI diffing.
    let id: UUID
    /// Display name shown to the user.
    var title: String
    /// Target date/time we count toward.
    var date: Date
    /// Emoji used as a lightweight icon for the event.
    var emoji: String
    
    init(id: UUID = UUID(), title: String, date: Date, emoji: String) {
        self.id = id
        self.title = title
        self.date = date
        self.emoji = emoji
    }
}
