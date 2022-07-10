//
//  ActiveApptView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

struct ActiveApptView: View {
    @Environment(\.controller) var controller
    @ObservedObject var firestore = FirestoreManager.shared

    var body: some View {
        Section {
            ForEach(firestore.activeAppts, id: \.self) { item in
                HStack(spacing: 2) {
                    AppointmentView(appt: item)
                        .onDrag {
                            NSItemProvider(object: item)
                        }
                }
                .background(Color("csb-main"))
                .listRowBackground(Color("csb-main"))
                .listRowSeparator(.hidden)
                .frame(height: 28)
            }
            .onDelete { controller.deleteActiveAppts(atOffsets: $0) }
            .onMove { controller.moveActiveAppts(fromOffsets: $0, toOffset: $1) }
        } header: {
            HeaderView(title: (firestore.sort == 0) ?
                          "Confirm appointments" : "Active requests",
                   fontSize: (firestore.sort == 0) ? 25 : 20)
        } footer: {
            FooterView(title: "Unconfirmed:", count: firestore.activeCount)
        }
        .background(Color("csb-main"))
        .listRowBackground(Color("csb-main"))
        .listRowSeparator(.hidden)
    }
}
