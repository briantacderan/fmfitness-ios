//
//  SignUpView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 3/20/22.
//

import SwiftUI

struct SignUpView: View {
    var body: some View {
        NavigationView {
            SignUpPage()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    MenuButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    LogoButton()
                }
            }
        }
        //.transition(.opacity)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
