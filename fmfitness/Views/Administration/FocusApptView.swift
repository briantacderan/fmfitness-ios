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
                Text("DRAG      HERE")
                    .font(Font.custom("BebasNeue", size: 30))
                    .foregroundColor(Color("csb-gray-str"))
                    .kerning(10)
                    .opacity(0.6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(Color("csf-accent-light").opacity(1.0), style: StrokeStyle(lineWidth: 4.0, dash: [10]))
                .background(
                    Image("LaunchBlackTile")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: UIScreen.width*5, height: UIScreen.height*5)
                        .aspectRatio(1, contentMode: .fill)
                        .foregroundColor(Color("csf-menu-gray")) 
                        .blur(radius: 0)
                        .opacity(1)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .strokeBorder(Color("csb-gray").opacity(1))
                                .background(Color("csb-gray").opacity(0.1)))))
        //.frame(width: UIScreen.width*0.9, height: 40)
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

struct FocusApptView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FocusApptView()
                .environmentObject(FirestoreManager.shared)
        }
                //.preferredColorScheme(.dark)
    }
}
