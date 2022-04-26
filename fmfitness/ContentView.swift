//
//  ContentView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/19/22
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    var body: some View {
        switch firestore.currentPage {
        case .welcomePage:
            withAnimation {
                WelcomeView()
            }
        case .homePage:
            withAnimation {
                HomeBase(selection: .home)
            }
        case .loginPage:
            withAnimation {
                SignInView() 
            }
        case .registerPage:
            withAnimation {
                SignUpView()
            }
        case .rsvpPage:
            withAnimation {
                HomeBase(selection: .schedule)
            }
        case .adminPage:
            withAnimation {
                HomeBase(selection: .admin)
            }
        case .billingsPage:
            withAnimation {
                HomeBase(selection: .billings)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FirestoreManager.shared)
    }
}
