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
    
    override func setUpWithError() throws {
        try? super.setUpWithError()
//        PersistenceController.preview.container.
    }
    override func tearDownWithError() throws {
        try? super.tearDownWithError()
        PersistenceController.preview.container.viewContext.reset()
    }
    
//    func testAllTimes() throws {
//        let alarm = alarmMaker(context: nil)
//        XCTAssertEqual(alarm.allTimes.count, 1)
//
//        // one scheduled day
//        alarm.schedule![0] = true
//        XCTAssertEqual(alarm.allTimes.count, 1)
//
//        // with followups
//        for num in [7, 11, 140] { alarm.addFollowup(with: num) }
//        XCTAssertEqual(alarm.allTimes.count, 4)
////        XCTAssert(alarm.allTimes.min() == alarm.latestFollowup()?.time)
//
//        // if we fail, this checks if we generate an incorrect number vs generate nothing (0)
//        XCTAssertNotEqual(alarm.allTimes.count, 0)
//
//        // more days with followups
//        for i in [1, 2] { alarm.schedule![i] = true }
//        XCTAssertEqual(alarm.allTimes.count, 12)
//    }
    
    func testNumericalWeekdays() throws {
        let alarm = alarmMaker(context: nil)
        XCTAssertEqual(alarm.numericalWeekdays, [])
        alarm.schedule![0] = true
        XCTAssertEqual(alarm.numericalWeekdays, [1])
        alarm.schedule![5] = true
        XCTAssertEqual(alarm.numericalWeekdays, [1, 6])
    }
  
//    func testOneFollowup() throws {
//        let alarm = alarmMaker(context: nil)
//        alarm.addFollowup(with: 5)
//        let fol = alarm.latestFollowup()
//        XCTAssert(fol != nil)
////        let del = fol!.delay
////        XCTAssertTrue(del == 5)
//
////    }
////    func testMoreFollowups() throws {
////        let alarm = alarmMaker(context: nil)
////        alarm.addFollowup(with: 10)
////        alarm.addFollowup(with: 2)
////        XCTAssert(alarm.latestFollowup()?.delay != 2)
////        XCTAssert(alarm.latestFollowup()?.delay != nil)
////        XCTAssert(alarm.latestFollowup()?.delay != 0)
////        XCTAssert(alarm.latestFollowup()!.delay == 10)
////        XCTAssert(alarm.allTimes != [])
//    }
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
