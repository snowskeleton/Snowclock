//
//  Formatters.swift
//  Snowclock
//
//  Created by snow on 12/19/22.
//

import SwiftUI
import CoreData


public let NO_REPEATS = [false,false,false,false,false,false,false]

public func alarmMaker(
    context: NSManagedObjectContext?,
    time: Date = Date()
) -> Alarm {
    let _context = context != nil ? context! : PersistenceController.preview.container.viewContext
    
    let alarm = Alarm(context: _context)
    alarm.time = time
    alarm.sortTime = alarm.time?.formatted(date: .omitted, time: .shortened) ?? ""

    // default values
    alarm.id = UUID()
    alarm.schedule = NO_REPEATS
    alarm.enabled = true
    // default title set to 'Alarm' in CoreData declaration
    
    return alarm
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
