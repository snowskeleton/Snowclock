//
//  DayOfTheWeekPicker.swift
//  Declare Alarm
//
//  Created by Isaac Lyons on 10/1/20.
//

import SwiftUI

struct DayOfTheWeekPicker: View {
    @State private var date: Date = Date()
    @State private var sun = false
    @State private var mon = false
    @State private var tue = false
    @State private var wed = false
    @State private var thu = false
    @State private var fri = false
    @State private var sat = false
    var weekdays: [Bool] = {
        mon, tue, wed, thu, fri
    }
    var weekends: [Bool] = {
        sun, sat
    }
    @Binding var activeDays: [Bool]
    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var allWeekDaysSelected: Bool {
        for i in 1...5 { if activeDays[i] == false { return false } }
        return true
    }
    var allWeekEndsSelected: Bool {
        if activeDays[0] && activeDays[6] { return true }
        return false
    }

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
                toggleWeekdays()
            }) {
                Text("Weekdays")
            }
            Button(action: {
                toggleWeekends()
            }) {
                Text("Weekends")
            }
        }
    }

    fileprivate func toggleWeekdays() {
        if allWeekDaysSelected {
            for i in 1...5 {
                activeDays[i] = false
            }
        } else {
            for i in 1...5 {
                activeDays[i] = true
            }
        }
    }

    fileprivate func toggleWeekends() {
        if allWeekEndsSelected {
            activeDays[0] = false
            activeDays[6] = false
        } else {
            activeDays[0] = true
            activeDays[6] = true
        }
    }

}

