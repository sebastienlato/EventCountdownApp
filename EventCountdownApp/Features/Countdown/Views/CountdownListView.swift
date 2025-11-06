import Combine
import SwiftUI

struct CountdownListView: View {
    @StateObject private var viewModel = CountdownListViewModel()
    @State private var showingAddEvent = false
    @State private var editingEvent: CountdownEvent?
    @State private var currentDate = Date()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.events.isEmpty {
                        emptyState
                    } else {
                        ForEach(viewModel.events.sorted { $0.date < $1.date }) { event in
                            EventCard(
                                event: event,
                                currentDate: currentDate,
                                onEdit: { editingEvent = event },
                                onDelete: { viewModel.delete(event) }
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Countdown")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.syncWithCalendar()
                    } label: {
                        Image(systemName: "calendar.badge.clock")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView { event in
                    viewModel.upsert(event)
                }
            }
            .sheet(item: $editingEvent) { event in
                AddEventView(existingEvent: event) { updatedEvent in
                    viewModel.upsert(updatedEvent)
                }
            }
            .onReceive(timer) { _ in
                let previousDate = currentDate
                currentDate = Date()
                viewModel.checkForCompletedEvents(previousDate: previousDate, currentDate: currentDate)
            }
            .onAppear {
                viewModel.loadData()
                currentDate = Date()
                viewModel.prepareNotifications()
            }
            .alert(item: $viewModel.celebrationEvent) { event in
                Alert(
                    title: Text("\(event.emoji) Event Reached!"),
                    message: Text("\(event.title) is happening now!"),
                    dismissButton: .default(Text("Celebrate! 🎉"))
                )
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "hourglass")
                .font(.system(size: 70))
                .foregroundStyle(.gray.opacity(0.5))
            
            Text("No Events Yet")
                .font(.title2.bold())
            
            Text("Tap + to add an event and start counting down")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CountdownListView()
}
