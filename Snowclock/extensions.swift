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


extension Alarm {
    func updateNotifications() -> Void {
        verifyPermissions()
        for note in self.notificationsIDs ?? [] {
            UNUserNotificationCenter
                .current()
                .removePendingNotificationRequests(
                    withIdentifiers: [note])
            self.notificationsIDs?.remove(
                at: (self.notificationsIDs?.firstIndex(
                    of: note))!)
        }
        if !self.enabled { return }
        
        let content = UNMutableNotificationContent()
        content.title = self.time!.formatted(date: .omitted, time: .shortened)
        content.body = self.name!
        content.badge = 0
        content.interruptionLevel = .timeSensitive
        content.threadIdentifier = self.id!.uuidString
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "defaultSound.m4r"))
        
        var newNotificationIDs = self.notificationsIDs ?? []
        for day in self.numericalWeekdays {
            let request = createRequest(with: content, at: self.time!, on: day)
            UNUserNotificationCenter.current().add(request)
            newNotificationIDs.append(request.identifier)
            
            for fu in self.followups?.allObjects as! [Followup] {
                content.title = "\(fu.time.formatted(date: .omitted, time: .shortened))"
                
                // this fails if the user schedules an Alarm for 23:59 and a followup for 5 min later at 0:04,
                // since it won't update the weekday.
                let request = createRequest(with: content, at: fu.time, on: day)
                UNUserNotificationCenter.current().add(request)
                newNotificationIDs.append(request.identifier)
            }
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
