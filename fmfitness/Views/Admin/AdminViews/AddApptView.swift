//
//  AddApptView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

struct AddApptView: View {
    @ObservedObject var firestore = FirestoreManager.shared
    
    @Environment(\.presentationMode) private var presentationMode
  
    @State private var email = ""
    @State private var timeslot = Date()

    func addNewAppt() {
        firestore.addAppt(withEmail: email, invoice: "", isConfirmed: true, isCompleted: false, isPaid: false, nextAppointment: timeslot)
        presentationMode.wrappedValue.dismiss()
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("User", text: $email)
                DatePicker("Session Timeslot", selection: $timeslot, displayedComponents: .date)

                Section {
                    Button(action: addNewAppt) {
                        Text("Add New Appointment")
                    }
                    .disabled(email.isEmpty)
                }
            }
            .navigationBarTitle(Text("New Appointment"), displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: dismiss) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
