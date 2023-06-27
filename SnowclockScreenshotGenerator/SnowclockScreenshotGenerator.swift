//
//  SnowclockScreenshotGenerator.swift
//  SnowclockScreenshotGenerator
//
//  Created by snow on 6/27/23.
//

import XCTest

final class SnowclockScreenshotGenerator: XCTestCase {
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
        
        let sc1 = app.screenshot()
        if let attachment = sc1.quickExportWithTitle(
            "1st Image",
            background: .color(.blue),
            exportSize: .iPhone_6_5_Inches,
            alignment: .titleAbove) {
            add(attachment)
        }
        
        let newAlarm = app.buttons["New Alarm"]
        newAlarm.tap()
        
        let sc2 = app.screenshot()
        if let attachment = sc2.quickExportWithTitle(
            "Add Alarm",
            background: .color(.blue),
            exportSize: .iPhone_6_5_Inches,
            alignment: .titleAbove) {
            add(attachment)
        }
    }
}
