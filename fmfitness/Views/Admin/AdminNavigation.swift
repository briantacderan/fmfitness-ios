//
//  AdminNavigation.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

struct AdminNavigation: View {
    @ObservedObject var firestore = FirestoreManager.shared
    
    @State private var isShowingAddApptView = false
    @State private var focusId: Int?

    func addAppt() {
        isShowingAddApptView = true
    }

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    if firestore.editMode && firestore.sort == 0 {
                        FocusApptView(focusId: focusId)
                            .padding()
                            .onDrop(
                                of: [AdminData.typeIdentifier],
                                delegate: ApptDropDelegate(focusId: $focusId))
                    }
                    
                    ScrollView {
                        ActiveApptView()
                            .disabled(firestore.editMode && firestore.sort != 0)
                            .onDrop(of: [AdminData.typeIdentifier], isTargeted: nil) { apptProviders in
                                for apptProvider in apptProviders {
                                    apptProvider.loadObject(ofClass: AdminData.self) { appointment, _ in
                                        guard
                                            let appointment = appointment as? AdminData
                                        else { return }
                                        DispatchQueue.main.async {
                                            firestore.updateAppt(withId: appointment.id, isConfirmed: false, isCompleted: false, isPaid: false)
                                        }
                                    }
                                }
                                return true
                            }
                        ConfirmedApptView()
                            .disabled(firestore.editMode && firestore.sort == 2)
                            .onDrop(of: [AdminData.typeIdentifier], isTargeted: nil) { apptProviders in
                                for apptProvider in apptProviders {
                                    apptProvider.loadObject(ofClass: AdminData.self) { appointment, _ in
                                        guard
                                            let appointment = appointment as? AdminData
                                        else { return }
                                        DispatchQueue.main.async {
                                            firestore.updateAppt(withId: appointment.id, isConfirmed: true, isCompleted: false, isPaid: false)
                                        }
                                    }
                                }
                                return true
                            }
                        CompletedApptView()
                            .disabled(firestore.editMode && firestore.sort == 0)
                            .onDrop(of: [AdminData.typeIdentifier], isTargeted: nil) { apptProviders in
                                for apptProvider in apptProviders {
                                    apptProvider.loadObject(ofClass: AdminData.self) { appointment, _ in
                                        guard
                                            let appointment = appointment as? AdminData
                                        else { return }
                                        DispatchQueue.main.async {
                                            firestore.updateAppt(withId: appointment.id, isConfirmed: true, isCompleted: true, isPaid: false)
                                        }
                                    }
                                }
                                return true
                            }
                        PaidApptView()
                            .disabled(firestore.editMode && firestore.sort != 2)
                            .onDrop(of: [AdminData.typeIdentifier], isTargeted: nil) { apptProviders in
                                for apptProvider in apptProviders {
                                    apptProvider.loadObject(ofClass: AdminData.self) { appointment, _ in
                                        guard
                                            let appointment = appointment as? AdminData
                                        else { return }
                                        DispatchQueue.main.async {
                                            firestore.updateAppt(withId: appointment.id, isConfirmed: true, isCompleted: true, isPaid: true)
                                        }
                                    }
                                }
                                return true
                            }
                    }
                    .applyPlainListAppearance()
                }
                .foregroundColor(Color("csf-main"))
                .navigationBarTitle("Administration")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        MenuButton()
                            .foregroundColor(Color("csf-main-gray"))
                    }
                    
                    ToolbarItemGroup(placement: .primaryAction) {
                        Menu {
                            Picker(selection: $firestore.sort, label: Text("Sorting options")) {
                                Text("Confirm appointments").tag(0)
                                Text("Mark as completed").tag(1)
                                Text("Mark as paid for").tag(2)
                            }
                            .onChange(of: firestore.sort) { value in
                                if value == 3 {
                                    firestore.editMode = false
                                } else {
                                    firestore.editMode = true
                                }
                            }
                            
                            Button {
                                addAppt()
                            } label: {
                                Label("Add", systemImage: "plus.rectangle.fill")
                            }
                        }
                        label: {
                            Label("Sort", systemImage: "plus.rectangle.fill.on.rectangle.fill")
                        }
                        .disabled(firestore.editMode)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            firestore.editMode = false
                            firestore.sort = 3
                        } label: {
                            firestore.editMode ? Text("Confirm") : Text("")
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width,
                       height: UIScreen.main.bounds.height)
                .background(Color("csb-main"))
                .ignoresSafeArea()
                .offset(y: 115)
                .sheet(isPresented: $isShowingAddApptView) {
                    AddApptView()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
