//
//  AppDelegate.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/26/22.
//

import Foundation
import SwiftUI
import UIKit
import Firebase
import GoogleSignIn
import Stripe

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let tabBar = UITabBar.appearance()
    let tab = UITabBarAppearance()
    let navBar = UINavigationBar.appearance()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        configureApplicationAppearance()
        if case StripeAPI.defaultPublishableKey = ProcessInfo.processInfo.environment["STRIPE_PUBLISHABLE_KEY"] {
            FirebaseApp.configure()
            return true
        }
        FirebaseApp.configure()
        return true
    }

    
    /// This method handles opening custom URL schemes (for example, "your-app://")
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        
        var handled: Bool
        handled = GIDSignIn.sharedInstance.handle(url)
        if (handled) {
            return true
        }

        var stripeHandled: Bool
        stripeHandled = StripeAPI.handleURLCallback(with: url)
        if (stripeHandled) {
            return true
        }

        /// If not handled by this app, return false.
        return false
    }

    // MARK: - Application Appearance

    private func configureApplicationAppearance() {
        tab.configureWithOpaqueBackground()
        // tab.backgroundColor = UIColor(Color("csb-main"))
        tab.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
        tab.stackedLayoutAppearance.selected.iconColor = UIColor(Color("csf-accent"))
        
        tabBar.scrollEdgeAppearance = tab
        tabBar.standardAppearance = tab
        tabBar.clipsToBounds = true
        
        navBar.tintColor = .systemOrange
        
        // NavigationBarTitle
        navBar.largeTitleTextAttributes = [
            .font : UIFont(name: "BebasNeue", size: 40)!,
            .foregroundColor : UIColor(Color("csf-main"))
        ]
        
        // displayMode = .inline
        navBar.titleTextAttributes = [
            .font : UIFont(name: "BebasNeue", size: 30)!,
            .foregroundColor : UIColor(Color("csf-main"))
        ]
        
        // Allow NavigationView to set background color
        UITableView.appearance().backgroundColor = UIColor(Color("csb-main"))
    }
}
