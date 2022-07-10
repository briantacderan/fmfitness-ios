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
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    // @Environment(\.editMode) var editMode
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    @State var editMode: EditMode
    
    private var urlString: String? {
        return "https://checkout.stripe.com/pay/cs_live_a18agieXo53jtxINTkyulMRiO4j85TzXfGhOxtY7SyptfkWMMUFzZIxfMm#fidkdWxOYHwnPyd1blppbHNgWjA0TVQ9TDdERlI1TDJTZnx0PElzUDJMS1FXfGxBPFQ3REZEdURQb2tCPXNdbEg3M0N9PDFvaE5mTTRramNMR19PbF1nTUs8YEdvajYyXUNEXUQ3cUE8aX11NTVxdGRNMn1jdCcpJ3VpbGtuQH11anZgYUxhJz8nPERUPX1AZEBsPVM1NG1gZEBAJykndXdgaWpkYUNqa3EnPydGbWRud2QlVWBxZm0neCUl"
    }
    
    private var user: GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }
    
    let dateNow = Date()

    var body: some View {
        ZStack(alignment: .top) {
            /*Image("session-main")
                .resizable()
                .renderingMode(.template)
                .frame(height: 300)
                //.opacity(0.2)
                .ignoresSafeArea()
            
            Color("csb-gray")
                .frame(width: UIScreen.width*1.1, height: 50)
                .offset(y: 200)
                .blur(radius: 10)
                //.opacity(0.2)
                .ignoresSafeArea()
            
            Image("LaunchBlackTile")
                .resizable()
                .renderingMode(.template)
                .frame(width: UIScreen.width, height: UIScreen.height/3)
                .foregroundColor(Color("csb-gray"))
                //.opacity(0.2)
                .ignoresSafeArea()*/
        
            VStack {
                if let userProfile = user?.profile {
                    HStack {
                        Spacer()
                        ProfileImageView(profile: userProfile, frameSize: 155)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .overlay {
                                Circle().stroke(.white, lineWidth: 4)
                            }
                            .shadow(radius: 7)
                            .offset(y: -150)
                            .padding(.bottom, -150)
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(firestore.profile._username!)
                            .foregroundColor(Color("csf-main"))
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                editMode = .active
                            }
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(Color("csf-earth"))
                                .font(.system(size: 18))
                        }
                    }
                    .font(Font.custom("Rajdhani-Bold", size: 35))
                    
                    Text(firestore.profile.email)
                        .font(Font.custom("BebasNeue", size: 30))
                        .foregroundColor(Color("csb-main-gray"))
                }
                .frame(width: UIScreen.width*4/5)
                .padding(.vertical, 5)
                 
                Divider()
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Spacer()
                        VStack(spacing: -12) {
                            Text("Currently")
                                .font(Font.custom("Rajdhani-SemiBold", size: 16))
                            
                            Text(firestore.profile.currentLevel)
                                .frame(width: UIScreen.width*1/5,
                                       height: UIScreen.width*1/6)
                                .font(Font.custom("BebasNeue", size: 35))
                                .background(.thinMaterial)
                                .foregroundColor(Color("csf-main"))
                                .foregroundStyle(.ultraThinMaterial)
                                .cornerRadius(6)
                                .padding()
                        }
                        
                        Spacer()
                        
                        VStack(spacing: -12) {
                            Text("Balance")
                                .font(Font.custom("Rajdhani-SemiBold", size: 16))
                           
                            Text(firestore.appointment.invoice)
                                .frame(width: UIScreen.width/5,
                                   height: UIScreen.width/6)
                                .background(.thinMaterial)
                                .font(Font.custom("BebasNeue", size: 40))
                                .foregroundColor(Color("B1-red"))
                                .cornerRadius(6)
                                .padding()
                                .onTapGesture {
                                    openURL(URL(string: urlString!)!)
                                }
                                .disabled(firestore.profile.outstandingBalance == 0)
                        }
                        Spacer()
                    }
                    
                    Divider()
                    
                    Section(
                        header:
                            Text("Next coaching:")
                                .font(Font.custom("Rajdhani-SemiBold", size: 20))
                                .foregroundColor(Color("csf-main"))
                                .padding(.leading, 12),
                        content: {
                            if firestore.profile.nextAppointment > dateNow && !firestore.appointment.isPaid {
                                HStack {
                                    Text(firestore.profile.nextAppointment, style: .date)
                                        .font(Font.custom("Rajdhani-Bold", size: 30))
                                        .frame(width: UIScreen.width*3/7)
                                    Text("@")
                                        .font(Font.custom("Rajdhani-Bold", size: 20))
                                    Text(firestore.profile.nextAppointment, style: .time)
                                        .font(Font.custom("BebasNeue", size: 40))
                                        .foregroundColor(Color("csf-accent"))
                                }
                                .padding(.vertical, 0)
                                .padding(.horizontal, 6)
                            } else {
                                HStack {
                                    Text("NO TRAINING SCHEDULED")
                                        .font(Font.custom("Rajdhani-Bold", size: 25))
                                        .frame(width: UIScreen.width*2/5)
                                        .foregroundColor(Color("csf-main"))
                                    Spacer()
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            firestore.selection = .schedule
                                            dismiss()
                                        }
                                    } label: {
                                        Text("Schedule")
                                    }
                                    .padding()
                                    .frame(width: 120, height: 40)
                                    .background(Color("csb-main").opacity(0.2))
                                    .foregroundColor(Color("csf-accent"))
                                    .cornerRadius(10)
                                    .shadow(color: Color("csf-main").opacity(0.65), radius: 1, x: -1, y: -2)
                                    .shadow(color: Color("csb-main").opacity(0.65), radius: 2, x: 2, y: 2)
                                    .font(Font.custom("BebasNeue", size: 30))
                                    .padding(.trailing, 8)
                                }
                                .padding(.vertical, 0)
                                .padding(.horizontal, 6)
                            }
                        }
                    )
                    .padding()
                }
                .frame(width: UIScreen.width*0.95)
                .font(Font.custom("BebasNeue", size: 20))
                .padding()
            }
            .offset(y: UIScreen.height/9.5)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .frame(width: UIScreen.width, height: UIScreen.height*0.7)
        .background(
            LinearGradient(
                colors: [
                    Color("base-light").opacity(0.5),
                    Color("csb-main")
                ],
                startPoint: .top, endPoint: .bottom)
        )
        .ignoresSafeArea()
    }
}
