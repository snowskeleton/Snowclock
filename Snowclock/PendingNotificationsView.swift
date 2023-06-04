//
//  PendingNotificationsView.swift
//  Snowclock
//
//  Created by snow on 5/24/23.
//

import SwiftUI

struct PendingNotificationsView: View {
    
//    var notifications: [UNNotificationRequest] {
//        let center = UNUserNotificationCenter.current()
//        var temp: [UNNotificationRequest] = []
//        center.getPendingNotificationRequests { (notificationRequests) in
//            for notificationRequest:UNNotificationRequest in notificationRequests {
//                temp.append(notificationRequest)
//            }
//        }
//        print(temp)
//        return temp
//    }
    var body: some View {
        List {
            Text("Default")
//            Text("Length: \(notifications.count)")
            ForEach(getNotes(), id: \.self) { note in
                Text("What do you see?")
                Text(note.content.title)
            }
        }
    }
}

private func getNotes() -> [UNNotificationRequest] {
    var temp: [UNNotificationRequest] = []
    UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
        for notificationRequest:UNNotificationRequest in notificationRequests {
            temp.append(notificationRequest)
            print(temp)
        }
    }
//    print(temp.count)
    return temp
}

struct PendingNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        PendingNotificationsView()
    }
}
