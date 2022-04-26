//
//  CompletedApptView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

struct CompletedApptView: View {
    @ObservedObject var firestore = FirestoreManager.shared

    var body: some View {
        Group {
            HeaderView(title: "Completed")
                .foregroundColor(firestore.sort == 1 || firestore.sort == 2 ? Color("csf-earth") : Color("csb-choice"))

            ForEach(firestore.completedAppts) { appointment in
                AppointmentView(appointment: appointment)
                    .onDrag {
                        NSItemProvider(object: appointment)
                    }
            }
            .onMove(perform: firestore.moveActiveAppts(fromOffsets:toOffset:))

            FooterView(title: "Completed:", count: firestore.completedCount)
        }
        .opacity(firestore.sort == 1 || firestore.sort == 2 || !firestore.editMode ? 1.0 : 0.2)
    }
}
