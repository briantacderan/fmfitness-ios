//
//  CompletedApptView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

struct CompletedApptView: View {
    @Environment(\.controller) var controller
    @ObservedObject var firestore = FirestoreManager.shared

    var body: some View {
        Section {
            ForEach(firestore.completedAppts, id: \.self) { item in
                HStack(spacing: 2) {
                    AppointmentView(appt: item)
                        .onDrag {
                            NSItemProvider(object: item)
                        }
                }
                .frame(height: 28)
            }
            .onDelete { controller.deleteCompletedAppts(atOffsets: $0) }
            .onMove { controller.moveCompletedAppts(fromOffsets: $0, toOffset: $1) }
        } header: {
            HeaderView(title: "Completed",
                       fontSize: 20)
                .foregroundColor((firestore.sort == 1) ? Color("base-light") : Color("csf-main"))
        } footer: {
            FooterView(title: "Completed:", count: firestore.completedCount)
        }
    }
}
