//
//  HeaderView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

struct HeaderView: View {
    var title: String
    var fontSize: CGFloat = 20

    var body: some View {
        Text(title)
            .foregroundColor(Color("csf-main"))
            .font(Font.custom("Rajdhani-Bold", size: fontSize))
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("csb-main"))
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(title: "YO MAMA")
            //.preferredColorScheme(.dark)
    }
}
