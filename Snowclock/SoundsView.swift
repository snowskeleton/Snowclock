//
//  SoundsView.swift
//  Snowclock
//
//  Created by snow on 5/8/23.
//

import SwiftUI

struct SoundsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var newSound: String
    var body: some View {
        VStack {
            List {
                ForEach(getSounds(), id: \.self) { sound in
                    Button(action: {
                        newSound = sound
                    }, label: {
                        HStack {
                            Text("\(sound)")
                            if newSound == sound {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    })
                }
            }
            Spacer()
            Button("Back") {dismiss()}
        }
    }
}

struct SoundsView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDetailsView(preview: true)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

