//
//  RoutineView.swift
//  Declare Alarm
//
//  Created by snow on 12/21/22.
//

import SwiftUI

struct RoutineView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var alarm: Alarm
    
    var followupsFR: FetchRequest<Followup>
    var followups: FetchedResults<Followup> { followupsFR.wrappedValue }
    
    init(alarm: Binding<Alarm>) {
        _alarm = alarm
        followupsFR = FetchRequest(
            sortDescriptors: [SortDescriptor(\.delay)],
            predicate: NSPredicate(format: "alarm.id == %@", _alarm.id! as CVarArg )
        )
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(followups, id: \.self) { r in
                    
                    HStack {
                        Button(action: {
                        }, label:  { Text("\(r.delay) min after") })
                        
                        Spacer()
                        HStack {
                            Button(action: {
                                r.delay -= 5
                            }, label:  { Label("", systemImage: "minus") })
                            
                            Button(action: {
                                r.delay += 5
                            }, label:  { Label("", systemImage: "plus") })
                        }
                    }.padding()
                    
                }.onDelete(perform: someDelete) // ForEach
            }
        }
        Button(action: {
            addFollowup()
        }) { Label("", systemImage: "plus").font(.title) }
    }
    
    fileprivate func addFollowup() {
        let fol = Followup(context: viewContext)
        fol.id = UUID()
        fol.delay = 5
        fol.alarm = alarm
    }
    
    fileprivate func someDelete(offsets: IndexSet) {
        offsets.map { followups[$0] }.forEach(viewContext.delete)
    }
}

struct RoutineView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDetailsView(preview: true, showRoutine: true)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
