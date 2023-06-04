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
        self.verifyPermissions()
        self.cancelNotifications()
        if !self.enabled {
            print("Alarm disabled.")
            return
        }
//        let center = UNUserNotificationCenter.current()
        
        let content = createContent(
            title: self.stringyTime,
            body: self.name!,
            id: self.id!.uuidString
        )
        
        var tempArray = self.notificationsIDs ?? []
//        if !self.allTimes.isEmpty {
        for time in self.allTimes {
            if !self.numericalWeekdays.isEmpty {
                // schedule a separate notification for every separate weekday
                for day in self.numericalWeekdays {
                    let request = createRequest(with: content, at: time, on: day)
                    UNUserNotificationCenter.current().add(request)
                    tempArray.append(request.identifier)
                }
            } else {
                // if no schedule is chosen, but the alarm is still enabled, schedule a non-repeating alarm
                let request = createRequest(with: content, at: time, on: nil)
                UNUserNotificationCenter.current().add(request)
                tempArray.append(request.identifier)
            }
        }
        self.notificationsIDs = tempArray
    }
    
    func cancelNotifications() -> Void {
        for note in self.notificationsIDs ?? [] {
            UNUserNotificationCenter
                .current()
                .removePendingNotificationRequests(
                    withIdentifiers: [note])
            self.notificationsIDs?.remove(
                at: (self.notificationsIDs?.firstIndex(
                    of: note))!)
        }
    }
    
    func verifyPermissions() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [
                .alert, .badge, .sound
            ]) { success, error in
                if success {
                    
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
    }
}

fileprivate func createContent(
    title: String,
    body: String,
    id: String,
    sound: String = "defaultSound.m4r"
) -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.badge = 0
    content.interruptionLevel = .timeSensitive
    content.categoryIdentifier = "ALARM"
    content.userInfo = [
        "SOME_TAG": id
    ]
    content.threadIdentifier = id
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: sound))
    return content
}

fileprivate func createRequest(
    with content: UNMutableNotificationContent,
    at time: Date,
    on day: Int?
) -> UNNotificationRequest {
    var triggerDate = Calendar.current.dateComponents(
        [.hour,.minute],
        from: time
    )
    let repeats = day != nil
    if repeats {
        triggerDate.weekday = day
    }
    let trigger = UNCalendarNotificationTrigger(
        dateMatching: triggerDate,
        repeats: repeats
    )
    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: trigger
    )
    return request
}
