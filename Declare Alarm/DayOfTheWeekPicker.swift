//
//  DayOfTheWeekPicker.swift
//  Declare Alarm
//
//  Created by Isaac Lyons on 10/1/20.
//

import SwiftUI

struct DayOfTheWeekPicker: View {
    @Binding var activeDays: [Bool]

    var body: some View {
        List {
            ForEach(days, id: \.self) { day in
                Button(action: {
                    activeDays[days.firstIndex(of: day)!].toggle()
                }) {
                    HStack {
                        Text("\(day)")
                        if activeDays[days.firstIndex(of: day)!] == true {
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
    }
    
    fileprivate let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    fileprivate let weekdays = [1,2,3,4,5]
    fileprivate let weekends = [0,6]
    
    fileprivate var allWeekDaysSelected: Bool {
        return activeDays[1] && activeDays[2] && activeDays[3] && activeDays[4] && activeDays[5]
    }
    fileprivate var allWeekEndsSelected: Bool {
        return activeDays[0] && activeDays[6]
    }

    fileprivate func toggle(days: [Int], value: Bool) {
        for i in days {
            activeDays[i] = value
        }
    }
}

