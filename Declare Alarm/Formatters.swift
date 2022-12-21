//
//  Formatters.swift
//  Declare Alarm
//
//  Created by snow on 12/19/22.
//

import SwiftUI
import CoreData


public let shortDate: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

public let NO_REPEATS = [false,false,false,false,false,false,false]

public func alarmMaker(context: NSManagedObjectContext) -> Alarm {
    let alarm = Alarm(context: context)
    alarm.id = UUID()
    alarm.time = Date()
    alarm.schedule = NO_REPEATS
    // default title set to 'Alarm' in CoreData declaration
    return alarm
}
