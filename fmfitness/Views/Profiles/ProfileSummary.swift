//
//  ProfileSummary.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/18/22.
//

import SwiftUI
import GoogleSignIn
import Firebase
import FirebaseFirestore

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

struct ProfileSummary: View {
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    private var user: GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }
    
    let dateNow = Date()
    var focus = [""]
    var focusChar: [Character] = []
    
    init() {
        focus = [firestore.profile.focusTarget]
        focus = [focus[0].replacingOccurrences(of: "-", with: " ").capitalized]
        focus = focus[0].components(separatedBy: " ")
        focusChar = [focus[0][0], focus[1][0]]
    }

    var body: some View {
        ScrollView {
            Image("mix-program")
                .ignoresSafeArea()
                .frame(height: 300)
                .offset(y: -30)
                .blur(radius: 10)
            
            if let userProfile = user?.profile {
                ProfileImageView(profile: userProfile)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    .overlay {
                        Circle().stroke(.white, lineWidth: 4)
                    }
                    .shadow(radius: 7)
                    .offset(y: -130)
                    .padding(.bottom, -130)
            }
                
            VStack(alignment: .leading) {
                Text(firestore.profile._username!)
                    .font(Font.custom("BebasNeue", size: 35))
                    .foregroundColor(Color("csf-main"))

                Text(firestore.profile.email)
                    .font(Font.custom("BebasNeue", size: 30))
                    .foregroundColor(.secondary)
            }
            .frame(width: UIScreen.main.bounds.width*4/5)
            .padding(.top)
             
            Divider()
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Currently: ")
                        .padding(.bottom, 10)
                    
                    Text(firestore.profile.currentLevel)
                        .frame(width: UIScreen.main.bounds.width*1/6,
                               height: UIScreen.main.bounds.width*1/6)
                        .aspectRatio(1.0, contentMode: .fit)
                        .background(.thinMaterial)
                        .foregroundColor(Color("csf-main"))
                        .foregroundStyle(.ultraThinMaterial)
                        .cornerRadius(6)
                        .padding()
                    
                    Text("Next: ")
                        .padding(.bottom, 10)
                   
                    HStack {
                        Text(String(focusChar[0]))
                        Text(String(focusChar[1]))
                    }
                    .frame(width: UIScreen.main.bounds.width*1/6,
                           height: UIScreen.main.bounds.width*1/6)
                    .aspectRatio(1.0, contentMode: .fit)
                    .background(.thinMaterial)
                    .font(Font.custom("BebasNeue", size: 30))
                    .foregroundColor(Color("csf-main"))
                    .foregroundStyle(.ultraThinMaterial)
                    .cornerRadius(6)
                    .padding()
                }
                Divider()
                Spacer()
                
                if firestore.profile.nextAppointment > dateNow {
                    HStack {
                        Text("Next Appointment: ")
                        
                        Text(firestore.profile.nextAppointment, style: .date)
                        
                        Text("@")
                            
                        Text(firestore.profile.nextAppointment, style: .time)
                            .font(Font.custom("BebasNeue", size: 25))
                            .foregroundColor(Color("csf-accent"))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                } else {
                    HStack {
                        Text("No workout sessions scheduled")
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
                        .font(Font.custom("BebasNeue", size: 15))
                        .foregroundColor(Color("csf-accent"))
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width*4/5)
            .font(Font.custom("BebasNeue", size: 20))
            .padding()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea()
    }
}
