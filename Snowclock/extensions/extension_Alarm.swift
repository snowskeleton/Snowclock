//
//  extension_Alarm.swift
//  Declare Alarm
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
                    let fireDate = trigger.nextTriggerDate()
                    times.append(fu.time)
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
    
    func updateNotifications() -> Void {
        // check for permission
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [
                .alert, .badge, .sound
            ]) { success, error in
                if success {
                    
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        
        // cancel old notifications
        let oldNotifs = self.notificationsIDs ?? []
        for note in oldNotifs {
            UNUserNotificationCenter
                .current()
                .removePendingNotificationRequests(
                    withIdentifiers: [note])
            self.notificationsIDs?.remove(
                at: (self.notificationsIDs?.firstIndex(
                    of: note))!)
        }
        // schedule new notifications
        if self.enabled == false {
            print("Alarm not enabled. Returning early.")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = self.stringyTime
        content.body = self.name!
        content.badge = 0
        content.interruptionLevel = .timeSensitive
        content.userInfo = [
            "SOME_TAG": self.id?.uuidString ?? "no ID"
        ]
        content.threadIdentifier = String(describing: self.id!)
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "snowtone.aiff"))
        
        var tempArray = self.notificationsIDs ?? []
        for time in self.allTimes {
            // schedule a separate notification for every separate weekday
            for day in self.numericalWeekdays {
//                let triggers = setSixty(at: time)
                var triggerDate = Calendar.current.dateComponents([.hour,.minute], from: time)
                triggerDate.weekday = day
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                let triggers = expandTriggers(from: trigger.nextTriggerDate()!)
                for trigger in triggers {
                    let identifier = UUID().uuidString
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request)
                    tempArray.append(identifier)
                }
            }
        }
        self.notificationsIDs = tempArray
    }
    
    func secondsTilNextOccurance() -> Double {
        if let next = self.allTimes.min() {
            return Double(abs(Date().timeIntervalSince(next)))
        } else {
            return 0.0
        }
    }
}

fileprivate func expandTriggers(from trigger: Date) -> [UNCalendarNotificationTrigger] {
    var tempArray: [UNCalendarNotificationTrigger] = []
    for num in 0..<60 {
        var triggerDate = Calendar.current.dateComponents([.hour, .minute, .day, .weekday], from: trigger)
        triggerDate.second = num
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        tempArray.append(trigger)
    }
    return tempArray
}

