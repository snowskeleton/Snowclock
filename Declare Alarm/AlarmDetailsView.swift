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
    @State var showRoutine: Bool = false
    @State var newDate: Date
    @State var newSchedule: [Bool]
    @State var routine: [Followup]?
    @State var selectedRoutine: Int = 0
    
    init(alarm: Binding<Alarm>, routine: Binding<[Followup]>?) {
        _alarm = alarm
        _newDate = State(initialValue: alarm.wrappedValue.time!)
        _newSchedule = State(
            initialValue: (_alarm.wrappedValue.schedule != nil)
            ? _alarm.wrappedValue.schedule!
            : NO_REPEATS
        )
    }
    
    init(alarm: Binding<Alarm>, followup: Followup) {
        // convenience function for putting single Followup into routine array
        var temp = Array<Followup>()
        temp.append(followup)
        self.init(alarm: alarm, routine: Binding<[Followup]>.constant(temp))
        
    }
    
    init(preview: Bool = false, showRoutine: Bool = false) {
        let alarm = alarmMaker(context: PersistenceController.preview.container.viewContext)
        alarm.schedule![0] = true
        
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
                           selection: $newDate,
                           displayedComponents: [.hourAndMinute])
                .padding()
                .labelsHidden()
                .datePickerStyle(.wheel)
                
                Button(action: { showSchedule = true }, label: {
                    Text(daysAsString(days:newSchedule))
                })
                .sheet(isPresented: $showSchedule) {
                    DayOfTheWeekPicker(activeDays: $newSchedule)
                }
                Spacer()
                
                Button("Routine", action: {
                    showRoutine = true
                })
                .sheet(isPresented: $showRoutine) {
                    RoutineView(alarm: Binding<Alarm>.constant(alarm))
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
                        alarm.time = newDate
                        alarm.schedule = newSchedule
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
