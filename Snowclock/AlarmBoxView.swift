//
//  AlarmBoxView.swift
//  Snowclock
//
//  Created by snow on 12/21/22.
//

import SwiftUI

struct AlarmBoxView: View {
    @Binding var alarm: Alarm
    var showthis: String {
        var s = String()
        s += alarm.name!
        if alarm.stringySchedule != "" {
            s += ", "
            s += alarm.stringySchedule
        }
        return s
    }
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(alarm.time!, formatter: shortDate)
                        .font(.title)
                    Text(alarm.stringyFollowups)
                    Spacer()
                }
                HStack {
                    Text(showthis)
                    Spacer()
                }
            }
            Toggle(isOn: $alarm.enabled) {}
        }
        .foregroundColor(alarm.enabled ? Color.primary : Color.secondary)
        .italic(!alarm.enabled)
    }
}


struct AlarmBoxView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
