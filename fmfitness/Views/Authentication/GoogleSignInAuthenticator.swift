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

    @ObservedObject var firestore = FirestoreManager.shared
    @ObservedObject var authViewModel = AuthenticationViewModel.shared
    
    private let clientID = "946966093400-qmmq36blar2a2v0vj1073tg0do52db11.apps.googleusercontent.com"
    // private let clientID = FirebaseApp.app()?.options.clientID
    
    private lazy var config: GIDConfiguration = {
        return GIDConfiguration(clientID: clientID)
    }()
    
    /// Signs in the user based upon the selected account.'
    /// - note: Successful calls to this will set the `authViewModel`'s `state` property.
    func signIn() {
        
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            print("There is no root view controller!")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(with: config,
                                        presenting: rootViewController) { user, error in

            guard error == nil else { return }
            guard let user = user else { return }
            
            let authentication = user.authentication
            let idToken = authentication.idToken!

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)

            // Authenticate with Firebase using the credential object
            Auth.auth().signIn(with: credential) { (res, error) in
                if let error = error {
                    print("authentication error \(error.localizedDescription)")
                    return
                }
                
                // User is signed in
                self.authViewModel.state = .signedIn(user)
                self.firestore.login(email: user.profile!.email)
            }
        }
    }

    /// Signs out the current user.
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.authViewModel.state = .signedOut
        self.firestore.next(newPage: .loginPage)
    }

    /// Adds the firestore read scope for the current user.
    /// - parameter completion: An escaping closure that is called upon successful completion of the
    /// `addScopes(_:presenting:)` request.
    /// - note: Successful requests will update the `authViewModel.state` with a new current  user that
    /// has the granted scope.
    func addProfileReadScope(completion: @escaping () -> Void) {
        
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            fatalError("No root view controller!")
        }
        
        GIDSignIn.sharedInstance.addScopes([FirestoreLoader.dataReadScope],
                                           presenting: rootViewController) { user, error in
            if let error = error {
                print("Found error while adding/Users/briantacderan/Projects/fmfitness/ios/fmfitness/Views/Authentication/GoogleSignInAuthenticator.swift pro/Users/briantacderan/Projects/fmfitness/ios/fmfitness/Views/Authentication/GoogleSignInAuthenticator.swiftfile read scope: \(error).")
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
}
