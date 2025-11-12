import Foundation
import UserNotifications

/// Wraps UNUserNotificationCenter coordination for countdown reminders.
final class CountdownNotificationManager {
    private let center = UNUserNotificationCenter.current()
    
    /// Ensures we only prompt for notifications once and return the current status via closure.
    func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        fetchAuthorizationStatus { [weak self] status in
            guard let self = self else { return }
            
            switch status {
            case .authorized, .provisional, .ephemeral:
                completion(true)
            case .denied:
                completion(false)
            case .notDetermined:
                self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    completion(granted)
                }
            @unknown default:
                completion(false)
            }
        }
    }
    
    /// Aligns pending notifications with the in-memory events array.
    func syncNotifications(for events: [CountdownEvent]) {
        let identifiers = events.map { $0.id.uuidString }
        
        center.getPendingNotificationRequests { [weak self] requests in
            let existing = Set(requests.map(\.identifier))
            let desired = Set(identifiers)
            
            let toRemove = Array(existing.subtracting(desired))
            if !toRemove.isEmpty {
                self?.center.removePendingNotificationRequests(withIdentifiers: toRemove)
            }
            
            events.forEach { event in
                self?.scheduleNotification(for: event)
            }
        }
    }
    
    /// Creates or refreshes one notification per countdown (if the date is still in the future).
    func scheduleNotification(for event: CountdownEvent) {
        guard event.date > Date() else {
            removeNotification(for: event.id)
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "\(event.emoji) Event Reached!"
        content.body = "\(event.title) is happening now!"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: event.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: event.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        center.add(request, withCompletionHandler: nil)
    }
    
    /// Cancels a previously scheduled notification by identifier.
    func removeNotification(for id: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
    
    private func fetchAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }
}
