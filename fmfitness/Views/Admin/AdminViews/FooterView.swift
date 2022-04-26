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
    ListRow {
      Text("\(title) \(count)")
        .frame(maxWidth: .infinity, alignment: .trailing)
        .font(Font.custom("BebasNeue", size: 30))
    }
  }
}
