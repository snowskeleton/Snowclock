//
//  AlarmSetterView.swift
//  Snowclock
//
//  Created by snow on 12/16/22.
//

import SwiftUI
import CoreData
struct AddAlarmView: View {
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
        let _ = alarmMaker(context: viewContext, time: $date.wrappedValue)
        dismiss()
    }
}

struct AddAlarmView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(preview: true, showSheet: true)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
