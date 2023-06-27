//
//  ScreenshotTests.swift
//  ScreenshotTests
//
//  Created by snow on 6/4/23.
//

import XCTest

final class ScreenshotTests: XCTestCase {
    func testExample() throws {
        //        let localizations = [
        //            Localization(locale: "en", title: "1st Image")
        //        ]
        
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
//public extension XCUIScreenshot {
////#if os(macOS)
////    func quickExportWithTitle(
////        _ title: String,
////        background: ImageBackground,
////        exportSize: ExportSize,
////        alignment: TitleAlignment,
////        font: Font = .system(size: 50, weight: .regular, design: .rounded)
////    ) {
////        do {
////            let image = ScreenshotWithTitle(
////                title: title,
////                image: Image(nsImage: self.image),
////                background: background,
////                exportSize: exportSize,
////                alignment: alignment,
////                font: font
////            ).edgesIgnoringSafeArea(.all)
////
////            guard let nsImage = image.renderAsImage(),
////                  let representation = nsImage.tiffRepresentation else { return }
////
////            guard let bitmap = NSBitmapImageRep(data: representation) else { return }
////            let pngData = bitmap.representation(using: .png, properties: [:])
////
////            let url = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("\(title.replacingOccurrences(of: ".", with: "")).png")
////
////            try pngData?.write(to: url)
////            print("Blacksmith: ☑️ Exported marketing image to \(url).")
////        } catch {
////            print(error)
////        }
////    }
////#endif
//
////#if os(iOS)
//    func quickExportWithTitle(
//        _ title: String,
//        background: ImageBackground,
//        exportSize: ExportSize,
//        alignment: TitleAlignment,
//        font: Font = .system(size: 50, weight: .regular, design: .rounded)
//    ) -> XCTAttachment? {
//        let capturingView = ScreenshotWithTitle(
//            title: title,
//            image: Image(uiImage: self.image),
//            background: background,
//            exportSize: exportSize,
//            alignment: alignment,
//            font: font
//        ).edgesIgnoringSafeArea(.all)
//
//        let uiImage = capturingView.takeScreenshot(origin: .zero, size: exportSize.size)
//
//        let attachment = XCTAttachment(image: uiImage)
//        attachment.name = title
//        attachment.lifetime = .keepAlways
//
//        return attachment
//    }
////#endif
//}
