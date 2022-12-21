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
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Followup.delay, ascending: true)],
        animation: .default)
    private var the_routines: FetchedResults<Followup>
    
    @Environment(\.dismiss) private var dismiss
    @Binding var alarm: Alarm
    @State var showSchedule: Bool = false
    @State var showRoutine: Bool = false
    @State var newdate: Date
    @State var displayed_schedule: [Bool]
    @State var routine: [Followup]?
    @State var selectedRoutine: Int = 0
    
    init(alarm: Binding<Alarm>, routine: Binding<[Followup]>?) {
        _alarm = alarm
        _newdate = State(initialValue: alarm.wrappedValue.time!)
        
        _displayed_schedule = State(
            initialValue: (_alarm.wrappedValue.schedule != nil)
            ? _alarm.wrappedValue.schedule!
            : NO_REPEATS
        )
        
        if _alarm.wrappedValue.routine != nil {
            _routine = State(initialValue: _alarm.wrappedValue.routine!)
        }
        else if routine != nil {
            _routine = State(initialValue: routine?.wrappedValue)
        }
        else { _routine = State(initialValue: []) }
    }
    init(alarm: Binding<Alarm>, followup: Followup) {
        // convenience function for putting single Followup into routine array
        var temp = Array<Followup>()
        temp.append(followup)
        self.init(alarm: alarm, routine: Binding<[Followup]>.constant(temp))
        
    }
    
    init(preview: Bool = false, showRoutine: Bool = false) {
        let alarm = Alarm(context: PersistenceController.preview.container.viewContext)
        alarm.time = Date()
        var n = NO_REPEATS
        n[0] = true
        alarm.schedule = n
        
        let fol = Followup(context: PersistenceController.preview.container.viewContext)
        fol.delay = 10
        fol.id = UUID()
        
        self.init(alarm: Binding<Alarm>.constant(alarm), followup: fol)
        _showRoutine = State(initialValue: showRoutine)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Alarm time",
                           selection: $newdate,
                           displayedComponents: [.hourAndMinute])
                .padding()
                .labelsHidden()
                .datePickerStyle(.wheel)
                
                Button(action: { showSchedule = true }, label: {
                    Text(daysAsString(days:displayed_schedule))
                })
                .sheet(isPresented: $showSchedule) {
                    DayOfTheWeekPicker(activeDays: $displayed_schedule)
                }
                Spacer()
                
                Button("Routine", action: {
                    showRoutine = true
                })
                .sheet(isPresented: $showRoutine) {
                    RoutineView(routine: Binding<[Followup]>.constant(routine!))
                        .presentationDetents([.medium])
                }
                .environment(\.managedObjectContext, viewContext)
                
                Spacer()
                HStack {
                    Button("Cancel", action: {
                        dismiss()
                    })
                    Spacer()
                    Button("Save", action: {
                        alarm.time = newdate
                        alarm.schedule = displayed_schedule
                        alarm.routine = routine
                        dismiss()
                    })
                }.padding()
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
