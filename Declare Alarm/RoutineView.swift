//
//  RoutineView.swift
//  Declare Alarm
//
//  Created by snow on 12/21/22.
//

import SwiftUI

struct RoutineView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var routine: [Followup]
    @State var selectedRoutine: Int?
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                ForEach(routine, id: \.self) { r in
                    HStack {
                        Button(action: {
                        }, label:  { Text("\(r.delay) min after") })
                        
                        Spacer()
                        HStack {
                            Button(action: {
                                let i = routine.firstIndex(of: r)!
                                routine[i] = routine[i] - 5
                            }, label:  { Label("", systemImage: "minus") })
                            
                            Button(action: {
                                let i = routine.firstIndex(of: r)!
                                routine[i] = routine[i] + 5
                            }, label:  { Label("", systemImage: "plus") })
                        }
                    }.padding()
                }
                Spacer()
                Button(action: {
                    let fol = Followup(context: viewContext)
                    fol.delay = 5
                    routine.append(fol)
                }) { Label("", systemImage: "plus").font(.title) }
            }
        }
    }
}

struct RoutineView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDetailsView(preview: true, showRoutine: true)
    }
}
