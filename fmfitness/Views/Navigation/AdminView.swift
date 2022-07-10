//
//  AdminView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

struct AdminView: View {
    @Environment(\.controller) var controller
    @Environment(\.isPresented) var isPresented
    //@Environment(\.editMode) var editMode
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    @State private var editMode: EditMode = .inactive
    @State private var isShowingAddApptView = false
    @State private var focusId: Int?
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    
    func addAppt() {
        isShowingAddApptView = true
    }
    
    private func confirmChanges() {
        let edits = firestore.apptChanges
        
        if (edits != []) {
            for edit in edits {
                let appt = edit
                
                controller.setTraining(parameters: ["email": appt.email, "invoice": appt.invoice, "confirm": appt.isConfirmed, "complete": appt.isCompleted, "paid": appt.isPaid, "cancel": appt.isCanceled, "reason": appt.cancelReason, "timeslot": appt.nextAppointment, "mode": "edit"])
            }
        }
        
        DispatchQueue.main.async {
            firestore.apptChanges = []
            firestore.sort = 3
            editMode = .inactive
            //controller.fetchTrainings()
        }
    }
    
    var body: some View {
        SideBarStack(sidebarWidth: 125, showSidebar: $firestore.showSidebar) {
            MenuView()
        } content: {
            NavigationView {
                VStack {
                    ZStack(alignment: .bottom) {
                        FocusApptView(focusId: focusId)
                            .cornerRadius(15)
                            .padding()
                            .frame(height: UIScreen.height*1/4)
                            .onDrop(
                              of: [TodoItem.typeIdentifier],
                              delegate: ApptDropDelegate(focusId: $focusId))
                        
                    }
                    .frame(height: UIScreen.height/4)
                        
                    ZStack(alignment: .top) {
                        Color("csb-main")
                            .frame(height: UIScreen.height*6/7)
                        
                        VStack {
                            List {
                                if (firestore.sort != 1) {
                                    ActiveApptView()
                                        .background(Color("csb-main"))
                                        .onDrop(of: [TodoItem.typeIdentifier], isTargeted: nil) { apptProviders in
                                            for apptProvider in apptProviders {
                                                apptProvider.loadObject(ofClass: TodoItem.self) { todoItem, _ in
                                                    guard
                                                        let todoItem = todoItem as? TodoItem
                                                    else { return }
                                                    DispatchQueue.main.async {
                                                        controller.updateAppt(withId: todoItem.id, isConfirmed: false, isCompleted: false, isPaid: todoItem.isPaid, isCanceled: todoItem.isCanceled)
                                                    }
                                                }
                                            }
                                            return true
                                        }
                                }
                                
                                ConfirmedApptView()
                                    .background(Color("csb-main"))
                                    .onDrop(of: [TodoItem.typeIdentifier], isTargeted: nil) { apptProviders in
                                        for apptProvider in apptProviders {
                                            apptProvider.loadObject(ofClass: TodoItem.self) { todoItem, _ in
                                                guard
                                                    let todoItem = todoItem as? TodoItem
                                                else { return }
                                                DispatchQueue.main.async {
                                                    controller.updateAppt(withId: todoItem.id, isConfirmed: true, isCompleted: false, isPaid: todoItem.isPaid, isCanceled: todoItem.isCanceled)
                                                }
                                            }
                                        }
                                        return true
                                    }
                                
                                
                                if (firestore.sort > 0) {
                                    CompletedApptView()
                                        .background(Color("csb-main"))
                                        .onDrop(of: [TodoItem.typeIdentifier], isTargeted: nil) { apptProviders in
                                            for apptProvider in apptProviders {
                                                apptProvider.loadObject(ofClass: TodoItem.self) { todoItem, _ in
                                                    guard
                                                        let todoItem = todoItem as? TodoItem
                                                    else { return }
                                                    DispatchQueue.main.async {
                                                        controller.updateAppt(withId: todoItem.id, isConfirmed: true, isCompleted: true, isPaid: todoItem.isPaid, isCanceled: todoItem.isCanceled)
                                                    }
                                                }
                                            }
                                            return true
                                        }
                                }
                            }
                            .environment(\.defaultMinListRowHeight, 20)
                            .background(Color("csb-main"))
                            .listStyle(.grouped)
                            .refreshable {
                                controller.fetchTrainings()
                            }
                        }
                        .frame(height: UIScreen.main.bounds.height*3/4)
                        .background(Color("csb-main"))
                        
                        Color("csf-main")
                            .blur(radius: 3)
                            .frame(width: UIScreen.width*1.025, height: 6)
                            .offset(y: -6)
                        
                        Color("DA1-blue")
                            .frame(width: UIScreen.width, height: 6)
                    }
                    .frame(height: UIScreen.height*3/4)
                    .background(Color("csb-main"))
                }
                .foregroundColor(Color("csf-main"))
                .frame(width: UIScreen.width,
                       height: UIScreen.height)
                .scaledToFit()
                .background(
                    ZStack {
                        Color.gray
                        Image("LaunchBlackTile")
                                .renderingMode(.template)
                                .foregroundColor(Color("csf-main"))
                                .opacity(1)
                                .ignoresSafeArea()
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        MenuButton()
                            .foregroundColor(Color("csf-main"))
                            .tint(Color("csf-main"))
                            .padding(2)
                            .background(Color.gray.cornerRadius(10))
                            /*.offset(x: -2, y: 5)
                            .padding(0)
                            .padding(.horizontal, 8)
                            .background(Color.gray.cornerRadius(10))*/
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    firestore.showSidebar.toggle()
                                }
                            }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Administration")
                            .padding(.horizontal, 4)
                            .padding(.vertical, -1)
                            .background(Color.gray.cornerRadius(10))
                            .foregroundColor(Color("csf-main"))
                            .font(Font.custom("BebasNeue", size: 28))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    
                    ToolbarItemGroup(placement: .primaryAction) {
                        if (firestore.sort != 3) {
                            Button {
                                firestore.apptChanges = []
                                firestore.sort = 3
                                editMode = .inactive
                                controller.fetchTrainings()
                            } label: {
                                Label("Cancel", systemImage: "xmark.rectangle")
                                    .foregroundStyle(Color("B1-red"), Color("csf-main-str"))
                                    .padding(2)
                                    .background(Color.gray.cornerRadius(10))
                            }
                        } else {
                            Menu {
                                Picker(selection: $firestore.sort, label: Text("Sorting options")) {
                                    Text("CONFIRM requests").tag(0)
                                    Text("Mark item as COMPLETED").tag(1)
                                    Text("Mark item as PAID").tag(2)
                                }
                                //.font(Font.custom("BebasNeue", size: 18))
                                .onChange(of: firestore.sort) { value in
                                    if value == 3 {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            editMode = .inactive
                                        }
                                    } else {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            editMode = .active
                                        }
                                    }
                                }
                                
                                Button {
                                    addAppt()
                                } label: {
                                    Label("Add new appointment", systemImage: "plus.rectangle")
                                }
                                
                            } label: {
                                Label("Sort", systemImage: "plus.rectangle")
                                    .foregroundColor(Color("csb-main-str"))
                                    .opacity((editMode == .active) ? 0.2 : 1)
                                    .padding(2)
                                    .background(Color.gray.cornerRadius(10))
                                    .padding(.trailing, 2)
                            }
                            .disabled(editMode == .active)
                            .foregroundColor(Color("csb-main-str"))
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if (firestore.sort != 3) {
                            Button {
                                self.confirmChanges()
                            } label: {
                                Text("CONFIRM")
                                    .font(Font.custom("Rajdhani-SemiBold", size: 12))
                                    .foregroundColor(Color("A2-teal"))
                                    .padding(2)
                                    .background(Color.gray.cornerRadius(10))
                                    .overlay(
                                        Text("CONFIRM")
                                            .font(Font.custom("Rajdhani-SemiBold", size: 12))
                                            .foregroundColor(Color.black)
                                            .offset(x: 1, y: 1))
                            }
                        }
                    }
                }
                .overlay(
                    ZStack {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            ShadeView()
                        }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            Color("csb-main-str")
                                .frame(width: UIScreen.width,
                                       height: UIScreen.height)
                                .opacity(isShowingAddApptView ? 0.6 : 0)
                                .ignoresSafeArea()
                        }
                    }
                    .transition(.opacity)
                )
                .sheet(isPresented: $isShowingAddApptView) {
                    AddApptView()
                        .cornerRadius(10)
                        .offset(y: UIScreen.height/3 - 15)
                        .ignoresSafeArea()
                        .background(BackgroundClearView())
                }
                
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AdminView()
                .environmentObject(FirestoreManager.shared)
        }
                //.preferredColorScheme(.dark)
    }
}
