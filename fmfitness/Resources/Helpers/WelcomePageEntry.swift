//
//  WelcomePageEntry.swift
//  fmfitness
//
//  Created by Brian Tacderan on 3/18/22.
//

import SwiftUI

struct WelcomePageEntry: View {
    var textOne = "text one text one text one text one text one text one text one text one"
    var textTwo = "text two text two text two text two text two text two text two text two text two text two text two text two text two text two text two text two "
     
    var body: some View {
        VStack {
            Text(textOne)
                .font(Font.custom("BebasNeue", size: 40))
                .padding(40)
                .frame(width: UIScreen.main.bounds.width)
                .multilineTextAlignment(.leading)
                .ignoresSafeArea()
            Text(textTwo)
                .font(Font.custom("BebasNeue", size: 25))
                .padding(15)
                .frame(width: UIScreen.main.bounds.width)
                .multilineTextAlignment(.leading)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .background(Color("csb-main"))
    }
}

struct WelcomePageEntry_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePageEntry()
            .preferredColorScheme(.dark)
    }
}
