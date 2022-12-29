//
//  DayOfTheWeekPicker.swift
//  Snowclock
//
//  Created by Isaac Lyons on 10/1/20.
//

import SwiftUI

struct ScheduleView: View {
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

struct ScheduleView_Preview: PreviewProvider {
    static var previews: some View {
        AlarmDetailsView(preview: true, showSchedule: true)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


public func daysAsString(days: [Bool]) -> String {
    var addWeekdays = true
    var addWeekends = true
    var daysOfWeekString: [String] = []
    
    if days == [false, false, false, false, false, false, false] {
        return ""
    }
    if days == [true, true, true, true, true, true, true] {
        return "Every day"
    }
    
weekdayCheck: while true {
    for day in days[1...5] {
        if day == false {
            break weekdayCheck
        }
    }
    daysOfWeekString.append("Weekdays")
    addWeekdays = false
    break
}
    
    if days[0] && days[6] {
        daysOfWeekString.append("Weekends")
        addWeekends = false
    }
    
    if days[0] && addWeekends { daysOfWeekString.append("Sunday") }
    if days[1] && addWeekdays { daysOfWeekString.append("Monday") }
    if days[2] && addWeekdays { daysOfWeekString.append("Tuesday") }
    if days[3] && addWeekdays { daysOfWeekString.append("Wednesday") }
    if days[4] && addWeekdays { daysOfWeekString.append("Thursday") }
    if days[5] && addWeekdays { daysOfWeekString.append("Friday") }
    if days[6] && addWeekends { daysOfWeekString.append("Saturday") }
    return daysOfWeekString.joined(separator: ", ")
}
