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
            /* Process the URL
            guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
                  let stripePath = components.path,
                  let params = components.queryItems else {
                      print("Invalid URL or album path missing")
                      return false
            }
                
                
            }
            
            let message = url.host?.removingPercentEncoding
            if message == "Back to FM Fitness" {
                let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
            } else {
                
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(okAction)
            
            let rootViewController = UIApplication.shared.windows.first?.rootViewController
            rootViewController!.present(alertController, animated: true, completion: nil)*/
            
            return true
        }

        /// If not handled by this app, return false.
        return false
    }
    
    /// This method handles opening universal link URLs (for example, "https://example.com/stripe_ios_callback")
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool  {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                let stripeHandled = StripeAPI.handleURLCallback(with: url)
                if (stripeHandled) {
                    return true
                } else {
                    // This was not a Stripe url – handle the URL normally as you would
                }
            }
        }
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
        navBar.barTintColor = UIColor(Color("csb-main"))
        
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
