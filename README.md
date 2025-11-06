# EventCountdownApp

EventCountdownApp is a SwiftUI project that helps you track upcoming milestones with live countdowns, calendar import, and background notifications. Create personal events, keep them synced across launches, and celebrate when they arrive.

## Features
- Add, edit, or delete countdown events with emojis, dates, and times.
- Automatically import upcoming events from the system calendar (with permission).
- Persist countdown data locally and receive local notifications even when the app is closed.
- View time remaining in days, hours, minutes, and seconds with a clean SwiftUI layout.

## Project Structure
- `EventCountdownApp/App/`: Application entry point.
- `EventCountdownApp/Features/Countdown/`: SwiftUI views, view models, and models for the countdown feature.
- `EventCountdownApp/Services/`: Shared services, such as notification helpers.
- `EventCountdownApp/Assets.xcassets/`: Design assets and color resources.

## Getting Started
1. Open `EventCountdownApp.xcodeproj` in Xcode 15 or newer.
2. Select an iOS simulator (e.g., iPhone 15) and press ⌘R to run.
3. On first launch, accept the local notification permission prompt to enable background alerts.

## Key Commands
```bash
# Build in the simulator
xcodebuild -scheme EventCountdownApp -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run tests
xcodebuild test -scheme EventCountdownApp -destination 'platform=iOS Simulator,name=iPhone 15'
```
