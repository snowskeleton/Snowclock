//
//  extension_Alarm_Notifications.swift
//  Snowclock
//
//  Created by snow on 12/30/22.
//

import Foundation
import UserNotifications
import AVKit

extension Alarm {
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
        content.categoryIdentifier = "ALARM"
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
