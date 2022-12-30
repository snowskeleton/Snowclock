//
//  SnowclockTests.swift
//  SnowclockTests
//
//  Created by snow on 12/16/22.
//

import XCTest
import CoreData
@testable import Snowclock

final class SnowclockTests: XCTestCase {
    func testAllTimes() throws {
        let alarm = alarmMaker(context: nil)
        XCTAssertTrue(alarm.allTimes.count == 0)

        // one scheduled day
        alarm.schedule![0] = true
        XCTAssertTrue(alarm.allTimes.count == 1)

        // with followups
        for num in [7, 11, 140] {
            alarm.addFollowup(with: num)
        }
        XCTAssertTrue(alarm.allTimes.count == 4)

        // more days with followups
        alarm.schedule![1] = true
        alarm.schedule![2] = true
        XCTAssertTrue(alarm.allTimes.count == 12)

    }
    
    func testNumericalWeekdays() throws {
        let alarm = alarmMaker(context: PersistenceController.preview.container.viewContext)
        XCTAssertTrue(alarm.numericalWeekdays == [])
        alarm.schedule![0] = true
        XCTAssertTrue(alarm.numericalWeekdays == [1])
    }
  
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
