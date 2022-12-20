//
//  ContentView.swift
//  Declare Alarm
//
//  Created by snow on 12/16/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Alarm.time, ascending: true)],
        animation: .default)
    private var alarms: FetchedResults<Alarm>
    @State var showingSheet = false
    
    var body: some View {
        NavigationView {
            List(alarms) { alarm in
                NavigationLink {
                    AlarmDetailsView(alarm: Binding<Alarm>.constant(alarm)).environment(\.managedObjectContext, viewContext)
                } label: {
                    Text(alarm.time!, formatter: itemFormatter)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        showingSheet = true
                    }) {
                        Label("Add Item", systemImage: "plus")
                            .sheet(isPresented: $showingSheet) {
                                AlarmSetterView()
                                    .presentationDetents([.medium]).environment(\.managedObjectContext, viewContext)
                            }
                    }
                }
            }
        }
    }
    
    fileprivate func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { alarms[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
