//
//  ContentView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/19/22
//

import SwiftUI

struct ContentView: View {
    
    static var shared = ContentView()
    @Environment(\.controller) var controller
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    var body: some View {
        switch firestore.currentPage {
        case .startPage:
            switch firestore.authRedirect {
            case .welcomePage:
                withAnimation(.easeInOut(duration: 0.2)) {
                    WelcomeView()
                        .frame(width: UIScreen.width,
                               height: UIScreen.height)
                }
            case .loginPage:
                withAnimation(.easeInOut(duration: 0.2)) {
                    SignInView()
                        .frame(width: UIScreen.width,
                               height: UIScreen.height)
                }
            case .registerPage:
                withAnimation(.easeInOut(duration: 0.2)) {
                    SignUpPage()
                }
            }
        case .homePage:
            withAnimation(.easeInOut(duration: 0.2)) {
                DashboardView()
                    .frame(width: UIScreen.width,
                           height: UIScreen.height)
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
