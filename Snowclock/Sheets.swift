//
//  ContentSheets.swift
//  Snowclock
//
//  Created by snow on 6/22/23.
//

import SwiftUI
import CoreData
struct AddAlarmMiniSheet: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @Environment(\.dismiss) private var dismiss
    @State private var date: Date = Date()
    
    var body: some View {
        Section {
            VStack {
                DatePicker("Alarm time",
                           selection: $date,
                           displayedComponents: [.hourAndMinute])
                .padding()
                .labelsHidden()
                .datePickerStyle(.wheel)
                Spacer()
                Button("Done") {
                    let _ = alarmMaker(context: viewContext, time: $date.wrappedValue)
                    dismiss()
                }.accessibilityLabel("Save")
            }.padding()
        }
    }
}

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

struct PermissionsSheet: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Alarm.time,
                ascending: true
            )],
        animation: .default)
    private var alarms: FetchedResults<Alarm>
    
    private let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    @State var persistentBannerEnabled = false
    @State var bannerEnabled = false
    @State var soundEnabled = false
    @State var lockScreenEnabled = false
    @State var notificationsEnabled = false
    @State var timeSensitiveEnabled = false
    @State var criticalAlertsEnabled = false
    
    var body: some View {
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
            
            Section(footer: Text("Disables all alarms and removes all queued notifications.")) {
                Button("Clear all notifications", role: .destructive) { clearNotifications() }
            }
        }
        .onReceive(timer) { _ in
            setStates()
        }
    }
    
    fileprivate func setStates() {
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
    
    fileprivate func clearNotifications() {
        UNUserNotificationCenter
            .current()
            .removeAllPendingNotificationRequests()
        for alarm in alarms {
            alarm.enabled = false
            alarm.updateNotifications()
        }
        dismiss()
        
    }
}


struct ScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var schedule: [Bool]
    
    var body: some View {
        VStack {
            List {
                ForEach(days, id: \.self) { day in
                    Button(action: {
                        schedule[days.firstIndex(of: day)!].toggle()
                    }) {
                        HStack {
                            Text("\(day)")
                            if schedule[days.firstIndex(of: day)!] == true {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                Spacer()
                Button(action: {
                    toggle(days: [1,2,3,4,5], value: !allWeekDaysSelected)
                }) { Text("Weekdays") }
                Button(action: {
                    toggle(days: [0,6], value: !allWeekEndsSelected)
                }) { Text("Weekends") }
            }
            Spacer()
            Button("Back") {dismiss()}
        }
    }
    
    fileprivate let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    fileprivate var allWeekDaysSelected: Bool {
        return schedule[1] && schedule[2] && schedule[3] && schedule[4] && schedule[5]
    }
    fileprivate var allWeekEndsSelected: Bool {
        return schedule[0] && schedule[6]
    }
    
    fileprivate func toggle(days: [Int], value: Bool) {
        for i in days {
            schedule[i] = value
        }
    }
}


//struct SettingsView: View {
//    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
//    @Environment(\.dismiss) private var dismiss
//    @State var bypassMuteSwitch = false
//
//
//    var body: some View {
//        NavigationView {
//            List {
//                Toggle(
//                    isOn: $bypassMuteSwitch,
//                    label: {
//                        Text("Bypass Mute Switch")
//                            .foregroundColor(Color.secondary)
//                    }
//                )
//            }
//        }
//        .toolbar {
//            ToolbarItem(placement: .confirmationAction) {
//                Button("Save", action: {
//                    dismiss()
//                })
//            }
//        }
//    }
//}
