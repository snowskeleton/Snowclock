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
    @Binding var newSound: String
    @State var sounds: [String]
    
    ///File Manager alows us access to the device's files to which we are allowed.
    let fileManager: FileManager = FileManager()
    
    init(newSound: Binding<String>) {
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
            fileManager.fileExists(
                atPath: url.path,
                isDirectory: &urlIsaDirectory
            )
            if !urlIsaDirectory.boolValue {
                soundPaths.append("\(url.lastPathComponent)")
            }
        }
        _sounds = State(initialValue: soundPaths)
        _newSound = newSound
    }
    
    var body: some View {
            VStack {
                List {
//                    ForEach(sounds, id: \.self) { key in
//                        Text(key)
//                        if alarm.soundName == key {
//                            Spacer()
//                            Image(systemName: "checkmark")
//                        }
//                    }
                    ForEach(sounds, id: \.self) { sound in
                        Button(action: {
                            newSound = sound
                        }) {
                            HStack {
                                Text("\(sound)")
                                if newSound == sound {
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

