//
//  WelcomeView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 3/14/22.
//

import SwiftUI

struct WelcomeView: View {
    
    @ObservedObject var firestore = FirestoreManager.shared
    @ObservedObject var cloud = CloudManager.shared
    
    @State private var showSafari = false
    @State private var urlString = ""
    
    init() {
        showSafari = false
        if firestore.profile._username != "new_profile" && firestore.profile.stripeID != "new" && !firestore.profile.stripeConnected {
            cloud.createStripeAccountLink(params: ["accountID": firestore.profile.stripeID, "type": "account_onboarding"]) { [self] url, error in
                guard error == nil else {
                    firestore.currentPage = .loginPage
                    return
                }
                
                switch url {
                case .none:
                    print("Could not create Stripe Connect account")
                    withAnimation {
                        firestore.next(newPage: .loginPage)
                    }
                case .some(_):
                    print("Stripe Connect account created")
                    
                    urlString = url!
                    showSafari = true
                }
            }
        }
    }
    
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
        .navigationBarTitleDisplayMode(.inline)
        .frame(height: UIScreen.main.bounds.height + 15)
        .fixedSize(horizontal: false, vertical: true) 
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .preferredColorScheme(.dark)
    }
}
