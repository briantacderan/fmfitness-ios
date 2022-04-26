//
//  StripeView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/11/22.
//

import SwiftUI

struct StripeView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @ObservedObject var firestore = FirestoreManager.shared
    var selectView = StripePage()
    var titleView = "Account"
    var navTrailing = NavProfileButton()
    
    var body: some View {
        NavigationView {
            ZStack {
                selectView
                .navigationBarTitle(titleView, displayMode: .inline)
                .foregroundColor(Color("csb-main"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        MenuButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        navTrailing
                    }
                }
                .frame(width: UIScreen.main.bounds.width,
                       height: UIScreen.main.bounds.height)
                .background(SideBackground(isReversed: true))
            }
        }
    }
}

struct StripeView_Previews: PreviewProvider {
    static var previews: some View {
        StripeView()
    }
}
