//
//  AppointmentView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

struct AppointmentView: View {
    @ObservedObject var firestore = FirestoreManager.shared
  
    var appointment: AdminData

    var isConfirmed: Binding<Bool> {
        Binding(
            get: {
                appointment.isConfirmed
            },
            set: { isConfirmed, transaction in
                withTransaction(transaction) {
                    firestore.updateAppt(withId: appointment.id, isConfirmed: isConfirmed, isCompleted: false, isPaid: false)
                }
            })
    }
    
    var isCompleted: Binding<Bool> {
        Binding(
            get: {
                appointment.isCompleted
            },
            set: { isCompleted, transaction in
                withTransaction(transaction) {
                    firestore.updateAppt(withId: appointment.id, isConfirmed: true, isCompleted: isCompleted, isPaid: false)
                }
            })
    }
    
    var isPaid: Binding<Bool> {
        Binding(
            get: {
                appointment.isPaid
            },
            set: { isPaid, transaction in
                withTransaction(transaction) {
                    firestore.updateAppt(withId: appointment.id, isConfirmed: true, isCompleted: true, isPaid: isPaid)
                }
            })
    }

    var body: some View {
        if firestore.sort == 2 && appointment.isConfirmed == true && appointment.isCompleted == true {
            ListRow {
                HStack {
                    if firestore.editMode {
                        Toggle("", isOn: isPaid.animation(.easeInOut))
                            .toggleStyle(CheckboxToggleStyle())
                    }
                    
                    Text("\(appointment.email)")
                        .strikethrough(appointment.isPaid)

                    Spacer()

                    Text("for:")
                        .strikethrough(appointment.isPaid)

                    Text(appointment.nextAppointment, formatter: .apptFormatter)
                        .strikethrough(appointment.isPaid)
                }
                .foregroundColor(appointment.isPaid ? .gray: .black)
                .lineLimit(2)
            }
        } else if firestore.sort == 1 && appointment.isConfirmed == true && appointment.isPaid == false {
            ListRow {
                HStack {
                    if firestore.editMode {
                        Toggle("", isOn: isCompleted.animation(.easeInOut))
                            .toggleStyle(CheckboxToggleStyle())
                    }

                    Text("\(appointment.email)")

                    Spacer()

                    Text("for:")

                    Text(appointment.nextAppointment, formatter: .apptFormatter)
                }
                .foregroundColor(appointment.isCompleted ? .black : Color("csf-accent"))
                .lineLimit(2)
            }
        } else if firestore.sort == 1 && appointment.isConfirmed == true && appointment.isPaid == false {
            ListRow {
                HStack {
                    if firestore.editMode {
                        Toggle("", isOn: isCompleted.animation(.easeInOut))
                            .toggleStyle(CheckboxToggleStyle())
                    }

                    Text("\(appointment.email)")

                    Spacer()

                    Text("for:")

                    Text(appointment.nextAppointment, formatter: .apptFormatter)
                }
                .foregroundColor(appointment.isCompleted ? .black : Color("csf-accent"))
                .lineLimit(2)
            }
        } else {
            ListRow {
                HStack {
                    if firestore.editMode {
                        Toggle("", isOn: isConfirmed.animation(.easeInOut))
                            .toggleStyle(CheckboxToggleStyle())
                    }

                    Text("\(appointment.email)")

                    Spacer()

                    Text("for:")

                    Text(appointment.nextAppointment, formatter: .apptFormatter)
                }
                .foregroundColor(appointment.isConfirmed ? Color("csf-accent") : Color("csf-earth"))
                .lineLimit(2)
            }
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: configuration.isOn ? "checkmark.circle" : "circle")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(configuration.isOn ? Color("csb-choice") : .black)
            .onTapGesture { configuration.isOn.toggle() }
    }
}
