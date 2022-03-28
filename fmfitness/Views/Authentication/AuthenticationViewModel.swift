//
//  AuthenticationViewModel.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/26/22.
//

import SwiftUI
import Combine
import GoogleSignIn

/// A class conforming to `ObservableObject` used to represent a user's authentication status.
final class AuthenticationViewModel: ObservableObject {
    
    static var shared = AuthenticationViewModel()
    
    /// The user's log in status.
    /// - note: This will publish updates when its value changes.
    @Published var state: State
    
    private var authenticator: GoogleSignInAuthenticator {
        return GoogleSignInAuthenticator()
    }
    /// The user-authorized scopes.
    /// - note: If the user is logged out, then this will default to empty.
    var authorizedScopes: [String] {
        switch state {
        case .signedIn(let user):
            return user.grantedScopes ?? []
        case .signedOut:
            return []
        }
    }

    var hasProfileReadScope: Bool {
        return authorizedScopes.contains(FirestoreLoader.dataReadScope)
    }

    /// Creates an instance of this view model.
    init() {
        if let user = GIDSignIn.sharedInstance.currentUser {
            self.state = .signedIn(user)
        } else {
            self.state = .signedOut
        }
    }
    
    /// Signs the user in.
    func signIn() {
        authenticator.signIn()
    }

    /// Signs the user out.
    func signOut() {
        authenticator.signOut()
        authenticator.disconnect()
    }

    /// Adds the requested birthday read scope.
    /// - parameter completion: An escaping closure that is called upon successful completion.
    func addProfileReadScope(completion: @escaping () -> Void) {
        authenticator.addProfileReadScope(completion: completion)
    }

    /// Disconnects the previously granted scope and logs the user out.
    func disconnect() {
        authenticator.disconnect()
    }
}

extension AuthenticationViewModel {
    /// An enumeration representing logged in status.
    enum State {
        /// The user is logged in and is the associated value of this case.
        case signedIn(GIDGoogleUser)
        /// The user is logged out.
        case signedOut
    }
}
