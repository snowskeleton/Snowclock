//
//  extension_Alarm.swift
//  Snowclock
//
//  Created by snow on 12/22/22.
//

import Foundation
import UserNotifications
import AVKit
import CoreData

fileprivate func timedateFromCalendar(comps: DateComponents, repeats: Bool) -> Date? {
    let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: repeats)
    return trigger.nextTriggerDate()
}

fileprivate func calendarFromTimeAddDay(fuse time: Date, with day: Int) -> DateComponents {
    var triggerDate = Calendar.current.dateComponents([.hour,.minute], from: time)
    triggerDate.weekday = day
    return triggerDate
}

fileprivate func calendarFromTimeAddMinutes(fuse time: Date, with minutes: Int) -> DateComponents {
    var triggerDate = Calendar.current.dateComponents([.hour,.minute], from: time)
    triggerDate.minute! += minutes
    return triggerDate
}

extension Alarm {
    var allTimes: [Date] {
        var times: [Date] = []
        let daylessTimes = self.allTimesWithoutDays
        for t in daylessTimes {
            times.append(t)
        }
        if self.numericalWeekdays.isEmpty {
            return times
        } else {
            times = []
        }
        
        for day in self.numericalWeekdays {
            for time in daylessTimes {
                let timeWithDay = calendarFromTimeAddDay(fuse: time, with: day)
                let finalTimedate = timedateFromCalendar(comps: timeWithDay, repeats: true)
                if finalTimedate == nil { continue }
                times.append(finalTimedate!)
            }
        }
        return times
    }
    
    var allTimesWithoutDays: [Date] {
        var times: [Date] = []
        
        times.append(self.time!)
        
        let additionalTimes = self.followups?.allObjects as! [Followup]
        for time in additionalTimes {
            let cal = calendarFromTimeAddMinutes(fuse: self.time!, with: Int(time.delay))
            let newtime = timedateFromCalendar(comps: cal, repeats: false)
            if newtime == nil { continue }
            times.append(newtime!)
        }
        return times
    }
    
    func latestFollowup() -> Followup? {
        let unsorted = self.followups?.allObjects as! [Followup]
        if unsorted.count > 0 {
            return unsorted.max(by: { $0.delay < $1.delay })!
        }
        return nil
        
    }
    
    var numericalWeekdays: [Int] {
        var sch = [Int]()
        for i in 0..<(self.schedule?.count)! where self.schedule![i] == true {
            sch.append(i + 1)
        }
        return sch
    }
    
    var stringyTime: String {
        return self.time!.formatted(date: .omitted, time: .shortened)
    }
    
    var stringySchedule: String {
        return daysAsString(days: self.schedule!)
    }
    
    var stringyFollowups: String {
        var ans = String()
        var set = self.followups?.allObjects as! [Followup]
        set = set.sorted(by: { $0.delay < $1.delay })
        for f in set {
            let i = f.delay
            if i > 0 {
                ans += "+\(String(f.delay)) "
            }
            if i < 0 {
                ans += "\(String(f.delay)) "
            }
        }
        return ans
    }
    
    func secondsTilNextOccurance() -> Double {
        if let next = self.allTimes.min() {
            return Double(abs(Date().timeIntervalSince(next)))
        } else {
            return 0.0
        }
    }
    
    func addFollowup(with delay: Int) -> Void {
        let _ = followupMaker(context: self.managedObjectContext, delay: Int64(delay), alarm: self)
        
    }
}

public func followupMaker(
    context: NSManagedObjectContext?,
    delay: Int64 = 5,
    alarm: Alarm
) -> Followup {
    let _context = context != nil ? context! : PersistenceController.preview.container.viewContext
    
    let fu = Followup(context: _context)
    fu.delay = delay
    fu.id = UUID()
    fu.alarm = alarm
    return fu
}

