//
//  SnowclockApp.swift
//  Snowclock
//
//  Created by snow on 12/16/22.
//

import SwiftUI
import AVKit

@main
struct SnowclockApp: App {
    @Environment(\.scenePhase) var scenePhase
    let persistenceController = PersistenceController.shared
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Alarm.time, ascending: false)],
        animation: .default)
    private var noalarms: FetchedResults<Alarm>
    var nextAlarm: Optional<Alarm> {
        let val = noalarms.filter( {$0.enabled} )
        return val.min(by: { $0.time! > $1.time! })
    }
    @State var audioPlayer: AVAudioPlayer!
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
            //
            let sound = Bundle.main.path(forResource: "snowtone", ofType: "aiff")
            audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
            
            let ai = AVAudioSession.sharedInstance()
            try? ai.setCategory(.playback, options: [.duckOthers, .defaultToSpeaker, .interruptSpokenAudioAndMixWithOthers])
            try? ai.setActive(true)
            
            let delta = nextAlarm?.secondsTilNextOccurance() ?? 0
            let now = audioPlayer.deviceCurrentTime
            let then = now + delta
            
            audioPlayer.play(atTime: then)
        }
    }
}
