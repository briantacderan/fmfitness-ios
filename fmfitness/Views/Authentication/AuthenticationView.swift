//
//  AuthenticationView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/25/22.
//

import SwiftUI

struct AuthenticationView: View {

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.controller) var controller
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    static var hideMetric: CGFloat = 6
    static var lastHide: Bool = false
    
    let csf = Color("LaunchScreenColorTile")
    let csb = Color("LaunchScreenColor")
    
    var body: some View {
        ZStack {
            if firestore.profile._username != "new_profile" {
                ZStack {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        Text("FM Fitness")
                            .font(Font.custom("BebasNeue", size: 50))
                            .foregroundColor(csf)
                            .scaleEffect(1.4)
                            .blur(radius: AuthenticationView.hideMetric)
                    }
                }
                .frame(width: UIScreen.width, height: UIScreen.height)
                .background(AuthenticationView.lastHide ? .clear : csb)
                .edgesIgnoringSafeArea(.all)
                .opacity(AuthenticationView.lastHide ? 0 : 1)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        let canAuthBio = controller.canEvaluatePolicy()
                        if canAuthBio {
                            AlertController().bioIDLoginAction()
                        }
                    }
                }
            }
            
            SplashView()
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
        
    }
}
