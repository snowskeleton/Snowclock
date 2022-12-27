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
    func updateNotifications() -> Void {
        // check for permission
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [
                .alert, .badge, .sound, .criticalAlert
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
        content.sound = .defaultRingtone
        
        var tempArray = self.notificationsIDs ?? []
        for time in self.allTimes {
            // schedule a separate notification for every separate weekday
            for day in self.numericalWeekdays {
                var triggerDate = Calendar.current.dateComponents([.hour,.minute], from: time)
                triggerDate.weekday = day
                let identifier = UUID().uuidString
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
                
                tempArray.append(identifier)
            }
        }
        self.notificationsIDs = tempArray
    }
    
    func nextOccurance() -> Date? {
        var times: [Date] = []
        
        for time in self.allTimes {
            // schedule a separate notification for every separate weekday
            for day in self.numericalWeekdays {
                var triggerDate = Calendar.current.dateComponents([.hour,.minute], from: time)
                triggerDate.weekday = day
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                let next = trigger.nextTriggerDate()
                if next != nil {
                    times.append(next!)
                }
            }
        }
        return times.min()
    }
    
    func secondsTilNextOccurance() -> Double {
        if let next = nextOccurance() {
            return Double(abs(Date().timeIntervalSince(next)))
        } else {
            return 0.0
        }
    }
}


public func setPlayer(to alarm: Alarm, with player: AVAudioPlayer) {
    let ai = AVAudioSession.sharedInstance()
    try? ai.setCategory(.playAndRecord, options: [.duckOthers, .defaultToSpeaker])
    try? ai.setActive(true)
    
    let cur = player.deviceCurrentTime
    let add = alarm.secondsTilNextOccurance()
    let new = cur + add
    
    print("Current time: " + String(describing: cur))
    print("new time in: " + String(describing: Int(new - cur)))
    player.play(atTime: new)
}
