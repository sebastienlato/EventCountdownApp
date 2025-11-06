import SwiftUI

struct EventCard: View {
    let event: CountdownEvent
    let currentDate: Date
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    private var timeRemaining: (isPast: Bool, days: Int, hours: Int, minutes: Int, seconds: Int) {
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: event.date)
        let isPast = event.date < currentDate
        return (
            isPast,
            abs(components.day ?? 0),
            abs(components.hour ?? 0),
            abs(components.minute ?? 0),
            abs(components.second ?? 0)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(event.emoji)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                    
                    Text(event.date, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundStyle(.blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
            
            if timeRemaining.isPast {
                Text("Event Passed")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 20) {
                    TimeUnit(value: timeRemaining.days, unit: "days")
                    TimeUnit(value: timeRemaining.hours, unit: "hrs")
                    TimeUnit(value: timeRemaining.minutes, unit: "min")
                    TimeUnit(value: timeRemaining.seconds, unit: "sec")
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct TimeUnit: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title.bold())
                .monospacedDigit()
            
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
