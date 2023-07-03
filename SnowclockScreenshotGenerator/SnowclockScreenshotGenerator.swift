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
        
        app.buttons["New Alarm"].tap()
        
        let sc2 = app.screenshot()
        if let attachment = sc2.quickExportWithTitle(
            "Add Alarm",
            background: .color(.blue),
            exportSize: .iPhone_6_5_Inches,
            alignment: .titleAbove) {
            add(attachment)
        }
        
        app.buttons["Save"].tap()
        
//        app.buttons["New Alarm"].tap()
//        app.buttons["Save"].tap()
        
        let sc3 = app.screenshot()
        if let attachment = sc3.quickExportWithTitle(
            "Saved Alarm",
            background: .color(.blue),
            exportSize: .iPhone_6_5_Inches,
            alignment: .titleAbove) {
            add(attachment)
        }
        
        let count = app.links.count
        let sc4 = app.screenshot()
        if let attachment = sc4.quickExportWithTitle(
            "Number \(count)",
            background: .color(.blue),
            exportSize: .iPhone_6_5_Inches,
            alignment: .titleAbove) {
            add(attachment)
        }
    }
}
