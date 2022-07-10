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
    
    //@Environment(\.editMode) var editMode
    @Environment(\.controller) var controller
    
    @ObservedObject var firestore = FirestoreManager.shared
    @State var draftProfile: Profile
    @State var editMode: EditMode = .inactive
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 20) {
                if $editMode.wrappedValue == .inactive {
                    ProfileSummary(editMode: editMode)
                } else {
                    ZStack(alignment: .bottom) {
                        VStack {
                            Text("Slide down to confirm changes")
                                .padding()
                                .font(Font.custom("Rajdhani-Medium", size: 20))
                            
                            ProfileEditor(profile: $draftProfile)
                                .frame(height: UIScreen.height*2/3)
                                .onAppear {
                                    draftProfile = firestore.profile
                                }
                                .onDisappear {
                                    firestore.profile = draftProfile
                                    controller.setProfile(parameters: [
                                        "email": firestore.profile.email,
                                        "level": firestore.profile.currentLevel,
                                        "focus": firestore.profile.focusTarget,
                                        "username": firestore.profile._username
                                    ])
                                }
                            
                            HStack {
                                Spacer()
                                if $editMode.wrappedValue.isEditing {
                                    Button("cancel", role: .cancel) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            draftProfile = firestore.profile
                                            editMode = .inactive
                                        }
                                    }
                                    .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .font(Font.custom("Rajdhani-SemiBold", size: 35))
                            .foregroundColor(Color("csf-accent"))
                        }
                    }
                }
            }
            
            Capsule()
                .fill(Color.black)
                .frame(width: 75, height: 5)
                .padding(10)
        }
        .frame(width: UIScreen.width,
               height: UIScreen.height*2/3)
    }
}

/*
struct ProfileHost_Previews: PreviewProvider {
    static var firestore = FirestoreManager.shared
    
    static var previews: some View {
        ProfileHost(draftProfile: firestore.profile)
            //.preferredColorScheme(.dark)
    }
}
*/
