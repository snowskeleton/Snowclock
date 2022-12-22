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
    @State var showSheet = false
    
    init(preview: Bool = false, showSheet: Bool = false) {
        _showSheet = State(initialValue: showSheet)
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(alarms) { alarm in
                    NavigationLink {
                        AlarmDetailsView(alarm: Binding<Alarm>.constant(alarm))
                            .environment(\.managedObjectContext, viewContext)
                    } label: {
                        Text(alarm.time!, formatter: shortDate)
                    }
                    .font(.title)
                    .padding()
                }.onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        showSheet = true
                    }) {
                        Label("Add Item", systemImage: "plus")
                            .sheet(isPresented: $showSheet) {
                                AlarmSetterView()
                                    .presentationDetents([.medium])
                                    .environment(\.managedObjectContext, viewContext)
                            }
                    }
                }
            }
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
