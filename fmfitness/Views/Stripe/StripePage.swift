//
//  StripePage.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/11/22.
//

import SwiftUI

struct StripePage: View {
    
    @ObservedObject var firestore = FirestoreManager.shared
    @ObservedObject var cloud = CloudManager.shared
    
    var body: some View {
        ScrollView {
            GeometryReader { geometry in

                VStack(spacing: 0) {
                    Spacer()
                    
                    CategoryRow(geometry: geometry, categoryNameLeft: "Pay Balance", categoryNameRight: "Request Cancellation")
                    .padding()
                    
                    Spacer()
                }
            }
        }
        .offset(y: 75)
        .frame(width: UIScreen.main.bounds.width,
               height: UIScreen.main.bounds.height)
    }
}

struct StripePage_Previews: PreviewProvider {
    static var previews: some View {
        StripePage()
    }
}

struct CategoryCard: View {
    
    let geometry: GeometryProxy
    let categoryName: String
    
    @Environment(\.openURL) var openURL
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    @State private var urlString = "https://checkout.stripe.com/pay/cs_live_a18agieXo53jtxINTkyulMRiO4j85TzXfGhOxtY7SyptfkWMMUFzZIxfMm#fidkdWxOYHwnPyd1blppbHNgWjA0TVQ9TDdERlI1TDJTZnx0PElzUDJMS1FXfGxBPFQ3REZEdURQb2tCPXNdbEg3M0N9PDFvaE5mTTRramNMR19PbF1nTUs8YEdvajYyXUNEXUQ3cUE8aX11NTVxdGRNMn1jdCcpJ3VpbGtuQH11anZgYUxhJz8nPERUPX1AZEBsPVM1NG1gZEBAJykndXdgaWpkYUNqa3EnPydGbWRud2QlVWBxZm0neCUl"
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(categoryName == "Pay Balance" ? "$100" : "")
                .padding()
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.size.width * 0.45,
                       height: geometry.size.width * 0.55)
                .background(.ultraThinMaterial)
                .foregroundColor(Color.primary.opacity(0.35))
                .foregroundStyle(.ultraThinMaterial)
                .cornerRadius(10)
                .font(Font.custom("BebasNeue", size: 70))
                .onTapGesture {
                    if categoryName == "Pay Balance" {
                        openURL(URL(string: urlString)!)
                    } else if categoryName == "Request Cancellation" {
                        
                    }
                }
            Text(categoryName) // Use categoryName in place of our static string
                .font(Font.custom("BebasNeue", size: 25))
                .foregroundColor(Color("csf-main"))
                .multilineTextAlignment(.trailing)
                .padding(12)
        }
    }
}

struct CategoryRow: View {
    
    let geometry: GeometryProxy
    let categoryNameLeft: String
    let categoryNameRight: String
    
    var body: some View {
        HStack {
            NavigationLink(destination: Category(categoryName: categoryNameLeft)) {
                CategoryCard(geometry: geometry, categoryName: categoryNameLeft)
            }
            NavigationLink(destination: Category(categoryName: categoryNameRight)) {
                CategoryCard(geometry: geometry, categoryName: categoryNameRight)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Category: View {
    
    var categoryName: String
    
    var body: some View {
        VStack {
            Text("")
        }
        .navigationBarTitle(categoryName)
    }
}
