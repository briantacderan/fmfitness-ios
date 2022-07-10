//
//  MenuView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 3/19/22.
//

import SwiftUI
import Firebase
import GoogleSignIn


struct MenuView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.controller) var controller
    
    @ObservedObject var authViewModel = AuthenticationViewModel.shared
    @ObservedObject var firestore = FirestoreManager.shared
    
    private var user: GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    LogoView(logoWidth: 100, logoHeight: 20, vertPadding: 50)
                    
                    VStack(alignment: .center, spacing: 50) {

                        if user != nil || firestore.profile._username != "new_profile" {
                            VStack(alignment: .trailing, spacing: 3) {
                                Text("\(firestore.profile._username!)")
                                    .font(Font.custom("Rajdhani-Medium", size: 15))
                                    .foregroundColor(Color("csb-choice"))
                                    .fontWeight(.bold)
                                
                                Button {
                                    withAnimation {
                                        signOut()
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "pip.exit")
                                            .font(.system(size: 10))
                                        Spacer()
                                        Text("Log Out")
                                    }
                                }
                            }
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if firestore.currentPage == .startPage {
                                        // biometric.authRedirect = .welcomePage
                                        controller.next(newPage: .homePage)
                                    } else {
                                        firestore.selection = .home
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "list.dash.header.rectangle")
                                        .font(.system(size: 10))
                                    Spacer()
                                    Text("Home")
                                }
                            }
                        } else {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    firestore.authRedirect = .loginPage
                                    firestore.showSidebar = false
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "pip.enter")
                                        .font(.system(size: 10))
                                    Spacer()
                                    Text("Log In")
                                }
                            }
                        }
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                firestore.authRedirect = .welcomePage
                                if firestore.currentPage != .startPage {
                                    controller.next(newPage: .startPage)
                                }
                                firestore.showSidebar = false
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chart.xyaxis.line")
                                    .font(.system(size: 10))
                                Spacer()
                                Text("About")
                            }
                        }
                    }
                }
                .padding()
                .font(Font.custom("BebasNeue", size: 25))
                .frame(width: 125, alignment: .trailing)
            }
            
            Spacer()
            HStack {
                Spacer()
                
                HStack(spacing: 0) {
                    Text("©")
                    Text("FM")
                        .font(Font.custom("BebasNeue", size: 12))
                    Text("FITNESS")
                        .font(Font.custom("Rajdhani-Light", size: 12))
                }
                .padding(10)
            }
        }
        .foregroundColor(Color("csb-main"))
        .background(colorScheme == .dark ? Color("csb-menu-gray") : Color("DA1-blue"))
    }
    
    func signOut() {
        authViewModel.disconnect()
        authViewModel.signOut()
        signOutUser()
    }
    
    func signOutUser() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        withAnimation {
            firestore.authRedirect = .loginPage
            if firestore.currentPage != .startPage {
                controller.next(newPage: .startPage)
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
            .preferredColorScheme(.dark)
    }
}
