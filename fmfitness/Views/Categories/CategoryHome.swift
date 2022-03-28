//
//  CategoryHome.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/18/22.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct CategoryHome: View {
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    private var user: GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Image("chest-back")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/1.25)
                    .background(Color("csb-main"))
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.top, 30)
                
                Form {
                    HStack(alignment: .top, spacing: 30) {
                        Text("Next Target Focus:")
                            .font(Font.custom("BebasNeue", size: 20))
                            .foregroundColor(Color("csf-earth"))
                            .padding(.top, 2)
                        Text("Chest and Back")
                            .font(Font.custom("BebasNeue", size: 36))
                            .foregroundColor(Color("csf-main"))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
    
                    Section(header:
                        Text("Your next personal training appointment: ")
                            .font(Font.custom("BebasNeue", size: 20))
                            .foregroundColor(Color("csf-earth"))
                            .padding(.leading, 12)
                            .padding(.bottom, 5),
                            content: {
                        HStack {
                            Text(firestore.profile.nextAppointment, style: .date)
                                .font(Font.custom("BebasNeue", size: 35))
                                .frame(width: UIScreen.main.bounds.width*1/3)
                            Text("@")
                                .font(Font.custom("BebasNeue", size: 25))
                            Text(firestore.profile.nextAppointment, style: .time)
                                .font(Font.custom("BebasNeue", size: 45))
                                .foregroundColor(Color("csf-accent"))
                        }
                        .padding(0)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    })
                }
            }
            .background(Color("csb-main"))
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

struct CategoryHome_Previews: PreviewProvider {
    static var previews: some View {
        CategoryHome()
            .environmentObject(FirestoreManager.shared)
            .preferredColorScheme(.dark)
    }
}
