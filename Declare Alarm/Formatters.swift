//
//  Formatters.swift
//  Declare Alarm
//
//  Created by snow on 12/19/22.
//

import SwiftUI


public let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

public let NO_REPEATS = [false,false,false,false,false,false,false]

extension Followup {
    static func +(lhs: Followup, rhs: Int) -> Followup {
        let f = Followup()
        f.delay = lhs.delay + Int64(rhs)
        return f
    }
    static func -(lhs: Followup, rhs: Int) -> Followup {
        let f = Followup()
        f.delay = lhs.delay - Int64(rhs) < 0 ? 0 : lhs.delay - Int64(rhs)
        return f
    }
}

extension Followup {
    static func <(lhs: Followup, rhs: Int) -> Bool {
        return lhs.delay < rhs
    }
    static func >(lhs: Followup, rhs: Int) -> Bool {
        return lhs.delay > rhs
    }
}
