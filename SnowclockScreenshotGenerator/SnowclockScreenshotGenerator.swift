//
//  SnowclockScreenshotGenerator.swift
//  SnowclockScreenshotGenerator
//
//  Created by snow on 6/27/23.
//

import XCTest
import SwiftUI

final class SnowclockScreenshotGenerator: XCTestCase {
    func testExample() throws {
        let sizes: [ExportSize] = [
//            .iPhone_5_5_Inches,
            .iPhone_6_5_Inches,
//            .iPadPro_12_9_Inches
        ]
        let app = XCUIApplication()
        app.launch()

//        addUIInterruptionMonitor(withDescription: "System Dialog") {
//            (alert) -> Bool in
//            alert.buttons["Allow"].tap()
//            app.swipeUp()
//            return true
//        }
        
        let navView = app.collectionViews.element
        while navView.cells.count > 0 {
            navView.children(matching: .cell).firstMatch.swipeLeft()
            app.buttons["Delete"].tap()
        }
        app.buttons["New Alarm"].tap()
        app.buttons["Save"].tap()
        navView.children(matching: .cell).firstMatch.tap()
        let routineButton = app.collectionViews.staticTexts["ROUTINE"]
        routineButton.tap()
        routineButton.tap()
        routineButton.tap()
        
        let detailsScreenshot = app.screenshot()
        
        app.buttons["Save"].tap()
        
        // allow notifications
        let app2 = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let button = app2.alerts.firstMatch.buttons["Allow"]
        if button.waitForExistence(timeout: 2) {
            button.tap()
        }
        
        let mainscreenScreenShot = app.screenshot()
        
        for size in sizes {
            if let attachment = detailsScreenshot.quickExportWithTitle(
                "Fully Customizable",
                background: .color(.blue),
                exportSize: size,
                alignment: .titleAbove) {
                add(attachment)
            }
            if let attachment = mainscreenScreenShot.quickExportWithTitle(
                "Simple Design",
                background: .color(.blue),
                exportSize: size,
                alignment: .titleAbove) {
                add(attachment)
            }
        }
        
        
        
        
//        app.buttons["ADD FOLLOWUP"].tap()
        
//        let someview = app.collectionViews
//        someview.staticTexts["6:17 PM"].tap()

////        someOtherview.staticTexts["ROUTINE"].tap()
////        app.buttons["ROUTINE"].tap()
//        let sc3 = app.screenshot()
//        for size in sizes {
//            if let attachment = sc3.quickExportWithTitle(
//                "3rd Image",
//                background: .color(.blue),
//                exportSize: size,
//                alignment: .titleAbove) {
//                add(attachment)
//            }
//        }
    }
}

