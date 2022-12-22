//
//  AVPlayerView.swift
//  Declare Alarm
//
//  Created by snow on 12/22/22.
//

import SwiftUI
import AVKit


struct AVPlayerView: View {
    @State var audioPlayer: AVAudioPlayer!
    var body: some View {
        ZStack {
            VStack {
                Text("Play").font(.system(size: 45)).font(.largeTitle)
                HStack {
                    Spacer()
                    Button(action: {
                        self.audioPlayer.play()
//                        self.audioPlayer.play(atTime: 10)
                    }) {
                        Image(systemName: "play.circle.fill").resizable()
                            .frame(width: 50, height: 50)
                            .aspectRatio(contentMode: .fit)
                    }
                    Spacer()
                    Button(action: {
                        self.audioPlayer.pause()
                    }) {
                        Image(systemName: "pause.circle.fill").resizable()
                            .frame(width: 50, height: 50)
                            .aspectRatio(contentMode: .fit)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            let sound = Bundle.main.path(forResource: "MP3_700KB", ofType: "mp3")
            let ai = AVAudioSession.sharedInstance()
            try? ai.setCategory(.playAndRecord, options: [.duckOthers, .defaultToSpeaker])
            try? ai.setActive(true)
            self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
            let t = audioPlayer.deviceCurrentTime
            self.audioPlayer.play(atTime: t + 5)
//                    let audioPlayer: AVAudioPlayer!
//                    let sound = Bundle.main.path(forResource: "MP3_700KB", ofType: "mp3")
//                    audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
//                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: [.duckOthers, .defaultToSpeaker])
//                    try AVAudioSession.sharedInstance().setActive(true)
//                    UIApplication.shared.beginReceivingRemoteControlEvents()
////                    let diffComponents = Calendar.current.dateComponents([.second, .hour], from: Date(), to: onlyAlarm!.time!)
//                    var triggerDate = Calendar.current.dateComponents([.hour,.minute,.second], from: onlyAlarm!.time!)
//
//                    audioPlayer.play(atTime: Double(triggerDate.second!))
                    
        }
    }
}

struct AVPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AVPlayerView()
    }
}
