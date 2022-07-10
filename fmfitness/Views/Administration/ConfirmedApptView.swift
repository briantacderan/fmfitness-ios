//
//  ConfirmedApptView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/22/22.
//

import SwiftUI

struct ConfirmedApptView: View {
    @Environment(\.controller) var controller
    @ObservedObject var firestore = FirestoreManager.shared

    var body: some View {
        Section {
            ForEach(firestore.confirmedAppts, id: \.self) { item in
                HStack(spacing: 2) {
                    AppointmentView(appt: item)
                        .onDrag {
                            NSItemProvider(object: item)
                        }
                }
                .listRowBackground(Color("csb-main"))
                .listRowSeparator(.hidden)
                .frame(height: 28)
            }
            .onDelete { controller.deleteConfirmedAppts(atOffsets: $0) }
            .onMove { controller.moveConfirmedAppts(fromOffsets: $0, toOffset: $1) }
        } header: {
            HeaderView(title: (firestore.sort == 1) ? "Mark workout complete" : "Confirmed",
                       fontSize: (firestore.sort == 1) ? 25 : 20)
                .foregroundColor((firestore.sort == 0) ? Color("base-light") : Color("csf-main"))
        } footer: {
            FooterView(title: "Confirmed:", count: firestore.confirmedCount)
        }
    }
}
