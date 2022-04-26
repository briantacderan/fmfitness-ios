//
//  GlobalViews.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/18/22.
//

import SwiftUI

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
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var isReversed = false
    
    var body: some View {
        Image(colorScheme == .dark ? "green-black" : "green-white")
            .resizable()
            .brightness(colorScheme == .dark ? 0 : 0)
            .frame(width: UIScreen.main.bounds.width*1.001,
                   height: UIScreen.main.bounds.height*1.001,
                   alignment: .topTrailing)
            .offset(y: -30)
            .rotation3DEffect(.degrees(isReversed ? 180 : 0), axis: (x: 0, y: 1, z: 0))
    }
}

struct NavProfileButton: View {
    @ObservedObject var firestore = FirestoreManager.shared
    
    var body: some View {
        Button {
            firestore.showingProfile.toggle()
        } label: {
            Label("User Profile", systemImage: "person.crop.circle")
        }
        .foregroundColor(Color("csf-earth"))
        .font(.system(size: 22))
        .padding(.bottom, 12)
        .padding(.trailing, 5)
    }
}

struct MenuButton: View {
    @ObservedObject var firestore = FirestoreManager.shared
    
    var body: some View {
        Button {
            firestore.menuShow.toggle()
        } label: {
            Image("menu-white")
                .renderingMode(.template)
                .resizable()
                .frame(width: 26, height: 20)
                .padding(.bottom, 12)
                .padding(.leading, 5)
                .foregroundColor(Color("csf-main"))
        }
        .sheet(isPresented: $firestore.menuShow) {
            MenuView()
        }
    }
}

struct LogoButton: View {
    @ObservedObject var firestore = FirestoreManager.shared
    
    var body: some View {
        if firestore.profile._username != "new_profile" {
            Button {
                withAnimation {
                    firestore.next(newPage: .homePage)
                }
            } label: {
                Image("fmf-logo-white")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 125, height: 25)
                    .foregroundColor(Color("csf-main"))
                    .padding(.bottom, 10)
            }
        } else {
            Button {
                withAnimation {
                    firestore.next(newPage: .welcomePage)
                }
            } label: {
                Image("fmf-logo-white")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 125, height: 25)
                    .foregroundColor(Color("csf-main"))
                    .padding(.bottom, 10)
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
