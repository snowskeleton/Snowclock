//
//  extension_Alarm.swift
//  Snowclock
//
//  Created by snow on 12/22/22.
//

import Foundation
import UserNotifications
import AVKit

extension Alarm {
    var allTimes: [Date] {
        var times: [Date] = []
        
        for day in self.numericalWeekdays {
            // schedule a separate notification for every separate weekday
            var triggerDate = Calendar.current.dateComponents([.hour,.minute], from: self.time!)
            triggerDate.weekday = day
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
            let fireDate = trigger.nextTriggerDate()
            if fireDate != nil {
                times.append(fireDate!)
                for fu in self.followups?.allObjects as! [Followup] {
                    var triggerDate = Calendar.current.dateComponents([.hour, .minute, .day, .weekday], from: fireDate!)
                    triggerDate.minute! += Int(fu.delay)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                    let newFireDate = trigger.nextTriggerDate()
                    if newFireDate != nil {
                        times.append(newFireDate!)
                    }
                }
            }
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
        let _ = followupMaker(context: self.managedObjectContext, alarm: self)
        
    }
}

