//
//  Extensions.swift
//  Snowclock
//
//  Created by snow on 12/21/22.
//

import SwiftUI


extension Followup {
    
    convenience init(to alarm: Alarm) {
        self.init()
        self.alarm = alarm
    }
    
    var time: Date {
        let atime = self.alarm!.time
        var offset = DateComponents()
        offset.minute = Int(self.delay)
        let newcal = Calendar.current
        let newtime = newcal.date(byAdding: offset, to: atime!)
        return newtime!
    }
    func asString() -> String {
        return self.time.formatted(date: .omitted, time: .shortened)
    }
}
