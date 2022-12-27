//
//  Declare_AlarmApp.swift
//  Declare Alarm
//
//  Created by snow on 12/16/22.
//

import SwiftUI

@main
struct Declare_AlarmApp: App {
    @Environment(\.scenePhase) var scenePhase
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
