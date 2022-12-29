//
//  ContentView.swift
//  Snowclock
//
//  Created by snow on 12/16/22.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @Environment(\.scenePhase) private var scenePhase
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Alarm.time, ascending: false)],
        animation: .default)
    private var noalarms: FetchedResults<Alarm>
    var nextAlarm: Optional<Alarm> {
        let val = noalarms.filter( {$0.enabled} )
        return val.min(by: { $0.time! > $1.time! })
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Alarm.time, ascending: true)],
        animation: .default)
    private var alarms: FetchedResults<Alarm>
    @State var showAddAlarm = false
    
    
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
    }
 
    fileprivate func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { alarms[$0] }.forEach(viewContext.delete)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
