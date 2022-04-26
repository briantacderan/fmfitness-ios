//
//  HeaderView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/17/22.
//

import SwiftUI

struct HeaderView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var title: String

    var body: some View {
        ListRow(backgroundColor: colorScheme == .dark ? Color("csf-gray") : .white) {
            Text(title)
                .font(Font.custom("BebasNeue", size:35))
                .foregroundColor(Color("csb-choice"))
        }
        .overlay(Divider(), alignment: .top)
    }
}
