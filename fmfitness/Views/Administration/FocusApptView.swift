//
//  FocusApptView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

struct FocusApptView: View {
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    var focusId: Int?
    
    var body: some View {
        // let dropDelegate = ApptDropDelegate(focusId: $focusId)
        
        // return VStack {
        VStack {
            if let id = focusId, let focus = firestore.appts[id] {
                Text("Current Focus")
                AppointmentView(appt: focus)
            } else {
                Text("DRAG HERE")
                    .font(Font.custom("Rajdhani-Bold", size: 12))
                    .foregroundColor(Color("A2-teal"))
                    .overlay(
                        Text("DRAG HERE")
                            .font(Font.custom("Rajdhani-Bold", size: 12))
                            .foregroundColor(Color.black)
                            .offset(x: 1, y: 1))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(Color("base-light"), style: StrokeStyle(dash: [10]))
                .background(Color("csb-main")
                                .opacity(0.5)
                                .overlay(
                                    Image("LaunchBlackTile")
                                        .renderingMode(.template)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fill)
                                        .opacity(0.1))))
        //.onDrop(of: [TodoItem.typeIdentifier], delegate: dropDelegate)
    }
}

/* @State private var focusId: Int?

@State private var invoice = Appointment.StripeLink.hundred.rawValue

var body: some View {
    VStack {
        if let id = focusId, let appointment = firestore.appts[id] {
            HStack {
                Menu {
                    Picker("Invoice", selection: $invoice) {
                        ForEach(Appointment.StripeLink.allCases) { link in
                            Text(link.rawValue)
                                .tag(link)
                                .font(Font.custom("Rajdhani-Regular", size: 20))
                        }
                    }
                    .padding(5)
                } label: {
                    Image(systemName: "arrowtriangle.down.square")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.accentColor, Color.black)
                        .font(.title)
                }
                
                Button {
                    firestore
                } label: {
                    Text("Confirm")
                        .font(Font.custom("Rajdhani-SemiBold", size: 18))
                        .foregroundColor(Color("base-green"))
                        .padding()
                        .scaledToFill()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color("base-green"), style: StrokeStyle(dash: [5]))
                                .background(Color("csf-gray"))
                        )
                }
            }
        } else {
            HStack {
                Image(systemName: "trash")
                    .foregroundColor(Color("B1-red"))
                    .frame(width: 60, height: 60)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color("csf-main"), style: StrokeStyle(dash: [5]))
                            .background(Color("csb-main"))
                    )
                
                Image(systemName: "pencil")
                    .foregroundColor(Color("csf-earth"))
                    .frame(width: 60, height: 60)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color("csf-main"), style: StrokeStyle(dash: [5]))
                            .background(Color("csb-main"))
                    )
                
                Text("More Info")
                    .scaledToFill()
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color("csf-main"), style: StrokeStyle(dash: [5]))
                            .background(Color("csb-main"))
                    )
            }
        }
    }
}*/
