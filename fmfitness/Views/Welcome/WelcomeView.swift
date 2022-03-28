//
//  WelcomeView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 3/14/22.
//

// import SwiftUI

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            WelcomePage()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    MenuButton()
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    LogoButton()
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .preferredColorScheme(.dark)
    }
}

struct MenuButton: View {
    @ObservedObject var firestore = FirestoreManager.shared
    
    var body: some View {
        Button {
            firestore.menuShow.toggle()
        } label: {
            Image("menu-white")
                .renderingMode(.template)
                .resizable()
                .frame(width: 26, height: 20)
                .padding(.bottom, 12)
                .padding(.leading, 5)
        }
        .sheet(isPresented: $firestore.menuShow) {
            MenuView()
                // .preferredColorScheme(.dark)
        }
    }
}

struct LogoButton: View {
    @ObservedObject var firestore = FirestoreManager.shared
    
    var body: some View {
        if firestore.profile._username != "new_profile" {
            Button {
                withAnimation {
                    firestore.next(newPage: .homePage)
                }
            } label: {
                Image("fmf-logo-white")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 125, height: 25)
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
            }
        } else {
            Button {
                withAnimation {
                    firestore.next(newPage: .welcomePage)
                }
            } label: {
                Image("fmf-logo-white")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 125, height: 25)
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
            }
        }
    }
}
