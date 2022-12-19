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
        sortDescriptors: [NSSortDescriptor(keyPath: \Alarm.date, ascending: true)],
        animation: .default)
    private var alarms: FetchedResults<Alarm>
    @State var showingSheet = true
    
    var body: some View {
        NavigationView {
            List(alarms) { alarm in
                NavigationLink {
                    Text("Alarm at \(alarm.date!, formatter: itemFormatter)")
                } label: {
                    Text(alarm.date!, formatter: itemFormatter)
                } }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        showingSheet = true
                    }) {
                        Label("Add Item", systemImage: "plus")
                            .sheet(isPresented: $showingSheet) {
                                AlarmSetterView()
                                    .presentationDetents([.medium]).environment(\.managedObjectContext, viewContext)
                            } } } } } }
    
    fileprivate func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { alarms[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        } } }

fileprivate let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    } }
