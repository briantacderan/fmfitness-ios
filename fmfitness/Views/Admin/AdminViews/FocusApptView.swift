//
//  FocusApptView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

struct FocusApptView: View {
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    var focusId: Int?

    var body: some View {
        VStack {
            if let id = focusId, let appointment = firestore.appts[id] {
                Text("Current Focus")
                AppointmentView(appointment: appointment)
            } else {
                Text("Drag Current Focus Here")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(Color("csf-main"), style: StrokeStyle(dash: [10]))
                .background(Color("csb-main"))
        )
    }
}

struct FocusApptView_Previews: PreviewProvider {
    init() {
        FirestoreManager.sampleData()
    }
    
    static var previews: some View {
        Group {
            FocusApptView(focusId: nil)
            FocusApptView(focusId: 0)
            FocusApptView(focusId: 4)
        }
        .padding()
        .frame(width: 375)
        .previewLayout(.sizeThatFits)
    }
}
