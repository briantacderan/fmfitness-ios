//
//  AdminPage.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI
import Firebase
import GoogleSignIn

import SwiftUI

struct AdminPage: View {
    
    @ObservedObject var firestore = FirestoreManager.shared
    @ObservedObject var cloud = CloudManager.shared
    
    var body: some View {
        ScrollView {
            GeometryReader { geometry in

                VStack(spacing: 0) {
                    Spacer()
                    
                    RowCard(geometry: geometry)
                    .padding()
                    
                    Spacer()
                }
            }
        }
        .offset(y: 75)
        .frame(width: UIScreen.main.bounds.width,
               height: UIScreen.main.bounds.height)
    }
}

struct AdminPage_Previews: PreviewProvider {
    static var previews: some View {
        AdminPage()
            //.preferredColorScheme(.dark)
    }
}

struct RowCard: View {
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            Form {
                ForEach(firestore.appointments.indices, id: \.self) { (index: Int) in
                    Section {
                        VStack {
                            Text(firestore.appointments[index].email)
                                .padding()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * 0.9,
                                       height: geometry.size.width * 0.3)
                                .background(.ultraThinMaterial)
                                .foregroundColor(Color.primary.opacity(0.35))
                                .foregroundStyle(.ultraThinMaterial)
                                .cornerRadius(10)
                                .font(Font.custom("BebasNeue", size: 40))
                                /*.onTapGesture {
                                    if categoryName == "Pay Balance" {
                                        openURL(URL(string: urlString)!)
                                    }
                                } */
                            
                            Text(firestore.appointments[index].email) // Use categoryName in place of our static string
                                .font(Font.custom("BebasNeue", size: 30))
                                .foregroundColor(Color("csf-main"))
                                .multilineTextAlignment(.trailing)
                                .padding(12)
                        }
                    }
                    
                }
            }
        }
    }
}
