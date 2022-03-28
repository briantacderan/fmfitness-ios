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
    
    @ObservedObject var firestore = FirestoreManager.shared
    @ObservedObject var authViewModel = AuthenticationViewModel.shared
    
    private var user: GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Capsule()
                    .fill(Color("csf-accent"))
                    .frame(width: 75, height: 5)
                    .padding(10)
                
                Image("fmf-logo-white")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color("csf-accent"))
                    .frame(width: UIScreen.main.bounds.width*2/3, height: 50)
                    .padding(.top, 30)
                
                VStack(alignment: .trailing, spacing: 30) {

                    if user != nil || firestore.profile._username != "new_profile" {
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("\(firestore.profile._username!)")
                                .font(Font.custom("rajdhani", size: 15))
                                .fontWeight(.semibold)
                            
                            Button {
                                withAnimation {
                                    firestore.profile._username = "new_profile"
                                    firestore.menuShow.toggle()
                                    signOut()
                                }
                            } label: {
                                Text("Log Out")
                            }
                        }
                        
                        Button {
                            withAnimation {
                                firestore.menuShow.toggle()
                                firestore.next(newPage: .homePage)
                            }
                        } label: {
                            Text("Home")
                        }
                    } else {
                        Button {
                            withAnimation {
                                firestore.next(newPage: .loginPage)
                                firestore.menuShow.toggle()
                            }
                        } label: {
                            Text("Log In")
                        }
                    }
                    
                    Button {
                        withAnimation {
                            firestore.next(newPage: .welcomePage)
                            firestore.menuShow.toggle()
                        }
                    } label: {
                        Text("About")
                    }
                }
                .padding(30)
                .font(Font.custom("BebasNeue", size: 50))
            .frame(width: UIScreen.main.bounds.width, alignment: .trailing)
            }
        }
        .foregroundColor(Color("csf-main"))
        .background(Color("csb-main"))
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
            firestore.next(newPage: .loginPage)
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
            .preferredColorScheme(.dark)
    }
}
