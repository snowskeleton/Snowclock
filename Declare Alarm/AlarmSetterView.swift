//
//  AlarmSetterView.swift
//  Declare Alarm
//
//  Created by snow on 12/16/22.
//

import SwiftUI
import CoreData
struct AlarmSetterView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Alarm.date, ascending: true)],
        animation: .default)
    private var alarms: FetchedResults<Alarm>
    
    @State var showSheet = false
    
    @State private var date: Date = Date()
    @State var something = [false, false, false, false, false, false, false]
    
    init() {
    }
    init(alarm: Binding<Alarm>) {
        date = alarm.date.wrappedValue!
    }
    
    var body: some View {
        Section {
            VStack {
                DatePicker("Alarm time",
                           selection: $date,
                           displayedComponents: [.hourAndMinute])
                .padding()
                .labelsHidden()
                .datePickerStyle(.wheel)
                Button("Repeat",action: {
                    showSheet = true
                }).sheet(isPresented: $showSheet){
                    DayOfTheWeekPicker(activeDays: $something)
                }
                Spacer()
                Button("Done") {
                    finished()
                }}.padding()}}
    
    fileprivate func finished() {
        let alarm = Alarm(context: viewContext)
        alarm.date = $date.wrappedValue
        let _ = print("help me")
        try? viewContext.save()
        dismiss()
    }
}
