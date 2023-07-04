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

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @Environment(\.scenePhase) private var scenePhase
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Alarm.time,
                ascending: true
            )],
        animation: .default)
    private var alarms: FetchedResults<Alarm>
    @State var showAddAlarm = false
    @State var showSettings = false
    @State var showPermissions = false
    @State var audioPlayer: AVAudioPlayer!
    
    init(preview: Bool = false, showSheet: Bool = false) {
        _showAddAlarm = State(initialValue: showSheet)
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(alarms) { alarm in
                    NavigationLink {
                        AlarmView(alarm: Binding<Alarm>.constant(alarm))
                            .environment(\.managedObjectContext, viewContext)
                    } label: {
                        AlarmListBoxView(alarm: Binding<Alarm>.constant(alarm))
                            .environment(\.managedObjectContext, viewContext)
                    }
                }.onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(
                        action: { showPermissions = true },
                        label:  {
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(Color.secondary)
                        }
                    ).accessibilityLabel(("Check Permissions"))
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(
                        action: { showAddAlarm = true },
                        label:  {
                            Image(systemName: "plus.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(Color.secondary)
                        }
                    ).accessibilityLabel(("New Alarm"))
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showAddAlarm) {
            AddAlarmMiniSheet()
                .presentationDetents([.medium])
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showPermissions) {
            PermissionsSheet()
                .environment(\.managedObjectContext, viewContext)
        }
    }
    
    fileprivate func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { alarms[$0] }.forEach(viewContext.delete)
        }
    }
}

struct AlarmListBoxView: View {
    @Binding var alarm: Alarm
    var weeklySchedule: String {
        var s = String()
        s += alarm.name!
        let stringySchedule = daysAsString(days: alarm.schedule!)
        if stringySchedule != "" {
            s += ", "
            s += stringySchedule
        }
        return s
    }
    var stringyFollowups: String {
        var ans = String()
        var set = alarm.followups?.allObjects as! [Followup]
        set = set.sorted(by: { $0.delay < $1.delay })
        for f in set {
            let i = f.delay
            if i > 0 {
                ans += "+\(String(f.delay)) "
            }
            if i < 0 {
                ans += "\(String(f.delay)) "
            }
        }
        return ans
    }
    var body: some View {
        VStack {
            HStack {
                Text(alarm.time!.formatted(date: .omitted, time: .shortened))
                    .font(.title)
                Text(stringyFollowups)
                VStack {
                    Spacer()
                    Toggle(isOn: $alarm.enabled) {}
                        .onChange(of: alarm.enabled) { _ in
                            alarm.updateNotifications()
                        }
                }
            }
            HStack {
                Text(weeklySchedule)
                Spacer()
            }
        }
        .foregroundColor(alarm.enabled ? Color.primary : Color.secondary)
        .italic(!alarm.enabled)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
