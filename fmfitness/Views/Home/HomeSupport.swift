//
//  HomeSupport.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/15/22.
//

import SwiftUI

struct HomeSupport: View {
    
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
                .background(SideBackground())
            }
        }
    }
}

struct HomeSupport_Previews: PreviewProvider {
    static var previews: some View {
        HomeSupport()
    }
}
