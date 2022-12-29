//
//  ContentView.swift
//  Snowclock
//
//  Created by snow on 12/16/22.
//

import SwiftUI
import CoreData
//import AVKit


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @Environment(\.scenePhase) private var scenePhase
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Alarm.time, ascending: false)],
        animation: .default)
    private var noalarms: FetchedResults<Alarm>
    var nextAlarm: Optional<Alarm> {
        let val = noalarms.filter( {$0.enabled} )
        return val.min(by: { $0.time! > $1.time! })
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Alarm.time, ascending: true)],
        animation: .default)
    private var alarms: FetchedResults<Alarm>
    @State var showAddAlarm = false
//    @State var audioPlayer: AVAudioPlayer!
    
    
    init(preview: Bool = false, showSheet: Bool = false) {
        _showAddAlarm = State(initialValue: showSheet)
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(alarms) { alarm in
                    NavigationLink {
                        AlarmDetailsView(alarm: Binding<Alarm>.constant(alarm))
                            .environment(\.managedObjectContext, viewContext)
                    } label: {
                        AlarmBoxView(alarm: Binding<Alarm>.constant(alarm))
                            .environment(\.managedObjectContext, viewContext)
                    }
                }.onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(
                        action: { showAddAlarm = true },
                        label:  {
                            Image(systemName: "plus.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(Color.secondary)
                        }
                    )
                }
            }
        }
//        .onChange(of: scenePhase) { (newScenePhase) in
//            if nextAlarm == nil {
//                print("Nothing scheduled")
//                return
//            } else {
////                print(nextAlarm!.time!.description)
//            }
//
//            let sound = Bundle.main.path(forResource: "snowtone", ofType: "aiff")
//            audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
//
//            switch newScenePhase {
//            case .active, .background, .inactive:
//                UNUserNotificationCenter.current().removeAllDeliveredNotifications() //get rid of current cruft
//                UNUserNotificationCenter.current().getPendingNotificationRequests { notes in //get rid of upcoming cruft
//                    for n in notes {
////                        if n.content.threadIdentifier
//                    }
//                }
//                // remove sending notifications
//                break
////                let ai = AVAudioSession.sharedInstance()
////                try? ai.setCategory(.playAndRecord, options: [.duckOthers, .defaultToSpeaker])
////                try? ai.setActive(true)
////
////                let cur = audioPlayer.deviceCurrentTime
////                let add = nextAlarm?.secondsTilNextOccurance() ?? 0
////                let new = cur + add
////
////                print("Current time: " + String(describing: cur))
////                print("new time in: " + String(describing: Int(new - cur)))
////                if add != 0 {
////                    audioPlayer.play(atTime: new)
////                }
//            @unknown default:
//                print("Something weird happened")
//            }
//        }
        .sheet(isPresented: $showAddAlarm) {
            AddAlarmView()
                .presentationDetents([.medium])
                .environment(\.managedObjectContext, viewContext)
        }
    }
 
    fileprivate func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { alarms[$0] }.forEach(viewContext.delete)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
