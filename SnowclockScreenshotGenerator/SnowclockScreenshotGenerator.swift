//
//  SnowclockScreenshotGenerator.swift
//  SnowclockScreenshotGenerator
//
//  Created by snow on 6/27/23.
//

import XCTest

final class SnowclockScreenshotGenerator:  XCTestCase {
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
        let screenshot = app.screenshot()
        
        if let attachment = screenshot.quickExportWithTitle(
            "1st Image",
            background: .color(.blue),
            exportSize: .iPhone,
            alignment: .titleAbove) {
            add(attachment)
        }
    }
}
