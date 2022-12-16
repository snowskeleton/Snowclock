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
                DayOfTheWeekPicker(activeDays: [false, false, false, false, false, false, false])
            }.padding()
        }
    }
}
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State var showingSheet = true

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                        .sheet(isPresented: $showingSheet) {
                            AlarmSetterView().presentationDetents([.medium])
                        }
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        showingSheet = true
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

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

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
