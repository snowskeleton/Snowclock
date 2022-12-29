//
//  RoutineView.swift
//  Snowclock
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
        Section {
            ForEach(followups, id: \.self) { r in
                HStack {
                    HStack {
                        Button(
                            role: .destructive,
                            action: { viewContext.delete(r) },
                            label:  { Image(systemName: "minus") })
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Spacer()
                        Text(String(r.delay) + " min")
                        Spacer()
                    }
                    
                    Spacer()
                    HStack {
                        Button(
                            action: { r.delay -= 1 },
                            label:  {
                                Image(systemName: "arrow.down")
                                    .font(.title)
                            })
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Button(
                            action: { r.delay += 1 },
                            label: {
                                Image(systemName: "arrow.up")
                                    .font(.title)
                            })
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }.padding()
            }
        } header: {
            HStack {
                Button(action: {
                    addFollowup()
                }) { Image(systemName: "plus");Text("Routine").foregroundColor(Color.secondary)}
            }
        }
    }
    
    fileprivate func addFollowup() {
        let highest = alarm.latestFollowup()
        let fol = Followup(context: viewContext)
        fol.id = UUID()
        fol.delay = (highest?.delay ?? 0) + 5
        fol.alarm = alarm
    }
    
    fileprivate func someDelete(offsets: IndexSet) {
        offsets.map { followups[$0] }.forEach(viewContext.delete)
    }
}

struct RoutineView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDetailsView(preview: true)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
