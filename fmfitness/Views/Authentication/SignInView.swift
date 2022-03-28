//
//  SignInView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 3/20/22.
//

import SwiftUI

struct SignInView: View {
    var body: some View {
        NavigationView {
            SignInPage()
                .offset(y: -50)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    MenuButton()
                        .foregroundColor(Color("csf-main"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    LogoButton()
                        .foregroundColor(Color("csf-main"))
                }
            }
        }
        //.transition(.move(edge: .trailing))
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
