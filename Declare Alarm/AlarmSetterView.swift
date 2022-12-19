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
    @State private var date: Date = Date()
    
    var body: some View {
        Section {
            VStack {
                DatePicker("Alarm time",
                           selection: $date,
                           displayedComponents: [.hourAndMinute])
                .padding()
                .labelsHidden()
                .datePickerStyle(.wheel)
                Spacer()
                Button("Done") {
                    finished()
                }}.padding()}}
    
    fileprivate func finished() {
        let alarm = Alarm(context: viewContext)
        alarm.date = $date.wrappedValue
        alarm.activeDays = [false, false, false, false, false, false, false]
        dismiss()
    }
}
