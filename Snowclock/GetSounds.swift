//
//  GetSounds.swift
//  Snowclock
//
//  Created by snow on 5/8/23.
//

import Foundation
func getSounds() -> [String]{
    ///File Manager alows us access to the device's files to which we are allowed.
    let fileManager: FileManager = FileManager()
    
//    let rootSoundDirectory = Bundle.main.resourcePath
////    print(rootSoundDirectory!)
//    let newDirectory: NSMutableDictionary = [
//        "path" : "\(rootSoundDirectory!)",
//        "files" : [] as [String]
//    ]
    /**
     For each directory, it looks at each item (file or directory) and only appends the sound files to the soundfiles[i]files array.
     
     - URLs: All of the contents of the directory (files and sub-directories).
     */
//    let directoryURL: URL = URL(
//        fileURLWithPath: newDirectory.value(forKey: "path") as! String,
//        isDirectory: true
//    )
    var directoryURL = Bundle.main.resourceURL
    print(directoryURL)
//    directoryURL = directoryURL!.appendingPathComponent("Snowclock")
//    print(directoryURL)
    
    
    var URLs: [URL] = []
    do {
        URLs = try fileManager.contentsOfDirectory(
            at: directoryURL!,
            includingPropertiesForKeys: [URLResourceKey.isDirectoryKey],
            options: FileManager.DirectoryEnumerationOptions()
        )
    } catch {
        debugPrint("\(error)")
    }
    var urlIsaDirectory: ObjCBool = ObjCBool(false)
    var soundPaths: [String] = []
    for url in URLs {
        fileManager.fileExists(
            atPath: url.path,
            isDirectory: &urlIsaDirectory
        )
        if !urlIsaDirectory.boolValue && url.absoluteString.hasSuffix(".m4r") {
            soundPaths.append("\(url.lastPathComponent)")
        }
    }
    return soundPaths
}
