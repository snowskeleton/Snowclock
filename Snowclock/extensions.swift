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
        content.categoryIdentifier = "ALARM"
        content.userInfo = [
            "SOME_TAG": self.id!.uuidString
        ]
        content.threadIdentifier = self.id!.uuidString
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "defaultSound.m4r"))
        
        var newNotificationIDs = self.notificationsIDs ?? []
        for day in self.numericalWeekdays {
            let request = createRequest(with: content, at: self.time!, on: day)
            UNUserNotificationCenter.current().add(request)
            newNotificationIDs.append(request.identifier)
            for fu in self.followups?.allObjects as! [Followup] {
                content.title = "\(content.title) + \(fu.delay)"
                let request = createRequest(with: content, at: self.time!, on: day, addDelay: Int(fu.delay))
                UNUserNotificationCenter.current().add(request)
                newNotificationIDs.append(request.identifier)
            }
        }
        self.notificationsIDs = newNotificationIDs
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

fileprivate func followupMaker(
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


fileprivate func createRequest(
    with content: UNMutableNotificationContent,
    at time: Date,
    on day: Int?,
    addDelay: Int? = nil
) -> UNNotificationRequest {
    var triggerDate = Calendar.current.dateComponents(
        [.hour,.minute],
        from: time
    )
    let repeats = day != nil
    if repeats {
        triggerDate.weekday = day
    }
    if addDelay != nil {
        triggerDate.minute! += addDelay!
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
        return get(.next, weekday, considerToday: considerToday)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.previous, weekday, considerToday: considerToday)
    }
    
    func get(_ direction: SearchDirection, _ weekDay: Weekday, considerToday consider: Bool = false) -> Date {
        
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
