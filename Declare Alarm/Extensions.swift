//
//  Extensions.swift
//  Declare Alarm
//
//  Created by snow on 12/21/22.
//

import Foundation
import CoreData
import UserNotifications
import AVFoundation
import SwiftUI





extension Alarm {
    func updateNotifications() -> Void {
        // check for permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .criticalAlert]) { success, error in
            if success {
//                print("All set!")
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
        if self.enabled == false { return }

        let content = UNMutableNotificationContent()
        content.title = self.stringyTime
        content.body = self.name!
        content.badge = 0
        content.interruptionLevel = .critical
        content.sound = .defaultCriticalSound(withAudioVolume: 50)
        
        for time in self.allTimes {
            // schedule a separate notification for every separate weekday
            for day in self.numericalWeekdays {
                var triggerDate = Calendar.current.dateComponents([.hour,.minute], from: time)
                triggerDate.weekday = day
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                var tempArray = self.notificationsIDs ?? []
                tempArray.append(request.identifier)
                self.notificationsIDs = tempArray
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
}



extension Followup {
    
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

extension Alarm {
    var allTimes: [Date] {
        var times: [Date] = []
        times.append(self.time!)
        for n in self.followups?.allObjects as! [Followup] {
            times.append(n.time)
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
}
