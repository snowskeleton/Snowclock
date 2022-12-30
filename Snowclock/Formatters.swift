//
//  Formatters.swift
//  Snowclock
//
//  Created by snow on 12/19/22.
//

import SwiftUI
import CoreData


public let shortDate: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
    return formatter
}()

public let NO_REPEATS = [false,false,false,false,false,false,false]

public func alarmMaker(
    context: NSManagedObjectContext?,
    time: Date = Date()
) -> Alarm {
    let _context = context != nil ? context! : PersistenceController.preview.container.viewContext
    
    let alarm = Alarm(context: _context)
    alarm.time = time
    
    // default values
    alarm.id = UUID()
    alarm.schedule = NO_REPEATS
    alarm.enabled = true
    // default title set to 'Alarm' in CoreData declaration
    
    return alarm
}

public func nextAlarm(from alarms: FetchedResults<Alarm>) -> Optional<Alarm> {
    let val = alarms.filter( {$0.enabled} )
    return val.min(by: { $0.time! > $1.time! })
}
    
