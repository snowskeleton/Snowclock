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
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var alarms: FetchedResults<Item>
    @State var showSheet = false
    
    @State private var date: Date = Date()
    @State var something = [false, false, false, false, false, false, false]
    
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
                }).sheet(isPresented: $showSheet){DayOfTheWeekPicker(activeDays: $something)}
                Spacer()
                Button("Done") {
                    finished()
                }}.padding()}}
    
    fileprivate func addItem() {
        withAnimation {
            let alarm = Item(context: viewContext)
            alarm.timestamp = $date.wrappedValue
            try? viewContext.save()
        } }
    
    fileprivate func finished() {
        try? viewContext.save()
        dismiss()
    } }

struct AlarmSetterView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmSetterView()
    } }
