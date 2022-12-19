//
//  ContentView.swift
//  Declare Alarm
//
//  Created by snow on 12/16/22.
//

import SwiftUI
import CoreData
struct AlarmSetterView: View {
    @State private var date: Date = Date()
    @State var something = [false, false, false, false, false, false, false]
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
                DayOfTheWeekPicker(activeDays: $something)
            }.padding()
        }
    }
}
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var alarms: FetchedResults<Item>
    @State var showingSheet = true

    var body: some View {
        NavigationView {
            List {
                ForEach(alarms) { alarm in
                    NavigationLink {
                        Text("Alarm at \(alarm.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(alarm.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                        .sheet(isPresented: $showingSheet) {
                            AlarmSetterView()
                                .presentationDetents([.medium])
                                .onDisappear(perform: save)
                            
                        }
                    }
                }
            }
            Text("Select an item")
        }
    }

    fileprivate func addItem() {
        showingSheet = true
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

        }
    }

    fileprivate func save() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError: NSError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    fileprivate func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { alarms[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError: NSError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

fileprivate let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
