//
//  AlarmBoxView.swift
//  Declare Alarm
//
//  Created by snow on 12/21/22.
//

import SwiftUI

struct AlarmBoxView: View {
    @Binding var alarm: Alarm
    var body: some View {
        VStack {
            HStack {
                Text(alarm.time!, formatter: shortDate)
                    .font(.title)
                Text(alarm.stringyFollowups)
                Spacer()
                Text(String(alarm.enabled))
            }
            HStack {
                Text(alarm.stringySchedule)
                Spacer()
                Text(alarm.name!)
            }
        }
    }
}


struct AlarmBoxView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
