//
//  AlarmDetailsView.swift
//  Declare Alarm
//
//  Created by snow on 12/19/22.
//

import SwiftUI

struct AlarmDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @State var showingSheet = false
    @State var repeatDays = [false, false, false, false, false, false, false]
    @State var newdate = Date()
    @Binding var alarm: Alarm
    
    private var date: Date {
        alarm.date!
    }
    init(alarm: Binding<Alarm>) {
        _alarm = alarm
        _newdate = State(initialValue: alarm.wrappedValue.date!)
        _repeatDays = State(initialValue: alarm.wrappedValue.activeDays!)
    }
    
    var body: some View {
        VStack {
            DatePicker("Alarm time",
                       selection: $newdate,
                       displayedComponents: [.hourAndMinute])
            .padding()
            .labelsHidden()
            .datePickerStyle(.wheel)
            Text(alarm.date!, formatter: itemFormatter)
            Button("Repeat",action: {
                showingSheet = true
            }).sheet(isPresented: $showingSheet){
                DayOfTheWeekPicker(activeDays: $repeatDays)
            }
            Spacer()
            Button("Save", action: {
                alarm.date = newdate
                alarm.activeDays = repeatDays
                dismiss()
            })
        }
    }
}
