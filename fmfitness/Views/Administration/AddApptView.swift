//
//  AddApptView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

public extension Binding where Value: Equatable {
    init(_ source: Binding<Value>, deselectTo value: Value) {
        self.init(get: { source.wrappedValue },
                  set: { source.wrappedValue = $0 == source.wrappedValue ? value : $0 }
        )
    }
}

struct AddApptView: View {
    @Environment(\.isPresented) var isPresented
    @Environment(\.dismiss) var dismiss
    @Environment(\.controller) var controller
    
    @ObservedObject var firestore = FirestoreManager.shared
  
    @State private var email = ""
    @State private var userIndex: Int?
    @State private var timeslot = Date()
    @State private var invoice = Appointment.StripeLink.hundred.rawValue
    
    private let dateNow = Date()

    func addNewAppt() {
        controller.setTraining(parameters: ["email": email, "invoice": invoice, "confirm": true, "complete": false, "paid": false, "cancel": false, "reason": "", "timeslot": timeslot, "mode": "add"])
        withAnimation(.easeInOut(duration: 0.25)) {
            dismiss()
        }
    }
    
    init() {
        UITableViewCell.appearance().backgroundColor = UIColor(Color("csf-menu-gray"))
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    HStack {
                        Spacer()
                        Spacer()
                        
                        ZStack {
                            FrequentlyUpdatedView(counter: $userIndex)
                                .onChange(of: userIndex) {
                                    if userIndex != nil {
                                        self.email = firestore.allUsers[firestore.activeUserIds[userIndex!]].email
                                        print($0 ?? "")
                                    } else {
                                        self.email = ""
                                    }
                                }
                             
                            Menu {
                                Picker("User", selection: Binding($userIndex, deselectTo: nil)) {
                                    ForEach(firestore.activeUserIds.indices, id: \.self) { (index: Int) in
                                        Text("\(firestore.allUsers[firestore.activeUserIds[index]].email)")
                                            .tag(firestore.activeUserIds[index] as Int?)
                                    }
                                }
                            } label: {
                                if userIndex == nil {
                                    HStack {
                                        Text("select client").bold()
                                            .font(Font.custom("BebasNeue", size: 20))
                                            .foregroundColor(Color("B1-red"))
                                            .offset(y: 2)
                                        
                                        Image(systemName: "arrowtriangle.down.square")
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(Color.accentColor, Color.black)
                                            .font(.title)
                                    }
                                } else {
                                    Text("\(firestore.allUsers[firestore.activeUserIds[userIndex!]].email)")
                                }
                            }
                        }
                    }
                    
                    DatePicker("Timeslot", selection: $timeslot)
                        .font(Font.custom("BebasNeue", size: 20))
                        .foregroundColor(timeslot < dateNow ? Color("B1-red") : Color("csf-main"))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Invoice amount")
                            .font(Font.custom("BebasNeue", size: 20))
                            .padding(.top, 6)
                        
                        Picker("Invoice", selection: $invoice) {
                            ForEach(Appointment.StripeLink.allCases) { link in
                                Text(link.rawValue)
                                    .tag(link)
                                    .font(Font.custom("BebasNeue", size: 20))
                            }
                        }
                        .padding(5)
                        .pickerStyle(.segmented)
                    }

                    Section {
                        Button(action: addNewAppt) {
                            Text("Add New Appointment")
                        }
                        .disabled((email == "") && (timeslot <= dateNow))
                    }
                }
                .navigationBarTitle(Text(""), displayMode: .inline)
                .offset(y: -6)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Text("New Appointment")
                            .font(Font.custom("BebasNeue", size: 30))
                    }
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                dismiss()
                            }
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .foregroundColor(Color("csf-spin"))
                    }
                }
            }
        }
        .frame(width: UIScreen.width,
               height: UIScreen.height/3)
        .environment(\.layoutDirection, .rightToLeft)
        .flipsForRightToLeftLayoutDirection(true)
        .background(
            LinearGradient(
                colors: [
                    Color("base-light").opacity(0.5),
                    Color("csb-main")
                ],
                startPoint: .top, endPoint: .bottom)
        )
        .ignoresSafeArea()
    }
}

struct FrequentlyUpdatedView: View {
    @Binding fileprivate var counter: Int?
    
    var body: some View {
        if counter != nil {
            Text("\(counter ?? -1)")
                .opacity(0)
        } else {
            EmptyView()
        }
    }
}
