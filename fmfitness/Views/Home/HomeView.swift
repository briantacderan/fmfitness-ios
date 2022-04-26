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
    
    private var user: GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }
    
    let dateNow = Date()
    var focus = ""
    
    init() {
        focus = firestore.profile.focusTarget
        focus = focus.replacingOccurrences(of: "-", with: " ").capitalized
        if focus != "Total Body" {
            focus = focus.replacingOccurrences(of: " ", with: " + ")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                withAnimation {
                    TargetFocusView()
                }
                    
                Form {
                    HStack(alignment: .top, spacing: 30) {
                        Text("Next Target Focus:")
                            .font(Font.custom("BebasNeue", size: 20))
                            .foregroundColor(Color("csf-earth"))
                            .padding(.top, 2)
                        Text(focus)
                            .font(Font.custom("BebasNeue", size: 36))
                            .foregroundColor(Color("csf-main"))
                    }
                    .blur(radius: firestore.blurSecure)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
    
                    Section(header:
                        Text("Your next personal training appointment: ")
                            .font(Font.custom("BebasNeue", size: 20))
                            .foregroundColor(Color("csf-earth"))
                            .padding(.leading, 12)
                            .padding(.bottom, 5),
                            content: {
                        if firestore.profile.nextAppointment > dateNow {
                            HStack {
                                Text(firestore.profile.nextAppointment, style: .date)
                                    .font(Font.custom("BebasNeue", size: 35))
                                    .frame(width: UIScreen.main.bounds.width*3/7)
                                Text("@")
                                    .font(Font.custom("BebasNeue", size: 25))
                                Text(firestore.profile.nextAppointment, style: .time)
                                    .font(Font.custom("BebasNeue", size: 40))
                                    .foregroundColor(Color("csf-accent"))
                            }
                            .padding(0)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                        } else {
                            HStack {
                                Text("No workout sessions scheduled")
                                    .font(Font.custom("BebasNeue", size: 24))
                                    .frame(width: UIScreen.main.bounds.width*3/5)
                                Spacer()
                                Button {
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        firestore.next(newPage: .rsvpPage)
                                    }
                                } label: {
                                    Text("Schedule")
                                }
                                .padding()
                                .frame(width: 90, height: 30)
                                .background(.ultraThinMaterial)
                                .cornerRadius(10)
                                .shadow(color: .white.opacity(0.65), radius: 1, x: -1, y: -2)
                                .shadow(color: .black.opacity(0.65), radius: 2, x: 2, y: 2)
                                .font(Font.custom("BebasNeue", size: 20))
                                .foregroundColor(Color("csf-accent"))
                            }
                            .padding(0)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                        }
                    })
                        .blur(radius: firestore.blurSecure)
                }
            }
            .background(Color("csb-main"))
            .blur(radius: firestore.blurSecure)
            .navigationBarTitle("FM Fitness", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    MenuButton()
                        .foregroundColor(Color("csf-gray"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        firestore.showingProfile.toggle()
                    } label: {
                        Label("User Profile", systemImage: "person.crop.circle")
                    }
                    .foregroundColor(Color("csf-earth"))
                    .font(.system(size: 22))
                    .padding(.bottom, 12)
                    .padding(.trailing, 5)
                }
            }
            .sheet(isPresented: $firestore.showingProfile) {
                ProfileHost(draftProfile: firestore.profile)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(FirestoreManager.shared)
            .preferredColorScheme(.dark)
    }
}

struct TargetFocusView: View {
    @ObservedObject var firestore = FirestoreManager.shared
    
    @State var scale: CGFloat = 1.0
    @State var location: CGPoint = CGPoint(x: 0, y: 0)
    @State var isActiveLeft = false
    @State var isActiveRight = false

    var body: some View {
        
        HStack {
            ZStack{
                Image("\(firestore.profile.focusTarget)-front")
                    .resizable()
                    .scaleEffect(1.0)
                    .frame(width: UIScreen.main.bounds.width*0.40, height: UIScreen.main.bounds.width*0.80)
                    .background(Color("csb-main"))
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.top, 30)
                    .blur(radius: scale - 1)
                
                
                Image("\(firestore.profile.focusTarget)-front")
                    .resizable()
                    .scaleEffect(scale)
                    .frame(width: UIScreen.main.bounds.width*0.40, height: UIScreen.main.bounds.width*0.80)
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.top, scale != 1.0 ? 50 : 30)
                    .offset(x: scale != 1.0 ? -30 : 0)
                    .opacity(isActiveLeft ? 1.0 : 0)
                    .position(location)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                self.location = value.location
                            }
                    )
                    .pressAction {
                        withAnimation(.easeIn(duration: 0.15)) {
                            self.scale = 1.5
                            self.isActiveLeft = true
                        }
                    } onRelease: {
                        print(self.location)
                        withAnimation(.spring()) {
                            self.scale = 1.0
                            self.isActiveLeft = false
                        }
                    }
            }
                
            ZStack {
                Image("\(firestore.profile.focusTarget)-back")
                    .resizable()
                    .scaleEffect(1.0)
                    .frame(width: UIScreen.main.bounds.width*0.40, height: UIScreen.main.bounds.width*0.80)
                    .background(Color("csb-main"))
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.top, 30)
                    .blur(radius: scale - 1)
                    
                
                Image("\(firestore.profile.focusTarget)-back")
                    .resizable()
                    .scaleEffect(scale)
                    .frame(width: UIScreen.main.bounds.width*0.40, height: UIScreen.main.bounds.width*0.80)
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.top, scale != 1.0 ? 50 : 30)
                    .offset(x: scale != 1.0 ? -30 : 0)
                    .opacity(isActiveRight ? 1 : 0)
                    .position(location)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                self.location = value.location
                            }
                            .onEnded { value in
                                self.location = value.location
                            }
                    )
                    .pressAction {
                        withAnimation(.easeIn(duration: 0.15)) {
                            self.scale = 1.5
                            self.isActiveRight = true
                        }
                    } onRelease: {
                        print(self.location)
                        withAnimation(.spring()) {
                            self.scale = 1.0
                            self.isActiveRight = false
                        }
                    }
            }
        }
            
        
        
        
        
        
        /*
        .gesture(MagnificationGesture()
                    .onChanged { value in
                        self.scale = value.magnitude
                    }
                    .onEnded { value in
                        self.scale = 1.0
                    }
        )*/
    }
}



