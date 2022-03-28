//
//  ProfileHost.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/18/22.
//
import SwiftUI
import Firebase
import GoogleSignIn

struct ProfileHost: View {
    
    @Environment(\.editMode) var editMode

    @ObservedObject var firestore = FirestoreManager.shared
    @ObservedObject var authViewModel = AuthenticationViewModel.shared
    
    @State var draftProfile: Profile
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 20) {
                if editMode?.wrappedValue == .inactive {
                    ProfileSummary()
                    HStack {
                        Spacer()
                        EditButton()
                        Spacer()
                    }
                    .font(Font.custom("BebasNeue", size: 30))
                    .foregroundColor(Color("csf-accent"))
                    .frame(width: UIScreen.main.bounds.width)
                    .offset(x: 55, y: -UIScreen.main.bounds.height/8)
                } else {
                    ZStack(alignment: .top) {
                        VStack {
                            Text("Slide down to confirm changes")
                                .frame(width: UIScreen.main.bounds.width/1.5)
                                .padding(.top, 25)
                                .font(Font.custom("BebasNeue", size: 20))
                            
                            ProfileEditor(profile: $draftProfile)
                                .onAppear {
                                    draftProfile = firestore.profile
                                }
                                .onDisappear {
                                    firestore.profile = draftProfile
                                    firestore.setProfile(email: firestore.profile.email,
                                                         isAdmin: firestore.profile.isAdmin,
                                                         prefersNotifications: firestore.profile.prefersNotifications,
                                                         seasonalPhoto: firestore.profile.seasonalPhoto,
                                                         nextAppointment: firestore.profile.nextAppointment,
                                                         username: firestore.profile._username)
                                }
                            
                            HStack {
                                Spacer()
                                if editMode?.wrappedValue == .active {
                                    Button("Cancel", role: .cancel) {
                                        draftProfile = firestore.profile
                                        editMode?.animation().wrappedValue = .inactive
                                    }
                                    .foregroundColor(Color("csf-main"))
                                }
                                Spacer()
                            }
                            .font(Font.custom("BebasNeue", size: 35))
                            .foregroundColor(Color("csf-accent"))
                            .offset(y: -UIScreen.main.bounds.height/3)
                        }
                    }
                }
            }
            .background(Color("csb-main"))
            .ignoresSafeArea()
            
            Capsule()
                .fill(.black)
                .frame(width: 75, height: 5)
                .padding(10)
        }
    }
}

struct ProfileHost_Previews: PreviewProvider {
    static var firestore = FirestoreManager.shared
    
    static var previews: some View {
        ProfileHost(draftProfile: firestore.profile)
            //.preferredColorScheme(.dark)
    }
}
