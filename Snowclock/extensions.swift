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




extension Date {
    
    static func today() -> Date {
        return Date()
    }
    
    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.next,
                   weekday,
                   considerToday: considerToday)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.previous,
                   weekday,
                   considerToday: considerToday)
    }
    
    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {
        
        let dayName = weekDay.rawValue
        
        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1
        
        let calendar = Calendar(identifier: .gregorian)
        
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        
        var nextDateComponent = calendar.dateComponents([.hour, .minute, .second], from: self)
        nextDateComponent.weekday = searchWeekdayIndex
        
        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: direction.calendarSearchDirection)
        
        return date!
    }
    
    func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }
    
    enum Weekday: String {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }
    
    enum SearchDirection {
        case next
        case previous
        
        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .next:
                return .forward
            case .previous:
                return .backward
            }
        }
    }
}


extension Followup {
    
    convenience init(to alarm: Alarm) {
        self.init()
        self.alarm = alarm
    }
    
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


public extension NSManagedObject {
    convenience init(context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        self.init(entity: entity, insertInto: context)
    }
    
}


