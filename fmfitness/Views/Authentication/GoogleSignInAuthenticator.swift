//
//  GoogleSignInAuthenticator.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/26/22.
//

import Foundation
import GoogleSignIn
import SwiftUI
import Firebase

/// An observable class for authenticating via Google.
final class GoogleSignInAuthenticator: ObservableObject {
    @Environment(\.controller) var controller
    
    @ObservedObject var authViewModel = AuthenticationViewModel.shared
    @ObservedObject var firestore = FirestoreManager.shared
    
    private let clientID = "724139873464-o0urc022edt67e6d96ps6tljhatvm9aq.apps.googleusercontent.com"
    // private let clientID = FirebaseApp.app()?.options.clientID
    
    private lazy var config: GIDConfiguration = {
        return GIDConfiguration(clientID: clientID)
    }()
    
    private lazy var user: GIDGoogleUser? = {
        return GIDSignIn.sharedInstance.currentUser
    }()
    
    /// Signs in the user based upon the selected account.'
    /// - note: Successful calls to this will set the `authViewModel`'s `state` property.
    func signIn() {
        
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                self.authenticateUser(for: user, with: error)
            }
        } else {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            else { return }
            
            guard
                let rootViewController = windowScene.windows.first?.rootViewController
            else { return }
            
            /*guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                print("There is no root view controller!")
                return
            }*/
            
            GIDSignIn.sharedInstance.signIn(with: config,
                                            presenting: rootViewController) { (user, error) in
                self.authenticateUser(for: user, with: error)
                
                
                /*
                // Authenticate with Firebase using the credential object
                Auth.auth().signIn(with: credential) { (res, error) in
                    if let error = error {
                        print("authentication error \(error.localizedDescription)")
                        return
                    }
                    // let currentUser = Auth.auth().currentUser!
                    
                    // User is signed in
                    self.authViewModel.state = .signedIn(user)
                    self.firestore.firstLogin = true
                    // self?.controller.login(uid: currentUser.uid, email: currentUser.email!)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.controller.login(uid: res!.user.uid, email: user.profile!.email)
                    }
                }
                */
            }
        }
    }

    /// Signs out the current user.
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.authViewModel.state = .signedOut
        self.controller.next(newPage: Dashboard.startPage)
    }

    /// Adds the firestore read scope for the current user.
    /// - parameter completion: An escaping closure that is called upon successful completion of the
    /// `addScopes(_:presenting:)` request.
    /// - note: Successful requests will update the `authViewModel.state` with a new current  user that
    /// has the granted scope.
    func addProfileReadScope(completion: @escaping () -> Void) {
        
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { return }
        
        guard
            let rootViewController = windowScene.windows.first?.rootViewController
        else { return }
        
        GIDSignIn.sharedInstance.addScopes([FirestoreLoader.dataReadScope],
                                           presenting: rootViewController) { user, error in
            if let error = error {
                print("Found error while adding /Users/briantacderan/Projects/fm-fitness/ios/fm-fitness/Views/Authentication/GoogleSignInAuthenticator.swift profile read scope: \(error).")
                return
            }

            guard let user = user else { return }
            self.authViewModel.state = .signedIn(user)
            completion()
        }
    }

    /// Disconnects the previously granted scope and signs the user out.
    func disconnect() {
        GIDSignIn.sharedInstance.disconnect { error in
            if let error = error {
                print("Encountered error disconnecting scope: \(error).")
            }
            self.signOut()
        }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user?.authentication,
              let idToken = authentication.idToken
        else { return }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: authentication.accessToken)

        Auth.auth().signIn(with: credential) { (res, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
                
            switch res {
            case .none:
                print("Could not sign in user.")
                return
            case .some(_):
                print("User signed in")
                
                guard
                    let user = self.user
                else { return }
                
                self.authViewModel.state = .signedIn(user)
                self.firestore.firstLogin = true
                withAnimation {
                    self.controller.login(uid: res!.user.uid, email: user.profile!.email)
                }
                    
                /*if let userId = Auth.auth().currentUser?.uid {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.controller.login(uid: userId, email: user.profile!.email)
                    }
                }*/
            }
        }
    }
}
