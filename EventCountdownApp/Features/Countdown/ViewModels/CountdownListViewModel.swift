import Combine
import Foundation
import EventKit
import AudioToolbox
import UIKit

@MainActor
final class CountdownListViewModel: ObservableObject {
    @Published private(set) var events: [CountdownEvent] = []
    @Published var celebrationEvent: CountdownEvent?
    
    private var completedEvents: Set<UUID> = []
    private let eventsKey = "events"
    private let completedEventsKey = "completedEvents"
    private let eventStore = EKEventStore()
    private let notificationManager = CountdownNotificationManager()
    private var notificationAuthorizationGranted = false
    
    func loadData() {
        loadEvents()
        loadCompletedEvents()
        
        if notificationAuthorizationGranted {
            notificationManager.syncNotifications(for: events)
        }
    }
    
    func prepareNotifications() {
        notificationManager.requestAuthorizationIfNeeded { [weak self] granted in
            guard let self = self else { return }
            Task { @MainActor in
                self.notificationAuthorizationGranted = granted
                guard granted else { return }
                self.notificationManager.syncNotifications(for: self.events)
            }
        }
    }
    
    func upsert(_ event: CountdownEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        } else {
            events.append(event)
        }
        persistEvents()
        notificationManager.scheduleNotification(for: event)
    }
    
    func delete(_ event: CountdownEvent) {
        events.removeAll { $0.id == event.id }
        completedEvents.remove(event.id)
        persistEvents()
        persistCompletedEvents()
        notificationManager.removeNotification(for: event.id)
    }
    
    func checkForCompletedEvents(previousDate: Date, currentDate: Date) {
        for event in events where !completedEvents.contains(event.id) {
            if previousDate < event.date && currentDate >= event.date {
                completedEvents.insert(event.id)
                persistCompletedEvents()
                notificationManager.removeNotification(for: event.id)
                triggerCelebration(for: event)
            }
        }
    }
    
    func syncWithCalendar() {
        eventStore.requestFullAccessToEvents { [weak self] granted, error in
            guard let self = self, error == nil, granted else { return }
            Task { @MainActor in
                self.importCalendarEvents()
            }
        }
    }
    
    private func loadEvents() {
        guard let data = UserDefaults.standard.data(forKey: eventsKey),
              let decoded = try? JSONDecoder().decode([CountdownEvent].self, from: data) else {
            events = []
            return
        }
        events = decoded
    }
    
    private func loadCompletedEvents() {
        guard let data = UserDefaults.standard.data(forKey: completedEventsKey),
              let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: data) else {
            completedEvents = []
            return
        }
        completedEvents = decoded
    }
    
    private func persistEvents() {
        guard let encoded = try? JSONEncoder().encode(events) else { return }
        UserDefaults.standard.set(encoded, forKey: eventsKey)
    }
    
    private func persistCompletedEvents() {
        guard let encoded = try? JSONEncoder().encode(completedEvents) else { return }
        UserDefaults.standard.set(encoded, forKey: completedEventsKey)
    }
    
    private func importCalendarEvents() {
        let calendars = eventStore.calendars(for: .event)
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate) ?? startDate
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let calendarEvents = eventStore.events(matching: predicate)
        
        var observedIdentifiers = Set(events.map { makeIdentifier(title: $0.title, date: $0.date) })
        
        for ekEvent in calendarEvents.prefix(20) {
            let identifier = makeIdentifier(title: ekEvent.title, date: ekEvent.startDate)
            guard !observedIdentifiers.contains(identifier) else { continue }
            observedIdentifiers.insert(identifier)
            
            let newEvent = CountdownEvent(
                title: ekEvent.title,
                date: ekEvent.startDate,
                emoji: "📅"
            )
            events.append(newEvent)
            notificationManager.scheduleNotification(for: newEvent)
        }
        
        persistEvents()
    }
    
    private func makeIdentifier(title: String, date: Date) -> String {
        let day = Calendar.current.startOfDay(for: date).timeIntervalSinceReferenceDate
        return "\(title)#\(day)"
    }
    
    private func triggerCelebration(for event: CountdownEvent) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        playSound()
        celebrationEvent = event
    }
    
    private func playSound() {
        let systemSoundID: SystemSoundID = 1016
        AudioServicesPlaySystemSound(systemSoundID)
    }
}
