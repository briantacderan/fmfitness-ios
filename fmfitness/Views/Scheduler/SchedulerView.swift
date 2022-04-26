//
//  SchedulerView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 2/28/22.
//

import SwiftUI

struct SchedulerView: View {
    
    @ObservedObject var scheduler = SchedulerModel.shared
    @ObservedObject var firestore = FirestoreManager.shared
    
    @State private var weekConfirmed = false
    @State private var dayConfirmed = false
    @State private var timeSelected = false
    @State private var timeConfirmed = false
    
    @State var items: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        NavigationView {
            ZStack {
                ZStack {
                    VStack {
                        VStack {
                            if !weekConfirmed {
                                VStack {
                                    HStack {
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.35)) {
                                                firestore.showingProfile.toggle()
                                            }
                                        } label: {
                                            Label("Profile", systemImage: "person.crop.square")
                                        }
                                        .font(Font.custom("BebasNeue", size: 20))
                                        .foregroundColor(Color("csf-gray"))
                                        .padding(3)
                                        
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
                                                        .foregroundColor(.black)
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
                                        NextButtonContent()
                                    }
                                    .padding(.trailing)
                                    
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
                                            Label("", systemImage: "chevron.backward.circle.fill")
                                        }
                                        .font(Font.custom("BebasNeue", size: 30))
                                        .foregroundColor(Color("csf-gray"))
                                        .padding(.top, 0)
                                        .padding(.leading, 5)

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
                                                    .foregroundColor(.black)
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
                                        ShowButtonContent()
                                    }
                                    .padding(.trailing)
                                    
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
                                            Label("", systemImage: "chevron.backward.circle.fill")
                                        }
                                        .font(Font.custom("BebasNeue", size: 30))
                                        .foregroundColor(Color("csf-gray"))
                                        .padding(.top, 0)
                                        .padding(.leading, 5)

                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Spacer()
                                        Spacer()
                                        VStack(spacing: -10) {
                                            Text("RESERVING")
                                                .font(Font.custom("BebasNeue", size: 40))
                                            Text("timeslot for")
                                                .font(Font.custom("BebasNeue", size: 20))
                                                .padding(.bottom, 10)
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    HStack {
                                        if let timeTable = scheduler.timeFinal.components(separatedBy: ", ") {
                                            ForEach(timeTable.indices) { (index: Int) in
                                                if index < timeTable.count - 1 {
                                                    Text("\(timeTable[index]),")
                                                        .font(Font.custom("BebasNeue", size: 35))
                                                        .foregroundColor(Color("csf-main"))
                                                } else {
                                                    Text(timeTable[index])
                                                        .font(Font.custom("BebasNeue", size: 40))
                                                        .foregroundColor(Color("csf-earth"))
                                                }
                                            }
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
                                                    .foregroundColor(.clear)
                                            }
                                            .cornerRadius(10)
                                            .aspectRatio(0.8, contentMode: .fit)
                                        }
                                    }
                                    
                                    Spacer()
                                    Spacer()
                                    
                                    Button(action: {
                                        
                                        firestore.setTraining(parameters: ["timeslot": scheduler.trainingTime, "email": firestore.profile.email])
                                        firestore.fetchProfile(email: firestore.profile.email)
                                        withAnimation(.easeInOut(duration: 0.35)) {
                                            timeConfirmed.toggle()
                                        }
                                    }) {
                                        ConfirmButtonContent()
                                    }
                                    .padding(.trailing)
                                    
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
                                                firestore.next(newPage: .homePage)
                                            }
                                        } label: {
                                            Label("", systemImage: "house.circle.fill")
                                        }
                                        .font(Font.custom("BebasNeue", size: 30))
                                        .foregroundColor(Color("csf-gray"))
                                        .padding(.top, 0)
                                        .padding(.leading, 5)

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
                                        .font(Font.custom("BebasNeue", size: 25))
                                        .frame(width: UIScreen.main.bounds.width/2)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                    Text(scheduler.timeFinal)
                                        .font(Font.custom("BebasNeue", size: 45))
                                        .foregroundColor(Color("csf-main"))
                                        .multilineTextAlignment(.center)
                                    
                                    Spacer()
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .frame(width: 325, height: 500)
                        .background(.ultraThinMaterial)
                        .foregroundColor(Color.primary.opacity(0.35))
                        .foregroundStyle(.ultraThinMaterial)
                        .cornerRadius(25)
                        .padding()
                    }
                    .sheet(isPresented: $firestore.showingProfile) {
                        ProfileHost(draftProfile: firestore.profile)
                    }
                }
                .frame(width: 305, height: 475)
                .background(.clear)
            }
            .background(.clear)
            .frame(width: UIScreen.main.bounds.width,
                   height: UIScreen.main.bounds.height)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    MenuButton()
                        .foregroundColor(Color("csb-main-gray"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    LogoButton()
                        .foregroundColor(Color("csb-main-gray"))
                }
            }
            .background(SideBackground())
            //.background(Color("csb-main"))
            .offset(y: -60)
        }
    }
}

struct SchedulerView_Previews: PreviewProvider {
    static var previews: some View {
        SchedulerView()
            .preferredColorScheme(.dark)
    }
}

struct SchedButtonMod: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .padding()
                .frame(width: 180, height: 60)
                .background(.ultraThinMaterial)
                .overlay(
                    LinearGradient(colors: [.clear,.black.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                .cornerRadius(10)
                .shadow(color: .white.opacity(0.65), radius: 1, x: -1, y: -2)
                .shadow(color: .black.opacity(0.65), radius: 2, x: 2, y: 2)
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

struct NextButtonContent: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        Text("NEXT ▶︎")
            .font(Font.custom("BebasNeue", size: 35))
            .foregroundColor(colorScheme == .dark ? .white : Color("csb-choice"))
            .padding()
            .frame(width: 180, height: 60)
            .background(colorScheme == .dark ? Color("csb-choice") : .white)
            .cornerRadius(10)
            .modifier(SchedButtonMod())
            .padding(.bottom, 30)
    }
}

struct ShowButtonContent: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        Text("Show Availability")
            .font(Font.custom("BebasNeue", size: 25))
            .foregroundColor(colorScheme == .dark ? .white : Color("csb-choice"))
            .padding()
            .frame(width: 180, height: 60)
            .background(colorScheme == .dark ? Color("csb-choice") : .white)
            .cornerRadius(10)
            .modifier(SchedButtonMod())
    }
}

struct TimesListView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Binding var activeTime: Int
    let label: String
    let idx: Int
    
    var body: some View {
        Text(label)
            .font(Font.custom("BebasNeue", size: 25))
            .foregroundColor(colorScheme == .dark ? .white : Color("csb-choice"))
            .padding()
            .background(.ultraThinMaterial)
            .overlay(
                LinearGradient(colors: [.clear, .white.opacity(0.2)], startPoint: .top, endPoint: .bottom))
            .cornerRadius(9)
            .shadow(color: .white.opacity(0.65), radius: 1, x: -1, y: -2)
            .shadow(color: .black.opacity(0.65), radius: 2, x: 2, y: 2)
            .onTapGesture { self.activeTime = self.idx }
            .background(TimeBorder(show: activeTime == idx))
    }
}

struct TimeBorder: View {
    let show: Bool
    
    var body: some View {
        withAnimation(.easeIn(duration: 0.6)) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 6.0).foregroundColor(show ? Color("csb-choice") : .white)
                .background(show ? Color("csb-main") : Color("csb-choice"))
        }
    }
}

struct ConfirmButtonContent: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        Text("CONFIRM")
            .font(Font.custom("BebasNeue", size: 35))
            .foregroundColor(colorScheme == .dark ? Color("csb-main") : Color("csb-choice"))
            .padding()
            .frame(width: 180, height: 60)
            .background(colorScheme == .dark ? Color("csf-accent") : Color("csb-main"))
            .cornerRadius(10)
            .modifier(SchedButtonMod())
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
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: UIScreen.main.bounds.size.width/1.25, height: 65)
            .foregroundColor(Color("csf-accent"))
    }
}
