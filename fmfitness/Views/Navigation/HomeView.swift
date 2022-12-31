//
//  HomeView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/18/22.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct HomeView: View {
    @ObservedObject var firestore = FirestoreManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    private var user: GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }
    
    private var today = Date()
    
    func parseTarget() -> String {
        var focus = firestore.profile.focusTarget
        focus = focus.replacingOccurrences(of: "-", with: " ").capitalized
        if focus != "Total Body" {
            focus = focus.replacingOccurrences(of: " ", with: " + ")
        }
        return focus
    }
    
    var body: some View {
        SideBarStack(sidebarWidth: 125, showSidebar: $firestore.showSidebar) {
            MenuView()
        } content: {
            NavigationView {
                VStack {
                    ZStack(alignment: .bottom) {
                        Color("csb-gray-str")
                            .blur(radius: 4)
                            .frame(width: UIScreen.width*1.1, height: 15)
                            .offset(y: 35)
                        
                        Color.white
                            .blur(radius: 4)
                            .frame(width: UIScreen.width*1.1, height: 6)
                            .offset(y: 24)
                        
                        Color("base-green")
                            .frame(width: UIScreen.width*1.1, height: 5)
                            .offset(y: 30)
                    }
                    .frame(height: 180)
                    
                    VStack {
                        VStack {
                            Section {
                                VStack {
                                    HStack {
                                        Text("YOUR NEXT FITNESS INSTRUCTION: ")
                                            .font(Font.custom("Rajdhani-Bold", size: 20))
                                            .foregroundColor(colorScheme == .dark ? Color("A1-blue") : Color("csf-menu-gray"))
                                            .brightness(colorScheme == .dark ? 0.4 : -0.1)
                                            .padding(.leading, 8)
                                            .padding(.bottom, 0)
                                        Spacer()
                                    }
                                  
                                    if firestore.profile.nextAppointment > today && !firestore.appointment.isPaid {
                                        HStack {
                                            Text(firestore.profile.nextAppointment, style: .date)
                                                .font(Font.custom("Rajdhani-Bold", size: 30))
                                            Text(firestore.profile.nextAppointment, style: .time)
                                                .font(Font.custom("BebasNeue", size: 40))
                                                .foregroundColor(Color("csf-accent"))
                                        }
                                        .padding(.vertical, 8)
                                        .frame(width: UIScreen.width*0.8)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(10)
                                        .shadow(color: Color("csf-gray"), radius: 1, x: 2, y: (colorScheme == .dark ? -2 : 2))
                                    } else {
                                        HStack {
                                            Spacer()
                                            Text("No training scheduled")
                                                .foregroundColor(Color("B1-red"))
                                                .font(Font.custom("Rajdhani-Light", size: 20))
                                            Spacer()
                                        }
                                        .padding(.vertical, 12)
                                        .frame(width: UIScreen.width*0.8)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(10)
                                        .shadow(color: Color("csf-gray"), radius: 1, x: 2, y: (colorScheme == .dark ? -2 : 2))
                                    }
                                }
                                .padding(6)
                            }
                            .padding(.top, 20)
                            .padding(.horizontal, 12)
                            
                            Section {
                                VStack {
                                    HStack {
                                        Text("YOUR TARGET FOCUS:")
                                            .font(Font.custom("Rajdhani-Bold", size: 20))
                                            .foregroundColor(colorScheme == .dark ? Color("A1-blue") : Color("csf-menu-gray"))
                                            .brightness(colorScheme == .dark ? 0.4 : -0.1)
                                            .padding(.leading, 8)
                                            .padding(.bottom, 0)
                                        Spacer()
                                    }
                                    
                                    HStack(alignment: .top, spacing: 20) {
                                        Text(parseTarget())
                                            .font(Font.custom("BebasNeue", size: 36))
                                            .foregroundColor(Color("csf-main"))
                                    }
                                    .padding(.vertical, 8)
                                    .frame(width: UIScreen.width*0.8)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(10)
                                    .shadow(color: Color("csf-gray"), radius: 1, x: 2, y: (colorScheme == .dark ? -2 : 2))
                                }
                                .padding(6)
                            }
                            .padding(.top, 10)
                            .padding(.horizontal, 12)
                        }
                        .padding(.top, 20)
                    }
                    .opacity(firestore.showProfile ? 0.2 : 1)
                    .offset(x: (firestore.showProfile ? -UIScreen.width : 0), y: -90)
                    .transition(AnyTransition.homerSimpson)
                    
                    VStack {
                        withAnimation {
                            TargetFocusView()
                                .scaledToFit()
                        }
                        
                        GeometryReader { geometry in
                            VStack(spacing: 0) {
                                Spacer()
                                CategoryRow(geometry: geometry,
                                            categoryNameLeft: "Pay Balance",
                                            categoryNameRight: (firestore.profile.nextAppointment > today && !firestore.appointment.isPaid) ? "Request Cancellation" : "Schedule Training")
                                    .padding()
                                Spacer()
                            }
                        }
                        .offset(y: -70)
                    }
                    .opacity(firestore.showProfile ? 0.2 : 1)
                    .offset(x: (firestore.showProfile ? -UIScreen.width : 0), y: -115)
                    .transition(AnyTransition.homerSimpson)
                }
                .frame(width: UIScreen.width,
                       height: UIScreen.height)
                .scaledToFit()
                .background(
                    ZStack {
                        Color.gray
                        Color("csb-main")
                            .offset(y: 90)
                            .frame(height: UIScreen.height-75)
                        Image("LaunchBlackTile")
                                .renderingMode(.template)
                                .foregroundColor(Color("csf-main"))
                                .opacity(0.013)
                                .ignoresSafeArea()
                    }
                )
                .navigationBarTitle(firestore.showProfile ? "" : "Dashboard")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if firestore.showProfile {
                            LogoButton()
                                .tint(Color.black)
                                .foregroundColor(Color.black)
                                .transition(.opacity)
                        } else {
                            MenuButton()
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        firestore.showSidebar.toggle()
                                    }
                                }
                                .transition(.opacity)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            NavProfileButton()
                                .opacity(firestore.showProfile ? 0 : 1 )
                                .transition(.opacity)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavLogoName()
                            .transition(AnyTransition.homerSimpson)
                    }
                }
                .animation(.default, value: firestore.showProfile)
                .sheet(isPresented: $firestore.showProfile) {
                    withAnimation(Animation.linear.delay(1)) {
                        ProfileHost(draftProfile: firestore.profile)
                            .frame(width: UIScreen.width,
                                   height: UIScreen.height*0.7)
                            .cornerRadius(10)
                            .offset(y: UIScreen.height/15)
                            .ignoresSafeArea()
                            .background(BackgroundClearView())
                    }
                }
                .overlay(
                    ShadeView()
                )
            }
            //.animation(.default, value: firestore.showProfile)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            //.preferredColorScheme(.dark)
    }
}

struct CategoryCard: View {
    
    let geometry: GeometryProxy
    let categoryName: String
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.controller) var controller 
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    @State private var urlString = "https://checkout.stripe.com/pay/cs_live_a18agieXo53jtxINTkyulMRiO4j85TzXfGhOxtY7SyptfkWMMUFzZIxfMm#fidkdWxOYHwnPyd1blppbHNgWjA0TVQ9TDdERlI1TDJTZnx0PElzUDJMS1FXfGxBPFQ3REZEdURQb2tCPXNdbEg3M0N9PDFvaE5mTTRramNMR19PbF1nTUs8YEdvajYyXUNEXUQ3cUE8aX11NTVxdGRNMn1jdCcpJ3VpbGtuQH11anZgYUxhJz8nPERUPX1AZEBsPVM1NG1gZEBAJykndXdgaWpkYUNqa3EnPydGbWRud2QlVWBxZm0neCUl"
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color("csf-gray")
                .frame(width: geometry.size.width * 0.45,
                       height: geometry.size.width * 0.35)
                .cornerRadius(10)
                .blur(radius: 1)
                .offset(x: 2, y: (colorScheme == .dark ? -2 : 2))
            
            Color("csb-main")
                .frame(width: geometry.size.width * 0.45,
                       height: geometry.size.width * 0.35)
                .cornerRadius(10)
            
            Text(categoryName == "Pay Balance" ? "$\(firestore.profile.outstandingBalance)" : "")
                .padding()
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.size.width * 0.45,
                       height: geometry.size.width * 0.35)
                .background(.ultraThinMaterial)
                .foregroundColor(firestore.appointment.invoice != "$0" ? Color("B1-red") : Color.primary.opacity(0.35))
                .foregroundStyle(.ultraThinMaterial)
                .cornerRadius(10)
                .font(Font.custom("BebasNeue", size: 40))
                .onTapGesture {
                    if categoryName == "Request Cancellation" {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            firestore.induceShade.toggle()
                            controller.fetchTraining(for: firestore.profile.email)
                            AlertController().permitCancel()
                        }
                    } else if categoryName == "Schedule Training" {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            firestore.selection = .schedule
                        }
                    } else if firestore.appointment.invoice != "$0" {
                        openURL(URL(string: urlString)!)
                    }
                }
                .disabled(categoryName == "Pay Balance" && firestore.profile.outstandingBalance == 0)
            
            
            Text(categoryName)
                .font(Font.custom("BebasNeue", size: 24))
                .foregroundColor(Color("csf-main"))
                .multilineTextAlignment(.trailing)
                .padding(12)
        }
    }
}

struct CategoryRow: View {
    
    let geometry: GeometryProxy
    let categoryNameLeft: String
    let categoryNameRight: String
    
    var body: some View {
        HStack {
            NavigationLink(destination: Category(categoryName: categoryNameLeft)) {
                CategoryCard(geometry: geometry, categoryName: categoryNameLeft)
            }
            NavigationLink(destination: Category(categoryName: categoryNameRight)) {
                CategoryCard(geometry: geometry, categoryName: categoryNameRight)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Category: View {
    
    var categoryName: String
    
    var body: some View {
        VStack {
            Text("")
        }
        .navigationBarTitle(categoryName)
    }
}
