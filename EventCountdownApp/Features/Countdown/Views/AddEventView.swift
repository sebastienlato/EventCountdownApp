import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var date = Date()
    @State private var emoji = "🎉"
    
    let existingEvent: CountdownEvent?
    let onSave: (CountdownEvent) -> Void
    
    private let emojis = [
        "🎉", "🎂", "✈️", "🎓", "💍", "🏖️", "🎄", "🎃", "❤️", "🎁", "🏆", "🎭", "🎸",
        "🏠", "👶", "📅", "🚢", "🎊", "🌟", "⚽️", "🎮", "🍕", "🌴", "⛰️", "🏋️", "🎬",
        "📚", "💼", "🚗", "🎨", "☕️", "🌈"
    ]
    
    init(existingEvent: CountdownEvent? = nil, onSave: @escaping (CountdownEvent) -> Void) {
        self.existingEvent = existingEvent
        self.onSave = onSave
        
        if let event = existingEvent {
            _title = State(initialValue: event.title)
            _date = State(initialValue: event.date)
            _emoji = State(initialValue: event.emoji)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    emojiPicker
                    titleField
                    datePicker
                }
                .padding()
            }
            .navigationTitle(existingEvent == nil ? "New Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(existingEvent == nil ? "Add" : "Save") {
                        let event = CountdownEvent(
                            id: existingEvent?.id ?? UUID(),
                            title: title.isEmpty ? "Untitled Event" : title.trimmingCharacters(in: .whitespacesAndNewlines),
                            date: date,
                            emoji: emoji
                        )
                        onSave(event)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
    
    private var emojiPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Emoji")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(emojis, id: \.self) { item in
                        Button {
                            emoji = item
                        } label: {
                            Text(item)
                                .font(.system(size: 40))
                                .frame(width: 60, height: 60)
                                .background(emoji == item ? Color.blue.opacity(0.2) : Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.horizontal, -16)
        }
    }
    
    private var titleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Event Name")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            
            TextField("e.g., My Birthday", text: $title)
                .textFieldStyle(.roundedBorder)
                .font(.body)
        }
    }
    
    private var datePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date & Time")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            
            DatePicker("", selection: $date)
                .datePickerStyle(.graphical)
        }
    }
}
