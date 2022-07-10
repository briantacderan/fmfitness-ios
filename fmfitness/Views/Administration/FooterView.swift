//
//  FooterView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

struct FooterView: View {
    var title: String
    var count: Int

    var body: some View {
        HStack {
            Spacer()
            
            Text(title.uppercased())
                .font(Font.custom("Rajdhani-Light", size: 20))
        
            Text("\(count)")
                .font(Font.custom("BebasNeue", size: 30))
                .foregroundColor(count > 0 ? Color("A1-blue") : Color("B1-red"))
        }
    }
}
