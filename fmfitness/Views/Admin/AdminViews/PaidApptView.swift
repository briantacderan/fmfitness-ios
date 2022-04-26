//
//  paidApptView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/22/22.
//

import SwiftUI

struct PaidApptView: View {
    @ObservedObject var firestore = FirestoreManager.shared

    var body: some View {
        Group {
            HeaderView(title: "Paid")
                .foregroundColor(firestore.sort == 2 ? Color("csf-earth") : Color("csb-choice"))

            ForEach(firestore.paidAppts) { appointment in
                AppointmentView(appointment: appointment)
            }

            FooterView(title: "Paid:", count: firestore.paidCount)
        }
        .opacity(firestore.sort == 2 || !firestore.editMode ? 1.0 : 0.2)
    }
}
