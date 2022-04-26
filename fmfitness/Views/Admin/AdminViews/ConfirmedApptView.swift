//
//  ConfirmedApptView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/22/22.
//

import SwiftUI

struct ConfirmedApptView: View {
    @ObservedObject var firestore = FirestoreManager.shared
    @Environment(\.isEnabled) private var isEnabled: Bool

    var body: some View {
        Group {
            HeaderView(title: "Confirmed")
                .foregroundColor(firestore.sort == 0 || firestore.sort == 1 ? Color("csf-earth") : Color("csb-choice"))

            ForEach(firestore.confirmedAppts) { appointment in
                AppointmentView(appointment: appointment)
                    .onDrag {
                        NSItemProvider(object: appointment)
                    }
            }
            .onMove(perform: firestore.moveActiveAppts(fromOffsets:toOffset:))

            FooterView(title: "Confirmed:", count: firestore.confirmedCount)
        }
        .opacity(firestore.sort == 0 || firestore.sort == 1 || !firestore.editMode ? 1.0 : 0.2)
    }
}
