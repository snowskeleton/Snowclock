//
//  PermissionsView.swift
//  Snowclock
//
//  Created by snow on 5/10/23.
//

import SwiftUI
import CoreData

struct IndiPermissionView: View {
    var title: String
    var toggle: Bool
    var options: Array = ["Enabled", "Disabled"]
    var body: some View {
        HStack {
            Text("\(title):")
            Spacer()
            Text(toggle ? options[0] : options[1])
        }
    }
}
struct PermissionsView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @Environment(\.dismiss) private var dismiss
    
    @State var persistentBannerEnabled = false
    @State var bannerEnabled = false
    @State var soundEnabled = false
    @State var lockScreenEnabled = false
    @State var notificationsEnabled = false
    @State var timeSensitiveEnabled = false
    @State var criticalAlertsEnabled = false
    
    var body: some View {
        NavigationView {
            List {
                IndiPermissionView(title: "Notifications", toggle: notificationsEnabled)
                IndiPermissionView(title: "Sound", toggle: soundEnabled)
                Section(header: Text("Where to show alarms")) {
                    IndiPermissionView(title: "Lock Screen", toggle: lockScreenEnabled)
                    IndiPermissionView(title: "Banner", toggle: bannerEnabled)
                    if bannerEnabled {
                        IndiPermissionView( title: "Persistent Banner", toggle: persistentBannerEnabled)
                    }
                }
                Section(header: Text("Special Permissions")) {
                    IndiPermissionView(title: "Time Sensitive", toggle: timeSensitiveEnabled)
                    IndiPermissionView(title: "Critical Alerts", toggle: criticalAlertsEnabled)
                }
                
                Section {
                    Button("Open Notification Settings") {
                        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                Section(footer: Text("Ensure Snowclock has permission for any Focus modes you use.")) {}
                
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: {
                    dismiss()
                })
            }
        }
        .task {
            UNUserNotificationCenter.current().getNotificationSettings  { settings in
                bannerEnabled = settings.alertSetting.rawValue == 2
                criticalAlertsEnabled = settings.criticalAlertSetting.rawValue == 2
                if bannerEnabled {
                    persistentBannerEnabled = settings.alertStyle.rawValue == 2
                }
                soundEnabled = settings.soundSetting.rawValue == 2
                lockScreenEnabled = settings.lockScreenSetting.rawValue == 2
                notificationsEnabled = settings.authorizationStatus.rawValue == 2
                timeSensitiveEnabled = settings.timeSensitiveSetting.rawValue == 2
            }
        }
    }
}

struct PermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsView()
    }
}
