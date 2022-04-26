//
//  ActiveApptView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

struct ActiveApptView: View {
    @ObservedObject var firestore = FirestoreManager.shared

    var body: some View {
        Group {
            HeaderView(title: "Unconfirmed")
                .foregroundColor(firestore.sort == 0 ? Color("csf-earth") : Color("csb-choice"))

            ForEach(firestore.activeAppts) { appointment in
                AppointmentView(appointment: appointment)
                    .onDrag {
                        NSItemProvider(object: appointment)
                    }
            }
            .onDelete(perform: firestore.deleteActiveAppts(atOffsets:))
            .onMove(perform: firestore.moveActiveAppts(fromOffsets:toOffset:))

            FooterView(title: "Unconfirmed:", count: firestore.activeCount)
        }
        .opacity(firestore.sort == 0 || !firestore.editMode ? 1.0 : 0.2)
    }
}
