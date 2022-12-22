//
//  AlarmDetailsView.swift
//  Declare Alarm
//
//  Created by snow on 12/19/22.
//

import SwiftUI
import CoreData

struct AlarmDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @Environment(\.dismiss) private var dismiss
    @Binding var alarm: Alarm
    @State var showSchedule: Bool = false
    @State var newDate: Date
    @State var newName: String
    @State var newSchedule: [Bool]
    
    private var routines: [Followup] {
        let n = alarm.followups?.allObjects as! [Followup]
        return n.sorted(by: { $0.delay < $1.delay })
    }
    
    init(alarm: Binding<Alarm>) {
        _alarm = alarm
        _newName = State(initialValue: alarm.wrappedValue.name!)
        _newDate = State(initialValue: alarm.wrappedValue.time!)
        _newSchedule = State(
            initialValue: (_alarm.wrappedValue.schedule != nil)
            ? _alarm.wrappedValue.schedule!
            : NO_REPEATS
        )
    }
    
    init(preview: Bool = false, showSchedule: Bool = false) {
        let alarm = alarmMaker(context: PersistenceController.preview.container.viewContext)
        alarm.schedule![0] = true
        
        let nums = [7, 11, 140]
        for num in nums {
            let fol = Followup(context: PersistenceController.preview.container.viewContext)
            fol.delay = Int64(num)
            fol.id = UUID()
            fol.alarm = alarm
        }
        
        self.init(alarm: Binding<Alarm>.constant(alarm))
        _showSchedule = State(initialValue: showSchedule)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    DatePicker("Alarm time",
                               selection: $newDate,
                               displayedComponents: [.hourAndMinute])
                    .padding()
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                    
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Alarm name", text: $newName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Button(
                        action: { showSchedule = true },
                        label: {
                            VStack {
                                Text(daysAsString(days: newSchedule))
                                    .padding(.top, 1)
                                    .foregroundColor(Color.primary)
                            }
                        }
                    )
                    .sheet(isPresented: $showSchedule) {
                        DayOfTheWeekPicker(schedule: $newSchedule)
                    }
                    .environment(\.managedObjectContext, viewContext)
                }
                
                RoutineView(alarm: Binding<Alarm>.constant(alarm))
                    .environment(\.managedObjectContext, viewContext)
                
            }
        }.toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: {
                    alarm.time = newDate
                    alarm.name = newName
                    alarm.schedule = newSchedule
                    dismiss()
                })
            }
        }
    }
}

struct AlarmDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDetailsView(preview: true).environment(
            \.managedObjectContext,
             PersistenceController.preview.container.viewContext
        )
    }
}
