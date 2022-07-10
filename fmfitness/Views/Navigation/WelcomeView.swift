//
//  WelcomeView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 3/14/22.
//

import SwiftUI

struct WelcomeView: View {
    
    @ObservedObject var firestore = FirestoreManager.shared
    //@ObservedObject var cloud = CloudManager.shared
    
    var title = "fernando maguina fitness"
    var textOne = "\"I can help you in building a strong and lean body or guide you in recovering from an injury.\""
    var textTwo = "Whether that means gaining the confidence to wear a two-piece at the beach after having their first child, fitting into the suit they always imagined they'd wear for their daughters' wedding, or the everyday confidence that permeates everything they do, installed through the effort they've put in at the studio."
    
    /*
    @State private var showSafari = false
    @State private var urlString = ""
     
    init() {
        showSafari = false
        if firestore.profile._username != "new_profile" && firestore.profile.userInfo == "new" && firestore.profile.isMember {
            cloud.createStripeAccountLink(params: ["accountID": firestore.profile.userInfo, "type": "account_onboarding"]) { [self] url, error in
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
    } */
    
    var body: some View {
        SideBarStack(sidebarWidth: 125, showSidebar: $firestore.showSidebar) {
            MenuView()
        } content: {
            NavigationView {
                ZStack(alignment: .top) {
                    Image("home-main")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height*3.25/5, alignment: .top)
                        
                    VStack {
                        Text(title)
                            .frame(maxWidth: UIScreen.main.bounds.width,
                                   minHeight: UIScreen.main.bounds.height*3.25/5)
                            .frame(width: UIScreen.main.bounds.width*1/2,
                                   height: 350,
                                   alignment: .top)
                            .offset(x: UIScreen.main.bounds.width*1/5)
                            .padding(.bottom, 75)
                            .foregroundColor(.white)
                            .font(Font.custom("BebasNeue", size: 60)
                                    .leading(.tight))
                    
                        ZStack(alignment: .top) {
                            Color("csb-main")
                                .offset(y: 10)
                            
                            Color("csb-main")
                                .frame(maxWidth: .infinity)
                                .frame(width: UIScreen.width*1.2, height: 40)
                                .ignoresSafeArea()
                                .background(.ultraThinMaterial)
                                .blur(radius: 10.0)
                            
                            ScrollView {
                                WelcomePageEntry(textOne: textOne, textTwo: textTwo)
                                    .scaledToFill()
                            }
                            .offset(y: 10)
                            
                            Color("csb-main")
                                .frame(maxWidth: .infinity)
                                .frame(width: UIScreen.width*1.2, height: 20)
                                .ignoresSafeArea()
                                .background(.ultraThinMaterial)
                                .blur(radius: 10.0)
                        }
                    }
                }
                .frame(width: UIScreen.width,
                       height: UIScreen.height)
                .background(Color("csb-main"))
                .frame(maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()
                .overlay(
                    withAnimation(.easeInOut(duration: 0.2)) {
                        ShadeView()
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        MenuButton()
                            .foregroundColor(.white)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    firestore.showSidebar.toggle()
                                }
                            }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        LogoButton()
                            .tint(Color("base-light"))
                            .foregroundColor(Color("base-light"))
                            .accentColor(Color("base-light"))
                            .overlay(
                                Image("fmf-logo-white")
                                    .renderingMode(.template)
                                    .resizable()
                                    .tint(.black)
                                    .foregroundColor(.black)
                                    .accentColor(.black)
                                    .frame(width: 85, height: 16)
                                    .padding(.bottom, 5)
                                    .padding(.leading, 5)
                            )
                            /*.tint(Color("B1-red"))
                            .foregroundColor(Color("B1-red"))
                            .accentColor(Color("B1-red"))*/
                    }
                }
            }
            .transition(.opacity)
            .frame(height: UIScreen.height + 10)
            .fixedSize(horizontal: false, vertical: true)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .preferredColorScheme(.dark)
    }
}
