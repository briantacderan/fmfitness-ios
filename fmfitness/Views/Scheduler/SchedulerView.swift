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
                                        .foregroundColor(Color("csf-earth"))
                                        .padding(.top, 5)
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
                                        Button("◀︎ BACK") {
                                            withAnimation(.easeInOut(duration: 0.35)) {
                                                weekConfirmed.toggle()
                                            }
                                        }
                                        .font(.headline)
                                        .foregroundColor(Color("csf-earth"))

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
                                        Button("◀︎ BACK") {
                                            withAnimation(.easeInOut(duration: 0.35)) {
                                                dayConfirmed.toggle()
                                            }
                                        }
                                        .font(.headline)
                                        .foregroundColor(Color("csf-earth"))

                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Spacer()
                                        
                                        VStack(spacing: -10) {
                                            Text("RESERVING TIME")
                                                .font(Font.custom("BebasNeue", size: 40))
                                            Text("on")
                                                .font(Font.custom("BebasNeue", size: 20))
                                                .padding(.bottom, 10)
                                            Text(scheduler.timeFinal)
                                                .font(Font.custom("BebasNeue", size: 35))
                                                .foregroundColor(Color("csf-main"))
                                        }
                                        .ignoresSafeArea(.all)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical)
                                    
                                    Divider()
                                    
                                    Spacer()
                                    
                                    LazyVGrid(columns: items) {
                                        ForEach(scheduler.timeArray.indices, id: \.self) { (index: Int) in
                                            Button(action: {
                                                scheduler.timeIndex = index
                                            }) {
                                                TimesListView(activeTime: $scheduler.timeIndex, label: self.scheduler.timeArray[index], idx: index)
                                                    .foregroundColor(Color("csf-earth"))
                                            }
                                            .cornerRadius(14)
                                        }
                                    }
                                    
                                    Spacer()
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.35)) {
                                            firestore.setTraining(timeslot: scheduler.trainingTime, email: firestore.profile.email)
                                            firestore.fetchProfile(email: firestore.profile.email)
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
                                        Button("HOME") {
                                            withAnimation(.easeInOut(duration: 0.35)) {
                                                scheduler.resetScheduler()
                                                dayConfirmed.toggle()
                                                weekConfirmed.toggle()
                                                timeConfirmed.toggle()
                                                firestore.next(newPage: .homePage)
                                            }
                                        }
                                        .font(.headline)
                                        .foregroundColor(Color("csf-earth"))

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
                                        .foregroundColor(.white)
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
                        .cornerRadius(35)
                        .padding()
                    }
                    .sheet(isPresented: $firestore.showingProfile) {
                        ProfileHost(draftProfile: firestore.profile)
                    }
                }
                .frame(width: 305, height: 475)
                .background(Color(UIColor.systemGray6))
            }
            .background(.white)
            .frame(width: UIScreen.main.bounds.width,
                   height: UIScreen.main.bounds.height)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    MenuButton()
                        .foregroundColor(Color("csf-gray"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    LogoButton()
                        .foregroundColor(Color("csf-accent"))
                }
            }
            .background(Color("csb-main"))
            .offset(y: -60)
            .transition(.moveFromBottom)
        }
    }
}

struct SchedulerView_Previews: PreviewProvider {
    static var previews: some View {
        SchedulerView()
            //.preferredColorScheme(.dark)
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
                .font(Font.custom("BebasNeue", size: 40))
        }
    }
}

struct NextButtonContent: View {
    var body: some View {
        Text("NEXT ▶︎")
            .font(Font.custom("BebasNeue", size: 35))
            .foregroundColor(Color("csf-main"))
            .padding()
            .frame(width: 180, height: 60)
            .background(Color("csb-main"))
            .cornerRadius(10)
            .modifier(SchedButtonMod())
            .padding(.bottom, 30)
    }
}

struct ShowButtonContent: View {
    var body: some View {
        Text("Show Times")
            .font(Font.custom("BebasNeue", size: 35))
            .foregroundColor(Color("csf-main"))
            .padding()
            .frame(width: 180, height: 60)
            .background(Color("csb-main"))
            .cornerRadius(10)
            .modifier(SchedButtonMod())
    }
}

struct TimesListView: View {
    @Binding var activeTime: Int
    let label: String
    let idx: Int
    
    var body: some View {
        Text(label)
            .font(Font.custom("BebasNeue", size: 25))
            .foregroundColor(Color("csf-earth"))
            .padding()
            .background(.ultraThinMaterial)
            .overlay(
                LinearGradient(colors: [.clear, .white.opacity(0.2)], startPoint: .top, endPoint: .bottom))
            .cornerRadius(14)
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
                .stroke(lineWidth: 6.0).foregroundColor(show ? Color("csf-accent") : Color.clear)
                .background(show ? .black : Color("csb-main"))
        }
    }
}

struct ConfirmButtonContent: View {
    var body: some View {
        Text("CONFIRM")
            .font(Font.custom("BebasNeue", size: 35))
            .foregroundColor(Color("csf-main"))
            .padding()
            .frame(width: 180, height: 60)
            .background(Color("csb-main"))
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
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.linearGradient(colors:[.black,.white.opacity(0.75)], startPoint: .top, endPoint: .bottom), lineWidth: 2)
                        .blur(radius: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.radialGradient(Gradient(colors: [.clear,.black.opacity(0.1)]), center: .bottomLeading, startRadius: 300, endRadius: 0), lineWidth: 15)
                        .offset(y: 5)
                )
                .cornerRadius(14)
        } else {
            // Fallback on earlier versions
            content
                .padding()
                .frame(width: 325, height: 60)
                .cornerRadius(14)
                .shadow(color: .white, radius: 3, x: -3, y: -3)
                .shadow(color: .black, radius: 3, x: 3, y: 3)
        }
    }
}

struct HighlightChoice: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: UIScreen.main.bounds.size.width/1.25, height: 65)
            .foregroundColor(Color("csf-earth"))
    }
}
