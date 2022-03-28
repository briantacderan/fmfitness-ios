//
//  HomeView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct HomeView: View {

    @ObservedObject var firestore = FirestoreManager.shared
    @State var selection: Tab = .home
    
    enum Tab {
        case home
        case schedule
        case billings
        case admin
    }

    var body: some View {
        TabView(selection: $selection) {
                    
            CategoryHome()
                .tabItem {
                    Label("", systemImage: "house")
                }
                .offset(y: -15)
                .tag(Tab.home)

            SchedulerView()
                .tabItem {
                    Label("", systemImage: "calendar.badge.clock")
                }
                .offset(y: -15)
                .tag(Tab.schedule)
            
            SchedulerView()
                .tabItem {
                    Label("", systemImage: "dollarsign.circle.fill")
                }
                .offset(y: -15)
                .tag(Tab.billings)
            
            if firestore.profile.isAdmin {
                SchedulerView()
                    .tabItem {
                        Label("", systemImage: "key")
                    }
                    .offset(y: -15)
                    .tag(Tab.admin)
            }
        }
        .frame(height: UIScreen.main.bounds.height + 15)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
    }
}
