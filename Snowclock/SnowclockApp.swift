//
//  SnowclockApp.swift
//  Snowclock
//
//  Created by snow on 12/16/22.
//

import SwiftUI
import AVKit
import CoreData

@main
struct SnowclockApp: App {
    @Environment(\.scenePhase) var scenePhase
    let persistenceController = PersistenceController.shared
    private let context = PersistenceController.shared.container.viewContext
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, context)
        }
        .onChange(of: scenePhase) { _ in
            try? context.save()
        }
    }
}
