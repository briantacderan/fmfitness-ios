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
                        List {
                            HStack {
                                Text("Username").bold()
                                Divider()
                                TextField("Username", text: Binding($profile._username)!)
                            }
                            
                            Toggle(isOn: $profile.prefersNotifications) {
                                Text("Enable Notifications").bold()
                            }
                            
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Workout team").bold()
                                
                                Picker("Readiness", selection: $profile.seasonalPhoto) {
                                    ForEach(Profile.Season.allCases) { season in
                                        Text(season.rawValue).tag(season)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            DatePicker(selection: $profile.nextAppointment,
                                       in: dateRange,
                                       displayedComponents: .date) {
                                Text("Schedule a Workout Session").bold()
                            }
                        }
                    )
            }
            .font(Font.custom("BebasNeue", size: 30))
            .ignoresSafeArea()
        }
    }
}
