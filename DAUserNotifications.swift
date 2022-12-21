//
//  LocalNotificationManager.swift
//  Time Lord
//
//  Created by Isaac Lyons on 10/15/20.
//

import Foundation
import SwiftUI
import UserNotifications

class LocalNotificationManager {
    var notifications = [Notification]()
    
    struct Notification {
        var ids: [String]
        var title: String
        var datetime: DateComponents
        var repeating: [Bool]
        var isSingle: Bool {
            if repeatingDays == [] { return true } else { return false }
        }
        var repeatingDays: [Int] {
            var days: [Int] = []
            for i in 1...repeating.count {
                if repeating[i - 1] == true {
                    days.append(i)
                }
            }
            return days
        }
        var cancelDays: [Int] {
            var days: [Int] = []
            for i in 1...repeating.count {
                if repeating[i - 1] == false {
                    days.append(i)
                }
            }
            return days
        }
    }
    
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            
            if granted == true && error == nil {
                self.prepareNotification()
            }
        }
    }
    
    func listScheduledNotifications() { //for debugging
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            for notification in notifications {
                print(notification)
            }
        }
    }
    
    func schedule() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.prepareNotification()
            default:
                break // Do nothing
            }
        }
    }
    
    private func prepareNotification() {
        for notif in notifications {
            let content      = UNMutableNotificationContent()
            content.title    = notif.title
            content.sound    = .default
            
            if notif.isSingle {
                let trigger = UNCalendarNotificationTrigger(dateMatching: notif.datetime, repeats: false)
                scheduleNotification(UNNotificationRequest(identifier: notif.ids[0], content: content, trigger: trigger))
                for i in 1...6 { // 0 is used by this notification, but I need to cancel all the other ones.
                    LocalNotificationManager().removeNotifications([notif.ids[i]])
                }
            } else {
                for repeatingDay in notif.repeatingDays {
                    var day = notif.datetime
                    day.weekday = repeatingDay
                    let trigger = UNCalendarNotificationTrigger(dateMatching: day, repeats: true)
                    scheduleNotification(UNNotificationRequest(identifier: notif.ids[repeatingDay - 1], content: content, trigger: trigger))
                    
                }
                for cancelDay in notif.cancelDays {
                    LocalNotificationManager().removeNotifications([notif.ids[cancelDay - 1]])
                }
            }
        }
    }
    
    private func scheduleNotification(_ request: UNNotificationRequest) {
        UNUserNotificationCenter.current().add(request) { error in
            guard error == nil else { return }
        }
    }
    
    func removeNotifications(_ ids: [String]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
    }
    
}
