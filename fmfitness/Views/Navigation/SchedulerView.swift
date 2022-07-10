//
//  SchedulerView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 2/28/22.
//

import SwiftUI
import Firebase

struct SchedulerView: View {
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.controller) var controller
    
    @ObservedObject var scheduler = SchedulerModel.shared
    @ObservedObject var firestore = FirestoreManager.shared

    @State private var weekConfirmed = false
    @State private var dayConfirmed = false
    @State private var timeSelected = false
    @State private var timeConfirmed = false
    @State private var items: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @State private var urlString = "https://checkout.stripe.com/pay/cs_live_a18agieXo53jtxINTkyulMRiO4j85TzXfGhOxtY7SyptfkWMMUFzZIxfMm#fidkdWxOYHwnPyd1blppbHNgWjA0TVQ9TDdERlI1TDJTZnx0PElzUDJMS1FXfGxBPFQ3REZEdURQb2tCPXNdbEg3M0N9PDFvaE5mTTRramNMR19PbF1nTUs8YEdvajYyXUNEXUQ3cUE8aX11NTVxdGRNMn1jdCcpJ3VpbGtuQH11anZgYUxhJz8nPERUPX1AZEBsPVM1NG1gZEBAJykndXdgaWpkYUNqa3EnPydGbWRud2QlVWBxZm0neCUl"
    
    func userId() -> String {
       return Auth.auth().currentUser!.uid
    }
    
    private var today = Date()
    
    
    func df() -> DateFormatter {
        let df = DateFormatter()
        
        df.dateFormat = "dd/MM/yy"
        df.dateStyle = .medium
        df.timeStyle = .short
        
        return df
    }
    
    var body: some View {
        SideBarStack(sidebarWidth: 125, showSidebar: $firestore.showSidebar) {
           MenuView()
        } content: {
            NavigationView {
                ZStack {
                    ZStack {
                        VStack {
                            VStack {
                                if firestore.appointment.invoice != "$0" && firestore.appointment.isConfirmed && firestore.appointment.isCompleted && !firestore.appointment.isPaid && !firestore.appointment.isCanceled && !weekConfirmed {
                                    VStack {
                                        HStack {
                                            LogoButton()
                                                .tint(Color("B1-red"))
                                                .foregroundColor(Color("B1-red"))
                                                .padding(2)
                                            
                                            Spacer()
                                        }
                                        
                                        HStack {
                                            Spacer()
                                            SchedulerTitle()
                                                .ignoresSafeArea(.all)
                                            Spacer()
                                        }
                                        .padding(.vertical)
                                        
                                        Divider()
                                        Spacer()

                                        Text("Please pay your remaining balance before scheduling a new appointment: ")
                                            .font(Font.custom("Rajdhani-SemiBold", size: 24))
                                            .frame(width: UIScreen.width/2)
                                            .foregroundColor(Color("csf-gray"))
                                            .multilineTextAlignment(.center)
                                        
                                        Spacer()
                                        
                                        VStack(spacing: 5) {
                                            Text("Current balance")
                                                .font(Font.custom("BebasNeue", size: 25))
                                            
                                            Text(firestore.appointment.invoice)
                                                .padding()
                                                .font(Font.custom("BebasNeue", size: 30))
                                                .foregroundColor(Color("B1-red"))
                                                .multilineTextAlignment(.center)
                                                .frame(width: UIScreen.width/4,
                                                       height: UIScreen.width/6)
                                                .background(.thinMaterial)
                                                .foregroundStyle(.ultraThinMaterial)
                                                .cornerRadius(8)
                                                .padding()
                                                .onTapGesture {
                                                    openURL(URL(string: urlString)!)
                                                }
                                        }
                                        .scaledToFit()
                                        
                                        Spacer()
                                        Spacer()
                                    }
                                } else if firestore.appointment.nextAppointment > today && firestore.appointment.isConfirmed && !firestore.appointment.isPaid && !firestore.appointment.isCanceled && !weekConfirmed {
                                    VStack {
                                        HStack {
                                            Button {
                                                withAnimation(.easeInOut(duration: 0.35)) {
                                                    firestore.induceShade.toggle()
                                                    AlertController().permitCancel()
                                                }
                                            } label: {
                                                HStack(spacing: 3) {
                                                    Image(systemName: "x.square.fill")
                                                        .symbolRenderingMode(.palette)
                                                        .foregroundStyle(Color.white, Color("B1-red"))
                                                        .font(Font.custom("BebasNeue", size: 24))
                                                    Text("Request cancellation")
                                                        .foregroundColor(Color("csf-gray"))
                                                }
                                            }
                                            .font(Font.custom("BebasNeue", size: 18))
                                            .padding(2)
                                            
                                            Spacer()
                                        }
                                        
                                        HStack {
                                            Spacer()
                                            SchedulerTitle()
                                                .ignoresSafeArea(.all)
                                            Spacer()
                                        }
                                        .padding(.vertical)
                                        
                                        Divider()
                                        
                                        Spacer()

                                        Text("You currently have reservations for timeslot: ")
                                            .font(Font.custom("Rajdhani-Medium", size: 24))
                                            .frame(width: UIScreen.width/2)
                                            .foregroundColor(Color("csf-gray"))
                                            .multilineTextAlignment(.center)
                                        Spacer()
                                        Text(df().string(from: firestore.appointment.nextAppointment))
                                            .font(Font.custom("BebasNeue", size: 45))
                                            .foregroundColor(Color("csf-main"))
                                            .multilineTextAlignment(.center)
                                        
                                        Spacer()
                                        Spacer()
                                    }
                                } else {
                                    if !weekConfirmed {
                                        VStack {
                                            HStack {
                                                LogoButton()
                                                    .tint(Color("B1-red"))
                                                    .foregroundColor(Color("B1-red"))
                                                    .padding(2)
                                                
                                                Spacer()
                                            }
                                            
                                            HStack {
                                                Spacer()
                                                Spacer()
                                                SchedulerTitle()
                                                    .ignoresSafeArea(.all)
                                            }
                                            
                                            Divider()
                                            
                                            ZStack {
                                                HighlightChoice()
                                                
                                                Picker("Training Week", selection: $scheduler.weekIndex) {
                                                    ForEach(scheduler.weekArray.indices, id: \.self) { (index: Int) in
                                                        Text(self.scheduler.weekArray[index])
                                                                .font(Font.custom("BebasNeue", size: 40))
                                                                .foregroundColor(Color("csf-main-str"))
                                                                .padding(20)
                                                            Spacer()
                                                    }
                                                }
                                                .pickerStyle(WheelPickerStyle())
                                            }
                                            
                                            Button(action: {
                                                withAnimation(.easeInOut(duration: 0.35)) {
                                                    weekConfirmed.toggle()
                                                }
                                            }) {
                                                Text("OK →")
                                                    .modifier(SchedButtonMod())
                                            }
                                            .padding(.horizontal)
                                            .scaledToFill()
                                            
                                            Spacer()
                                        }
                                    }
                                        
                                    if !dayConfirmed && weekConfirmed {
                                        VStack {
                                            HStack {
                                                Button {
                                                    withAnimation(.easeInOut(duration: 0.35)) {
                                                        weekConfirmed.toggle()
                                                    }
                                                } label: {
                                                    Image(systemName: "chevron.backward.circle.fill")
                                                        .symbolRenderingMode(.palette)
                                                        .foregroundStyle(Color.white, Color("B1-red"))
                                                }
                                                .font(Font.custom("BebasNeue", size: 28))
                                                .padding(2)

                                                Spacer()
                                            }
                                            
                                            HStack {
                                                Spacer()
                                                Spacer()
                                                SchedulerTitle()
                                                    .ignoresSafeArea(.all)
                                            }
                                            
                                            Divider()
                                            
                                            ZStack {
                                                HighlightChoice()

                                                Picker("Training Day", selection: $scheduler.dayIndex) {
                                                    ForEach(scheduler.dayArray.indices, id: \.self) { (index: Int) in
                                                        Text(self.scheduler.dayArray[index])
                                                            .font(Font.custom("BebasNeue", size: 40))
                                                            .foregroundColor(Color("csf-main-str"))
                                                        Spacer()
                                                    }
                                                }
                                                .pickerStyle(WheelPickerStyle())
                                            }
                                            
                                            Button(action: {
                                                withAnimation(.easeInOut(duration: 0.35)) {
                                                    dayConfirmed.toggle()
                                                }
                                            }) {
                                                Text("OK →")
                                                        .modifier(SchedButtonMod())
                                            }
                                            .padding(.horizontal)
                                            .scaledToFill()
                                            
                                            Spacer()
                                        }
                                    }
                                    
                                    if dayConfirmed && weekConfirmed && !timeConfirmed {
                                        VStack {
                                            HStack {
                                                Button {
                                                    withAnimation(.easeInOut(duration: 0.35)) {
                                                        dayConfirmed.toggle()
                                                    }
                                                } label: {
                                                    Image(systemName: "chevron.backward.circle.fill")
                                                        .symbolRenderingMode(.palette)
                                                        .foregroundStyle(Color("csb-main-gray"), Color("B1-red"))
                                                        .font(Font.custom("BebasNeue", size: 28))
                                                }
                                                .padding(2)

                                                Spacer()
                                            }
                                            
                                            HStack {
                                                Spacer()
                                                Spacer()
                                                VStack(alignment: .trailing, spacing: -10) {
                                                    Text("RESERVING")
                                                        .font(Font.custom("BebasNeue", size: 40))
                                                    
                                                    Text("timeslot for")
                                                        .font(Font.custom("BebasNeue", size: 25))
                                                        .foregroundColor(Color("csf-main"))
                                                        .padding(0)
                                                }
                                            }
                                            
                                            Divider()
                                            
                                            HStack {
                                                if let timeTable = scheduler.timeFinal.components(separatedBy: ", ") {
                                                    ForEach(timeTable.indices) { (index: Int) in
                                                        if index == 0 {
                                                            Text("\(String(timeTable[index].prefix(3))),")
                                                        } else if index == 1 {
                                                            Text("\(timeTable[index])")
                                                        } else {
                                                            Text(timeTable[index])
                                                                .foregroundColor(Color("csf-accent-light"))
                                                        }
                                                    }
                                                    .font(Font.custom("Rajdhani-SemiBold", size: 32))
                                                    .foregroundColor(Color("csf-main"))
                                                    .ignoresSafeArea(.all)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            LazyVGrid(columns: items) {
                                                ForEach(scheduler.timeArray.indices, id: \.self) { (index: Int) in
                                                    Button(action: {
                                                        scheduler.timeIndex = index
                                                    }) {
                                                        TimesListView(activeTime: $scheduler.timeIndex, label: self.scheduler.timeArray[index], idx: index)
                                                            // .foregroundColor(.clear)
                                                    }
                                                    .cornerRadius(10)
                                                    .aspectRatio(1, contentMode: .fit)
                                                }
                                            }
                                            
                                            Button(action: {
                                                controller.setTraining(parameters: [
                                                    "email": firestore.profile.email,
                                                    "uid": userId(),
                                                    "timeslot": scheduler.trainingTime,
                                                    "mode": "new"
                                                ])
                                                controller.fetchProfile(uid: userId(), email: firestore.profile.email)
                                                withAnimation(.easeInOut(duration: 0.35)) {
                                                    timeConfirmed.toggle()
                                                }
                                            }) {
                                                ConfirmButtonContent()
                                            }
                                            .padding(.horizontal)
                                            .scaledToFit()
                                            
                                            Spacer()
                                        }
                                    }
                                    
                                    if dayConfirmed && weekConfirmed && timeConfirmed {
                                        VStack {
                                            HStack {
                                                Button {
                                                    withAnimation(.easeInOut(duration: 0.35)) {
                                                        scheduler.resetScheduler()
                                                        dayConfirmed.toggle()
                                                        weekConfirmed.toggle()
                                                        timeConfirmed.toggle()
                                                        controller.next(newPage: Dashboard.homePage)
                                                    }
                                                } label: {
                                                    Image(systemName: "house.circle.fill")
                                                        .symbolRenderingMode(.palette)
                                                        .foregroundStyle(Color("csf-main-str"), Color("B1-red"))
                                                }
                                                .font(Font.custom("BebasNeue", size: 30))
                                                .padding(2)

                                                Spacer()
                                            }
                                            
                                            HStack {
                                                Spacer()
                                                SchedulerTitle()
                                                    .ignoresSafeArea(.all)
                                                Spacer()
                                            }
                                            .padding(.vertical)
                                            
                                            Divider()
                                            
                                            Spacer()

                                            Text("You have successfully reserved timeslot: ")
                                                .font(Font.custom("Rajdhani-Medium", size: 24))
                                                .frame(width: UIScreen.main.bounds.width/2)
                                                .foregroundColor(Color("csf-gray"))
                                                .multilineTextAlignment(.center)
                                            Spacer()
                                            Text(scheduler.timeFinal.replacingOccurrences(of: ",", with: ""))
                                                .font(Font.custom("BebasNeue", size: 45))
                                                .foregroundColor(Color("csf-main"))
                                                .multilineTextAlignment(.center)
                                            
                                            Spacer()
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .padding()
                            .frame(width: 325, height: 550)
                            .background(.ultraThinMaterial)
                            .foregroundColor(Color.primary.opacity(0.35))
                            .foregroundStyle(.ultraThinMaterial)
                            .cornerRadius(25)
                            .padding()
                            .opacity(firestore.showProfile ? 0.2 : 1)
                            .offset(y: firestore.showProfile ? -UIScreen.height : 0)
                            .transition(AnyTransition.homerSimpson)
                        }
                        .animation(.default, value: firestore.showProfile)
                        .sheet(isPresented: $firestore.showProfile) {
                            withAnimation(Animation.linear.delay(1)) {
                                ProfileHost(draftProfile: firestore.profile)
                                    .frame(width: UIScreen.width,
                                           height: UIScreen.height*0.7)
                                    .cornerRadius(10)
                                    .offset(y: UIScreen.height/15)
                                    .ignoresSafeArea()
                                    .background(BackgroundClearView())
                            }
                        }
                    }
                    .frame(width: 305, height: 475)
                }
                .frame(width: UIScreen.width,
                       height: UIScreen.height)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if firestore.showProfile {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                LogoButton()
                                    .tint(Color("csf-main-str"))
                                    .foregroundColor(Color("csf-main-str"))
                                    .transition(.opacity)
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                MenuButton()
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            firestore.showSidebar.toggle()
                                        }
                                    }
                                    .transition(.opacity)
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            NavProfileButton()
                                .opacity(firestore.showProfile ? 0 : 1 )
                                .transition(.opacity)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavLogoName()
                            .tint(firestore.showProfile ? Color("csf-main-str") : Color.white)
                            .foregroundColor(firestore.showProfile ? Color("csf-main-str") : Color.white)
                    }
                }
                .background(SideBackground(isReversed: true,
                                           upsideDown: colorScheme == .dark ? true : false))
                .overlay(
                    ZStack {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            ShadeView()
                        }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            Color("csb-main-str")
                                .frame(width: UIScreen.width,
                                       height: UIScreen.height)
                                .opacity(firestore.showProfile ? 0.6 : 0)
                                .ignoresSafeArea()
                        }
                    }
                    .transition(.opacity)
                )
                .offset(y: -60)
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

struct SchedulerView_Previews: PreviewProvider {
    static var previews: some View {
        SchedulerView()
            //.preferredColorScheme(.dark)
    }
}

struct SchedButtonMod: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .font(Font.custom("BebasNeue", size: 35))
                .foregroundColor(colorScheme == .dark ? Color("A1-blue") : Color("csf-menu-gray"))
                .overlay(
                    content
                        .font(Font.custom("BebasNeue", size: 35))
                        .foregroundColor((colorScheme == .dark ? .white : Color("DA1-blue")))
                        .offset(x: 2, y: -2)
                        
                )
                .padding(.top, 5)
                .padding()
                .frame(width: 180, height: 60)
                .scaledToFit()
                .background(.ultraThinMaterial)
                .overlay(
                    LinearGradient(colors: [.clear,.black.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                .cornerRadius(10)
                .shadow(color: .white.opacity(0.65), radius: 1, x: -1, y: -2)
                .shadow(color: .black.opacity(0.65), radius: 2, x: 2, y: 2)
                .padding()
        } else {
            // Fallback on earlier versions
            content
                .padding()
                .frame(height: 60)
                .cornerRadius(10)
                .shadow(color: .white, radius: 3, x: -3, y: -3)
                .shadow(color: .black, radius: 3, x: 3, y: 3)
        }
    }
}

struct SchedulerTitle: View {
    var body: some View {
        VStack(spacing: -10) {
            Text("Schedule")
                .font(Font.custom("BebasNeue", size: 50))
                .foregroundColor(Color("csf-main"))
            Text("Personal Training")
                .font(Font.custom("BebasNeue", size: 25))
        }
    }
}

struct TimesListView: View {
    @Binding var activeTime: Int
    let label: String
    let idx: Int
    
    var body: some View {
        Text(label)
            .foregroundColor(activeTime == idx ? Color("csf-main") : Color("csb-main"))
            .font(Font.custom("BebasNeue", size: 25))
            .padding()
            .background(.ultraThinMaterial)
            .overlay(
                LinearGradient(colors: [.clear, .white.opacity(0.2)], startPoint: .top, endPoint: .bottom))
            .cornerRadius(10)
            .shadow(color: .white.opacity(0.65), radius: 1, x: -1, y: -2)
            .shadow(color: .black.opacity(0.65), radius: 2, x: 2, y: 2)
            .onTapGesture { self.activeTime = self.idx }
            .background(TimeBorder(show: activeTime == idx))
            /*.overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.clear)
                    .background(Color("csb-main-gray"))
            )*/
    }
}

struct TimeBorder: View {
    @Environment(\.colorScheme) var colorScheme
    
    let show: Bool
    
    var body: some View {
        withAnimation(.easeIn(duration: 0.6)) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 6.0)
                .foregroundColor(show ? Color("csf-spin") : .clear)
                .background(show ? ((colorScheme == .dark) ? Color("DA1-blue") : Color("csb-menu-gray")) : .clear)
        }
    }
}

struct ConfirmButtonContent: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Text("CONFIRM")
            .foregroundColor(.white)
            .padding()
            .frame(width: 200, height: 60)
            .foregroundColor(Color("csb-main"))
            .background(Color("DA1-blue"))
            .cornerRadius(9)
            .modifier(SchedButtonMod())
            .padding()
    }
}

struct SelectionGlassView: ViewModifier {
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .padding()
                .frame(width: 325, height: 60)
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.linearGradient(colors:[.black,.white.opacity(0.75)], startPoint: .top, endPoint: .bottom), lineWidth: 2)
                        .blur(radius: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.radialGradient(Gradient(colors: [.clear,.black.opacity(0.1)]), center: .bottomLeading, startRadius: 300, endRadius: 0), lineWidth: 15)
                        .offset(y: 5)
                )
                .cornerRadius(14)
        } else {
            // Fallback on earlier versions
            content
                .padding()
                .frame(width: 325, height: 60)
                .cornerRadius(10)
                .shadow(color: .white, radius: 3, x: -3, y: -3)
                .shadow(color: .black, radius: 3, x: 3, y: 3)
        }
    }
}

struct HighlightChoice: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: UIScreen.main.bounds.size.width/1.25, height: 65)
            .foregroundColor(colorScheme == .dark ? Color("A1-blue") : Color("csf-menu-gray"))
            .brightness(0.0)
    }
}
