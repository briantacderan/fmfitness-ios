//
//  DashboardView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct DashboardView: View {
    @ObservedObject var scheduler = SchedulerModel.shared
    @ObservedObject var firestore = FirestoreManager.shared

    var body: some View {
        TabView(selection: $firestore.selection) {
            
            withAnimation(.easeInOut(duration: 0.2)) {
                HomeView()
                    .tabItem {
                        Label("", systemImage: firestore.selection == .home ? "house.fill" : "house")
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    firestore.showSidebar = false
                                }
                            }
                            .environment(\.symbolVariants, .none)
                    }
                    .transition(.opacity)
                    .offset(y: -6)
                    .tag(Tab.home)
            }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                SchedulerView()
                    .tabItem {
                        Label("", systemImage: firestore.selection == .schedule ? "clock.circle.fill" : "clock.circle")
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    firestore.showSidebar = false
                                }
                            }
                            .environment(\.symbolVariants, .none)
                    }
                    .transition(.opacity)
                    .offset(y: -6)
                    .tag(Tab.schedule)
            }
            
            if firestore.profile.isAdmin {
                withAnimation(.easeInOut(duration: 0.2)) {
                    AdminView()
                        .tabItem {
                            Label("", systemImage: firestore.selection == .admin ? "key.fill" : "key")
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        firestore.showSidebar = false
                                    }
                                }
                                .environment(\.symbolVariants, .none)
                        }
                        .transition(.opacity)
                        .offset(y: -6)
                        .tag(Tab.admin)
                }
            }
        }
        .frame(height: UIScreen.height + 6)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            //.preferredColorScheme(.dark)
    }
}
