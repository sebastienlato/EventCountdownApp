//
//  EventCountdownAppApp.swift
//  EventCountdownApp
//
//  Created by sebastien lato on 2025-11-05.
//

import SwiftUI

/// Root scene for the Countdown experience; wires SwiftUI to the app lifecycle.
@main
struct EventCountdownAppApp: App {
    var body: some Scene {
        WindowGroup {
            // CountdownListView orchestrates the full feature set, so surface it right away.
            CountdownListView()
        }
    }
}
