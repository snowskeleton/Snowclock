//
//  SoundsView.swift
//  Snowclock
//
//  Created by snow on 5/8/23.
//

import SwiftUI

struct SoundsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var alarm: Alarm
    @State var sounds: [String]
    
    ///File Manager alows us access to the device's files to which we are allowed.
    let fileManager: FileManager = FileManager()
    
    init(alarm: Binding<Alarm>) {
        _alarm = alarm
        let rootSoundDirectory = "/Library/Ringtones"
        let newDirectory: NSMutableDictionary = [
            "path" : "\(rootSoundDirectory)",
            "files" : [] as [String]
        ]
        /**
         For each directory, it looks at each item (file or directory) and only appends the sound files to the soundfiles[i]files array.
         
         - URLs: All of the contents of the directory (files and sub-directories).
         */
        let directoryURL: URL = URL(
            fileURLWithPath: newDirectory.value(forKey: "path") as! String,
            isDirectory: true
        )
        
        var URLs: [URL]?
        do {
            URLs = try fileManager.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [URLResourceKey.isDirectoryKey],
                options: FileManager.DirectoryEnumerationOptions()
            )
        } catch {
            debugPrint("\(error)")
        }
        var urlIsaDirectory: ObjCBool = ObjCBool(false)
        var soundPaths: [String] = []
        for url in URLs! {
            print(url)
            fileManager.fileExists(
                atPath: url.path,
                isDirectory: &urlIsaDirectory
            )
            if !urlIsaDirectory.boolValue {
                soundPaths.append("\(url.lastPathComponent)")
            }
        }
        _sounds = State(initialValue: soundPaths)
    }
    
    var body: some View {
            VStack {
                List {
                    ForEach(sounds, id: \.self) { sound in
                        Button(action: {
                            schedule[days.firstIndex(of: day)!].toggle()
                        }) {
                            HStack {
                                Text("\(day)")
                                if schedule[days.firstIndex(of: day)!] == true {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                Spacer()
                HStack {
                    Button("Back") {dismiss()}
                    Spacer()
                    Button("Save") {dismiss()}
                }
            }
//        List {
//            Text("Topper")
//            ForEach(sounds, id: \.self) { key in
//                Text(key)
//            }
//        }
    }
}

struct SoundsView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDetailsView(preview: true)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

