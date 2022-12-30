//
//  ContentView.swift
//  Snowclock
//
//  Created by snow on 12/16/22.
//

import SwiftUI
import CoreData
import AVKit


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @Environment(\.scenePhase) private var scenePhase
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Alarm.time,
                ascending: true
            )],
        animation: .default)
    private var alarms: FetchedResults<Alarm>
    @State var showAddAlarm = false
    @State var audioPlayer: AVAudioPlayer!
    
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
        .onChange(of: scenePhase) { phase in
            let delta = nextAlarm(from: alarms)?.secondsTilNextOccurance()
            if delta != 0.0 {
                let sound = Bundle.main.path(forResource: "snowtone", ofType: "aiff")
                audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
                
                let ai = AVAudioSession.sharedInstance()
                try? ai.setCategory(
                    .playAndRecord,
                    options: [
                        .duckOthers,
                        .defaultToSpeaker,
                        .interruptSpokenAudioAndMixWithOthers
                    ])
                try? ai.setActive(true)
                
                let now = audioPlayer.deviceCurrentTime
                let then = now + delta!
                print(delta!)
                print("-")
                print(now)
                print("=")
                print(delta! - now)
                
                audioPlayer.play(atTime: then)
            }
        }
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
