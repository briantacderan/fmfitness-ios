//
//  GlobalViews.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/18/22.
//

import SwiftUI
import GoogleSignIn

struct CircleImage: View {
    var image: ProfileImageView

    var body: some View {
        image
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            .overlay {
                Circle().stroke(.white, lineWidth: 4)
            }
            .shadow(radius: 7)
    }
}

struct SideBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var isReversed = false
    var upsideDown = false
    
    var body: some View {
        Image(colorScheme == .dark ? "green-black" : "green-white")
            .resizable()
            .brightness(colorScheme == .dark ? 0.1 : 0)
            .frame(width: UIScreen.main.bounds.width*1.001,
                   height: UIScreen.main.bounds.height*1.001,
                   alignment: .topTrailing)
            .offset(y: -30)
            .rotation3DEffect(.degrees(isReversed ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .rotation3DEffect(.degrees(upsideDown ? 180 : 0), axis: (x: 1, y: 0, z: 0))
            .overlay(
                ZStack {
                    Image("LaunchBlackTile")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color("csb-main-str"))
                        .opacity(0.05)
                    
                    Image("LaunchBlackTile")
                        .renderingMode(.template)
                        .foregroundColor(Color("csb-main-str"))
                        .opacity(0.05)
                }
            )
    }
}

struct NavProfileButton: View {
    @ObservedObject var firestore = FirestoreManager.shared
    
    private var user: GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                firestore.showProfile.toggle()
            }
        } label: {
            if let userProfile = user?.profile {
                ProfileImageView(profile: userProfile, frameSize: 30)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            } else {
                Label("User Profile", systemImage: "person.crop.circle")
            }
        }
        .foregroundColor(Color("csf-earth"))
        .font(.system(size: 22))
        //.padding(.bottom, 12)
        //.padding(.trailing, 5)
    }
}

struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct NavLogoName: View {
    @ObservedObject var firestore = FirestoreManager.shared

    var body: some View {
        ZStack(alignment: .trailing) {
            withAnimation(.easeInOut(duration: 0.2)) {
                HStack(spacing: 0) {
                    Text("FM")
                        .font(Font.custom("BebasNeue", size: 15))
                    Text("FITNESS")
                        .font(Font.custom("Rajdhani-Light", size: 15))
                }
                .offset(x: firestore.showProfile ? -80 : 0)
                .opacity(firestore.showProfile ? 0 : 1)
            }
        
            withAnimation(.easeInOut(duration: 0.2)) {
                HStack(spacing: 0) {
                    Text("ACCOUNT")
                        .font(Font.custom("BebasNeue", size: 30))
                    Text("DETAILS")
                        .font(Font.custom("Rajdhani-Light", size: 30))
                }
                .offset(x: firestore.showProfile ? 0 : -80)
                .opacity(firestore.showProfile ? 1 : 0)

            }
        }
        .padding(.bottom, 15)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .transition(AnyTransition.homerSimpson)
        
        /*
         ZStack(alignment: .trailing) {
             withAnimation(.easeInOut(duration: 0.2)) {
                 HStack(spacing: 0) {
                     Text(firestore.showProfile ? "ACCOUNT" : "FM")
                         .font(Font.custom("BebasNeue", size: 20))
                     Text(firestore.showProfile ? "SETTINGS" : "FITNESS")
                         .font(Font.custom("Rajdhani-Light", size: 20))
                 }
                 .transition(AnyTransition.homerSimpson)
             }
         }
         .padding(.bottom, 15)
         .lineLimit(1)
         .minimumScaleFactor(0.5)
        */
    }
}

struct MenuButton: View {
    @ObservedObject private var firestore = FirestoreManager.shared
    
    var body: some View {
        /*
        Image("menu-white")
                .renderingMode(.template)
                .resizable()
                .frame(width: 22, height: 18)
                .padding(.bottom, 12)
                .padding(.leading, 5)
                .foregroundColor((firestore.authRedirect == Page.welcomePage) ? .white : Color("csf-main-str"))
        */
        Label("", systemImage: "sidebar.squares.left")
            .foregroundColor((firestore.authRedirect == Page.welcomePage) ? .white : Color("csf-main-str"))
    }
}

struct ShadeView: View {
    @ObservedObject private var firestore = FirestoreManager.shared
    
    var body: some View {
        Color.black
            .frame(width: UIScreen.width*1.1,
                   height: UIScreen.height*1.1)
            .ignoresSafeArea()
            .opacity(firestore.induceShade ? 0.5 : 0)
            .blur(radius: firestore.induceShade ? 10 : 0)
    }
}

struct EditView: View {
    var body: some View {
        EditButton()
    }
}

struct LogoView: View {
    @ObservedObject var firestore = FirestoreManager.shared
    
    var logoWidth: CGFloat
    var logoHeight: CGFloat
    var vertPadding: CGFloat
    
    var body: some View {
        Image("fmf-logo-white")
            .renderingMode(.template)
            .resizable()
            .frame(width: logoWidth, height: logoHeight)
            .padding(.vertical, vertPadding)
    }
}

struct LogoButton: View {
    @Environment(\.controller) var controller
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    var body: some View {
        if firestore.profile._username != "new_profile" {
            Button {
                withAnimation {
                    if firestore.currentPage == .startPage {
                        controller.next(newPage: Dashboard.homePage)
                    } else {
                        firestore.selection = .home
                    }
                }
            } label: {
                Image("fmf-logo-white")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 75, height: 15)
                    .padding(.bottom, 10)
            }
        } else {
            Button {
                withAnimation {
                    firestore.authRedirect = Page.welcomePage
                }
            } label: {
                Image("fmf-logo-white")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 85, height: 17)
                    .padding(.bottom, 5)
            }
        }
    }
}

extension View {
    func pressAction(onPress: @escaping (() -> Void),
                     onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}

struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}

struct TargetFocusView: View {
    @ObservedObject var firestore = FirestoreManager.shared
    
    @State var scale: CGFloat = 1.0
    @State var location: CGPoint = CGPoint(x: 228, y: 482)
    @State var isActive: Bool = false

    var body: some View {
        HStack {
            ZStack {
                Image("\(firestore.profile.focusTarget)")
                    .resizable()
                    .scaleEffect(scale)
                    .frame(width: UIScreen.width*0.60, height: UIScreen.width*0.60)
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.top, scale != 1.0 ? 50 : 30)
                    //.position(location)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                self.location = value.location
                            }
                            .onEnded { value in
                                self.location = value.location
                            }
                    )
                    .pressAction {
                        withAnimation(.easeIn(duration: 0.15)) {
                            self.scale = 2
                            self.isActive = true
                        }
                    } onRelease: {
                        print(self.location)
                        withAnimation(.spring()) {
                            self.scale = 1.0
                            self.isActive = false
                        }
                    }
            }
        }
        /*
        .gesture(MagnificationGesture()
                    .onChanged { value in
                        self.scale = value.magnitude
                    }
                    .onEnded { value in
                        self.scale = 1.0
                    }
        )*/
    }
}

struct SideBarStack<SidebarContent: View, Content: View>: View {
    
    let sidebarContent: SidebarContent
    let mainContent: Content
    let sidebarWidth: CGFloat
    @Binding var showSidebar: Bool
    
    init(sidebarWidth: CGFloat, showSidebar: Binding<Bool>, @ViewBuilder sidebar: ()->SidebarContent, @ViewBuilder content: ()->Content) {
        self.sidebarWidth = sidebarWidth
        self._showSidebar = showSidebar
        sidebarContent = sidebar()
        mainContent = content()
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            sidebarContent
                .frame(width: sidebarWidth, alignment: .center)
                .offset(x: showSidebar ? 0 : -1 * sidebarWidth, y: 0)
             
            mainContent
                .overlay(
                    Group {
                        if showSidebar {
                            Color.white
                                .opacity(showSidebar ? 0.01 : 0)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        self.showSidebar = false
                                    }
                                }
                        } else {
                            Color.clear
                            .opacity(showSidebar ? 0 : 0)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    self.showSidebar = false
                                }
                            }
                        }
                    }
                )
                .offset(x: showSidebar ? sidebarWidth : 0, y: 0)
        }
    }
}
