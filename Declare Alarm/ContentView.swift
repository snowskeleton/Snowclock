//
//  ContentView.swift
//  Declare Alarm
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
        sortDescriptors: [NSSortDescriptor(keyPath: \Alarm.time, ascending: false)],
        animation: .default)
    private var noalarms: FetchedResults<Alarm>
    var nextAlarm: Optional<Alarm> {
        let val = noalarms.filter( {$0.enabled} )
        let max = val.max(by: { $0.time! < $1.time! })
        return max
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Alarm.time, ascending: true)],
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
        .onChange(of: scenePhase) { (newScenePhase) in
            if nextAlarm == nil {
                print("Nothing scheduled")
                return
            } else {
//                print(nextAlarm!.time!.description)
            }
            
            let sound = Bundle.main.path(forResource: "MP3_700KB", ofType: "mp3")
            audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))

            switch newScenePhase {
            case .active:
                setPlayer(to: nextAlarm!, with: audioPlayer)
            case .inactive:
                setPlayer(to: nextAlarm!, with: audioPlayer)
            case .background:
                setPlayer(to: nextAlarm!, with: audioPlayer)
            @unknown default:
                print("Something weird happened")
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
    
    fileprivate func getEnabledAlarms() -> FetchRequest<Alarm> {
        let fr: FetchRequest<Alarm>
        let request: NSFetchRequest<Alarm> = Alarm.fetchRequest()
        var alarms: FetchedResults<Alarm> { fr.wrappedValue }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "enabled == %@", "yes")
        ])
        
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \Alarm.time,
                ascending: true
            )
        ]
        
        return FetchRequest<Alarm>(fetchRequest: request)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
