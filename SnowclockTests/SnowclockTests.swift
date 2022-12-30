//
//  SnowclockTests.swift
//  SnowclockTests
//
//  Created by snow on 12/16/22.
//

import XCTest
@testable import Snowclock

final class SnowclockTests: XCTestCase {
//
//    override func setUpWithError() throws {
//    }
//
//    override func tearDownWithError() throws {
//    }
    
//    func testObjectsExist() throws {
//        let alarms = PersistenceController.preview.container.viewContext.registeredObjects
//        XCTAssertTrue(alarms.count != 0)
//        XCTAssertFalse(alarms.count == 0)
//    }

    func testAllTimesFiltering() throws {
        // test that it returns the most recent rather than any other
        let date = Date()
        let alarm = alarmMaker(context: nil, time: date)
        let allTimes = alarm.allTimes
        XCTAssertTrue(allTimes.count == 0)
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
