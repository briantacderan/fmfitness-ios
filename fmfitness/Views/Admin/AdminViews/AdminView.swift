//
//  AdminView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/14/22.
//

import SwiftUI

struct AdminView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var firestore = FirestoreManager.shared
    
    @State private var isShowingAddApptView = false
    @State private var editMode: EditMode = .inactive
    @State private var focusId: Int?

    func addAppt() {
        isShowingAddApptView = true
    }
    
    @State private var sort: Int = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                AdminNavigation()
                .navigationBarTitle("Administration")
                .foregroundColor(Color("csf-main"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        MenuButton()
                            .foregroundColor(Color("csf-main-gray"))
                    }
                    
                    ToolbarItemGroup(placement: .primaryAction) {
                        Menu {
                            Picker(selection: $sort, label: Text("Sorting options")) {
                                Text("Add session").tag(0)
                                Text("Cancel session").tag(1)
                                Text("Edit session").tag(2)
                            }
                        }
                        label: {
                            Label("Sort", systemImage: "plus.rectangle.fill.on.rectangle.fill")
                        }
                        
                        Menu {
                            Button(action: {}) {
                                Label("Create a file", systemImage: "doc")
                            }

                            Button(action: {}) {
                                Label("Create a folder", systemImage: "folder")
                            }
                        }
                        label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width,
                       height: UIScreen.main.bounds.height)
                .background(Color("csb-main"))
                .ignoresSafeArea()
            }
        }
    }
}

struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
            //.preferredColorScheme(.dark)
    }
}
