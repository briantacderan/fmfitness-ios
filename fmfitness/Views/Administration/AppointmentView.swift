//
//  AppointmentView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

struct AppointmentView: View {
    @Environment(\.editMode) var editMode
    @Environment(\.controller) var controller
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    var appt: TodoItem
    
    let dateNow = Date()

    var isConfirmed: Binding<Bool> {
        Binding(
            get: {
                appt.isConfirmed
            },
            set: { isConfirmed, transaction in
                withTransaction(transaction) {
                    controller.updateAppt(withId: appt.id, isConfirmed: isConfirmed, isCompleted: false, isPaid: appt.isPaid, isCanceled: false)
                    let newAppt = appt
                    newAppt.isConfirmed = isConfirmed
                    firestore.apptChanges.append(newAppt)
                }
            })
    }
    
    var isCompleted: Binding<Bool> {
        Binding(
            get: {
                appt.isCompleted
            },
            set: { isCompleted, transaction in
                withTransaction(transaction) {
                    controller.updateAppt(withId: appt.id, isConfirmed: true, isCompleted: isCompleted, isPaid: appt.isPaid, isCanceled: false)
                    let newAppt = appt
                    newAppt.isCompleted = isCompleted
                    firestore.apptChanges.append(newAppt)
                }
            })
    }
    
    var isPaid: Binding<Bool> {
        Binding(
            get: {
                appt.isPaid
            },
            set: { isPaid, transaction in
                withTransaction(transaction) {
                    controller.updateAppt(withId: appt.id, isConfirmed: appt.isConfirmed, isCompleted: appt.isConfirmed, isPaid: isPaid, isCanceled: false)
                    let newAppt = appt
                    newAppt.isPaid = isPaid
                    firestore.apptChanges.append(newAppt)
                }
            })
    }
    
    var isCanceled: Binding<Bool> {
        Binding(
            get: {
                appt.isCanceled
            },
            set: { isCanceled, transaction in
                withTransaction(transaction) {
                    controller.updateAppt(withId: appt.id, isConfirmed: appt.isConfirmed, isCompleted: appt.isCompleted, isPaid: appt.isPaid, isCanceled: isCanceled)
                    let newAppt = appt
                    newAppt.isCanceled = isCanceled
                    firestore.apptChanges.append(newAppt)
                }
            })
    }

    var body: some View {
        if !appt.isConfirmed && !appt.isCanceled {
            ListRow {
                HStack {
                    if (firestore.sort == 2) {
                        Toggle("Paid?", isOn: isPaid.animation(.easeInOut))
                            .foregroundColor(Color("csf-choice"))
                            .toggleStyle(SwitchToggleStyle(tint: Color("csf-menu-gray")))
                            .font(Font.custom("BebasNeue", size: 20))
                    } else if (firestore.sort == 0) {
                        Toggle("", isOn: isConfirmed.animation(.easeInOut))
                            .toggleStyle(CheckboxStyle())
                    }
                    
                    Text("\(appt.email.components(separatedBy: "@")[0])")

                    Spacer()
                    
                    if ((editMode == .inactive) && appt.isPaid) {
                        Image(systemName: "dollarsign.square")
                            .foregroundColor(Color("csf-menu-gray"))
                    }

                    Text("for:")
                        .foregroundColor(Color("csf-main"))
                    Text(appt.nextAppointment, formatter: .apptFormatter)
                }
                .padding()
                .opacity((appt.nextAppointment < dateNow) ? 0.2 : 1)
                .foregroundColor(appt.isConfirmed ? Color("A2-teal") : Color("B1-red"))
                .lineLimit(2)
            }
        } else if appt.isConfirmed && !appt.isCompleted && !appt.isCanceled {
            ListRow {
                HStack {
                    if (firestore.sort == 2) {
                        Toggle("Paid?", isOn: isPaid.animation(.easeInOut))
                            .foregroundColor(Color("csf-choice"))
                            .toggleStyle(SwitchToggleStyle(tint: Color("csf-menu-gray")))
                            .font(Font.custom("BebasNeue", size: 20))
                    } else if (firestore.sort == 0) {
                        Toggle("", isOn: isConfirmed.animation(.easeInOut))
                            .toggleStyle(CheckboxStyle())
                    } else if (firestore.sort == 1 ) {
                        Toggle("", isOn: isCompleted.animation(.easeInOut))
                            .toggleStyle(CheckboxStyle())
                    }
                    
                    Text("\(appt.email.components(separatedBy: "@")[0])")

                    Spacer()
                    
                    if ((editMode == .inactive) && appt.isPaid) {
                        Image(systemName: "dollarsign.square")
                            .foregroundColor(Color("csf-menu-gray"))
                    }

                    Text("for:")
                        .foregroundColor(Color("csf-main"))
                    Text(appt.nextAppointment, formatter: .apptFormatter)
                }
                .padding()
                .opacity((appt.nextAppointment < dateNow) ? 0.2 : 1)
                .foregroundColor(appt.isConfirmed ? (appt.isCompleted ? Color("base-green") : Color("A2-teal")) : Color("B1-red"))
                .lineLimit(2)
            }
        } else if appt.isCompleted && !appt.isCanceled {
            ListRow {
                HStack {
                    if (firestore.sort == 2) {
                        Toggle("Paid?", isOn: isPaid.animation(.easeInOut))
                            .foregroundColor(Color("csf-choice"))
                            .toggleStyle(SwitchToggleStyle(tint: Color("csf-menu-gray")))
                            .font(Font.custom("BebasNeue", size: 20))
                    } else if (firestore.sort == 1) {
                        Toggle("", isOn: isCompleted.animation(.easeInOut))
                            .toggleStyle(CheckboxStyle())
                    }
                    
                    Text("\(appt.email.components(separatedBy: "@")[0])")

                    Spacer()
                    
                    if ((editMode == .inactive) && appt.isPaid) {
                        Image(systemName: "dollarsign.square")
                            .foregroundColor(Color("csf-menu-gray"))
                    }

                    Text("for: ")
                        .foregroundColor(Color("csf-main"))
                    Text(appt.nextAppointment, formatter: .apptFormatter)
                }
                .padding()
                .opacity((appt.nextAppointment < dateNow) ? 0.2 : 1)
                .foregroundColor(appt.isCompleted ? Color("base-green") : Color("A2-teal"))
                .lineLimit(2)
            }
        }
    }
}
