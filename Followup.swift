//
//  Followup.swift
//  Snowclock
//
//  Created by snow on 9/30/23.
//
//

//import Foundation
//import SwiftData
//
//
//@Model public class Followup {
//    var delay: Int64 = 0
//    var id: UUID
//    var alarm: Alarm
//    
//    
//}
//@Model public class Alarm {
//    var enabled: Bool = false
//    var id: UUID
//    var name: String = "Alarm"
//    @Attribute(.transformable(by: "NSSecureUnarchiveFromData")) var notificationsIDs: [String]?
//    @Attribute(.transformable(by: "NSSecureUnarchiveFromData")) var schedule: [Bool]
//    var soundName: String? = ""
//    var time: Date?
//    @Relationship(deleteRule: .cascade, inverse: \Followup.alarm) var followups: [Followup]?
//    
//    
//}
