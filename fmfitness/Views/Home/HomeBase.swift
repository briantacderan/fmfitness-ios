//
//  HomeBase.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI
import Firebase
import GoogleSignIn

extension AnyTransition {
    static var bottomScale: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        )
    }
}

struct HomeBase: View {

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
                  
            withAnimation {
                StripeView()
                    .tabItem {
                        Label("", systemImage: "dollarsign.circle.fill")
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .offset(y: -15)
                    .tag(Tab.billings)
            }

            withAnimation {
                HomeView()
                    .tabItem {
                        Label("", systemImage: "house")
                    }
                    .font(.system(size: 50))
                    .transition(.bottomScale)
                    .offset(y: -15)
                    .tag(Tab.home)
            }
            
            withAnimation {
                SchedulerView()
                    .tabItem {
                        Label("", systemImage: "calendar.badge.clock")
                    }
                    .offset(y: -15)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .tag(Tab.schedule)
            }
            
            if firestore.profile.isAdmin {
                withAnimation {
                    AdminNavigation()
                        .tabItem {
                            Label("", systemImage: "key")
                        }
                        .transition(.bottomScale)
                        .offset(y: -15)
                        .tag(Tab.admin)
                }
            }
        }
        .frame(height: UIScreen.main.bounds.height + 15)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct HomeBase_Previews: PreviewProvider {
    static var previews: some View {
        HomeBase()
            .preferredColorScheme(.dark)
    }
}
