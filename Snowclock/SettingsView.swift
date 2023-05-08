//
//  SettingsView.swift
//  Snowclock
//
//  Created by snow on 5/7/23.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @Environment(\.dismiss) private var dismiss
    @State var bypassMuteSwitch = false
    
    
    var body: some View {
        NavigationView {
            List {
                Toggle(
                    isOn: $bypassMuteSwitch,
                    label: {
                        Text("Bypass Mute Switch")
                            .foregroundColor(Color.secondary)
                    }
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: {
                    dismiss()
                })
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environment(
            \.managedObjectContext,
             PersistenceController.preview.container.viewContext
        )
    }
}
