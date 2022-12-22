//
//  DayOfTheWeekPicker.swift
//  Declare Alarm
//
//  Created by Isaac Lyons on 10/1/20.
//

import SwiftUI

struct DayOfTheWeekPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var schedule: [Bool]
    
    var body: some View {
        VStack {
            List {
                ForEach(days, id: \.self) { day in
                    Button(action: {
                        schedule[days.firstIndex(of: day)!].toggle()
                    }) {
                        HStack {
                            Text("\(day)")
                            if schedule[days.firstIndex(of: day)!] == true {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                Spacer()
                Button(action: {
                    toggle(days: weekdays, value: !allWeekDaysSelected)
                }) {
                    Text("Weekdays")
                }
                Button(action: {
                    toggle(days: weekends, value: !allWeekEndsSelected)
                }) {
                    Text("Weekends")
                }
            }
            Spacer()
            Button("Back") {dismiss()}
        }
    }
    
    fileprivate let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    fileprivate let weekdays = [1,2,3,4,5]
    fileprivate let weekends = [0,6]
    
    fileprivate var allWeekDaysSelected: Bool {
        return schedule[1] && schedule[2] && schedule[3] && schedule[4] && schedule[5]
    }
    fileprivate var allWeekEndsSelected: Bool {
        return schedule[0] && schedule[6]
    }
    
    fileprivate func toggle(days: [Int], value: Bool) {
        for i in days {
            schedule[i] = value
        }
    }
}

struct DayOfTheWeekPicker_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDetailsView(preview: true, showSchedule: true)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
