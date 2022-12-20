//
//  AlarmDetailsView.swift
//  Declare Alarm
//
//  Created by snow on 12/19/22.
//

import SwiftUI

struct AlarmDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var alarm: Alarm
    @State var showingSheet = false
    @State var newdate: Date
    @State var displayed_schedule: [Bool]
    
    init(alarm: Binding<Alarm>) {
        _alarm = alarm
        _newdate = State(initialValue: alarm.wrappedValue.time!)
        _displayed_schedule = State(initialValue: _alarm.wrappedValue.schedule!)
    }
    init(preview: Bool = false) {
        let alarm = Alarm(context: PersistenceController.preview.container.viewContext)
        alarm.time = Date()
        alarm.schedule = NO_REPEATS
        self.init(alarm: Binding<Alarm>.constant(alarm))
    }
    
    var body: some View {
        VStack {
            DatePicker("Alarm time",
                       selection: $newdate,
                       displayedComponents: [.hourAndMinute])
            .padding()
            .labelsHidden()
            .datePickerStyle(.wheel)
            Text("Schedule")
            Text(alarm.time!, formatter: itemFormatter)
            Button("Repeat",action: {
                showingSheet = true
            }).sheet(isPresented: $showingSheet){
                DayOfTheWeekPicker(activeDays: $displayed_schedule)
            }
            Text(daysAsString(days:displayed_schedule))
            VStack { // schedule more alarms
                Button(action: {
                    
                }) {
                    Label("", systemImage: "plus").font(.title)
                        .sheet(isPresented: $showingSheet) {
                            AlarmSetterView()
                                .presentationDetents([.medium])
                        }
                }
            }
            Spacer()
            HStack {
                Button("Cancel", action: {
                    dismiss()
                })
                Button("Save", action: {
                    alarm.time = newdate
                    alarm.schedule = displayed_schedule
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
