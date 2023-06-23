//
//  AlarmDetailsView.swift
//  Snowclock
//
//  Created by snow on 12/19/22.
//

import SwiftUI
import CoreData

struct AlarmView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @Environment(\.dismiss) private var dismiss
    @Binding var alarm: Alarm
    @State var showSchedule: Bool = false
    @State var showSounds: Bool = false
    @State var newDate: Date
    @State var newName: String
    @State var newSound: String
    @State var newSchedule: [Bool]
    @State var newEnabledStatus: Bool
    
    private var routines: [Followup] {
        let n = alarm.followups?.allObjects as! [Followup]
        return n.sorted(by: { $0.delay < $1.delay })
    }
    
    init(alarm: Binding<Alarm>) {
        _alarm = alarm
        _newName = State(initialValue: alarm.wrappedValue.name!)
        _newDate = State(initialValue: alarm.wrappedValue.time!)
        _newSound = State(initialValue: alarm.wrappedValue.soundName ?? "Alarm.m4r")
        _newEnabledStatus = State(initialValue: alarm.wrappedValue.enabled)
        _newSchedule = State(
            initialValue: (_alarm.wrappedValue.schedule != nil)
            ? _alarm.wrappedValue.schedule!
            : NO_REPEATS
        )
    }
    
    init(preview: Bool = false) {
        let alarm = alarmMaker(context: PersistenceController.preview.container.viewContext)
        alarm.schedule![0] = true
        
        let nums = [7, 11, 140]
        for num in nums {
            let fol = Followup(context: PersistenceController.preview.container.viewContext)
            fol.delay = Int64(num)
            fol.id = UUID()
            fol.alarm = alarm
        }
        
        self.init(alarm: Binding<Alarm>.constant(alarm))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    DatePicker("Alarm time",
                               selection: $newDate,
                               displayedComponents: [.hourAndMinute])
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                    
                    HStack {
                        Text("Name")
                            .foregroundColor(Color.secondary)
                            .padding(.leading, 10)
                        Spacer()
                        TextField("Alarm name", text: $newName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Schedule")
                            .foregroundColor(Color.secondary)
                            .padding(.leading, 10)
                        Spacer()
                        Button(
                            action: { showSchedule = true },
                            label: {
                                Text(daysAsString(days: newSchedule))
                                    .foregroundColor(Color.primary)
                            }
                        )
                        .sheet(isPresented: $showSchedule) {
                            ScheduleView(schedule: $newSchedule)
                        }
                        .environment(\.managedObjectContext, viewContext)
            
                    }
                    
                    HStack {
                        Text("Sound")
                            .foregroundColor(Color.secondary)
                            .padding(.leading, 10)
                        Spacer()
                        Button {
                            showSounds = true
                        } label: {
                            Text( newSound)
                                .foregroundColor(Color.primary)
                        }
                        .sheet(isPresented: $showSounds) {
                            SoundsView(newSound: $newSound)
                        }
                        .environment(\.managedObjectContext, viewContext)
                    }
                    
                    HStack {
                        Spacer()
                        Toggle(
                            isOn: $newEnabledStatus,
                            label: {
                                Text("Enabled")
                                    .foregroundColor(Color.secondary)
                            }
                        )
                    }
                }
                RoutineBox(alarm: Binding<Alarm>.constant(alarm))
                    .environment(\.managedObjectContext, viewContext)
            }
        }.toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: {
                    alarm.time = newDate
                    alarm.name = newName
                    alarm.schedule = newSchedule
                    alarm.soundName = newSound
                    alarm.enabled = newEnabledStatus
                    alarm.updateNotifications()
                    dismiss()
                })
            }
        }
    }
}

struct RoutineBox: View {
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
                }) {
                    Image(systemName: "plus")
                    Text("Routine").foregroundColor(Color.secondary)
                }
            }
        }
    }
    
    fileprivate func addFollowup() {
        let fu = alarm.latestFollowup()
        let idelay = fu?.delay ?? 0
        let delay = idelay + 5
        alarm.addFollowup(with: Int(delay))
    }
    
    fileprivate func someDelete(offsets: IndexSet) {
        offsets.map { followups[$0] }.forEach(viewContext.delete)
    }
}
struct AlarmDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmView(preview: true).environment(
            \.managedObjectContext,
             PersistenceController.preview.container.viewContext
        )
    }
}
