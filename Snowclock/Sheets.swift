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
                }
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



struct PendingNotificationsSheet: View {
    
//    var notifications: [UNNotificationRequest] {
//        let center = UNUserNotificationCenter.current()
//        var temp: [UNNotificationRequest] = []
//        center.getPendingNotificationRequests { (notificationRequests) in
//            for notificationRequest:UNNotificationRequest in notificationRequests {
//                temp.append(notificationRequest)
//            }
//        }
//        print(temp)
//        return temp
//    }
    var body: some View {
        List {
            Text("Default")
//            Text("Length: \(notifications.count)")
            ForEach(getNotes(), id: \.self) { note in
                Text("What do you see?")
                Text(note.content.title)
            }
        }
    }
}

private func getNotes() -> [UNNotificationRequest] {
    var temp: [UNNotificationRequest] = []
    UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
        for notificationRequest:UNNotificationRequest in notificationRequests {
            temp.append(notificationRequest)
            print(temp)
        }
    }
//    print(temp.count)
    return temp
}

struct SoundsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var newSound: String
    var body: some View {
        VStack {
            List {
                ForEach(getSounds(), id: \.self) { sound in
                    Button(action: {
                        newSound = sound
                    }, label: {
                        HStack {
                            Text("\(sound)")
                            if newSound == sound {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    })
                }
            }
            Spacer()
            Button("Back") {dismiss()}
        }
    }
}
func getSounds() -> [String]{
    ///File Manager alows us access to the device's files to which we are allowed.
    let fileManager: FileManager = FileManager()

//    let rootSoundDirectory = Bundle.main.resourcePath
////    print(rootSoundDirectory!)
//    let newDirectory: NSMutableDictionary = [
//        "path" : "\(rootSoundDirectory!)",
//        "files" : [] as [String]
//    ]
    /**
     For each directory, it looks at each item (file or directory) and only appends the sound files to the soundfiles[i]files array.

     - URLs: All of the contents of the directory (files and sub-directories).
     */
//    let directoryURL: URL = URL(
//        fileURLWithPath: newDirectory.value(forKey: "path") as! String,
//        isDirectory: true
//    )
    let directoryURL = Bundle.main.resourceURL
    print(directoryURL as Any)
//    directoryURL = directoryURL!.appendingPathComponent("Snowclock")
//    print(directoryURL)


    var URLs: [URL] = []
    do {
        URLs = try fileManager.contentsOfDirectory(
            at: directoryURL!,
            includingPropertiesForKeys: [URLResourceKey.isDirectoryKey],
            options: FileManager.DirectoryEnumerationOptions()
        )
    } catch {
        debugPrint("\(error)")
    }
    var urlIsaDirectory: ObjCBool = ObjCBool(false)
    var soundPaths: [String] = []
    for url in URLs {
        fileManager.fileExists(
            atPath: url.path,
            isDirectory: &urlIsaDirectory
        )
        if !urlIsaDirectory.boolValue && url.absoluteString.hasSuffix(".m4r") {
            soundPaths.append("\(url.lastPathComponent)")
        }
    }
    return soundPaths
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
                    toggle(days: weekdays, value: !allWeekDaysSelected)
                }) {
                    Text("Weekdays")
                }
                Button(action: {
                    toggle(days: weekends, value: !allWeekEndsSelected)
                }) {
                    Text("Weekends")
                }
            }
            Spacer()
            Button("Back") {dismiss()}
        }
    }
    
    fileprivate let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    fileprivate let weekdays = [1,2,3,4,5]
    fileprivate let weekends = [0,6]
    
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
