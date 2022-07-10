//
//  ProfileEditor.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/19/22.
//

import SwiftUI
import GoogleSignIn

struct ProfileEditor: View {
    
    @ObservedObject var authViewModel = AuthenticationViewModel.shared
    @ObservedObject var firestore = FirestoreManager.shared
    
    @Binding var profile: Profile
    
    var dateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let max = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        return min...max
    }

    var body: some View {
        /* let backgroundGradient = LinearGradient(
            colors: [
                Color("csb-main"),
                Image("csf-spin")
                    .resizable()
            ],
            startPoint: .top, endPoint: .bottom) */
        
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        
        return Group {
            ZStack {
                /* backgroundGradient */
                Image("session-main")
                    .resizable()
                    .offset(y: 75)
                    .frame(width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.height+75)
                    .ignoresSafeArea()
                    .overlay(
                        Form {
                            Section {
                                HStack {
                                    Text("Username")
                                        .font(Font.custom("Rajdhani-SemiBold", size: 20))
                                    Divider()
                                    TextField("Username", text: Binding($profile._username)!)
                                        .font(Font.custom("Rajdhani-Medium", size: 15))
                                        .multilineTextAlignment(.trailing)
                                }
                      
                                HStack {
                                    Text("Target focus")
                                        .font(Font.custom("Rajdhani-SemiBold", size: 20))
                                    Divider()
                                    Spacer()
                                    Picker("Target focus", selection: $profile.focusTarget) {
                                        ForEach(Profile.Focus.allCases) { focus in
                                            Text((focus.rawValue == "total-body" ? focus.rawValue.replacingOccurrences(of: "-", with:" ") : focus.rawValue.replacingOccurrences(of: "-", with:" + ")))
                                                .tag(focus)
                                                .font(Font.custom("Rajdhani-Medium", size: 20))
                                                .foregroundColor(Color("csb-main"))
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .accentColor(Color("csb-main"))
                                }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Recovery status")
                                        .font(Font.custom("BebasNeue", size: 18))
                                    
                                    Picker("Readiness", selection: $profile.currentLevel) {
                                        ForEach(Profile.Level.allCases) { level in
                                            Text(level.rawValue)
                                                .tag(level)
                                        }
                                    }
                                    .padding(5)
                                    .pickerStyle(.segmented)
                                }
                                .scaledToFit()
                            }
                        }
                        .padding(.top, 50)
                        .scaledToFill()
                        
                    )
            }
            .font(Font.custom("BebasNeue", size: 30))
            .frame(height: UIScreen.main.bounds.height)
            .offset(y: 50)
            .ignoresSafeArea()
        }
    }
}
