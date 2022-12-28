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
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
) {
    
    // Get the meeting ID from the original notification.
    let userInfo = response.notification.request.content.userInfo
    let someTag = userInfo["SOME_TAG"] as! String
    
    // Perform the task associated with the action.
    switch response.actionIdentifier {
    case "SOME_TAG":
        print("we got there, boys")
        break
    default:
        break
    }
    
    // Always call the completion handler when done.
    completionHandler()
}
