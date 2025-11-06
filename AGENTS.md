# Repository Guidelines

## Project Structure & Module Organization
- Main SwiftUI sources live in `EventCountdownApp/`. `EventCountdownAppApp.swift` configures the scene, while `ContentView.swift` holds the default UI. Add new features as folders (`EventCountdownApp/Features/EventList`, etc.) to keep views, models, and modifiers grouped.
- Store design assets in `EventCountdownApp/Assets.xcassets`; add image sets and colors there so they sync with interface previews.
- When you introduce preview-only helpers, keep them in `EventCountdownApp/Shared/PreviewSupport` and gate them with `#if DEBUG` to keep production code lean.

## Build, Test, and Development Commands
- `open EventCountdownApp.xcodeproj` launches Xcode with the correct workspace; use ⌘R to run the simulator build.
- `xcodebuild -scheme EventCountdownApp -destination 'platform=iOS Simulator,name=iPhone 15' build` performs a clean CLI build suitable for CI smoke checks.
- `xcodebuild test -scheme EventCountdownApp -destination 'platform=iOS Simulator,name=iPhone 15'` runs the XCTest suite; pair it with `clean` when chasing intermittent failures.

## Coding Style & Naming Conventions
- Follow Swift API Design Guidelines: `UpperCamelCase` for types, `lowerCamelCase` for properties/functions, and verbs for actions (e.g., `startCountdown()`).
- Use 4-space indentation and rely on Xcode’s “Editor > Format > Re-Indent” before committing. Prefer `struct` for views/state containers unless reference semantics are required.
- Annotate logical sections with `// MARK:` and keep files under ~200 lines by extracting subviews or extensions.

## Testing Guidelines
- Co-locate tests under `EventCountdownAppTests/`, mirroring the production folder names (`EventListViewTests.swift`, etc.).
- Use XCTest with the `test_featureExpectation_whenCondition` naming pattern for clarity. Aim for ≥80% coverage on business logic utilities and any date/time calculations.
- Run `xcodebuild test -scheme EventCountdownApp -destination 'platform=iOS Simulator,name=iPhone 15'` (or ⌘U inside Xcode) before opening a pull request; include failing screenshots when reproducing bugs.

## Commit & Pull Request Guidelines
- There is no existing Git history, so adopt Conventional Commits (`feat: add countdown list view`, `fix: correct remaining-time formatter`) to communicate intent to reviewers and automation.
- Each PR should include: purpose summary, linked issue (if any), simulator/device tested, and screenshots for UI-facing changes. Reference the test command you executed so reviewers can replay it quickly.
- Keep PRs focused; if you must touch unrelated files (e.g., reformatting), isolate that work in a preparatory commit to simplify review.
