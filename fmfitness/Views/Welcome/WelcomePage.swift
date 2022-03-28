//
//  WelcomePage.swift
//  fmfitness
//
//  Created by Brian Tacderan on 3/14/22.
//

import SwiftUI

struct WelcomePage: View {
    var title = "fernando maguina fitness"
    var textOne = "\"I can help you in building a strong and lean body or guide you in recovering from an injury.\""
    var textTwo = "Whether that means gaining the confidence to wear a two-piece at the beach after having their first child, fitting into the suit they always imagined they'd wear for their daughters' wedding, or the everyday confidence that permeates everything they do, installed through the effort they've put in at the studio."

    var body: some View {
        ScrollView {
            ZStack {
                Image("home-main")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width*2.1, height: UIScreen.main.bounds.height*3.25/5, alignment: .topLeading
                    )
                
                VStack {
                    Text(title)
                        .frame(maxWidth: UIScreen.main.bounds.width,
                               minHeight: UIScreen.main.bounds.height*3.25/5)
                        .frame(width: UIScreen.main.bounds.width*1/2,
                               height: 225,
                               alignment: .top)
                        .offset(x: UIScreen.main.bounds.width*1/5)
                        .padding(.bottom, 75)
                        .foregroundColor(.white)
                        .font(Font
                                .custom("BebasNeue", size: 60)
                                .leading(.tight))
                    
                    Color("csb-main")
                        .frame(maxWidth: .infinity)
                        .frame(width: UIScreen.main.bounds.width*2.1, height: 80)
                        .ignoresSafeArea()
                        .background(.ultraThinMaterial)
                        .blur(radius: 15.0)
                        .offset(y: 100)
                }
            }
            
            /// Comment out when ready for WelcomeView
            WelcomePageEntry(textOne: textOne, textTwo: textTwo)
                .scaledToFill()
                .offset(y: -30)
             
        }
        .background(Color("csb-main"))
        .frame(maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
    }
}

struct WelcomePage_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePage()
            .preferredColorScheme(.dark)
    }
}
