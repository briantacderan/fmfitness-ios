//
//  fmfitnessApp.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI
import GoogleSignIn

@main
struct fmfitnessApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var firestore = FirestoreManager.shared
    @StateObject var authViewModel = AuthenticationViewModel.shared
    @StateObject var scheduler = SchedulerModel.shared
    @StateObject var cloud = CloudManager.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .blur(radius: firestore.blurSecure)
                    .environmentObject(authViewModel)
                    .environmentObject(firestore)
                    .environmentObject(scheduler)
                    .environmentObject(cloud)
                    .onAppear {
                        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                            if let user = user {
                                self.authViewModel.state = .signedIn(user)
                                self.firestore.login(email: user.profile!.email)
                            } else {
                                if let error = error {
                                    print("There was an error restoring the previous sign-in: \(error)")
                                }
                                self.firestore.next(newPage: .welcomePage)
                            }
                        }
                    }
                SplashView()
            }
        }
    }
}

