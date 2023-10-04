//
//  extensions.swift
//  Snowclock
//
//  Created by snow on 6/22/23.
//

import Foundation
import UserNotifications
import AVKit
import CoreData

struct timePlusWeekday {
    var time: Date
    var day: Int
}

extension Alarm {
    var sortTime: String {
        self.time?.formatted(date: .omitted, time: .shortened) ?? ""
    }
    var weeklySchedule: String {
        var s = String()
        s += self.name!
        let stringySchedule = daysAsString(days: self.schedule!)
        if stringySchedule != "" {
            s += ", "
            s += stringySchedule
        }
        return s
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
extension Alarm {
    func updateNotifications() -> Void {
        verifyPermissions()
        self.cancelExistingNotifications()
        if !self.enabled { return }
        
        let content = UNMutableNotificationContent()
        content.body = self.name!
        content.badge = 0
        content.interruptionLevel = .timeSensitive
        content.threadIdentifier = self.id!.uuidString
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "defaultSound.m4r"))
        
        var times: [timePlusWeekday] = []
        for day in self.numericalWeekdays {
            times.append(timePlusWeekday(time: self.time!, day: day))
            for fu in self.followups?.allObjects as! [Followup] {
                times.append(timePlusWeekday(time: fu.time, day: day))
            }
        }
        var newNotificationIDs = self.notificationsIDs ?? []
        for time in times {
            // this fails if the user schedules an Alarm for 23:59 and a followup for 5 min later at 0:04,
            // since it won't update the weekday.
            content.title = time.time.formatted(date: .omitted, time: .shortened)
            let request = createRequest(with: content, at: time.time, on: time.day)
            UNUserNotificationCenter.current().add(request)
            newNotificationIDs.append(request.identifier)
        }
        self.notificationsIDs = newNotificationIDs
    }
    
    var numericalWeekdays: [Int] {
        var sch = [Int]()
        for i in 0..<(self.schedule?.count)! where self.schedule![i] == true {
            sch.append(i + 1)
        }
        return sch
    }
    
    func cancelExistingNotifications() -> Void {
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
}

fileprivate func createRequest(
    with content: UNMutableNotificationContent,
    at time: Date,
    on day: Int
) -> UNNotificationRequest {
    var triggerDate = Calendar.current.dateComponents(
        [.hour,.minute],
        from: time
    )
    triggerDate.weekday = day
    let trigger = UNCalendarNotificationTrigger(
        dateMatching: triggerDate,
        repeats: true
    )
    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: trigger
    )
    return request
}

public extension NSManagedObject {
    convenience init(context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        self.init(entity: entity, insertInto: context)
    }
    
}

fileprivate func verifyPermissions() {
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

extension Followup {
    var time: Date {
        let atime = self.alarm!.time
        var offset = DateComponents()
        offset.minute = Int(self.delay)
        let newcal = Calendar.current
        let newtime = newcal.date(byAdding: offset, to: atime!)
        return newtime!
    }
}
