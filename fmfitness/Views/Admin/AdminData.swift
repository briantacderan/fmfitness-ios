//
//  AdminData.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/18/22.
//

import Foundation

final class AdminData: NSObject, Codable, Identifiable {
    let id: Int
    let email: String
    var invoice: String
    var isConfirmed: Bool
    var isCompleted: Bool
    var isPaid: Bool
    var nextAppointment: Date
    
    init(
        id: Int,
        email: String,
        invoice: String,
        isConfirmed: Bool,
        isCompleted: Bool,
        isPaid: Bool,
        nextAppointment: Date
    ) {
        self.id = id
        self.email = email
        self.invoice = invoice
        self.isConfirmed = isConfirmed
        self.isCompleted = isCompleted
        self.isPaid = isPaid
        self.nextAppointment = nextAppointment
        super.init()
    }
    
    enum StripeLink: String, CaseIterable, Identifiable {
        case custom = "0"
        case hund = "https://checkout.stripe.com/pay/cs_live_a18agieXo53jtxINTkyulMRiO4j85TzXfGhOxtY7SyptfkWMMUFzZIxfMm#fidkdWxOYHwnPyd1blppbHNgWjA0TVQ9TDdERlI1TDJTZnx0PElzUDJMS1FXfGxBPFQ3REZEdURQb2tCPXNdbEg3M0N9PDFvaE5mTTRramNMR19PbF1nTUs8YEdvajYyXUNEXUQ3cUE8aX11NTVxdGRNMn1jdCcpJ3VpbGtuQH11anZgYUxhJz8nPERUPX1AZEBsPVM1NG1gZEBAJykndXdgaWpkYUNqa3EnPydGbWRud2QlVWBxZm0neCUl"
        case hundHalf = "2"
        case twoHund = "3"
        case threeHund = "4"

        var id: String { rawValue }
    }
}

extension AdminData: NSItemProviderWriting {
    static let typeIdentifier = "com.thetacderancode.fmfitness.adminData"

    static var writableTypeIdentifiersForItemProvider: [String] {
        [typeIdentifier]
    }

    func loadData(
        withTypeIdentifier typeIdentifier: String,
        forItemProviderCompletionHandler completionHandler:
            @escaping (Data?, Error?) -> Void
    ) -> Progress? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            completionHandler(try encoder.encode(self), nil)
        } catch {
            completionHandler(nil, error)
        }

        return nil
    }
}

extension AdminData: NSItemProviderReading {
    static var readableTypeIdentifiersForItemProvider: [String] {
        [typeIdentifier]
    }

    static func object(
        withItemProviderData data: Data,
        typeIdentifier: String
    ) throws -> AdminData {
        let decoder = JSONDecoder()
        return try decoder.decode(AdminData.self, from: data)
    }
}
