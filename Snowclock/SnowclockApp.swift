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
    @State var showPendingNotifications = false
    @State var audioPlayer: AVAudioPlayer!
    
    init(preview: Bool = false, showSheet: Bool = false) {
        _showAddAlarm = State(initialValue: showSheet)
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(alarms) { alarm in
                    NavigationLink {
                        AlarmDetailsView(alarm: Binding<Alarm>.constant(alarm))
                            .environment(\.managedObjectContext, viewContext)
                    } label: {
                        AlarmBoxView(alarm: Binding<Alarm>.constant(alarm))
                            .environment(\.managedObjectContext, viewContext)
                    }
                }.onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(
                        action: { showPendingNotifications = true },
                        label:  {
                            Image(systemName: "gear")
                                .foregroundColor(Color.secondary)
                        }
                    )
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(
                        action: { showPermissions = true },
                        label:  {
                            Image(systemName: "bell")
                                .foregroundColor(Color.secondary)
                        }
                    )
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
                    )
                }
            }
        }
        .sheet(isPresented: $showAddAlarm) {
            AddAlarmView()
                .presentationDetents([.medium])
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showPermissions) {
            PermissionsView()
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showPendingNotifications) {
            PendingNotificationsView()
                .environment(\.managedObjectContext, viewContext)
        }
    }
    
    fileprivate func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { alarms[$0] }.forEach(viewContext.delete)
        }
    }
}

struct AlarmBoxView: View {
    @Binding var alarm: Alarm
    var showthis: String {
        var s = String()
        s += alarm.name!
        if alarm.stringySchedule != "" {
            s += ", "
            s += alarm.stringySchedule
        }
        return s
    }
    var body: some View {
        VStack {
            HStack {
                Text(alarm.time!, formatter: shortDate)
                    .font(.title)
                Text(alarm.stringyFollowups)
                VStack {
                    Spacer()
                    Toggle(isOn: $alarm.enabled) {}
                        .onChange(of: alarm.enabled) { _ in
                            alarm.updateNotifications()
                        }
                }
            }
            HStack {
                Text(showthis)
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
