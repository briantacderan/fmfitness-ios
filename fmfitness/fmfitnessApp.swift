//
//  fmfitnessApp.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI
import GoogleSignIn
import Firebase

@main
struct fmfitnessApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var controller = PageController.shared
    @StateObject var authViewModel = AuthenticationViewModel.shared
    @StateObject var firestore = FirestoreManager.shared
    @StateObject var scheduler = SchedulerModel.shared
    
    let csf = Color("LaunchScreenColorTile")
    let csb = Color("LaunchScreenColor")

    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView.shared
                    .environmentObject(controller)
                    .environmentObject(authViewModel)
                    .environmentObject(firestore)
                    .environmentObject(scheduler)
                    .frame(width: UIScreen.width,
                           height: UIScreen.height)
                    .onAppear {
                        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                            if let user = user,
                               let currentUser = Auth.auth().currentUser?.uid {
                                self.authViewModel.state = .signedIn(user)
                                self.controller.login(uid: currentUser,
                                                      email: user.profile!.email)
                            } else {
                                if let error = error {
                                    print("There was an error restoring the previous sign-in: \(error)")
                                }
                            }
                        }
                    }
                
                if ((firestore.firstLogin && (firestore.currentPage == Dashboard.homePage)) || !(firestore.isFresh)) {
                    EmptyView()
                        .opacity(0)
                    
                } else if !firestore.firstLogin && (firestore.currentPage == Dashboard.homePage) {
                    ZStack {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            csb
                                .edgesIgnoringSafeArea(.all)
                                .opacity(AuthenticationView.lastHide ? 0 : 1)
                                .transition(.opacity)
                        }
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            AuthenticationView()
                                .opacity(!SplashScreen.shouldAnimate ? 0 : 1)
                                .transition(.opacity)
                        }
                    }
                    .frame(width: UIScreen.width, height: UIScreen.height)
                    .animation(.default, value: SplashScreen.shouldAnimate)
                    
                } else if (firestore.currentPage == Dashboard.startPage) && (firestore.authRedirect == Page.loginPage) {
                    SplashView()
                    
                } else {
                    EmptyView()
                        .opacity(0)
                }
            }
        }
    }
}

