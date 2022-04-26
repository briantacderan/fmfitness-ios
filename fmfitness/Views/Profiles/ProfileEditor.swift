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
        let backgroundGradient = LinearGradient(
            colors: [Color("csb-main"), Color("csf-accent")],
            startPoint: .top, endPoint: .bottom)
        
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        
        return Group {
            ZStack {
                backgroundGradient
                    .offset(y: 75)
                    .overlay(
                        Form {
                            Section {
                                HStack {
                                    Text("Username").bold()
                                    Divider()
                                    TextField("Username", text: Binding($profile._username)!)
                                        .font(Font.custom("Rajdhani Medium", size: 15))
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                            
                            Section {
                                HStack {
                                    Text("Target focus").bold()
                                    Divider()
                                    Spacer()
                                    Picker("Target focus", selection: $profile.focusTarget) {
                                        ForEach(Profile.Focus.allCases) { focus in
                                            Text((focus.rawValue == "total-body" ? focus.rawValue.replacingOccurrences(of: "-", with:" ") : focus.rawValue.replacingOccurrences(of: "-", with:" + ")))
                                                .tag(focus)
                                                .font(Font.custom("Rajdhani", size: 15))
                                                .foregroundColor(Color("csf-main"))
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .accentColor(Color("csf-main"))
                                }
                            }
                            
                            Section {
                                VStack(alignment: .leading, spacing: 20) {
                                    Text("Recovery status").bold()
                                    
                                    Picker("Readiness", selection: $profile.currentLevel) {
                                        ForEach(Profile.Level.allCases) { level in
                                            Text(level.rawValue)
                                                .tag(level)
                                        }
                                    }
                                    .padding(5)
                                    .pickerStyle(.segmented)
                                }
                            }
                        }
                    )
            }
            .font(Font.custom("BebasNeue", size: 30))
            .ignoresSafeArea()
        }
    }
}
