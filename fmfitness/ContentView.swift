//
//  ContentView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/19/22
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var firestore = FirestoreManager.shared
    @ObservedObject var authViewModel = AuthenticationViewModel.shared
    
    var body: some View {
        switch firestore.currentPage {
        case .welcomePage:
            WelcomeView()
        case .homePage:
            HomeView(selection: .home)
        case .loginPage:
            SignInView()
        case .registerPage:
            SignUpView()
        case .rsvpPage:
            HomeView(selection: .schedule)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel.shared)
            .environmentObject(FirestoreManager.shared)
    }
}
